import { Toolbar } from "../../../component/Toolbar";
import { router, Prompt } from '@kit.ArkUI';
import { preferences } from "@kit.ArkData";
import { common } from "@kit.AbilityKit";

// 定义颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const BACKGROUND_COLOR: ResourceColor = '#F5F5F5';
const DIVIDER_COLOR: ResourceColor = '#E5E5E5';

// 问题类型接口
interface FaqItem {
  question: string;
  answer: string;
  expanded: boolean;
}

// 反馈类型接口
interface FeedbackType {
  id: number;
  name: string;
}

@Entry
@Component
export default struct HelpFeedbackPage {
  @State currentTabIndex: number = 0;
  @State faqItems: FaqItem[] = [];
  @State feedbackContent: string = '';
  @State contactInfo: string = '';
  @State selectedFeedbackType: number = 0;
  @State overscrollOffset: number = 0;
  @State isSubmitting: boolean = false;
  
  // 反馈类型列表
  private feedbackTypes: FeedbackType[] = [
    { id: 0, name: '功能建议' },
    { id: 1, name: '产品问题' },
    { id: 2, name: '使用疑问' },
    { id: 3, name: '其他' }
  ];
  
  // 获取本地存储实例
  private context = getContext(this) as common.UIAbilityContext;
  private options: preferences.Options = { name: 'help_feedback_data' };
  private preference = preferences.getPreferencesSync(this.context, this.options);
  
  aboutToAppear() {
    // 初始化FAQ数据
    this.initFaqData();
  }
  
  // 初始化FAQ数据
  private initFaqData() {
    this.faqItems = [
      {
        question: '如何开启健康数据监测？',
        answer: '打开主页，点击相应的健康监测项目（如心率、血压等），允许相应权限后，系统将自动开始监测。如果您使用的是外接设备，请先在"设备授权管理"中连接并授权该设备。',
        expanded: false
      },
      {
        question: '如何查看历史健康数据？',
        answer: '在主页中点击相应的健康监测项目，进入详情页后点击右上角的"历史记录"按钮，即可查看您的历史健康数据。您还可以通过日期筛选来查看特定时间段的数据。',
        expanded: false
      },
      {
        question: '如何将我的数据同步到云端？',
        answer: '首先确保您已经注册并登录账号，然后在"APP设置"中打开"数据同步"选项。系统将自动在WiFi环境下同步您的健康数据到云端，以便您在不同设备上访问。',
        expanded: false
      },
      {
        question: '积分如何获取和使用？',
        answer: '您可以通过完成每日签到、记录健康数据、参与健康活动等方式获取积分。积分可以在"我的"页面的积分商城中兑换各种健康相关的商品和服务。',
        expanded: false
      },
      {
        question: '如何删除我的账号和数据？',
        answer: '在"设置"页面中，点击"账号与安全"，选择"账号注销"选项。注销前请确保您已备份重要数据，因为账号注销后，所有个人数据将被永久删除，无法恢复。',
        expanded: false
      },
      {
        question: '应用崩溃或无响应怎么办？',
        answer: '请尝试以下步骤：1. 重启应用；2. 清除应用缓存（在"APP设置"中）；3. 重启设备；4. 检查应用是否有更新；5. 如问题持续存在，请通过反馈功能向我们报告问题。',
        expanded: false
      }
    ];
  }
  
  // 切换FAQ项展开状态
  private toggleFaqItem(index: number) {
    this.faqItems[index].expanded = !this.faqItems[index].expanded;
  }
  
  // 提交反馈
  private submitFeedback() {
    if (!this.feedbackContent.trim()) {
      Prompt.showToast({ message: '请输入反馈内容', duration: 2000 });
      return;
    }
    
    this.isSubmitting = true;
    
    // 模拟提交反馈的网络请求
    setTimeout(() => {
      this.isSubmitting = false;
      Prompt.showToast({ message: '反馈提交成功，感谢您的反馈！', duration: 2000 });
      this.feedbackContent = '';
      this.contactInfo = '';
    }, 1500);
  }

  build() {
    Column() {
      // 自定义顶部栏
      Column() {
        Row() {
          Image($r("app.media.ic_back_black"))
            .width(22)
            .height(22)
            .margin({ left: 5 })
            .onClick(() => {
              router.back()
            })
          Blank()
          Text('帮助与反馈')
            .fontSize(22)
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
          Blank()
          Row() {
            // 可以根据需要添加右侧按钮
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .height(56)
        .padding({ left: 12, right: 12 })
        .backgroundColor(Color.White)
        .zIndex(100)

        // 底部分割线
        Divider().color(DIVIDER_COLOR).height(1).width('100%')
      }
      .width('100%')
      .margin({ top: 35 }) // 预留状态栏高度
      .backgroundColor(Color.White)
      .shadow({ radius: 2, color: 'rgba(0, 0, 0, 0.05)', offsetY: 2 })

      Column() {
        // 顶部选项卡
        Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
          TabContent() {
            this.buildHelpTab()
          }
          .tabBar('常见问题')
          
          TabContent() {
            this.buildFeedbackTab()
          }
          .tabBar('问题反馈')
        }
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
        .width('100%')
        .height('100%')
        .backgroundColor(BACKGROUND_COLOR)
        .barMode(BarMode.Fixed)
        .barHeight(50)
        .animationDuration(300)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildHelpTab() {
    Scroll() {
      Column() {
        // 搜索框
        Row() {
          Image($r('app.media.right'))
            .width(24)
            .height(24)
            .margin({ right: 8 })
          
          TextInput({ placeholder: '搜索常见问题' })
            .width('100%')
            .height(40)
            .backgroundColor(Color.Transparent)
            .placeholderColor(SECONDARY_TEXT_COLOR)
            .fontSize(16)
        }
        .width('95%')
        .height(50)
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .borderRadius(25)
        .margin({ top: 16, bottom: 16 })
        
        // 常见问题列表
        Column() {
          ForEach(this.faqItems, (item: FaqItem, index: number) => {
            Column() {
              Row() {
                Text(item.question)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(PRIMARY_TEXT_COLOR)
                  .width('85%')
                
                Image(item.expanded ? $r('app.media.right') : $r('app.media.right'))
                  .width(24)
                  .height(24)
                  .transform({ rotate: item.expanded ? 270 : 90 })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.toggleFaqItem(index);
              })
              
              if (item.expanded) {
                Text(item.answer)
                  .fontSize(14)
                  .fontColor(SECONDARY_TEXT_COLOR)
                  .width('100%')
                  .margin({ top: 8 })
                  .padding({ left: 8, right: 8 })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .margin({ bottom: 12 })
          })
          
          Button("查看更多问题")
            .width('95%')
            .height(40)
            .fontColor(ACCENT_COLOR)
            .backgroundColor(Color.Transparent)
            .margin({ top: 8, bottom: 20 })
            .border({ width: 1, color: ACCENT_COLOR, style: BorderStyle.Solid })
            .borderRadius(20)
            .onClick(() => {
              Prompt.showToast({ message: '更多问题将在后续版本中上线', duration: 2000 });
            })
          
          // 联系客服
          Column() {
            Text("无法解决您的问题？")
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_TEXT_COLOR)
              .margin({ bottom: 8 })
            
            Text("联系客服热线：400-123-4567")
              .fontSize(14)
              .fontColor(SECONDARY_TEXT_COLOR)
              .margin({ bottom: 8 })
            
            Text("服务时间：周一至周日 9:00-21:00")
              .fontSize(14)
              .fontColor(SECONDARY_TEXT_COLOR)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .margin({ bottom: 30 })
          
          Blank().height(this.overscrollOffset)
        }
        .width('95%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .edgeEffect(EdgeEffect.Spring)
    .onScrollEdge((edge: Edge) => {
      this.handleOverscroll(edge);
    })
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildFeedbackTab() {
    Scroll() {
      Column() {
        // 反馈说明
        Column() {
          Text("问题反馈")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
            .margin({ bottom: 8 })
          
          Text("您可以在这里向我们提交使用过程中遇到的问题或建议，我们会尽快处理并回复。")
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
        }
        .width('95%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ top: 16, bottom: 16 })
        
        // 反馈表单
        Column() {
          // 反馈类型选择
          Text("反馈类型")
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(PRIMARY_TEXT_COLOR)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          Row() {
            ForEach(this.feedbackTypes, (type: FeedbackType) => {
              Text(type.name)
                .fontSize(14)
                .fontColor(this.selectedFeedbackType === type.id ? Color.White : PRIMARY_TEXT_COLOR)
                .textAlign(TextAlign.Center)
                .backgroundColor(this.selectedFeedbackType === type.id ? ACCENT_COLOR : '#F0F0F0')
                .borderRadius(16)
                .width('22%')
                .height(32)
                .margin({ right: 8 })
                .onClick(() => {
                  this.selectedFeedbackType = type.id;
                })
            })
          }
          .width('100%')
          .margin({ bottom: 16 })
          
          // 反馈内容
          Text("反馈内容")
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(PRIMARY_TEXT_COLOR)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          TextArea({ placeholder: '请详细描述您遇到的问题或建议（最多500字）', text: this.feedbackContent })
            .width('100%')
            .height(150)
            .backgroundColor('#F5F5F5')
            .placeholderColor(SECONDARY_TEXT_COLOR)
            .borderRadius(8)
            .fontSize(14)
            .padding(12)
            .onChange((value: string) => {
              this.feedbackContent = value;
            })
            .margin({ bottom: 16 })
          
          // 联系方式
          Text("联系方式（选填）")
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(PRIMARY_TEXT_COLOR)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          TextInput({ placeholder: '请留下您的联系方式，方便我们回复', text: this.contactInfo })
            .width('100%')
            .height(45)
            .backgroundColor('#F5F5F5')
            .placeholderColor(SECONDARY_TEXT_COLOR)
            .borderRadius(8)
            .fontSize(14)
            .padding({ left: 12, right: 12 })
            .onChange((value: string) => {
              this.contactInfo = value;
            })
            .margin({ bottom: 24 })
          
          // 提交按钮
          Button(this.isSubmitting ? "提交中..." : "提交反馈")
            .width('100%')
            .height(45)
            .fontColor(Color.White)
            .backgroundColor(ACCENT_COLOR)
            .borderRadius(22)
            .enabled(!this.isSubmitting)
            .onClick(() => {
              this.submitFeedback();
            })
          
          Text("我们会在3个工作日内处理您的反馈")
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 16, bottom: 30 })
          
          Blank().height(this.overscrollOffset)
        }
        .width('95%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .margin({ bottom: 16 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .edgeEffect(EdgeEffect.Spring)
    .onScrollEdge((edge: Edge) => {
      this.handleOverscroll(edge);
    })
    .width('100%')
    .height('100%')
  }
  
  private handleOverscroll(edge: Edge) {
    if (edge === Edge.Bottom || edge === Edge.Top) {
      this.overscrollOffset = edge === Edge.Bottom ? -50 : 50;
      animateTo({
        duration: 600,
        curve: Curve.Friction,
        onFinish: () => {
          this.overscrollOffset = 0;
        }
      }, () => {
        this.overscrollOffset = 0;
      });
    }
  }
} 