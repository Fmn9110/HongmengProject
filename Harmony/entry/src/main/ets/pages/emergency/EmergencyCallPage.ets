import { Toolbar } from '../../component/Toolbar';
import router from '@ohos.router';
import { VibrateUtil } from '../../utils/VibrateUtil';

/**
 * 紧急呼救模拟页面
 */
@Entry
@Component
export default struct EmergencyCallPage {
  @State phoneNumber: string = '119'; // 默认急救电话
  @State isCallActive: boolean = false; // 是否正在通话
  @State callDuration: number = 0; // 通话时长（秒）
  @State callStatus: string = '准备拨号'; // 通话状态
  private timer: number = -1; // 计时器ID
  private callTime: string = ''; // 从路由参数获取的呼叫时间
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams();
    if (params && (params as Record<string, string>).callTime) {
      this.callTime = (params as Record<string, string>).callTime;
      console.info('收到呼叫时间参数:', this.callTime);
    }
  }
  
  aboutToDisappear() {
    // 清除计时器
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }
  
  // 模拟拨打电话
  startCall() {
    if (this.isCallActive) return;
    
    // 震动提示
    VibrateUtil.vibrate(500);
    
    // 更新状态
    this.isCallActive = true;
    this.callStatus = '正在拨号...';
    
    // 模拟接通延迟
    setTimeout(() => {
      this.callStatus = '通话中';
      this.callDuration = 0;
      
      // 开始计时
      this.timer = setInterval(() => {
        this.callDuration++;
      }, 1000);
      
    }, 2000);
  }
  
  // 结束通话
  endCall() {
    if (!this.isCallActive) return;
    
    // 震动提示
    VibrateUtil.vibrate(300);
    
    // 清除计时器
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    
    // 更新状态
    this.isCallActive = false;
    this.callStatus = '通话结束';
    
    // 2秒后返回上一页
    setTimeout(() => {
      router.back();
    }, 2000);
  }
  
  // 格式化通话时间
  formatCallTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
  }
  
  build() {
    Column() {
      Toolbar({ title: '紧急呼救' }) {
        Column() {
          // 拨号状态区域
          Column() {
            Text(this.phoneNumber)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 40, bottom: 20 })
            
            Text(this.callStatus)
              .fontSize(18)
              .fontColor('#666666')
              .margin({ bottom: 10 })
            
            if (this.isCallActive) {
              Text(this.formatCallTime(this.callDuration))
                .fontSize(16)
                .fontColor('#007DFF')
            }
          }
          .width('100%')
          .height('30%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          
          // 模拟拨号界面
          Column() {
            // 联系人头像
            Image($r('app.media.emergency'))
              .width(120)
              .height(120)
              .borderRadius(60)
              .backgroundColor('#EFEFEF')
              .margin({ bottom: 20 })
            
            Text('急救中心')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 10 })
            
            Text('紧急救援热线')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 40 })
            
            // 通话控制按钮
            Row() {
              // 免提
              Column() {
                Stack() {
                  Circle()
                    .width(60)
                    .height(60)
                    .fill('#EEEEEE')
                  
                  Image($r('app.media.speaker'))
                    .width(30)
                    .height(30)
                }
                
                Text('免提')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 8 })
              }
              .margin({ right: 30 })
              
              // 拨号/挂断按钮
              Stack() {
                Circle()
                  .width(80)
                  .height(80)
                  .fill(this.isCallActive ? '#FF4500' : '#4CAF50')
                
                Image(this.isCallActive ? $r('app.media.call_end') : $r('app.media.call'))
                  .width(40)
                  .height(40)
              }
              .onClick(() => {
                if (this.isCallActive) {
                  this.endCall();
                } else {
                  this.startCall();
                }
              })
              
              // 静音
              Column() {
                Stack() {
                  Circle()
                    .width(60)
                    .height(60)
                    .fill('#EEEEEE')
                  
                  Image($r('app.media.mute'))
                    .width(30)
                    .height(30)
                }
                
                Text('静音')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 8 })
              }
              .margin({ left: 30 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 30 })
            
            // 提示文本
            Text('模拟呼救界面，实际使用时请拨打真实急救电话')
              .fontSize(14)
              .fontColor('#999999')
              .textAlign(TextAlign.Center)
              .padding({ left: 20, right: 20 })
          }
          .width('100%')
          .height('70%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
  }
} 