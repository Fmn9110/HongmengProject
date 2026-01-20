# -*- coding: utf-8 -*-
"""
配置文件 - Python后端服务
包含数据库连接、JWT密钥、服务器端口等配置
"""

import os

# ============== 数据库配置 ==============
# 本地MySQL数据库连接信息
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),  # 数据库主机地址
    'port': int(os.getenv('DB_PORT', 3306)),     # 数据库端口
    'user': os.getenv('DB_USER', 'root'),        # 数据库用户名
    'password': os.getenv('DB_PASSWORD', '123456'),    # 数据库密码（请在环境变量中设置）
    'database': os.getenv('DB_NAME', 'health'),  # 数据库名称
    'charset': 'utf8mb4',
    'cursorclass': 'DictCursor',  # 返回字典格式的查询结果
    'autocommit': False  # 手动控制事务提交
}

# ============== JWT配置 ==============
# JWT密钥（生产环境请使用强随机字符串并存储在环境变量中）
JWT_SECRET = os.getenv('JWT_SECRET', 'your-secret-key-change-in-production')
JWT_ALGORITHM = 'HS256'
JWT_EXPIRATION_DAYS = 7  # JWT token有效期（天）

# ============== 服务器配置 ==============
SERVER_HOST = os.getenv('SERVER_HOST', '0.0.0.0')  # 监听所有网络接口
SERVER_PORT = int(os.getenv('SERVER_PORT', 5000))   # 服务端口
DEBUG_MODE = os.getenv('DEBUG_MODE', 'True') == 'True'  # 调试模式

# ============== 时区配置 ==============
TIMEZONE = 'Asia/Shanghai'  # 服务器时区

# ============== 验证码配置 ==============
VERIFICATION_CODE_LENGTH = 6  # 验证码长度
VERIFICATION_CODE_EXPIRY = 5 * 60  # 验证码有效期（秒），5分钟

# ============== 设备监控配置 ==============
DEVICE_OFFLINE_TIMEOUT = 15 * 1000  # 设备离线超时时间（毫秒），15秒
DEFAULT_DEVICE_ID = 'qqq001'  # 默认设备ID

# ============== CORS配置 ==============
CORS_ORIGINS = '*'  # 允许的跨域来源，生产环境应设置具体域名

# ============== 日志配置 ==============
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')  # 日志级别
