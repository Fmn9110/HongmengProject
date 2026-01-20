import { healthAlertService, HealthAlertType } from '../component/HealthAlert';
import { simpleAlertService } from '../component/SimpleAlert';
import router from '@ohos.router';
import { Prompt } from '@kit.ArkUI';

@Entry
@Component
struct HealthAlertTestPage {
  aboutToAppear() {
    console.info('健康警告测试页面加载');
  }

  build() {
    Column() {
      Text('健康警告测试')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50, bottom: 30 })
      
      // 复杂警告测试
      Text('自定义对话框测试')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 10, bottom: 10 })
      
      Button('触发心率异常警告 (125 bpm)')
        .width('80%')
        .height(50)
        .margin({ bottom: 10 })
        .onClick(() => {
          console.info('手动触发心率异常警告');
          healthAlertService.checkHeartRate('125 bpm');
        })
      
      Button('直接显示自定义警告对话框')
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .onClick(() => {
          console.info('直接显示自定义警告对话框');
          healthAlertService.showAlert({
            type: HealthAlertType.HEART_RATE,
            value: '125',
            message: '测试警告：您的心率(125次/分钟)超出正常范围',
            suggestions: [
              '这是测试提示1',
              '这是测试提示2',
              '这是测试提示3',
            ]
          });
        })
      
      // 简单警告测试
      Text('简单对话框测试')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 20, bottom: 10 })
      
      Button('系统提示框测试')
        .width('80%')
        .height(50)
        .margin({ bottom: 10 })
        .onClick(() => {
          console.info('显示系统提示框');
          Prompt.showDialog({
            title: '系统提示框测试',
            message: '这是一个系统提示框测试',
            buttons: [
              {
                text: '确定',
                color: '#007DFF'
              }
            ]
          });
        })
      
      Button('简单警告测试 (125 bpm)')
        .width('80%')
        .height(50)
        .margin({ bottom: 10 })
        .onClick(() => {
          console.info('简单警告测试');
          simpleAlertService.checkHeartRate('125 bpm');
        })
      
      Button('Toast提示测试')
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .onClick(() => {
          console.info('Toast提示测试');
          simpleAlertService.showToast('这是一条Toast提示消息');
        })
      
      Button('返回')
        .width('80%')
        .height(50)
        .margin({ top: 30 })
        .onClick(() => {
          router.back();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .padding({ bottom: 50 })

  }
} 