import { Prompt, router } from '@kit.ArkUI';
import { globalStates } from './global';

@Entry
@Component
struct FloatBall {
  @State gx: number = 300; // 拖拽X轴偏移量
  @State gy: number = 570; // 拖拽Y轴偏移量
  @Link isVisible: boolean;
  @State isMenuVisible: boolean = false; // 控制菜单可见性
  private px: number = 0; // 触摸点X坐标
  private py: number = 0; // 触摸点Y坐标
  @State menuWidth: string = '0%'; // 菜单动画宽度
  @State menuHeight: string = '0%'; // 菜单动画高度
  @State showCongratulateImage: boolean = false; // 控制图片显示状态
  vipDialogController: CustomDialogController | null = new CustomDialogController({
    builder: VipDialog({
      openVipDetails: () => {
        if (this.vipDetailsDialogController != null) {
          this.vipDetailsDialogController.open();
        }
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    customStyle: true
  });
  vipDetailsDialogController: CustomDialogController | null = new CustomDialogController({
    builder: VipDetailsDialog({
      onConfirm: () => {
        this.showCongratulateImage = true; // 在对话框关闭时显示图片
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: 0 },
    customStyle: true
  });

  aboutToDisappear() {
    this.vipDialogController = null;
    this.vipDetailsDialogController = null;
  }

  // 处理拖拽逻辑
  private handleTouch(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      // 记录触摸点相对于悬浮球左上角的偏移
      this.px = event.touches[0].screenX - this.gx;
      this.py = event.touches[0].screenY - this.gy;
    } else if (event.type === TouchType.Move) {
      // 更新悬浮球位置
      this.gx = event.touches[0].screenX - this.px;
      this.gy = event.touches[0].screenY - this.py;
    } else if (event.type === TouchType.Up) {
      // 拖拽结束，处理吸附逻辑
      const screenWidth = 1080; // 假设屏幕宽度为1080px，可动态获取
      const threshold = 300; // 吸附阈值100px
      const ballWidth = 50; // 悬浮球宽度120px（与Image宽度一致）
      let targetX = this.gx; // 目标X坐标

      if (this.gx < threshold) {
        // 吸附到左边缘
        targetX = 300;
      } else if (this.gx > screenWidth - ballWidth - threshold) {
        // 吸附到右边缘
        targetX = screenWidth - ballWidth;
      }

      // 使用动画平滑移动到目标位置
      animateTo({ duration: 200, curve: Curve.EaseOut }, () => {
        this.gx = targetX;
      });
    }
  }

  build() {
    Stack() {
      // 悬浮球
      if (this.isVisible) {
        Stack() {
          Image($r('app.media.vip_card'))
            .width(120)
            .height(120)
            .onClick(() => {
              if (this.vipDialogController != null) {
                this.vipDialogController.open();
              }
            })
            .onTouch((event: TouchEvent) => {
              this.handleTouch(event); // 拖拽悬浮球
            })
          Text('x')
            .width(20)
            .height(20)
            .fontColor('#ffab8063')
            .borderRadius(10)
            .position({ x: 5, y: 60 })
            .onClick(() => {
              this.isVisible = false;
            })
            .zIndex(2)
        }
        .position({ x: this.gx, y: this.gy }) // 设置悬浮球位置
        .zIndex(1001) // 确保悬浮球在顶层
      }

      // 图片显示区域
      if (this.showCongratulateImage) {
        Stack() {
          // 添加半透明背景遮罩
          // Blank()
          //   .backgroundColor(Color.Black.opacity(0.5))
          //   .width('100%')
          //   .height('100%')
          //   .onClick(() => {
          //     this.showCongratulateImage = false; // 点击遮罩关闭图片
          //   })
          Image($r('app.media.congratulate'))// 请替换为你的图片资源
            .width(300)// 可根据需要调整图片大小
            .height(300)
            .position({ x: '50%', y: '50%' })// 居中定位
            .translate({ x: '-50%', y: '-50%' })// 偏移以确保图片中心对齐
            .zIndex(1002)// 确保图片在最上层
            .onClick(() => {
              this.showCongratulateImage = false; // 点击图片关闭
            })
        }
        .position({ x: 0, y: 0 }) // 绝对定位于页面左上角
        .width('100%')
        .height('100%')
        .zIndex(1000) // 确保图片容器在最上层
      }
    }
    .position({ x: 0, y: 0 }) // 根Stack绝对定位于页面左上角
    .zIndex(1000) // 确保整个FloatBall组件在顶层
  }
}

@CustomDialog
struct VipDialog {
  controller?: CustomDialogController;
  openVipDetails?: () => void;

  build() {
    Column() {
      Text('会员权益')
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })
        .fontColor('#302D31')
      Row() {
        Row() {
          Row() {
            Image($r('app.media.doctor1vs1'))
              .padding(5)
              .width(43)
          }
          .width(50)
          .height(50)
          .border({ width: 1 })
          .margin({ right: 10 })
          .linearGradient({
            direction: GradientDirection.Bottom, // 渐变方向
            colors: [['#666764', 0.0], ['#434441', 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .border({ color: '#666764' })
          .borderRadius(30)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('专属医生')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 5, top: 7 })
            Text('1对1问诊')
              .fontSize(14)
              .fontColor('#AEAEAE')
          }
          .alignItems(HorizontalAlign.Start)
        }

        Row() {
          Row() {
            Image($r('app.media.ad'))
              .padding(5)
              .width(43)
          }
          .width(50)
          .height(50)
          .border({ width: 1 })
          .margin({ right: 10 })
          .linearGradient({
            direction: GradientDirection.Bottom, // 渐变方向
            colors: [['#666764', 0.0], ['#434441', 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .border({ color: '#666764' })
          .borderRadius(30)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('去广告')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 5, top: 7 })
            Text('免APP内广告')
              .fontSize(14)
              .fontColor('#AEAEAE')
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 15 })

      Row() {
        Row() {
          Row() {
            Image($r('app.media.food2'))
              .padding(5)
              .width(43)
          }
          .width(50)
          .height(50)
          .border({ width: 1 })
          .margin({ right: 10 })
          .linearGradient({
            direction: GradientDirection.Bottom, // 渐变方向
            colors: [['#666764', 0.0], ['#434441', 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .border({ color: '#666764' })
          .borderRadius(30)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('定制食谱')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 5, top: 7 })
            Text('定制化饮食')
              .fontSize(14)
              .fontColor('#AEAEAE')
          }
          .alignItems(HorizontalAlign.Start)
        }

        Row() {
          Row() {
            Image($r('app.media.accelerate'))
              .padding(5)
              .width(43)
          }
          .width(50)
          .height(50)
          .border({ width: 1 })
          .margin({ right: 10 })
          .linearGradient({
            direction: GradientDirection.Bottom, // 渐变方向
            colors: [['#666764', 0.0], ['#434441', 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .border({ color: '#666764' })
          .borderRadius(30)
          .justifyContent(FlexAlign.Center)

          Column() {
            Text('极致加速')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 5, top: 7 })
            Text('APP加载提速')
              .fontSize(14)
              .fontColor('#AEAEAE')
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 15 })

      Button('前往开通')
        .width('97%')
        .borderRadius(5)
        .type(ButtonType.Normal)
        .linearGradient({
          direction: GradientDirection.LeftBottom, // 渐变方向
          colors: [['#fff1ddcc', 0.0], ['#ffdbbfa1', 1]] // 数组末尾元素占比小于1时满足重复着色效果
        })
        .fontColor(Color.Black)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .padding({
          top: 12,
          bottom: 10,
          left: 20,
          right: 20
        })
        .onClick(() => {
          this.controller!.close();
          this.openVipDetails!();
        })
    }
    .backgroundColor(Color.White)
    .width(340)
    .borderRadius(24)
    .border({ width: 1, style: BorderStyle.Solid, color: ('#DECFB8') }) // 科技蓝边框
    .shadow({ radius: 2 })
    .transition(TransitionEffect.asymmetric(
      TransitionEffect.OPACITY
        .animation({ duration: 400, curve: Curve.EaseInOut })
        .combine(TransitionEffect.scale({ x: 1.1, y: 1.1 }).animation({ duration: 400 })),
      TransitionEffect.OPACITY
        .animation({ duration: 200, curve: Curve.EaseOut })
        .combine(TransitionEffect.scale({ x: 0.8, y: 0.8 }).animation({ duration: 200, curve: Curve.EaseOut }))
    ))
    .padding(20)
  }
}

@CustomDialog
struct VipDetailsDialog {
  @State to: boolean = false;
  @State selectedPlan: string = 'yearly'; // 新增状态跟踪选中计划
  controller?: CustomDialogController;
  onConfirm?: () => void; // 回调函数，用于触发图片显示

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            Text('连续包年')
              .fontSize(17)
              .fontColor('#ff807a72')
              .margin({ bottom: 16, top: 13 })
            Text() {
              Span('￥')
                .fontColor('#010101')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 13 })
              Span('128.0')
                .fontColor('#010101')
                .fontSize(27)
                .fontWeight(FontWeight.Bold)
                .fontStyle(FontStyle.Italic)
                .margin({ bottom: 13 })
            }

            Text('￥11.5元/月')
              .fontSize(13)
              .fontColor('#C2C0BB')
              .margin({ bottom: 13 })
            Row() {
              Text('立省80元')
                .fontColor('#685D4B')
            }
            .padding(5)
            .width('60%')
            .height(25)
            .backgroundColor('#ECDFCB')
            .borderRadius(30)
            .margin({ bottom: 13 })
            .justifyContent(FlexAlign.Center)
          }
          .width(130)
          .height(150)
          .borderRadius(23)
          .backgroundColor(this.selectedPlan === 'yearly' ? '#F5EEE3' : '#FFFFFF') // 根据选中状态设置背景
          .border({ color: '#ffc6c6c6', width: 1 })
          .onClick(() => {
            this.selectedPlan = 'yearly'; // 点击时更新选中计划
          })

          Column() {
            Text('连续包月')
              .fontSize(17)
              .fontColor('#ff807a72')
              .margin({ bottom: 16, top: 13 })
            Text() {
              Span('￥')
                .fontColor('#010101')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 13 })
              Span('25.0')
                .fontColor('#010101')
                .fontSize(27)
                .fontWeight(FontWeight.Bold)
                .fontStyle(FontStyle.Italic)
                .margin({ bottom: 13 })
            }

            Text('￥25元/月')
              .fontSize(13)
              .fontColor('#C2C0BB')
              .margin({ bottom: 13 })
            Row() {
              Text('立省10元')
                .fontColor('#685D4B')
            }
            .padding(5)
            .width('60%')
            .height(25)
            .backgroundColor('#ECDFCB')
            .borderRadius(30)
            .margin({ bottom: 13 })
            .justifyContent(FlexAlign.Center)
          }
          .width(130)
          .height(150)
          .borderRadius(23)
          .border({ color: '#ffc6c6c6', width: 1 })
          .backgroundColor(this.selectedPlan === 'monthly' ? '#F5EEE3' : '#FFFFFF') // 根据选中状态设置背景
          .onClick(() => {
            this.selectedPlan = 'monthly'; // 点击时更新选中计划
          })
        }
        .width('97%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 20 })

        Row() {
          Column() {
            Text('12个月')
              .fontSize(17)
              .fontColor('#ff807a72')
              .margin({ bottom: 16, top: 13 })
            Text() {
              Span('￥')
                .fontColor('#010101')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 13 })
              Span('188.0')
                .fontColor('#010101')
                .fontSize(27)
                .fontWeight(FontWeight.Bold)
                .fontStyle(FontStyle.Italic)
                .margin({ bottom: 13 })
            }

            Text('￥15.6元/月')
              .fontSize(13)
              .fontColor('#C2C0BB')
              .margin({ bottom: 13 })
            Row() {
              Text('立省30元')
                .fontColor('#685D4B')
            }
            .padding(5)
            .width('60%')
            .height(25)
            .backgroundColor('#ECDFCB')
            .borderRadius(30)
            .margin({ bottom: 13 })
            .justifyContent(FlexAlign.Center)
          }
          .width(130)
          .height(150)
          .borderRadius(23)
          .border({ color: '#ffc6c6c6', width: 1 })
          .backgroundColor(this.selectedPlan === '12months' ? '#F5EEE3' : '#FFFFFF') // 根据选中状态设置背景
          .onClick(() => {
            this.selectedPlan = '12months'; // 点击时更新选中计划
          })

          Column() {
            Text('1个月')
              .fontSize(17)
              .fontColor('#ff807a72')
              .margin({ bottom: 16, top: 13 })
            Text() {
              Span('￥')
                .fontColor('#010101')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 13 })
              Span('35')
                .fontColor('#010101')
                .fontSize(27)
                .fontWeight(FontWeight.Bold)
                .fontStyle(FontStyle.Italic)
                .margin({ bottom: 13 })
            }

            Text('￥35元/月')
              .fontSize(13)
              .fontColor('#C2C0BB')
              .margin({ bottom: 13 })
            Row() {
              Text('原价购买')
                .fontColor('#685D4B')
            }
            .padding(5)
            .width('60%')
            .height(25)
            .backgroundColor('#FFFFFF')
            .borderRadius(30)
            .margin({ bottom: 13 })
            .justifyContent(FlexAlign.Center)
          }
          .width(130)
          .height(150)
          .borderRadius(23)
          .border({ color: '#ffc6c6c6', width: 1 })
          .backgroundColor(this.selectedPlan === '1month' ? '#F5EEE3' : '#FFFFFF') // 根据选中状态设置背景
          .onClick(() => {
            this.selectedPlan = '1month'; // 点击时更新选中计划
          })
        }
        .width('97%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 20 })

        Button('立即开通')
          .width('97%')
          .borderRadius(5)
          .type(ButtonType.Normal)
          .linearGradient({
            direction: GradientDirection.LeftBottom, // 渐变方向
            colors: [['#fff1ddcc', 0.0], ['#ffdbbfa1', 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .fontColor(Color.Black)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .padding({
            top: 12,
            bottom: 10,
            left: 20,
            right: 20
          })
          .onClick(() => {
            if (this.to) {
              this.controller!.close();
              globalStates.emitIsVipChange(true);
              this.onConfirm!(); // 触发回调以显示图片
            } else {
              Prompt.showToast({ message: '请勾选协议', duration: 1500 });
            }
          })
        Row() {
          Checkbox()
            .select(false)
            .onChange((selected) => {
              this.to = selected
            })
            .width(13)
            .selectedColor('#ffcaae94')
          Text() {
            Span('已阅读并同意')
              .fontSize(13)
              .fontColor('#AEAEAE')
            Span('《付费协议》')
              .fontSize(13)
          }
        }
        .margin({ top: 8 })
      }
      .width(320)
      .height(450)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .border({ width: 1, style: BorderStyle.Solid, color: ('#1E90FF') }) // 科技蓝边框
      .transition(TransitionEffect.asymmetric(
        TransitionEffect.OPACITY
          .animation({ duration: 400, curve: Curve.EaseInOut })
          .combine(TransitionEffect.scale({ x: 1.1, y: 1.1 }).animation({ duration: 400 })),
        TransitionEffect.OPACITY
          .animation({ duration: 200, curve: Curve.EaseOut })
          .combine(TransitionEffect.scale({ x: 0.8, y: 0.8 }).animation({ duration: 200, curve: Curve.EaseOut }))
      ))
      .align(Alignment.Center)
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Center)
  }
}

export { FloatBall };