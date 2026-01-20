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

@Entry
@Component
export default struct SettingsPage {
  @State notificationEnabled: boolean = true;
  @State darkModeEnabled: boolean = false;
  @State fontSizeIndex: number = 1; // 0=小, 1=中, 2=大
  @State languageIndex: number = 0; // 0=简体中文, 1=繁体中文, 2=英语
  @State autoUpdateEnabled: boolean = true;
  @State dataSyncEnabled: boolean = true;
  @State overscrollOffset: number = 0;
  
  private fontSizeOptions: string[] = ['小', '中', '大'];
  private languageOptions: string[] = ['简体中文', '繁体中文', '英语'];
  
  // 存储设置的preferences实例
  private context = getContext(this) as common.UIAbilityContext;
  private options: preferences.Options = { name: 'app_settings' };
  private preference = preferences.getPreferencesSync(this.context, this.options);
  
  aboutToAppear() {
    // 从本地存储加载设置
    this.notificationEnabled = this.preference.getSync('notification_enabled', true) as boolean;
    this.darkModeEnabled = this.preference.getSync('dark_mode_enabled', false) as boolean;
    this.fontSizeIndex = this.preference.getSync('font_size_index', 1) as number;
    this.languageIndex = this.preference.getSync('language_index', 0) as number;
    this.autoUpdateEnabled = this.preference.getSync('auto_update_enabled', true) as boolean;
    this.dataSyncEnabled = this.preference.getSync('data_sync_enabled', true) as boolean;
  }
  
  // 保存设置到本地存储
  private saveSettings() {
    try {
      this.preference.putSync('notification_enabled', this.notificationEnabled);
      this.preference.putSync('dark_mode_enabled', this.darkModeEnabled);
      this.preference.putSync('font_size_index', this.fontSizeIndex);
      this.preference.putSync('language_index', this.languageIndex);
      this.preference.putSync('auto_update_enabled', this.autoUpdateEnabled);
      this.preference.putSync('data_sync_enabled', this.dataSyncEnabled);
      this.preference.flushSync();
      Prompt.showToast({ message: '设置已保存', duration: 2000 });
    } catch (error) {
      console.error('保存设置失败:', error);
      Prompt.showToast({ message: '保存设置失败', duration: 2000 });
    }
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
          Text('APP设置')
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

      Scroll() {
        Column() {
          Column() {
            Text("通知设置")
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(SECONDARY_TEXT_COLOR)
              .width('100%')
              .padding({ left: 16, top: 16, bottom: 8 })
            
            Column() {
              this.buildToggleSetting("接收通知", "控制是否接收应用推送通知", this.notificationEnabled, (val) => {
                this.notificationEnabled = val;
                this.saveSettings();
              })
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          
          Column() {
            Text("显示设置")
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(SECONDARY_TEXT_COLOR)
              .width('100%')
              .padding({ left: 16, top: 16, bottom: 8 })
            
            Column() {
              this.buildToggleSetting("深色模式", "开启后将使用深色主题", this.darkModeEnabled, (val) => {
                this.darkModeEnabled = val;
                this.saveSettings();
                // 实际应用中这里可能需要重新应用主题
              })
              
              this.buildSelectSetting("字体大小", this.fontSizeOptions[this.fontSizeIndex], () => {
                this.showFontSizeDialog();
              })
              
              this.buildSelectSetting("语言", this.languageOptions[this.languageIndex], () => {
                this.showLanguageDialog();
              })
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          
          Column() {
            Text("应用设置")
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(SECONDARY_TEXT_COLOR)
              .width('100%')
              .padding({ left: 16, top: 16, bottom: 8 })
            
            Column() {
              this.buildToggleSetting("自动更新", "应用将在WiFi环境下自动更新", this.autoUpdateEnabled, (val) => {
                this.autoUpdateEnabled = val;
                this.saveSettings();
              })
              
              this.buildToggleSetting("数据同步", "允许数据在云端同步", this.dataSyncEnabled, (val) => {
                this.dataSyncEnabled = val;
                this.saveSettings();
              })
              
              this.buildActionSetting("清除缓存", "清除应用产生的临时文件", () => {
                this.clearCache();
              })
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          
          Button("恢复默认设置")
            .width('90%')
            .height(50)
            .margin({ top: 30, bottom: 30 })
            .fontColor(ACCENT_COLOR)
            .backgroundColor(Color.White)
            .onClick(() => {
              this.resetSettings();
            })
            
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
  
  @Builder
  buildToggleSetting(title: string, description: string, checked: boolean, onChange: (val: boolean) => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor(PRIMARY_TEXT_COLOR)
        
        Text(description)
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      
      Blank()
      
      Toggle({ type: ToggleType.Switch, isOn: checked })
        .onChange(onChange)
    }
    .width('100%')
    .height(70)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 1 }, color: { bottom: DIVIDER_COLOR } })
  }
  
  @Builder
  buildSelectSetting(title: string, value: string, onClick: () => void) {
    Row() {
      Text(title)
        .fontSize(16)
        .fontColor(PRIMARY_TEXT_COLOR)
      
      Blank()
      
      Text(value)
        .fontSize(16)
        .fontColor(SECONDARY_TEXT_COLOR)
      
      Image($r('app.media.right'))
        .width(24)
        .height(24)
        .margin({ left: 4 })
    }
    .width('100%')
    .height(50)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 1 }, color: { bottom: DIVIDER_COLOR } })
    .onClick(onClick)
  }
  
  @Builder
  buildActionSetting(title: string, description: string, onClick: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor(PRIMARY_TEXT_COLOR)
        
        Text(description)
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      
      Blank()
      
      Image($r('app.media.right'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(70)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 1 }, color: { bottom: DIVIDER_COLOR } })
    .onClick(onClick)
  }
  
  // 显示字体大小选择对话框
  private showFontSizeDialog() {
    TextPickerDialog.show({
      range: this.fontSizeOptions,
      selected: this.fontSizeIndex,
      onAccept: (value: TextPickerResult) => {
        if (typeof value.index === 'number') {
          this.fontSizeIndex = value.index;
          this.saveSettings();
        }
      },
      onCancel: () => {
        console.log('字体大小选择已取消');
      }
    });
  }
  
  // 显示语言选择对话框
  private showLanguageDialog() {
    TextPickerDialog.show({
      range: this.languageOptions,
      selected: this.languageIndex,
      onAccept: (value: TextPickerResult) => {
        if (typeof value.index === 'number') {
          this.languageIndex = value.index;
          this.saveSettings();
        }
      },
      onCancel: () => {
        console.log('语言选择已取消');
      }
    });
  }
  
  // 清除缓存
  private clearCache() {
    // 在实际应用中，这里应该有清除缓存的逻辑
    Prompt.showDialog({
      title: '清除缓存',
      message: '确定要清除应用缓存吗？',
      buttons: [
        {
          text: '取消',
          color: '#666666',
        },
        {
          text: '确定',
          color: '#007DFF',
        }
      ],
      success: (result) => {
        if (result.index === 1) {
          // 清除缓存的具体操作
          setTimeout(() => {
            Prompt.showToast({ message: '缓存已清除', duration: 2000 });
          }, 1000);
        }
      }
    });
  }
  
  // 重置所有设置为默认值
  private resetSettings() {
    Prompt.showDialog({
      title: '恢复默认设置',
      message: '确定要将所有设置恢复为默认值吗？',
      buttons: [
        {
          text: '取消',
          color: '#666666',
        },
        {
          text: '确定',
          color: '#007DFF',
        }
      ],
      success: (result) => {
        if (result.index === 1) {
          this.notificationEnabled = true;
          this.darkModeEnabled = false;
          this.fontSizeIndex = 1;
          this.languageIndex = 0;
          this.autoUpdateEnabled = true;
          this.dataSyncEnabled = true;
          this.saveSettings();
        }
      }
    });
  }
} 