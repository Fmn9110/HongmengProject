# 慢宁康 (Health Monitoring System)

**慢宁康** 是一个基于 HarmonyOS（鸿蒙）和 Python Flask 的综合健康监测系统。该项目旨在帮助用户实时监控健康数据，并与智能硬件设备进行交互。

## 📂 项目结构

本项目包含两个主要部分：

*   **`Harmony/`**: 鸿蒙客户端应用 (ArkTS)
    *   用户界面与交互
    *   健康数据显示 (心率, 体温, 血氧等)
    *   签到与积分系统
    *   设备状态监控
*   **`python_backend/`**: Python 后端服务 (Flask)
    *   RESTful API 接口
    *   MySQL 数据库存储
    *   JWT 用户认证
    *   MQTT/WiFi 设备状态管理

## ✨ 主要功能

*   **用户系统**: 注册、登录、密码重置 (支持短信验证码模拟)。
*   **健康监测**: 记录并展示心率、体温、血氧、呼吸率和健康指数。
*   **硬件互联**: 实时监控设备 WiFi 和 MQTT 连接状态。
*   **积分签到**: 每日签到获取积分，连续签到奖励机制。
*   **数据可视化**: 查看历史健康数据趋势。

## 🚀 快速开始

### 1. 后端环境搭建 (`python_backend`)

后端详细文档请参考: [python_backend/README.md](python_backend/README.md)

**简要步骤**:
1.  安装 MySQL 5.7+ 并创建 `health` 数据库 (`database_schema.sql`)。
2.  安装 Python依赖: `pip install -r python_backend/requirements.txt`。
3.  配置 `python_backend/config.py` (数据库密码等)。
4.  启动服务: `python python_backend/app.py`。

### 2. 客户端环境搭建 (`Harmony`)

1.  需要 **DevEco Studio** (推荐最新版) 和 HarmonyOS SDK (API 12+)。
2.  使用 DevEco Studio 打开 `Harmony` 目录。
3.  同步 sync project with gradle files (ohpm install)。
4.  连接鸿蒙真机或模拟器运行 `entry` 模块。

## 📝 许可证

本项目仅供学习和个人使用。
