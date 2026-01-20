-- ============================================
-- 健康监测系统 - 数据库表结构
-- ============================================
-- 数据库: health
-- 用于本地MySQL数据库初始化
-- ============================================

-- 使用数据库
USE health;

-- ============================================
-- 1. 用户表 (users)
-- ============================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
  `phone` VARCHAR(11) NOT NULL UNIQUE COMMENT '手机号（11位）',
  `password` VARCHAR(255) NOT NULL COMMENT '加密后的密码',
  `refresh_token` VARCHAR(255) DEFAULT NULL COMMENT 'Refresh Token',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  INDEX idx_phone (`phone`),
  INDEX idx_refresh_token (`refresh_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';

-- ============================================
-- 2. 健康数据表 (health_data)
-- ============================================
CREATE TABLE IF NOT EXISTS `health_data` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '记录ID',
  `user_id` INT NOT NULL COMMENT '用户ID',
  `heart_rate` INT DEFAULT NULL COMMENT '心率（次/分钟）',
  `temperature` DECIMAL(4,2) DEFAULT NULL COMMENT '体温（摄氏度）',
  `blood_oxygen` INT DEFAULT NULL COMMENT '血氧饱和度（%）',
  `respiratory_rate` INT DEFAULT NULL COMMENT '呼吸率（次/分钟）',
  `health_index` INT DEFAULT NULL COMMENT '健康指数',
  `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
  INDEX idx_user_id (`user_id`),
  INDEX idx_recorded_at (`recorded_at`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康数据记录表';

-- ============================================
-- 3. 签到表 (CheckIns)
-- ============================================
CREATE TABLE IF NOT EXISTS `CheckIns` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '签到ID',
  `user_id` INT NOT NULL COMMENT '用户ID',
  `check_in_date` DATE NOT NULL COMMENT '签到日期',
  `points_earned` INT NOT NULL DEFAULT 0 COMMENT '获得的积分',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '签到时间',
  UNIQUE KEY unique_user_date (`user_id`, `check_in_date`),
  INDEX idx_user_id (`user_id`),
  INDEX idx_check_in_date (`check_in_date`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户签到记录表';

-- ============================================
-- 4. 积分表 (Points)
-- ============================================
CREATE TABLE IF NOT EXISTS `Points` (
  `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '积分记录ID',
  `user_id` INT NOT NULL COMMENT '用户ID',
  `points` INT NOT NULL DEFAULT 0 COMMENT '积分数（可正可负）',
  `reason` VARCHAR(255) DEFAULT NULL COMMENT '积分变动原因',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  INDEX idx_user_id (`user_id`),
  INDEX idx_created_at (`created_at`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户积分记录表';

-- ============================================
-- 示例数据（可选）
-- ============================================
-- 插入测试用户（密码: test123，已加密）
-- INSERT INTO `users` (`phone`, `password`) 
-- VALUES ('13800138000', '$2b$10$abcdefghijklmnopqrstuvwxyz1234567890');

-- ============================================
-- 完成
-- ============================================
