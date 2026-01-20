/**
 * API配置文件
 * 统一管理所有后端API端点地址
 */

/**
 * API 参数类型 - 使用Record类型以兼容ArkTS严格模式
 */
export type ApiParams = Record<string, string>;

/**
 * API基础配置
 * 
 * 开发环境说明：
 * - localhost: 本地开发时使用
 * - 10.0.2.2: Android模拟器访问宿主机使用
 * - 具体IP: HarmonyOS真机访问开发机使用（需要在同一局域网）
 */
export class ApiConfig {
  // 基础URL配置
  // private static readonly BASE_URL: string = 'http://localhost:5000';
  
  // 如果使用模拟器，请取消下面的注释并注释上一行
  private static readonly BASE_URL: string = 'http://10.0.2.2:5000';
  
  // 如果使用真机且需要访问局域网内的开发机，请使用开发机IP
  // private static readonly BASE_URL: string = 'http://192.168.x.x:5000';

  /**
   * 获取完整的API URL
   * @param path API路径（以/开头）
   * @returns 完整的API URL
   */
  private static getUrl(path: string): string {
    return `${ApiConfig.BASE_URL}${path}`;
  }

  // ============================================
  // 服务器状态接口
  // ============================================
  static readonly STATUS = ApiConfig.getUrl('/status');

  // ============================================
  // 用户认证相关接口
  // ============================================
  static readonly VERIFY_TOKEN = ApiConfig.getUrl('/api/verifyToken');
  static readonly REFRESH_TOKEN = ApiConfig.getUrl('/api/refreshToken');
  static readonly LOGIN = ApiConfig.getUrl('/login');
  static readonly REGISTER = ApiConfig.getUrl('/register');
  static readonly RESET_PASSWORD = ApiConfig.getUrl('/resetPassword');

  // ============================================
  // 验证码相关接口
  // ============================================
  static readonly SEND_CODE = ApiConfig.getUrl('/api/sendCode');
  static readonly VERIFY_CODE = ApiConfig.getUrl('/verifyCode');
  static readonly CHECK_PHONE_REGISTERED = ApiConfig.getUrl('/api/checkPhoneRegistered');

  // ============================================
  // 健康数据管理接口
  // ============================================
  static readonly SAVE_HEALTH_DATA = ApiConfig.getUrl('/saveHealthData');
  static readonly GET_HEALTH_HISTORY = ApiConfig.getUrl('/getHealthHistory');
  static readonly GET_HEALTH_HISTORY_COUNT = ApiConfig.getUrl('/getHealthHistoryCount');
  static readonly DELETE_HEALTH_DATA = ApiConfig.getUrl('/deleteHealthData');

  // ============================================
  // 签到与积分接口
  // ============================================
  static readonly CHECK_IN = ApiConfig.getUrl('/check-in');
  static readonly POINTS = ApiConfig.getUrl('/points');

  // ============================================
  // 设备连接监控接口
  // ============================================
  static readonly WIFI_STATUS = ApiConfig.getUrl('/wifi-status');

  /**
   * 构建带查询参数的URL
   * @param baseUrl 基础URL
   * @param params 查询参数对象（必须使用 Record<string, string> 类型）
   * @returns 带查询参数的完整URL
   */
  static buildUrlWithParams(baseUrl: string, params: Record<string, string>): string {
    const queryString = Object.keys(params)
      .map((key: string) => `${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`)
      .join('&');
    return queryString ? `${baseUrl}?${queryString}` : baseUrl;
  }
}
