import { Toolbar } from "../../../component/Toolbar";
import { router, Prompt } from '@kit.ArkUI';
import { preferences } from "@kit.ArkData";
import { common } from "@kit.AbilityKit";
import bundleManager from '@ohos.bundle.bundleManager';

// 定义颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const BACKGROUND_COLOR: ResourceColor = '#F5F5F5';
const DIVIDER_COLOR: ResourceColor = '#E5E5E5';

@Entry
@Component
export default struct AboutPage {
  @State appVersion: string = '1.0.0';
  @State buildNumber: string = '100';
  @State overscrollOffset: number = 0;
  @State isLoading: boolean = true;
  @State clickCount: number = 0;
  @State showDevMode: boolean = false;
  
  aboutToAppear() {
    // 获取应用版本信息
    this.getAppVersion();
    
    // 检查开发者模式状态
    this.checkDevModeStatus();
  }
  
  // 获取应用版本信息
  private async getAppVersion() {
    try {
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      this.appVersion = bundleInfo.versionName || '1.0.0';
      this.buildNumber = bundleInfo.versionCode ? bundleInfo.versionCode.toString() : '100';
      this.isLoading = false;
    } catch (error) {
      console.error('获取应用版本信息失败:', error);
      this.isLoading = false;
    }
  }
  
  // 检查开发者模式状态
  private checkDevModeStatus() {
    const context = getContext(this) as common.UIAbilityContext;
    const options: preferences.Options = { name: 'app_settings' };
    const preference = preferences.getPreferencesSync(context, options);
    this.showDevMode = preference.getSync('dev_mode_enabled', false) as boolean;
  }
  
  // 切换开发者模式
  private toggleDevMode() {
    this.clickCount++;
    if (this.clickCount >= 7 && !this.showDevMode) {
      const context = getContext(this) as common.UIAbilityContext;
      const options: preferences.Options = { name: 'app_settings' };
      const preference = preferences.getPreferencesSync(context, options);
      
      this.showDevMode = true;
      preference.putSync('dev_mode_enabled', true);
      preference.flushSync();
      
      Prompt.showToast({ message: '开发者模式已启用', duration: 2000 });
    }
  }
  
  // 检查更新
  private checkUpdate() {
    Prompt.showToast({ message: '正在检查更新...', duration: 2000 });
    
    // 模拟检查更新
    setTimeout(() => {
      Prompt.showToast({ message: '已是最新版本', duration: 2000 });
    }, 1500);
  }
  
  // 重置点击计数器
  private resetClickCounter() {
    setTimeout(() => {
      if (this.clickCount > 0 && this.clickCount < 7) {
        this.clickCount = 0;
      }
    }, 3000);
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
          Text('关于')
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

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(ACCENT_COLOR)
          Text('正在加载应用信息...')
            .fontSize(16)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 应用信息
            Column() {
              Image($r('app.media.startIcon'))
                .width(100)
                .height(100)
                .margin({ top: 20, bottom: 16 })
                .onClick(() => {
                  this.toggleDevMode();
                  this.resetClickCounter();
                })
              
              Text("慢宁康")
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(PRIMARY_TEXT_COLOR)
              
              Text(`版本 ${this.appVersion} (Build ${this.buildNumber})`)
                .fontSize(16)
                .fontColor(SECONDARY_TEXT_COLOR)
                .margin({ top: 8, bottom: 20 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            
            // 版本信息
            Column() {
              this.buildInfoItem("检查更新", () => {
                this.checkUpdate();
              })
              
              this.buildInfoItem("隐私政策", () => {
                router.pushUrl({ url: 'pages/childpages/privacypage/PrivacyPolicyPage' });
              })
              
              this.buildInfoItem("用户协议", () => {
                router.pushUrl({ url: 'pages/childpages/termspage/TermsOfServicePage' });
              })
              
              this.buildInfoItem("开源许可", () => {
                router.pushUrl({ url: 'pages/childpages/licensepage/OpenSourceLicensePage' });
              })
            }
            .width('95%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ top: 16, bottom: 16 })
            
            // 开发者选项（仅在开发者模式下显示）
            if (this.showDevMode) {
              Column() {
                Text("开发者选项")
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(PRIMARY_TEXT_COLOR)
                  .width('100%')
                  .padding({ left: 16, top: 16, bottom: 8 })
                
                Divider().color(DIVIDER_COLOR).margin({ left: 16, right: 16 })
                
                this.buildInfoItem("清除所有数据", () => {
                  this.resetAllData();
                })
                
                this.buildInfoItem("导出日志", () => {
                  this.exportLogs();
                })
                
                this.buildInfoItem("关闭开发者模式", () => {
                  this.disableDevMode();
                })
              }
              .width('95%')
              .backgroundColor(Color.White)
              .borderRadius(12)
              .margin({ bottom: 16 })
            }
            
            // 版权信息
            Column() {
              Text("© 2025 慢宁康项目团队")
                .fontSize(14)
                .fontColor(SECONDARY_TEXT_COLOR)
                .margin({ bottom: 8 })
              
              Text("保留所有权利")
                .fontSize(14)
                .fontColor(SECONDARY_TEXT_COLOR)
                .margin({ bottom: 30 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .margin({ top: 20 })
            
            Blank().height(this.overscrollOffset)
          }
          .width('100%')
          .padding(15)
          .backgroundColor(BACKGROUND_COLOR)
        }
        .edgeEffect(EdgeEffect.Spring)
        .onScrollEdge((edge: Edge) => {
          this.handleOverscroll(edge);
        })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildInfoItem(text: string, onClick: () => void) {
    Row() {
      Text(text)
        .fontSize(16)
        .fontColor(PRIMARY_TEXT_COLOR)
      
      Blank()
      
      Image($r('app.media.right'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .padding(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 1 }, color: { bottom: DIVIDER_COLOR } })
    .onClick(onClick)
  }
  
  // 清除所有数据
  private resetAllData() {
    Prompt.showDialog({
      title: '清除所有数据',
      message: '此操作将清除应用所有数据，包括用户信息、健康记录等，确定要继续吗？',
      buttons: [
        {
          text: '取消',
          color: '#666666',
        },
        {
          text: '确定',
          color: '#FF3B30',
        }
      ],
      success: (result) => {
        if (result.index === 1) {
          const context = getContext(this) as common.UIAbilityContext;
          
          // 清除用户数据
          try {
            const userOptions: preferences.Options = { name: 'userInfo' };
            const userPref = preferences.getPreferencesSync(context, userOptions);
            userPref.clearSync();
            userPref.flushSync();
          } catch (error) {
            console.error('清除用户数据失败:', error);
          }
          
          // 清除健康数据
          try {
            const healthOptions: preferences.Options = { name: 'health_data' };
            const healthPref = preferences.getPreferencesSync(context, healthOptions);
            healthPref.clearSync();
            healthPref.flushSync();
          } catch (error) {
            console.error('清除健康数据失败:', error);
          }
          
          // 清除设备数据
          try {
            const deviceOptions: preferences.Options = { name: 'device_data' };
            const devicePref = preferences.getPreferencesSync(context, deviceOptions);
            devicePref.clearSync();
            devicePref.flushSync();
          } catch (error) {
            console.error('清除设备数据失败:', error);
          }
          
          // 清除设置数据
          try {
            const settingsOptions: preferences.Options = { name: 'app_settings' };
            const settingsPref = preferences.getPreferencesSync(context, settingsOptions);
            settingsPref.clearSync();
            settingsPref.flushSync();
            
            // 保留开发者模式设置
            settingsPref.putSync('dev_mode_enabled', true);
            settingsPref.flushSync();
          } catch (error) {
            console.error('清除设置数据失败:', error);
          }
          
          Prompt.showToast({ message: '所有数据已清除', duration: 2000 });
          
          // 延迟返回主页
          setTimeout(() => {
            router.replaceUrl({ url: 'pages/index/Index' });
          }, 2000);
        }
      }
    });
  }
  
  // 导出日志
  private exportLogs() {
    Prompt.showToast({ message: '正在导出日志文件...', duration: 2000 });
    
    // 模拟导出操作
    setTimeout(() => {
      Prompt.showToast({ message: '日志文件已导出至/Documents/logs/', duration: 2000 });
    }, 1500);
  }
  
  // 关闭开发者模式
  private disableDevMode() {
    const context = getContext(this) as common.UIAbilityContext;
    const options: preferences.Options = { name: 'app_settings' };
    const preference = preferences.getPreferencesSync(context, options);
    
    this.showDevMode = false;
    preference.putSync('dev_mode_enabled', false);
    preference.flushSync();
    this.clickCount = 0;
    
    Prompt.showToast({ message: '开发者模式已关闭', duration: 2000 });
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