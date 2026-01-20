import { VibrateUtil } from '../utils/VibrateUtil';
import common from '@ohos.app.ability.common';
import router from '@ohos.router';
import { BusinessError } from '@kit.BasicServicesKit';
import promptAction from '@ohos.promptAction';

// 健康警告的类型
export enum HealthAlertType {
  HEART_RATE = 'heart_rate',
  TEMPERATURE = 'temperature',
  BLOOD_OXYGEN = 'blood_oxygen',
  RESPIRATORY_RATE = 'respiratory_rate'
}

// 健康警告的数据接口
export interface HealthAlertData {
  type: HealthAlertType;
  value: string;
  message: string;
  suggestions: string[];
}


// 全局健康警告管理服务（单例模式）
export class HealthAlertService {
  private static instance: HealthAlertService;
  private _alertData: HealthAlertData | null = null;
  private _isVisible: boolean = false;
  private _alertController: CustomDialogController | null = null;

  private constructor() {
  }

  public static getInstance(): HealthAlertService {
    if (!HealthAlertService.instance) {
      HealthAlertService.instance = new HealthAlertService();
    }
    return HealthAlertService.instance;
  }

  // 显示健康警告
  public showAlert(data: HealthAlertData): void {
    try {
      this._alertData = data;
      this._isVisible = true;

      // 触发震动提醒（1.5秒）
      VibrateUtil.vibrate(1500);

      // 创建警告对话框
      this._alertController = new CustomDialogController({
        builder: HealthAlertDialog({
          alertData: data,
          onClose: () => {
            this.hideAlert();
          }
        }),
        autoCancel: false,
        alignment: DialogAlignment.Center,
        customStyle: true
      });

      // 显示对话框
      this._alertController.open();
    } catch (error) {
      console.error('显示健康警告时发生错误:', error instanceof Error ? error.message : String(error));
    }
  }

  // 隐藏健康警告
  public hideAlert(): void {
    if (this._alertController) {
      this._alertController.close();
      this._alertController = null;
    }
    this._isVisible = false;
    this._alertData = null;
  }

  // 检查心率是否异常
  public checkHeartRate(heartRate: string | null | undefined, memberName: string = '您的'): void {
    try {
      // 转换心率字符串为数字
      let rate = 0;
      if (heartRate) {
        // 确保有效的字符串
        const heartRateStr = String(heartRate);
        rate = parseFloat(heartRateStr.replace(/[^0-9.]/g, ''));
      }

      // 测试用：降低阈值，使其更容易触发警告
      // 实际使用时应改回 rate > 120
      if (!isNaN(rate) && rate > 120) {
        console.log(`检测到心率异常：${rate}，触发警告`);
        this.showAlert({
          type: HealthAlertType.HEART_RATE,
          value: String(rate),
          message: `${memberName}心率(${rate}次/分钟)超出正常范围，可能存在健康风险`,
          suggestions: [
            '保持平静，避免剧烈活动',
            '坐下或躺下休息片刻',
            '深呼吸，放松身心',
            '如果症状持续，请立即就医'
          ]
        });
      }
    } catch (error) {
      console.error('检查心率时发生错误:', error instanceof Error ? error.message : String(error));
    }
  }
}

// 导出全局健康警告服务实例
export const healthAlertService = HealthAlertService.getInstance();

// 健康警告对话框组件
@CustomDialog
export struct HealthAlertDialog {
  controller: CustomDialogController;
  alertData: HealthAlertData = {
    type: HealthAlertType.HEART_RATE,
    value: '',
    message: '',
    suggestions: []
  };
  onClose?: () => void;
  
  // 紧急呼救功能 - 跳转到模拟拨号页面
  makeEmergencyCall() {
    try {
      // 关闭警告对话框
      this.controller.close();
      if (this.onClose) {
        this.onClose();
      }
      
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
      // 显示错误提示
      promptAction.showToast({
        message: '呼叫失败，请手动拨打119',
        duration: 3000
      });
    }
  }

  build() {
    Column() {
      // 警告图标和标题
      Row() {
        Image($r('app.media.warning'))
          .width(36)
          .height(36)
          .margin({ right: 12 })
        Text('健康警告')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF4500')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20, bottom: 16 })

      // 警告信息
      Text(this.alertData.message)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 20 })
        .textAlign(TextAlign.Center)

      // 心率值显示（仅当类型为心率时显示）
      if (this.alertData.type === HealthAlertType.HEART_RATE) {
        Row() {
          Text('当前心率：')
            .fontSize(20)
            .fontColor('#666666')
          
          Text(`${this.alertData.value}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF4500')
          
          Text(' 次/分钟')
            .fontSize(20)
            .fontColor('#666666')
        }
        .margin({ bottom: 20 })
        .justifyContent(FlexAlign.Center)
      }

      // 健康建议标题
      Text('健康建议：')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8, left: 12 })

      // 建议列表
      Column({ space: 8 }) {
        ForEach(this.alertData.suggestions, (item: string) => {
          Row({ space: 8 }) {
            Text('•')
              .fontSize(16)
              .fontColor('#007DFF')
            Text(item)
              .fontSize(16)
              .fontColor('#666666')
              .layoutWeight(1)
          }
          .alignItems(VerticalAlign.Top)
          .width('100%')
          .padding({ left: 12, right: 12 })
        })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 按钮区域
      Row({ space: 20 }) {
        // 我知道了按钮
        Button('我知道了', { type: ButtonType.Capsule })
          .width('40%')
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.controller.close();
            this.onClose && this.onClose();
          })
        
        // 紧急呼救按钮
        Button('紧急呼叫', { type: ButtonType.Capsule })
          .width('40%')
          .height(40)
          .backgroundColor('#FF4500')
          .fontColor(Color.White)
          .onClick(() => {
            this.makeEmergencyCall();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 16 })
    }
    .width('85%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding({
      top: 10,
      bottom: 16,
      left: 16,
      right: 16
    })
  }
}