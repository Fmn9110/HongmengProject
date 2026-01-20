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

// 设备类型接口
interface DeviceInfo {
  id: string;
  name: string;
  type: string;
  status: string;
  icon: Resource;
  isAuthorized: boolean;
  lastConnected: string;
}

@Entry
@Component
export default struct DeviceAuthPage {
  @State connectedDevices: DeviceInfo[] = [];
  @State historicalDevices: DeviceInfo[] = [];
  @State overscrollOffset: number = 0;
  @State isLoading: boolean = true;
  
  // 获取本地存储实例
  private context = getContext(this) as common.UIAbilityContext;
  private options: preferences.Options = { name: 'device_data' };
  private preference = preferences.getPreferencesSync(this.context, this.options);
  
  aboutToAppear() {
    // 模拟加载设备数据
    setTimeout(() => {
      this.loadDeviceData();
      this.isLoading = false;
    }, 1000);
  }
  
  // 加载设备数据
  private loadDeviceData() {
    // 从本地存储加载设备数据，如果没有则使用默认数据
    const savedConnectedDevices = this.preference.getSync('connected_devices', JSON.stringify([])) as string;
    const savedHistoricalDevices = this.preference.getSync('historical_devices', JSON.stringify([])) as string;
    
    try {
      const parsedConnected = JSON.parse(savedConnectedDevices) as DeviceInfo[];
      const parsedHistorical = JSON.parse(savedHistoricalDevices) as DeviceInfo[];
      
      if (parsedConnected.length > 0) {
        this.connectedDevices = parsedConnected;
      } else {
        // 默认已连接设备数据
        this.connectedDevices = [
          {
            id: '1',
            name: 'Smart Watch Pro',
            type: '智能手表',
            status: '已连接',
            icon: $r('app.media.device'),
            isAuthorized: true,
            lastConnected: '2023-09-25 10:30'
          },
          {
            id: '2',
            name: 'Health Monitor X1',
            type: '健康监测器',
            status: '已连接',
            icon: $r('app.media.device'),
            isAuthorized: true,
            lastConnected: '2023-09-24 14:15'
          }
        ];
        this.saveConnectedDevices();
      }
      
      if (parsedHistorical.length > 0) {
        this.historicalDevices = parsedHistorical;
      } else {
        // 默认历史设备数据
        this.historicalDevices = [
          {
            id: '3',
            name: 'Blood Pressure Monitor',
            type: '血压监测器',
            status: '已断开',
            icon: $r('app.media.device'),
            isAuthorized: false,
            lastConnected: '2023-08-15 09:20'
          },
          {
            id: '4',
            name: 'Smart Scale',
            type: '智能体重秤',
            status: '已断开',
            icon: $r('app.media.device'),
            isAuthorized: false,
            lastConnected: '2023-07-10 08:45'
          }
        ];
        this.saveHistoricalDevices();
      }
    } catch (error) {
      console.error('加载设备数据失败:', error);
      Prompt.showToast({ message: '加载设备数据失败', duration: 2000 });
    }
  }
  
  // 保存已连接设备数据
  private saveConnectedDevices() {
    try {
      this.preference.putSync('connected_devices', JSON.stringify(this.connectedDevices));
      this.preference.flushSync();
    } catch (error) {
      console.error('保存已连接设备数据失败:', error);
    }
  }
  
  // 保存历史设备数据
  private saveHistoricalDevices() {
    try {
      this.preference.putSync('historical_devices', JSON.stringify(this.historicalDevices));
      this.preference.flushSync();
    } catch (error) {
      console.error('保存历史设备数据失败:', error);
    }
  }
  
  // 更改设备授权状态
  private toggleAuthorization(device: DeviceInfo, isConnectedDevice: boolean) {
    device.isAuthorized = !device.isAuthorized;
    
    if (isConnectedDevice) {
      this.saveConnectedDevices();
    } else {
      this.saveHistoricalDevices();
    }
    
    Prompt.showToast({
      message: `${device.name} ${device.isAuthorized ? '已授权' : '已取消授权'}`,
      duration: 2000
    });
  }
  
  // 删除设备
  private deleteDevice(deviceId: string, isConnectedDevice: boolean) {
    Prompt.showDialog({
      title: '删除设备',
      message: '确定要删除此设备吗？',
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
          if (isConnectedDevice) {
            this.connectedDevices = this.connectedDevices.filter(device => device.id !== deviceId);
            this.saveConnectedDevices();
          } else {
            this.historicalDevices = this.historicalDevices.filter(device => device.id !== deviceId);
            this.saveHistoricalDevices();
          }
          Prompt.showToast({ message: '设备已删除', duration: 2000 });
        }
      }
    });
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
          Text('设备授权管理')
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
          Text('正在加载设备信息...')
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
            // 已连接设备部分
            this.buildDeviceSection("已连接的设备", this.connectedDevices, true)
            
            // 历史设备部分
            this.buildDeviceSection("历史连接设备", this.historicalDevices, false)
            
            // 扫描新设备按钮
            Button("扫描新设备")
              .width('90%')
              .height(50)
              .fontColor(Color.White)
              .backgroundColor(ACCENT_COLOR)
              .margin({ top: 30, bottom: 30 })
              .onClick(() => {
                this.scanNewDevices();
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
    }
    .width('100%')
    .height('100%')
  }
  
  // 扫描新设备的方法
  private scanNewDevices() {
    Prompt.showToast({ message: '正在扫描新设备...', duration: 2000 });
    // 这里是模拟扫描的逻辑，实际应用中应该连接到蓝牙或其他服务
    setTimeout(() => {
      Prompt.showToast({ message: '未发现新设备', duration: 2000 });
    }, 3000);
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
  buildDeviceSection(title: string, devices: DeviceInfo[], isConnectedDevice: boolean) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .width('100%')
        .padding({ left: 8, top: 16, bottom: 8 })
      
      if (devices.length > 0) {
        Column() {
          ForEach(devices, (device: DeviceInfo) => {
            this.buildDeviceItem(device, isConnectedDevice)
          })
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 16 })
      } else {
        Column() {
          Text('暂无设备')
            .fontSize(16)
            .fontColor(SECONDARY_TEXT_COLOR)
            .padding(16)
        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 16 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  @Builder
  buildDeviceItem(device: DeviceInfo, isConnectedDevice: boolean) {
    Column() {
      Row() {
        Image(device.icon)
          .width(50)
          .height(50)
          .margin({ right: 16 })
        
        Column() {
          Text(device.name)
            .fontSize(16)
            .fontColor(PRIMARY_TEXT_COLOR)
            .fontWeight(FontWeight.Medium)
          
          Text(`${device.type} | ${device.status}`)
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 4 })
          
          Text(`上次连接: ${device.lastConnected}`)
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      
      Row() {
        Button(device.isAuthorized ? '取消授权' : '授权')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(device.isAuthorized ? '#ff4d4d' : ACCENT_COLOR)
          .width(100)
          .height(36)
          .onClick(() => {
            this.toggleAuthorization(device, isConnectedDevice);
          })
        
        Blank()
        
        Button('删除')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .backgroundColor('#f0f0f0')
          .width(80)
          .height(36)
          .onClick(() => {
            this.deleteDevice(device.id, isConnectedDevice);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
      
      if (device !== undefined && device.id !== undefined) {
        if (isConnectedDevice) {
          if (this.connectedDevices.indexOf(device) !== this.connectedDevices.length - 1) {
            Divider()
              .color(DIVIDER_COLOR)
              .margin({ left: 16, right: 16 })
          }
        } else {
          if (this.historicalDevices.indexOf(device) !== this.historicalDevices.length - 1) {
            Divider()
              .color(DIVIDER_COLOR)
              .margin({ left: 16, right: 16 })
          }
        }
      }
    }
  }
} 