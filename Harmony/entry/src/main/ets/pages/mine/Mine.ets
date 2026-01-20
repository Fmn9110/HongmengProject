import http from '@ohos.net.http';
import { Toolbar } from "../../component/Toolbar";
import { preferences } from "@kit.ArkData";
import { common } from "@kit.AbilityKit";
import { router, Prompt } from '@kit.ArkUI';
import { globalState } from '../../component/HW_user';
import { FloatBall } from '../../component/Float';
import { globalStates } from '../../component/global';
import { ApiConfig } from '../../config/ApiConfig';

// 定义颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const LIGHT_BLUE: ResourceColor = '#fff6f8ff';
const DIVIDER_COLOR: ResourceColor = '#E5E5E5';

const context = getContext(this) as common.UIAbilityContext;
const options: preferences.Options = { name: 'userInfo' };
const preference = preferences.getPreferencesSync(context, options);

// 积分接口返回数据格式
interface checkInHistory {
  date: string;
  points: number;
}

interface PointsResponse {
  totalPoints: number;
  checkInHistory: checkInHistory[];
}

// 我的页面主组件
@Entry
@Preview
@Component
export default struct mine {
  @State isVip: boolean = false;
  @State overscrollOffset: number = 0;
  @State totalPoints: number = 0;
  @State refreshing: boolean = false;
  @State savedPhone: string = preference.getSync('phone', '未登录') as string;
  @State floatBallVisible: boolean = true;
  private unsubscribe?: () => void;

  async aboutToAppear() {
    this.savedPhone = preference.getSync('phone', '未登录') as string;
    this.isVip = globalStates.isVip; // Initial sync
    console.log('aboutToAppear: isVip =', this.isVip, 'at:', new Date().toISOString());
    // Subscribe to isVip changes
    this.unsubscribe = globalStates.onIsVipChange((isVip: boolean) => {
      this.isVip = isVip;
      console.log('mine: isVip updated to', isVip, 'at:', new Date().toISOString());
    });
    await this.fetchPoints();
  }

  aboutToDisappear() {
    // Unsubscribe to prevent memory leaks
    if (this.unsubscribe) {
      this.unsubscribe();
      this.unsubscribe = undefined;
      console.log('mine: Unsubscribed from isVip changes', 'at:', new Date().toISOString());
    }
  }

  async onPageShow() {
    this.savedPhone = preference.getSync('phone', '未登录') as string;
    this.isVip = globalState.isVip; // Sync for safety
    console.log('onPageShow: isVip =', this.isVip); // 添加日志
    await this.fetchPoints();
  }

  async fetchPoints() {
    try {
      if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
        this.totalPoints = 0;
        return;
      }
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(ApiConfig.POINTS, {
        method: http.RequestMethod.GET,
        header: { 'Authorization': `Bearer ${globalState.JWTtoken}` }
      });
      const data: PointsResponse = JSON.parse(response.result.toString());
      this.totalPoints = data.totalPoints ?? 0;
    } catch (error) {
      Prompt.showToast({ message: '获取积分失败', duration: 2000 });
      this.totalPoints = 0;
    } finally {
      this.refreshing = false;
    }
  }

  private getTodayDate(): string {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  build() {
    Column() {
      FloatBall({ isVisible: $floatBallVisible })
      Toolbar({ title: '我的' }) {
        Refresh({ refreshing: this.refreshing, offset: 50, friction: 0.6 }) {
          Scroll() {
            Column() {
              this.buildUserInfo()
              Grid() {
                GridItem() {
                  this.buildFunctionEntry($r('app.media.run'), "运动推荐")
                }
                .onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/childpages/exercisepage/ExerciseRecommendationPage' });
                })

                GridItem() {
                  this.buildFunctionEntry($r('app.media.heart_rate'), "心率")
                }.onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/childpages/heartratepage/HeartRatePage' });
                })

                GridItem() {
                  this.buildFunctionEntry($r('app.media.sleep'), "睡眠")
                }.onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/childpages/sleeptimepage/SleepTimePage' });
                })

                GridItem() {
                  this.buildFunctionEntry($r('app.media.food'), "餐饮管理") // 新增餐饮管理入口
                }
                .onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/foodmanagementpage/FoodManagementPage' });
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .margin({
                left: 8,
                right: 8,
                top: 12,
                bottom: 12
              })
              .height(100)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .shadow({ radius: 4, color: '#00000020' })

              this.buildHealthDataCard()
              this.buildPointsDataCard()

              Column() {
                Row() {
                  this.buildSettingItem($r('app.media.seting'), "APP设置")
                }
                .onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/childpages/settingspage/SettingsPage' });
                })

                Row() {
                  this.buildSettingItem($r("app.media.medical"), "既往病史")
                }
                .width('100%')
                .onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/childpages/medicalhistorypage/MedicalHistoryPage' });
                  console.log('导航到既往病史页面');
                })

                Row() {
                  this.buildSettingItem($r('app.media.device'), "设备授权管理")
                }
                .onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/childpages/deviceauthpage/DeviceAuthPage' });
                })

                Row() {
                  this.buildSettingItem($r('app.media.lock'), "系统权限")
                }
                .onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/childpages/syspermissionpage/SysPermissionPage' });
                })

                Row() {
                  this.buildSettingItem($r('app.media.help'), "帮助与反馈")
                }
                .onClick(() => {
                  router.pushUrl({ url: 'pages/childpages/helpfeedbackpage/HelpFeedbackPage' });
                })

                Row() {
                  this.buildSettingItem($r('app.media.share'), "设备共享")
                }
                .onClick(() => {
                  if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
                    Prompt.showToast({ message: '请先登录', duration: 2000 });
                    router.pushUrl({ url: 'pages/Login' });
                    return;
                  }
                  router.pushUrl({ url: 'pages/childpages/devicesharepage/DeviceSharePage' });
                })

                Row() {
                  this.buildSettingItem($r('app.media.about'), "关于")
                }
                .onClick(() => {
                  router.pushUrl({ url: 'pages/childpages/aboutpage/AboutPage' });
                })
              }
              .height('65%')
              .borderRadius(12)
              .width('94%')
              .backgroundColor(Color.White)
              .padding(16)

              Blank().height(this.overscrollOffset)
            }
            .width('100%')
            .backgroundColor(LIGHT_BLUE)
            .padding({ left: 8, right: 8 })
          }
          .edgeEffect(EdgeEffect.Spring)
          .onScrollEdge((edge: Edge) => {
            this.handleOverscroll(edge);
          })
        }
        .onRefreshing(() => {
          this.refreshing = true;
          this.fetchPoints();
          this.floatBallVisible = true;
        })
      }
    }
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

  @Builder
  buildUserInfo() {
    Column() {
      Row() {
        Image($r('app.media.adiminIcon'))
          .width(60)
          .height(60)
          .borderRadius(30)
          .margin({ right: 16 })

        Column({ space: 7 }) {
          Row() {
            Text(this.savedPhone === '未登录' ? '未登录' : `${this.savedPhone}`)
              .fontSize(18)
              .fontColor(PRIMARY_TEXT_COLOR)
              .fontWeight(FontWeight.Bold)
              .margin({ right: 5 })
            // 条件渲染 VIP 图标
            Row() {
              Image(this.isVip ? $r('app.media.vip_3') : $r('app.media.vip_2'))
                .width(25)
            }
            .width(this.isVip ? 40 : 40)
            .height(this.isVip ? 15 : 15)
            .linearGradient({
              direction: GradientDirection.LeftBottom,
              colors: this.isVip ? [['#ffa7a7', 0.0], ['#f51919', 1]] : [['transparent', 0.0], ['transparent', 1]]
            })
            .justifyContent(FlexAlign.Center)
            .borderRadius(this.isVip ? 15 : 0)
            .zIndex(this.isVip ? 10 : 0)
          }

          Text("男 | 178厘米 | 20岁")
            .fontSize(15)
            .fontColor(SECONDARY_TEXT_COLOR)
        }
        .alignItems(HorizontalAlign.Start)
        .width('50%')

        if (this.savedPhone !== '未登录') {
          Button('退出登录', { type: ButtonType.Normal })
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor(ACCENT_COLOR)
            .padding({
              left: 12,
              right: 12,
              top: 6,
              bottom: 6
            })
            .margin({ left: 10 })
            .borderRadius(16)
            .onClick(() => {
              preference.deleteSync('phone');
              preference.deleteSync('JWTtoken');
              preference.deleteSync('userId');
              preference.deleteSync('refreshToken');
              preference.flushSync();
              globalState.userId = null;
              globalState.JWTtoken = null;
              globalStates.emitIsVipChange(false);

              // 清除用户数据
              globalState.clearUserData();

              // 清除医疗记录持久化数据
              this.clearMedicalRecordsData();

              Prompt.showToast({ message: '已退出登录', duration: 2000 });
              router.pushUrl({ url: 'pages/Login' });
            })
        }
      }
      .padding(16)
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .margin({ left: 8, right: 8, top: 12 })
    .shadow({ radius: 4, color: '#00000020' })
  }

  @Builder
  buildFunctionEntry(icon: Resource, text: string) {
    Column() {
      Image(icon)
        .width(30)
        .height(30)
        .margin({ bottom: 8 })
      Text(text)
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildHealthDataCard() {
    Column() {
      Row() {
        Text("今日健康数据")
          .fontSize(20)
          .fontColor(PRIMARY_TEXT_COLOR)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text("更多数据 >")
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .onClick(() => {
            if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
              Prompt.showToast({ message: '请先登录', duration: 2000 });
              router.pushUrl({ url: 'pages/Login' });
              return;
            }
            const today = this.getTodayDate();
            router.pushUrl({
              url: 'pages/showhistory/showHistory',
              params: { startDate: today, endDate: today }
            });
          })
      }.width('100%')

      Divider().color(DIVIDER_COLOR).margin(8)

      Row({ space: 12 }) {
        this.buildHealthDataItem("8263", "步数")
        this.buildHealthDataItem("78", "平均心率")
        this.buildHealthDataItem("7.2h", "睡眠")
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding(16)
    .margin({
      left: 8,
      right: 8,
      top: 12,
      bottom: 12
    })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#00000020' })
  }

  @Builder
  buildHealthDataItem(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontColor(ACCENT_COLOR)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 5 })
      Text(label)
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
    }
  }

  @Builder
  buildPointsDataCard() {
    Column() {
      Row() {
        Text() {
          Span("我的积分：")
            .fontSize(20)
            .fontColor(PRIMARY_TEXT_COLOR)
            .fontWeight(FontWeight.Bold)
          Span(`${this.totalPoints}币`)
            .fontSize(24)
            .fontColor(ACCENT_COLOR)
        }

        Blank()
        Text('每日签到 >')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .padding(10)
          .onClick(() => {
            if (this.savedPhone === '未登录' || !globalState.JWTtoken) {
              Prompt.showToast({ message: '请先登录', duration: 2000 });
              router.pushUrl({ url: 'pages/Login' });
              return;
            }
            router.pushUrl({ url: 'pages/checkInpage/CheckInPage' });
          })
      }.width('100%')

      Divider().color(DIVIDER_COLOR).margin(8)

      Row({ space: 12 }) {
        this.buildPointsDataItem($r('app.media.award1'), "老年运动鞋", "1200币")
        this.buildPointsDataItem($r('app.media.award2'), "老花眼镜", "2000币")
        this.buildPointsDataItem($r('app.media.award3'), "清新盆栽", "1000币")
        this.buildPointsDataItem($r('app.media.award4'), "保温杯", "1500币")
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding(16)
    .margin({
      left: 8,
      right: 8,
      top: 12,
      bottom: 12
    })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#00000020' })
  }

  @Builder
  buildPointsDataItem(icon: Resource, name: string, price: string) {
    Column() {
      Image(icon)
        .width(60)
        .height(60)
        .borderRadius(10)
        .margin({ bottom: 5 })
      Text(name)
        .fontSize(12)
        .fontColor(PRIMARY_TEXT_COLOR)
      Text(price)
        .fontSize(14)
        .fontColor(ACCENT_COLOR)
    }
  }

  @Builder
  buildSettingItem(icon: Resource, text: string) {
    Row() {
      Image(icon)
        .width(23)
        .height(23)
        .margin({ right: 16 })
      Text(text)
        .fontSize(16)
        .fontColor(PRIMARY_TEXT_COLOR)
      Blank()
      Image($r('app.media.right'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .padding(12)
  }

  // 清除医疗记录持久化数据
  private async clearMedicalRecordsData() {
    try {
      // 动态导入，避免循环依赖
      const preferencesModule = await import('@kit.ArkData');
      const context = getContext(this) as common.UIAbilityContext;
      const options: preferences.Options = { name: 'health_data' };
      const pref = preferencesModule.preferences.getPreferencesSync(context, options);
      pref.deleteSync('medical_records');
      pref.flushSync();
      console.log('医疗记录持久化数据已清除');
    } catch (error) {
      console.error(`清除医疗记录持久化数据失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
}