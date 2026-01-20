# -*- coding: utf-8 -*-
"""
健康监测系统 - 统一后端服务
合并了健康监测系统(index.js)和硬件连接服务(Hardware_connection.js)的所有功能
运行端口: 5000
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import pymysql
from pymysql.cursors import DictCursor
import bcrypt
import jwt
from functools import wraps
from datetime import datetime, timedelta
import pytz
import secrets
import random
import time
import config

# 初始化Flask应用
app = Flask(__name__)
CORS(app, origins=config.CORS_ORIGINS)

# 设置时区
TZ = pytz.timezone(config.TIMEZONE)

# ============================================
# 数据库连接池
# ============================================
def get_db_connection():
    """获取数据库连接"""
    return pymysql.connect(
        host=config.DB_CONFIG['host'],
        user=config.DB_CONFIG['user'],
        password=config.DB_CONFIG['password'],
        database=config.DB_CONFIG['database'],
        charset=config.DB_CONFIG['charset'],
        cursorclass=DictCursor
    )

# ============================================
# 内存存储（验证码和设备状态）
# ============================================
verification_codes = {}  # 存储验证码 {phone: {code, expires}}
device_statuses = {}     # 存储设备状态 {device_id: {wifi_status, mqtt_status, lastUpdateTime}}

# ============================================
# 工具函数
# ============================================

def generate_code():
    """生成6位随机验证码"""
    return str(random.randint(100000, 999999))

def generate_refresh_token():
    """生成refresh token"""
    return secrets.token_hex(40)

def calculate_streak(dates, today):
    """
    计算连续签到天数
    :param dates: 签到日期列表
    :param today: 今天的日期字符串 (YYYY-MM-DD)
    :return: 连续签到天数
    """
    if not dates or len(dates) == 0:
        return 0
    
    # 去重并排序（从最近到最早）
    unique_dates = sorted(list(set([d.strftime('%Y-%m-%d') if hasattr(d, 'strftime') else str(d) for d in dates])), reverse=True)
    streak = 0
    expected_date = today
    
    print(f'calculateStreak - dates: {unique_dates}, today: {expected_date}')
    
    for date in unique_dates:
        if date == expected_date:
            streak += 1
            # 计算前一天
            expected_date = (datetime.strptime(expected_date, '%Y-%m-%d') - timedelta(days=1)).strftime('%Y-%m-%d')
        elif date < expected_date:
            break
    
    print(f'Calculated streak: {streak}')
    return streak

# ============================================
# JWT中间件
# ============================================

def authenticate_token(f):
    """JWT认证装饰器"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return jsonify({'error': '无访问权限，未提供令牌'}), 401
        
        try:
            token = auth_header.split(' ')[1]
            payload = jwt.decode(token, config.JWT_SECRET, algorithms=[config.JWT_ALGORITHM])
            request.user = {'userId': payload['userId']}
        except jwt.ExpiredSignatureError:
            return jsonify({'error': '令牌已过期'}), 403
        except jwt.InvalidTokenError:
            return jsonify({'error': '无效或过期令牌'}), 403
        except IndexError:
            return jsonify({'error': '令牌格式错误'}), 401
        
        return f(*args, **kwargs)
    
    return decorated_function

# ============================================
# 1. 服务器状态检查
# ============================================

@app.route('/status', methods=['GET'])
def server_status():
    """服务器状态检查接口"""
    return jsonify({
        'status': 'Server is running',
        'timestamp': datetime.now(TZ).isoformat()
    }), 200

# ============================================
# 2. 硬件连接监控接口（来自Hardware_connection.js）
# ============================================

@app.route('/wifi-status', methods=['POST'])
def update_wifi_status():
    """接收设备WiFi和MQTT状态更新"""
    data = request.get_json()
    wifi_status = data.get('wifi_status')
    mqtt_status = data.get('mqtt_status')
    device_id = data.get('device_id', config.DEFAULT_DEVICE_ID)
    
    # 验证请求参数
    if not wifi_status or wifi_status not in ['connected', 'disconnected']:
        print(f'无效的 POST 请求: {data}')
        return jsonify({'error': '无效的 wifi_status'}), 400
    
    if not mqtt_status or mqtt_status not in ['connected', 'disconnected']:
        print(f'无效的 POST 请求: {data}')
        return jsonify({'error': '无效的 mqtt_status'}), 400
    
    # 更新设备状态
    device_statuses[device_id] = {
        'wifi_status': wifi_status,
        'mqtt_status': mqtt_status,
        'lastUpdateTime': int(time.time() * 1000)  # 毫秒时间戳
    }
    
    print(f'POST /wifi-status: device_id={device_id}, wifi_status={wifi_status}, mqtt_status={mqtt_status}')
    return jsonify({'message': '状态接收成功'}), 200

@app.route('/wifi-status', methods=['GET'])
def get_wifi_status():
    """查询设备WiFi连接状态"""
    device_id = request.args.get('device_id', config.DEFAULT_DEVICE_ID)
    device = device_statuses.get(device_id)
    
    # 如果设备无状态记录
    if not device:
        print(f'GET /wifi-status: device_id={device_id}, status=disconnected (无数据)')
        return jsonify({
            'wifi_status': 'disconnected',
            'device_id': device_id,
            'lastSyncTime': None
        }), 200
    
    # 检查是否超时（15秒未更新）
    current_time = int(time.time() * 1000)
    is_offline = current_time - device['lastUpdateTime'] > config.DEVICE_OFFLINE_TIMEOUT
    
    status = 'disconnected'
    last_sync_time = None
    
    if not is_offline and device['wifi_status'] == 'connected' and device['mqtt_status'] == 'connected':
        status = 'connected'
        last_sync_time = device['lastUpdateTime']
    
    print(f"GET /wifi-status: device_id={device_id}, status={status}, wifi_status={device['wifi_status']}, "
          f"mqtt_status={device['mqtt_status']}, offline={is_offline}, lastSyncTime={last_sync_time}")
    
    return jsonify({
        'wifi_status': status,
        'device_id': device_id,
        'lastSyncTime': last_sync_time
    }), 200

# ============================================
# 3. 验证码相关接口
# ============================================

@app.route('/api/sendCode', methods=['GET'])
def send_verification_code():
    """发送验证码接口"""
    phone = request.args.get('phone')
    code_type = request.args.get('type', 'register')  # register 或 reset
    
    try:
        # 验证手机号
        if not phone or len(phone) != 11:
            raise ValueError('手机号必须为11位')
        
        # 检查手机号是否已注册
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT phone FROM users WHERE phone = %s', (phone,))
        is_registered = cursor.fetchone() is not None
        cursor.close()
        conn.close()
        
        # 根据type判断逻辑
        if code_type == 'reset':
            # 找回密码：手机号未注册则不允许
            if not is_registered:
                raise ValueError('该账号未注册，请前往注册')
        else:
            # 注册：手机号已注册则不允许
            if is_registered:
                raise ValueError('该手机号已注册')
        
        # 生成验证码
        code = generate_code()
        verification_codes[phone] = {
            'code': code,
            'expires': time.time() + config.VERIFICATION_CODE_EXPIRY
        }
        
        # 模拟发送短信
        message = f'您的验证码是{code}，请在5分钟内使用。'
        print(f'SMS sent to {phone}: {message}')
        
        return jsonify({
            'code': 200,
            'verificationCode': code,
            'message': '验证码发送成功'
        }), 200
        
    except ValueError as e:
        print(f'Error in /api/sendCode: {str(e)}')
        return jsonify({'code': 400, 'message': str(e)}), 400
    except Exception as e:
        print(f'Error in /api/sendCode: {str(e)}')
        return jsonify({'code': 500, 'message': '服务器错误'}), 500

@app.route('/verifyCode', methods=['POST'])
def verify_code():
    """验证验证码接口"""
    data = request.get_json()
    phone = data.get('phone')
    code = data.get('code')
    
    try:
        if not phone or not code:
            return jsonify({'code': 400, 'message': '手机号或验证码不能为空'}), 400
        
        if len(phone) != 11:
            return jsonify({'code': 400, 'message': '手机号必须为11位'}), 400
        
        stored = verification_codes.get(phone)
        if not stored:
            return jsonify({'code': 400, 'message': '验证码不存在'}), 400
        
        if time.time() > stored['expires']:
            del verification_codes[phone]
            return jsonify({'code': 400, 'message': '验证码已过期'}), 400
        
        if stored['code'] != code:
            return jsonify({'code': 400, 'message': '验证码错误'}), 400
        
        return jsonify({'code': 200, 'message': '验证码验证成功'}), 200
        
    except Exception as e:
        print(f'Error in /verifyCode: {str(e)}')
        return jsonify({'code': 500, 'message': '服务器错误'}), 500

@app.route('/api/checkPhoneRegistered', methods=['GET'])
def check_phone_registered():
    """检查手机号是否已注册"""
    phone = request.args.get('phone')
    
    try:
        if not phone or len(phone) != 11:
            return jsonify({'code': 400, 'message': '手机号必须为11位'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT phone FROM users WHERE phone = %s', (phone,))
        is_registered = cursor.fetchone() is not None
        cursor.close()
        conn.close()
        
        return jsonify({'code': 200, 'isRegistered': is_registered}), 200
        
    except Exception as e:
        print(f'Error in /api/checkPhoneRegistered: {str(e)}')
        return jsonify({'code': 500, 'message': '服务器错误'}), 500

# ============================================
# 4. 用户认证接口
# ============================================

@app.route('/register', methods=['POST'])
def register():
    """用户注册接口"""
    data = request.get_json()
    phone = data.get('phone')
    password = data.get('password')
    verification_code = data.get('verificationCode')
    
    try:
        # 验证输入
        if not phone or not password or not verification_code:
            return jsonify({'code': 400, 'message': '手机号、密码或验证码不能为空'}), 400
        
        if len(phone) != 11:
            return jsonify({'code': 400, 'message': '手机号必须为11位'}), 400
        
        # 验证验证码
        stored = verification_codes.get(phone)
        if not stored:
            return jsonify({'code': 400, 'message': '验证码不存在'}), 400
        
        if time.time() > stored['expires']:
            del verification_codes[phone]
            return jsonify({'code': 400, 'message': '验证码已过期'}), 400
        
        if stored['code'] != verification_code:
            return jsonify({'code': 400, 'message': '验证码错误'}), 400
        
        # 检查手机号是否已注册
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT phone FROM users WHERE phone = %s', (phone,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({'code': 400, 'message': '手机号已注册'}), 400
        
        # 加密密码并插入数据库
        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        refresh_token = generate_refresh_token()
        
        cursor.execute(
            'INSERT INTO users (phone, password, refresh_token) VALUES (%s, %s, %s)',
            (phone, hashed.decode('utf-8'), refresh_token)
        )
        conn.commit()
        user_id = cursor.lastrowid
        cursor.close()
        conn.close()
        
        # 生成JWT
        token = jwt.encode(
            {'userId': user_id, 'exp': datetime.utcnow() + timedelta(days=config.JWT_EXPIRATION_DAYS)},
            config.JWT_SECRET,
            algorithm=config.JWT_ALGORITHM
        )
        
        # 清除验证码
        del verification_codes[phone]
        
        return jsonify({
            'code': 200,
            'message': '注册成功',
            'userId': user_id,
            'JWTtoken': token,
            'refreshToken': refresh_token
        }), 200
        
    except Exception as e:
        print(f'Error in /register: {str(e)}')
        return jsonify({'code': 500, 'message': '服务器错误', 'error': str(e)}), 500

@app.route('/login', methods=['POST'])
def login():
    """用户登录接口"""
    data = request.get_json()
    phone = data.get('phone')
    password = data.get('password')
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM users WHERE phone = %s', (phone,))
        user = cursor.fetchone()
        
        if not user:
            cursor.close()
            conn.close()
            return jsonify({'code': 400, 'message': '手机号未注册'}), 400
        
        # 验证密码
        if not bcrypt.checkpw(password.encode('utf-8'), user['password'].encode('utf-8')):
            cursor.close()
            conn.close()
            return jsonify({'code': 400, 'message': '密码错误'}), 400
        
        # 生成新的token
        token = jwt.encode(
            {'userId': user['id'], 'exp': datetime.utcnow() + timedelta(days=config.JWT_EXPIRATION_DAYS)},
            config.JWT_SECRET,
            algorithm=config.JWT_ALGORITHM
        )
        refresh_token = generate_refresh_token()
        
        # 更新refresh token
        cursor.execute('UPDATE users SET refresh_token = %s WHERE id = %s', (refresh_token, user['id']))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'code': 200,
            'message': '登录成功',
            'userId': user['id'],
            'JWTtoken': token,
            'refreshToken': refresh_token
        }), 200
        
    except Exception as e:
        print(f'Error in /login: {str(e)}')
        return jsonify({'code': 500, 'message': '服务器错误', 'error': str(e)}), 500

@app.route('/resetPassword', methods=['POST'])
def reset_password():
    """重置密码接口"""
    data = request.get_json()
    phone = data.get('phone')
    verification_code = data.get('verificationCode')
    new_password = data.get('newPassword')
    
    try:
        if not phone or not verification_code or not new_password:
            return jsonify({'code': 400, 'message': '手机号、验证码或新密码不能为空'}), 400
        
        if len(phone) != 11:
            return jsonify({'code': 400, 'message': '手机号必须为11位'}), 400
        
        # 检查用户是否存在
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT password FROM users WHERE phone = %s', (phone,))
        user = cursor.fetchone()
        
        if not user:
            cursor.close()
            conn.close()
            return jsonify({'code': 400, 'message': '该账号未注册，请前往注册'}), 400
        
        # 验证验证码
        stored = verification_codes.get(phone)
        if not stored:
            cursor.close()
            conn.close()
            return jsonify({'code': 400, 'message': '验证码不存在'}), 400
        
        if time.time() > stored['expires']:
            del verification_codes[phone]
            cursor.close()
            conn.close()
            return jsonify({'code': 400, 'message': '验证码已过期'}), 400
        
        if stored['code'] != verification_code:
            cursor.close()
            conn.close()
            return jsonify({'code': 400, 'message': '验证码错误'}), 400
        
        # 检查新密码是否与旧密码相同
        if bcrypt.checkpw(new_password.encode('utf-8'), user['password'].encode('utf-8')):
            cursor.close()
            conn.close()
            return jsonify({'code': 400, 'message': '新密码不能与旧密码一致'}), 400
        
        # 更新密码
        hashed = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt())
        cursor.execute('UPDATE users SET password = %s WHERE phone = %s', (hashed.decode('utf-8'), phone))
        conn.commit()
        cursor.close()
        conn.close()
        
        # 清除验证码
        del verification_codes[phone]
        
        return jsonify({'code': 200, 'message': '密码重置成功'}), 200
        
    except Exception as e:
        print(f'Error in /resetPassword: {str(e)}')
        return jsonify({'code': 500, 'message': '服务器错误', 'error': str(e)}), 500

@app.route('/api/verifyToken', methods=['POST'])
def verify_token():
    """验证JWT token"""
    auth_header = request.headers.get('Authorization')
    
    if not auth_header:
        return jsonify({'code': 401, 'userId': None, 'message': '无访问权限，未提供令牌'}), 401
    
    try:
        token = auth_header.split(' ')[1]
        payload = jwt.decode(token, config.JWT_SECRET, algorithms=[config.JWT_ALGORITHM])
        return jsonify({
            'code': 200,
            'userId': payload['userId'],
            'message': 'Token is valid'
        }), 200
    except jwt.ExpiredSignatureError:
        return jsonify({'code': 401, 'userId': None, 'message': 'Token expired'}), 401
    except jwt.InvalidTokenError:
        return jsonify({'code': 401, 'userId': None, 'message': '无效或过期令牌'}), 401
    except IndexError:
        return jsonify({'code': 401, 'userId': None, 'message': '令牌格式错误'}), 401

@app.route('/api/refreshToken', methods=['POST'])
def refresh_token():
    """刷新JWT token"""
    data = request.get_json()
    refresh_token_value = data.get('refreshToken')
    
    if not refresh_token_value:
        return jsonify({'code': 401, 'message': '未提供刷新令牌'}), 401
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM users WHERE refresh_token = %s', (refresh_token_value,))
        user = cursor.fetchone()
        
        if not user:
            cursor.close()
            conn.close()
            return jsonify({'code': 401, 'message': '无效的刷新令牌'}), 401
        
        # 生成新token
        new_jwt = jwt.encode(
            {'userId': user['id'], 'exp': datetime.utcnow() + timedelta(days=config.JWT_EXPIRATION_DAYS)},
            config.JWT_SECRET,
            algorithm=config.JWT_ALGORITHM
        )
        new_refresh = generate_refresh_token()
        
        # 更新refresh token
        cursor.execute('UPDATE users SET refresh_token = %s WHERE id = %s', (new_refresh, user['id']))
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'code': 200,
            'JWTtoken': new_jwt,
            'refreshToken': new_refresh,
            'userId': user['id'],
            'message': 'Token refreshed'
        }), 200
        
    except Exception as e:
        print(f'Error in /api/refreshToken: {str(e)}')
        return jsonify({'code': 500, 'message': '服务器错误', 'error': str(e)}), 500

# ============================================
# 5. 健康数据管理接口
# ============================================

@app.route('/saveHealthData', methods=['POST'])
@authenticate_token
def save_health_data():
    """保存健康数据"""
    data = request.get_json()
    user_id = request.user['userId']
    
    heart_rate = data.get('heartRate')
    temperature = data.get('temperature')
    blood_oxygen = data.get('bloodOxygen')
    respiratory_rate = data.get('respiratoryRate')
    health_index = data.get('healthIndex')
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            '''INSERT INTO health_data (user_id, heart_rate, temperature, blood_oxygen, respiratory_rate, health_index) 
               VALUES (%s, %s, %s, %s, %s, %s)''',
            (user_id, heart_rate, temperature, blood_oxygen, respiratory_rate, health_index)
        )
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f'Error in /saveHealthData: {str(e)}')
        return jsonify({'error': '保存健康数据失败', 'details': str(e)}), 500

@app.route('/getHealthHistory', methods=['POST'])
@authenticate_token
def get_health_history():
    """获取健康数据历史"""
    user_id = request.user['userId']
    data = request.get_json()
    start_date = data.get('startDate')
    end_date = data.get('endDate')
    limit = data.get('limit', 1000)
    
    print(f'Received request to /getHealthHistory: userId={user_id}, startDate={start_date}, endDate={end_date}, limit={limit}')
    
    try:
        query = 'SELECT * FROM health_data WHERE user_id = %s'
        params = [user_id]
        
        # 处理日期范围
        if start_date and end_date:
            start_dt = datetime.strptime(start_date, '%Y-%m-%d').replace(tzinfo=TZ)
            end_dt = datetime.strptime(end_date, '%Y-%m-%d').replace(hour=23, minute=59, second=59, tzinfo=TZ)
            
            query += ' AND recorded_at BETWEEN %s AND %s'
            params.extend([start_dt, end_dt])
        
        # 添加排序和限制
        max_limit = 1000
        effective_limit = min(int(limit), max_limit)
        query += ' ORDER BY recorded_at DESC LIMIT %s'
        params.append(effective_limit)
        
        print(f'Executing query: {query} with params: {params}')
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(query, params)
        rows = cursor.fetchall()
        cursor.close()
        conn.close()
        
        print(f'Query returned: {len(rows)} rows')
        
        # 转换datetime为字符串
        for row in rows:
            if 'recorded_at' in row and row['recorded_at']:
                row['recorded_at'] = row['recorded_at'].strftime('%Y-%m-%d %H:%M:%S')
        
        return jsonify({'data': rows}), 200
        
    except Exception as e:
        print(f'Error in /getHealthHistory: {str(e)}')
        return jsonify({'error': '获取历史数据失败', 'details': str(e)}), 500

@app.route('/getHealthHistoryCount', methods=['POST'])
@authenticate_token
def get_health_history_count():
    """获取健康数据总数"""
    user_id = request.user['userId']
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT COUNT(*) as total FROM health_data WHERE user_id = %s', (user_id,))
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        
        print(f'Total records for user {user_id}: {result["total"]}')
        return jsonify({'total': result['total']}), 200
        
    except Exception as e:
        print(f'Error in /getHealthHistoryCount: {str(e)}')
        return jsonify({'error': '获取记录总数失败', 'details': str(e)}), 500

@app.route('/deleteHealthData', methods=['POST'])
@authenticate_token
def delete_health_data():
    """删除健康数据"""
    data = request.get_json()
    ids = data.get('ids')
    user_id = request.user['userId']
    
    if not ids or not isinstance(ids, list) or len(ids) == 0:
        return jsonify({'error': '无效的请求，缺少 ID 列表'}), 400
    
    if not all(isinstance(id, int) for id in ids):
        return jsonify({'error': 'ID 列表必须是数字数组'}), 400
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 使用 IN 子句删除
        placeholders = ','.join(['%s'] * len(ids))
        query = f'DELETE FROM health_data WHERE user_id = %s AND id IN ({placeholders})'
        cursor.execute(query, [user_id] + ids)
        conn.commit()
        affected = cursor.rowcount
        cursor.close()
        conn.close()
        
        return jsonify({'success': True, 'deletedCount': affected}), 200
        
    except Exception as e:
        print(f'Error in /deleteHealthData: {str(e)}')
        return jsonify({'error': '删除健康数据失败', 'details': str(e)}), 500

# ============================================
# 6. 签到与积分接口
# ============================================

@app.route('/check-in', methods=['POST'])
@authenticate_token
def check_in():
    """用户签到接口"""
    user_id = request.user['userId']
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 开始事务
        conn.begin()
        
        today = datetime.now(TZ).strftime('%Y-%m-%d')
        
        # 检查今天是否已签到
        cursor.execute(
            'SELECT * FROM CheckIns WHERE user_id = %s AND check_in_date = %s',
            (user_id, today)
        )
        existing = cursor.fetchone()
        
        if existing:
            conn.rollback()
            cursor.close()
            conn.close()
            return jsonify({'success': False, 'error': '今日已签到'}), 400
        
        # 根据星期几计算积分
        points_map = {
            0: 60,   # 周一
            1: 90,   # 周二
            2: 120,  # 周三
            3: 150,  # 周四
            4: 180,  # 周五
            5: 220,  # 周六
            6: 280   # 周日
        }
        weekday = datetime.now(TZ).weekday()
        points = points_map[weekday]
        created_at = datetime.now(TZ).strftime('%Y-%m-%d %H:%M:%S')
        
        # 插入签到记录
        cursor.execute(
            'INSERT INTO CheckIns (user_id, check_in_date, points_earned, created_at) VALUES (%s, %s, %s, %s)',
            (user_id, today, points, created_at)
        )
        
        # 插入积分记录
        cursor.execute(
            'INSERT INTO Points (user_id, points, reason, created_at) VALUES (%s, %s, %s, %s)',
            (user_id, points, '每日签到', created_at)
        )
        
        # 计算连续签到天数
        seven_days_ago = (datetime.now(TZ) - timedelta(days=7)).strftime('%Y-%m-%d')
        cursor.execute(
            'SELECT check_in_date FROM CheckIns WHERE user_id = %s AND check_in_date >= %s ORDER BY check_in_date DESC',
            (user_id, seven_days_ago)
        )
        streak_rows = cursor.fetchall()
        dates = [row['check_in_date'] for row in streak_rows]
        print(f'Check-in streakRows: {dates}')
        
        streak = calculate_streak(dates, today)
        
        # 提交事务
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'pointsEarned': points,
            'message': f'签到成功，获得{points}积分',
            'checkInStreak': streak
        }), 200
        
    except Exception as e:
        print(f'Error in /check-in: {str(e)}')
        if conn:
            conn.rollback()
            cursor.close()
            conn.close()
        return jsonify({'success': False, 'error': '签到失败，服务器错误', 'details': str(e)}), 500

@app.route('/points', methods=['GET'])
@authenticate_token
def get_points():
    """查询用户积分"""
    user_id = request.user['userId']
    month = request.args.get('month')
    
    print(f'Received request to /points: userId={user_id}, month={month}')
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 查询总积分
        cursor.execute('SELECT SUM(points) as total FROM Points WHERE user_id = %s', (user_id,))
        points_result = cursor.fetchone()
        # 确保转换为数字类型 (Decimal -> int/float)
        total_points = float(points_result['total']) if points_result and points_result['total'] else 0
        
        # 查询签到历史
        query = 'SELECT check_in_date, points_earned FROM CheckIns WHERE user_id = %s'
        params = [user_id]
        
        if month:
            # 解析月份参数 (YYYY-MM)
            try:
                month_dt = datetime.strptime(month, '%Y-%m')
                start_of_month = month_dt.replace(day=1).strftime('%Y-%m-%d')
                # 计算月底
                if month_dt.month == 12:
                    end_of_month = month_dt.replace(year=month_dt.year + 1, month=1, day=1) - timedelta(days=1)
                else:
                    end_of_month = month_dt.replace(month=month_dt.month + 1, day=1) - timedelta(days=1)
                end_of_month = end_of_month.strftime('%Y-%m-%d')
                
                print(f'Querying check-ins between: {start_of_month} and {end_of_month}')
                query += ' AND check_in_date BETWEEN %s AND %s'
                params.extend([start_of_month, end_of_month])
            except ValueError:
                cursor.close()
                conn.close()
                return jsonify({'success': False, 'error': '无效的月份格式，应为 YYYY-MM'}), 400
        else:
            # 默认查询最近31天
            thirty_one_days_ago = (datetime.now(TZ) - timedelta(days=31)).strftime('%Y-%m-%d')
            query += ' AND check_in_date >= %s'
            params.append(thirty_one_days_ago)
        
        query += ' ORDER BY check_in_date DESC'
        print(f'Executing query: {query} with params: {params}')
        
        cursor.execute(query, params)
        check_in_rows = cursor.fetchall()
        print(f'CheckIns query result: {check_in_rows}')
        
        cursor.close()
        conn.close()
        
        # 计算连续签到天数
        today = datetime.now(TZ).strftime('%Y-%m-%d')
        dates = [row['check_in_date'] for row in check_in_rows]
        streak = calculate_streak(dates, today)
        
        # 格式化签到历史
        check_in_history = []
        for row in check_in_rows:
            date_obj = row['check_in_date']
            # 如果是 datetime.date，转换为 datetime 或 string
            if hasattr(date_obj, 'strftime'):
                date_str = date_obj.strftime('%Y-%m-%d')
            else:
                date_str = str(date_obj)
                
            check_in_history.append({
                'date': date_str,
                'points': row['points_earned']
            })
        
        return jsonify({
            'totalPoints': total_points,
            'checkInHistory': check_in_history,
            'checkInStreak': streak
        }), 200
        
    except Exception as e:
        print(f'Error in /points: {str(e)}')
        return jsonify({'success': False, 'error': '获取积分失败，服务器错误', 'details': str(e)}), 500

# ============================================
# 启动服务
# ============================================

if __name__ == '__main__':
    print(f'后端服务运行在端口 {config.SERVER_PORT}')
    print(f'数据库连接: {config.DB_CONFIG["host"]}:{config.DB_CONFIG["database"]}')
    print(f'时区设置: {config.TIMEZONE}')
    app.run(
        host=config.SERVER_HOST,
        port=config.SERVER_PORT,
        debug=config.DEBUG_MODE
    )
