# 健康监测系统 - Python后端服务

这是一个基于Flask的Python后端服务，合并了健康监测系统和硬件连接监控的所有功能。

## 📋 目录

- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [详细配置](#详细配置)
- [API文档](#api文档)
- [常见问题](#常见问题)

---

## 🔧 环境要求

- **Python**: 3.8 或更高版本
- **MySQL**: 5.7 或更高版本
- **操作系统**: Windows / Linux / macOS

---

## 🚀 快速开始

### 1. 安装MySQL数据库

如果您还没有安装MySQL，请先下载并安装：

- **Windows**: 下载 [MySQL Community Server](https://dev.mysql.com/downloads/mysql/)
- **Linux**: `sudo apt-get install mysql-server` (Ubuntu/Debian)
- **macOS**: `brew install mysql`

启动MySQL服务后，创建数据库：

```bash
# 登录MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE health;
exit;
```

### 2. 初始化数据库表结构

```bash
# 导入表结构
mysql -u root -p health < database_schema.sql
```

### 3. 安装Python依赖

```bash
# 进入项目目录
cd e:\人工智能项目(鸿蒙)\后端JS代码\python_backend

# 创建Python虚拟环境（推荐）
python -m venv venv

# 激活虚拟环境
# Windows:
venv\Scripts\activate
# Linux/macOS:
# source venv/bin/activate

# 安装依赖
pip install -r requirements.txt
```

### 4. 配置数据库连接

编辑 `config.py` 文件，修改数据库配置：

```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '你的MySQL密码',  # 修改为你的密码
    'database': 'health',
    'charset': 'utf8mb4',
    'cursorclass': 'DictCursor',
    'autocommit': False
}
```

**推荐**: 使用环境变量设置敏感信息，创建 `.env` 文件：

```
DB_PASSWORD=你的MySQL密码
JWT_SECRET=你的JWT密钥
```

### 5. 启动服务

```bash
python app.py
```

如果看到以下输出，说明服务启动成功：

```
后端服务运行在端口 3000
数据库连接: localhost:health
时区设置: Asia/Shanghai
 * Running on http://0.0.0.0:3000
```

### 6. 测试服务

在浏览器或Postman中访问：

```
http://localhost:3000/status
```

应该返回：

```json
{
  "status": "Server is running",
  "timestamp": "2026-01-20T16:30:00+08:00"
}
```

---

## ⚙️ 详细配置

### 配置文件说明 (config.py)

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `DB_CONFIG['host']` | 数据库主机地址 | `localhost` |
| `DB_CONFIG['user']` | 数据库用户名 | `root` |
| `DB_CONFIG['password']` | 数据库密码 | 空（需设置） |
| `DB_CONFIG['database']` | 数据库名称 | `health` |
| `JWT_SECRET` | JWT密钥 | `your-secret-key-change-in-production` |
| `SERVER_PORT` | 服务端口 | `3000` |
| `DEBUG_MODE` | 调试模式 | `True` |
| `TIMEZONE` | 时区 | `Asia/Shanghai` |

### 环境变量支持

可以通过环境变量覆盖配置：

```bash
# Windows (PowerShell)
$env:DB_PASSWORD="your_password"
$env:JWT_SECRET="your_jwt_secret"
python app.py

# Linux/macOS
export DB_PASSWORD="your_password"
export JWT_SECRET="your_jwt_secret"
python app.py
```

---

## 📖 API文档

### 基础接口

#### 服务器状态检查
```
GET /status
```

**响应示例**:
```json
{
  "status": "Server is running",
  "timestamp": "2026-01-20T16:30:00+08:00"
}
```

---

### 硬件连接监控接口

#### 更新设备状态
```
POST /wifi-status
Content-Type: application/json

{
  "wifi_status": "connected",
  "mqtt_status": "connected",
  "device_id": "qqq001"
}
```

**参数说明**:
- `wifi_status`: WiFi连接状态 (`connected` | `disconnected`)
- `mqtt_status`: MQTT连接状态 (`connected` | `disconnected`)
- `device_id`: 设备ID（可选，默认 `qqq001`）

#### 查询设备状态
```
GET /wifi-status?device_id=qqq001
```

**响应示例**:
```json
{
  "wifi_status": "connected",
  "device_id": "qqq001",
  "lastSyncTime": 1737364200000
}
```

---

### 用户认证接口

#### 发送验证码
```
GET /api/sendCode?phone=13800138000&type=register
```

**参数**:
- `phone`: 11位手机号
- `type`: `register`（注册）或 `reset`（重置密码）

#### 用户注册
```
POST /register
Content-Type: application/json

{
  "phone": "13800138000",
  "password": "password123",
  "verificationCode": "123456"
}
```

#### 用户登录
```
POST /login
Content-Type: application/json

{
  "phone": "13800138000",
  "password": "password123"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "登录成功",
  "userId": 1,
  "JWTtoken": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "a1b2c3d4e5f6..."
}
```

#### 验证Token
```
POST /api/verifyToken
Authorization: Bearer <JWT_TOKEN>
```

#### 刷新Token
```
POST /api/refreshToken
Content-Type: application/json

{
  "refreshToken": "a1b2c3d4e5f6..."
}
```

---

### 健康数据管理接口

所有健康数据接口都需要JWT认证（在请求头中添加 `Authorization: Bearer <token>`）

#### 保存健康数据
```
POST /saveHealthData
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "heartRate": 75,
  "temperature": 36.5,
  "bloodOxygen": 98,
  "respiratoryRate": 16,
  "healthIndex": 85
}
```

#### 获取健康历史
```
POST /getHealthHistory
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "startDate": "2026-01-01",
  "endDate": "2026-01-20",
  "limit": 100
}
```

#### 删除健康数据
```
POST /deleteHealthData
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "ids": [1, 2, 3]
}
```

---

### 签到与积分接口

#### 每日签到
```
POST /check-in
Authorization: Bearer <JWT_TOKEN>
```

**响应示例**:
```json
{
  "success": true,
  "pointsEarned": 60,
  "message": "签到成功，获得60积分",
  "checkInStreak": 3
}
```

**积分规则**:
- 周一: 60分
- 周二: 90分
- 周三: 120分
- 周四: 150分
- 周五: 180分
- 周六: 220分
- 周日: 280分

#### 查询积分
```
GET /points?month=2026-01
Authorization: Bearer <JWT_TOKEN>
```

**响应示例**:
```json
{
  "totalPoints": 450,
  "checkInHistory": [
    {
      "date": "2026-01-20T00:00:00+08:00",
      "points": 60
    }
  ],
  "checkInStreak": 3
}
```

---

## ❓ 常见问题

### 1. 数据库连接失败

**错误**: `pymysql.err.OperationalError: (2003, "Can't connect to MySQL server")`

**解决方法**:
- 检查MySQL服务是否启动
- 确认数据库配置（host、user、password）正确
- 检查防火墙是否阻止了MySQL端口（默认3306）

### 2. 缺少Python模块

**错误**: `ModuleNotFoundError: No module named 'flask'`

**解决方法**:
```bash
pip install -r requirements.txt
```

### 3. JWT Token过期

**错误**: `{"error": "令牌已过期"}`

**解决方法**:
使用 `/api/refreshToken` 接口刷新token，或重新登录

### 4. 端口被占用

**错误**: `OSError: [WinError 10048] 通常每个套接字地址只允许使用一次`

**解决方法**:
- 修改 `config.py` 中的 `SERVER_PORT` 为其他端口
- 或关闭占用3000端口的程序

### 5. 验证码发送失败

当前版本的验证码只是打印到控制台（模拟发送）。在生产环境中，需要对接真实的短信服务商（如阿里云、腾讯云等）。

---

## 🔒 安全建议

### 生产环境部署前必须修改

1. **修改JWT密钥**:
   ```python
   JWT_SECRET = '使用强随机字符串'
   ```
   可以使用以下命令生成：
   ```bash
   python -c "import secrets; print(secrets.token_hex(32))"
   ```

2. **关闭调试模式**:
   ```python
   DEBUG_MODE = False
   ```

3. **使用HTTPS**: 生产环境必须使用HTTPS协议

4. **限制CORS来源**:
   ```python
   CORS_ORIGINS = 'https://your-frontend-domain.com'
   ```

5. **使用环境变量**: 不要在代码中硬编码敏感信息

---

## 📝 许可证

此项目仅供学习和个人使用。

## 📧 技术支持

如有问题，请检查：
1. MySQL服务是否正常运行
2. Python版本是否满足要求
3. 所有依赖是否正确安装
4. 数据库表结构是否正确导入

---

**祝您使用愉快！** 🎉
