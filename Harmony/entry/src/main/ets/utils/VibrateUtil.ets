import vibrator from '@ohos.vibrator';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 震动工具类
 */
export class VibrateUtil {
  /**
   * 触发震动
   * @param duration 震动时长（毫秒）
   */
  static vibrate(duration: number = 1500): void {
    try {
      // 调用系统震动API，duration单位为ms
      vibrator.startVibration({
        type: 'time',
        duration: duration
      }, {
        id: 0,
        usage: 'alarm'
      }).then(() => {
        console.log(`震动已开始，持续${duration}毫秒`);
      }).catch((err: BusinessError) => {
        console.error(`震动失败: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      console.error(`震动调用异常: ${error.message}`);
    }
  }

  /**
   * 停止震动
   */
  static stopVibration(): void {
    try {
      vibrator.stopVibration().then(() => {
        console.log('震动已停止');
      }).catch((err: BusinessError) => {
        console.error(`停止震动失败: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      console.error(`停止震动调用异常: ${error.message}`);
    }
  }
} 