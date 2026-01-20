import { Prompt } from '@kit.ArkUI';
import { VibrateUtil } from '../utils/VibrateUtil';
import router from '@ohos.router';
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';

// 简单警告数据接口
export interface SimpleAlertData {
  title: string;
  message: string;
  buttonText?: string;
}

// 全局警告服务
export class SimpleAlertService {
  private static instance: SimpleAlertService;

  private constructor() {
  }

  public static getInstance(): SimpleAlertService {
    if (!SimpleAlertService.instance) {
      SimpleAlertService.instance = new SimpleAlertService();
    }
    return SimpleAlertService.instance;
  }

  // 显示Toast提示
  public showToast(message: string, duration: number = 2000): void {
    try {
      Prompt.showToast({
        message: message,
        duration: duration,
      });
    } catch (error) {
      console.error('显示Toast提示失败:', error instanceof Error ? error.message : String(error));
    }
  }

  // 显示警告对话框
  public showAlert(data: SimpleAlertData): void {
    try {
      // 触发震动提醒（1.5秒）
      VibrateUtil.vibrate(1500);
      
      Prompt.showDialog({
        title: data.title,
        message: data.message,
        buttons: [
          {
            text: data.buttonText || '确定',
            color: '#007DFF'
          },
          {
            text: '紧急呼救',
            color: '#FF4500'
          }
        ],
        success: (result) => {
          // 如果点击了紧急呼救按钮（按钮索引为1）
          if (result.index === 1) {
            this.makeEmergencyCall();
          }
        }
      });
    } catch (error) {
      console.error('显示对话框失败:', error instanceof Error ? error.message : String(error));
      
      // 尝试使用Toast作为备选方案
      this.showToast(`${data.title}: ${data.message}`);
    }
  }
  
  // 紧急呼救功能 - 跳转到模拟拨号页面
  private makeEmergencyCall(): void {
    try {
      // 添加延迟，确保对话框已完全关闭
      setTimeout(() => {
        // 使用完整的路径跳转到模拟拨号页面
        router.pushUrl({
          url: '/pages/emergency/EmergencyCallPage',
          params: {
            callTime: new Date().toISOString()
          }
        })
        .then(() => {
          console.info('成功跳转到紧急呼救页面');
        })
        .catch((err: BusinessError | Error) => {
          console.error(`跳转到紧急呼救页面失败: ${JSON.stringify(err)}`);
          // 显示错误提示
          promptAction.showToast({
            message: '跳转失败，请手动拨打119',
            duration: 3000
          });
        });
      }, 200);
    } catch (error) {
      console.error(`紧急呼救失败: ${error instanceof Error ? error.message : String(error)}`);
      this.showToast('呼叫失败，请手动拨打119');
    }
  }

  // 检查心率
  public checkHeartRate(heartRate: string | null | undefined, memberName: string = '您的'): void {
    try {
      // 转换心率字符串为数字
      let rate = 0;
      if (heartRate) {
        const heartRateStr = String(heartRate);
        rate = parseFloat(heartRateStr.replace(/[^0-9.]/g, ''));
      }
      
      // 如果心率大于120，显示警告
      if (!isNaN(rate) && rate > 120) {
        this.showAlert({
          title: '心率警告',
          message: `${memberName}的心率(${rate}次/分钟)超出正常范围，可能存在健康风险。请保持平静，避免剧烈活动，如症状持续请及时就医。`,
          buttonText: '我知道了'
        });
      }
    } catch (error) {
      console.error('检查心率失败:', error instanceof Error ? error.message : String(error));
    }
  }
}

// 导出警告服务实例
export const simpleAlertService = SimpleAlertService.getInstance(); 