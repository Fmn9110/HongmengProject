import { Toolbar } from '../../component/Toolbar';
import { Prompt, router, AlertDialog } from '@kit.ArkUI';
import http from '@ohos.net.http';
import util from '@ohos.util';
import { scanCore, scanBarcode } from '@kit.ScanKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import deviceInfo from '@ohos.deviceInfo';
import { ApiConfig, ApiParams } from '../../config/ApiConfig';


// 定义扫码结果接口
interface ScanDeviceInfo {
  deviceId?: string;
  deviceName?: string;
  deviceType?: string;
  macAddress?: string;
  version?: string;
  rawResult?: string;
}

// WiFi状态响应接口
interface WifiStatusResponse {
  wifi_status: string;
  device_id: string;
  lastSyncTime: number | null;
}

@Entry
@Preview
@Component
export default struct DevicePage {
  @State deviceList: Array<DeviceInfo> = [
    {
      id: 1,
      name: '开发板32',
      type: DeviceType.BAND,
      battery: 75,
      connected: false,
      lastSyncTime: '未同步'
    },
    {
      id: 2,
      name: '电子秤S1',
      type: DeviceType.SCALE,
      battery: 100,
      connected: false,
      lastSyncTime: '未同步'
    }
  ];
  @State currentIndex: number = 0;
  @State overscrollOffset: number = 0;
  @State scanResult: string = '';
  @State isScanning: boolean = false;
  @State errorMessage: string = '';
  @State opacities: number[] = [1, 0, 0]; // 每张图片的透明度
  private timerId: number = 0;
  private swiperImages: Resource[] = [
    $r('app.media.hands1'),
    $r('app.media.hands2'),
    $r('app.media.hands3')
  ];
  private readonly PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
  private readonly SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
  private readonly ACCENT_COLOR: ResourceColor = '#007DFF';
  private readonly LIGHT_BLUE: ResourceColor = '#fff6f8ff';
  private readonly DIVIDER_COLOR: ResourceColor = '#E5E5E5';
  // 定义扫码参数选项
  private scanOptions: scanBarcode.ScanOptions = {
    scanTypes: [scanCore.ScanType.ALL],
    enableMultiMode: true,
    enableAlbum: true,
  };

  build() {
    Column() {
      Toolbar({ title: '我的设备' }) {
        Scroll() {
          Column() {
            this.buildBanner()
            List({ space: 10 }) {
              ForEach(this.deviceList, (item: DeviceInfo) => {
                ListItem() {
                  this.buildDeviceItem(item)
                }
              })
              ListItem() {
                this.buildAddDeviceButton()
              }
            }
            .width('100%')
            .layoutWeight(1)
            .padding({ left: 8, right: 8 })
            .backgroundColor(this.LIGHT_BLUE)

            Blank()
              .height(this.overscrollOffset)
          }
          .width('100%')
          .height('100%')
        }
        .edgeEffect(EdgeEffect.Spring)
        .onScrollEdge((edge: Edge) => {
          this.handleOverscroll(edge)
        })
      }

      // 显示扫码结果
      if (this.scanResult) {
        Column() {
          Text('扫码结果：')
            .fontSize(16)
            .fontColor(this.PRIMARY_TEXT_COLOR)
            .width('100%')
            .padding(10)
          Text(this.scanResult)
            .fontSize(16)
            .fontColor(this.ACCENT_COLOR)
            .width('100%')
            .padding(10)
            .textAlign(TextAlign.Center)
        }
        .width('90%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin(10)
        .padding(10)
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
  buildBanner() {
    Stack() {
      Swiper() {
        ForEach(this.swiperImages, (image: Resource, index: number) => {
          Image(image)
            .width('35%')
            .height(200)
            .borderRadius('50%')
            .objectFit(ImageFit.Cover)
            .margin({ left: 8, right: 8 })
            .opacity(this.opacities[index] ?? 1) // 每张图片独立透明度
        })
      }
      .index(this.currentIndex)
      .autoPlay(true)
      .interval(3500) // 增加间隔，避免动画重叠
      .indicator(false)
      .loop(true)
      .cachedCount(this.swiperImages.length) // 缓存所有图片
      .onChange((newIndex: number) => {
        console.log('Swiper changing to index:', newIndex);
        // 保存当前透明度
        const prevIndex = this.currentIndex;
        // 更新索引
        this.currentIndex = newIndex;
        // 动画：当前图片淡出，下一张淡入
        animateTo({
          duration: 500,
          curve: Curve.EaseInOut,
          onFinish: () => {
            this.opacities[prevIndex] = 0;
            this.opacities[newIndex] = 1;
            console.log('Animation finished, opacities:', this.opacities);
          }
        }, () => {
          this.opacities[prevIndex] = 1; // 上一张淡出
          this.opacities[newIndex] = 1; // 当前张淡入
        });
      })
    }
    .height(200)
    .margin({ top: 12, bottom: 24 })
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({ radius: 4, color: '#00000020' })
  }

  @Builder
  buildDeviceItem(item: DeviceInfo) {
    Column() {
      Row() {
        Image(this.getDeviceIcon(item.type))
          .width(30)
          .height(30)
          .margin({ right: 16 })
        Column() {
          Row() {
            Text(item.name)
              .fontSize(18)
              .fontColor(this.PRIMARY_TEXT_COLOR)
            if (item.connected) {
              Text('已连接')
                .fontSize(12)
                .padding({
                  left: 8,
                  right: 8,
                  top: 2,
                  bottom: 2
                })
                .backgroundColor('#E8F5E9')
                .fontColor(this.ACCENT_COLOR)
                .borderRadius(10)
                .margin({ left: 10 })
            } else {
              Text('未连接')
                .fontSize(12)
                .padding({
                  left: 8,
                  right: 8,
                  top: 2,
                  bottom: 2
                })
                .backgroundColor('#E8F5E9')
                .fontColor('#fff11010')
                .borderRadius(10)
                .margin({ left: 10 })
            }
          }

          Text(`${item.battery}% 电量 | 最后同步：${item.lastSyncTime}`)
            .fontSize(14)
            .fontColor(this.SECONDARY_TEXT_COLOR)
        }
        .layoutWeight(1)

        Image($r('app.media.right'))
          .width(24)
          .height(24)
      }
      .padding(20)

      Divider()
        .strokeWidth(0.5)
        .color(this.DIVIDER_COLOR)
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({
      left: 8,
      right: 8,
      top: 10,
      bottom: 5
    })
    .shadow({ radius: 4, color: '#00000020' })
  }

  @Builder
  buildAddDeviceButton() {
    Column() {
      Row() {
        Button('扫一扫', { type: ButtonType.Normal })
          .width(150)
          .height(50)
          .borderRadius('50%')
          .backgroundColor('#ff98f3f3')
          .fontColor('#ff434141')
          .fontSize(16)
          .onClick(() => this.startScan())
          .margin({ right: 20 })
        Button('检测设备', { type: ButtonType.Normal })
          .width(150)
          .height(50)
          .borderRadius('50%')
          .backgroundColor('#ff6095f5')
          .fontColor(Color.White)
          .fontSize(16)
          .onClick(() => this.checkDeviceStatus())
      }
    }
    .width('100%')
    .padding(20)
    .borderRadius(12)
    .margin({ left: 8, right: 8, bottom: 16 })
    .shadow({ radius: 4, color: '#00000020' })
  }

  private getDeviceIcon(type: DeviceType): Resource {
    switch (type) {
      case DeviceType.BAND:
        return $r("app.media.hand_round");
      case DeviceType.SCALE:
        return $r('app.media.weight');
      default:
        return $r('app.media.run');
    }
  }

  // 开始扫码
  private startScan(): void {
    this.isScanning = true;
    this.errorMessage = '';
    this.scanResult = '';

    if (this.isEmulator()) {
      this.isScanning = false;
      this.scanResult = '模拟器测试数据: 123456789';
      Prompt.showToast({ message: '模拟器模式: 使用假数据', duration: 2000 });
      return;
    }

    try {
      scanBarcode.startScan(this.scanOptions, (error: BusinessError | null, result: scanBarcode.ScanResult | null) => {
        this.isScanning = false;
        if (error) {
          hilog.error(0x0001, '[Scan Sample]',
            `Failed to get ScanResult. Code: ${error.code}, message: ${error.message}`);
          this.errorMessage = `扫码失败: ${error.message}`;
          Prompt.showToast({ message: this.errorMessage, duration: 2000 });
          return;
        }
        if (result) {
          hilog.info(0x0001, '[Scan Sample]', `Succeeded in getting ScanResult, result is ${JSON.stringify(result)}`);
          try {
            this.scanResult = JSON.stringify(result) || '无内容';
            Prompt.showToast({ message: '扫码成功', duration: 2000 });

            // 处理扫码结果，例如添加设备
            this.handleScanResult(this.scanResult);
          } catch (e) {
            this.scanResult = '无法解析扫码结果';
          }
        } else {
          this.errorMessage = '未获取到扫码结果';
          Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        }
      });
    } catch (error) {
      this.isScanning = false;
      const businessError = error as BusinessError;
      hilog.error(0x0001, '[Scan Sample]',
        `Failed to startScan. Code: ${businessError.code}, message: ${businessError.message}`);
      this.errorMessage = `启动扫码失败: ${businessError.message}`;
      Prompt.showToast({ message: this.errorMessage, duration: 2000 });
    }
  }

  // 处理扫码结果
  private handleScanResult(result: string): void {
    // 这里可以添加解析二维码内容、添加设备等逻辑
    console.info('扫码结果处理:', result);

    // 示例：解析JSON格式的设备信息
    try {
      const deviceData: ScanDeviceInfo = JSON.parse(result);
      if (deviceData.deviceId) {
        console.info('检测到设备ID:', deviceData.deviceId);

        // 显示扫码结果弹窗
        this.showScanResultDialog(deviceData);
      } else {
        // 如果不是标准格式的设备信息，直接显示原始结果
        const rawData: ScanDeviceInfo = { rawResult: result };
        this.showScanResultDialog(rawData);
      }
    } catch (e) {
      console.error('解析扫码结果失败:', e);
      // 解析失败时也显示原始结果
      const rawData: ScanDeviceInfo = { rawResult: result };
      this.showScanResultDialog(rawData);
    }
  }

  // 显示扫码结果弹窗
  private showScanResultDialog(data: ScanDeviceInfo): void {
    // 格式化显示内容
    let dialogContent = '';

    if (data.deviceId) {
      dialogContent = `设备ID: ${data.deviceId}\n`;
      if (data.deviceName) {
        dialogContent += `设备名称: ${data.deviceName}\n`;
      }
      if (data.deviceType) {
        dialogContent += `设备类型: ${data.deviceType}\n`;
      }
      if (data.macAddress) {
        dialogContent += `MAC地址: ${data.macAddress}\n`;
      }
      if (data.version) {
        dialogContent += `版本: ${data.version}\n`;
      }
    } else if (data.rawResult) {
      // 显示原始扫码结果
      dialogContent = `扫码内容:\n${data.rawResult}`;
    }

    // 显示弹窗
    this.getUIContext().showAlertDialog(
      {
        title: '扫码结果',
        message: dialogContent,
        autoCancel: true,
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: -20 },
        backgroundColor: Color.White,
        confirm: {
          value: '确定',
          action: () => {
            console.info('关闭扫码结果弹窗');
          }
        },
        cancel: () => {
          console.info('取消操作');
        }
      }
    )
  }

  // 判断是否是模拟器
  private isEmulator(): boolean {
    const deviceType = deviceInfo.deviceType;
    return deviceType === 'emulator' || deviceInfo.manufacture.toLowerCase().includes('emulator');
  }

  private async checkDeviceStatus(): Promise<void> {
    try {
      this.isScanning = true;
      this.errorMessage = '';
      Prompt.showToast({ message: '正在检测设备...', duration: 1000 });
      const httpRequest = http.createHttp();
      const url = ApiConfig.buildUrlWithParams(ApiConfig.WIFI_STATUS, { 'device_id': 'qqq001' } as Record<string, string>);
      const response: http.HttpResponse =
        await httpRequest.request(url, {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        });
      console.log('HTTP Response:', JSON.stringify({
        responseCode: response.responseCode,
        resultType: typeof response.result,
        resultLength: response.result && typeof response.result === 'string' ? response.result.length :
          (response.result ? (response.result as ArrayBuffer).byteLength : 0)
      }));
      if (response.responseCode !== 200) {
        throw new Error(`HTTP错误，状态码：${response.responseCode}`);
      }
      if (!response.result) {
        throw new Error('Response result is empty');
      }
      let jsonString: string;
      if (typeof response.result === 'string') {
        jsonString = response.result;
      } else if (response.result instanceof ArrayBuffer) {
        const uint8Array = new Uint8Array(response.result);
        const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
        jsonString = textDecoder.decodeWithStream(uint8Array);
      } else if (response.result instanceof Uint8Array) {
        const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
        jsonString = textDecoder.decodeWithStream(response.result);
      } else {
        throw new Error(`Unexpected response.result type: ${typeof response.result}`);
      }
      console.log('Received JSON:', jsonString);
      const data: WifiStatusResponse = this.parseJson(jsonString);
      const wifiStatus: string = data.wifi_status;
      const newSyncTime: string = this.formatSyncTime(data.lastSyncTime);
      const updatedDeviceList: Array<DeviceInfo> = [];
      for (let i = 0; i < this.deviceList.length; i++) {
        const device = this.deviceList[i];
        if (device.id === 1) {
          const updatedDevice = new DeviceInfo();
          updatedDevice.id = device.id;
          updatedDevice.name = device.name;
          updatedDevice.type = device.type;
          updatedDevice.battery = device.battery;
          updatedDevice.connected = wifiStatus === 'connected';
          updatedDevice.lastSyncTime = wifiStatus === 'connected' ? newSyncTime : device.lastSyncTime;
          updatedDeviceList.push(updatedDevice);
        } else {
          updatedDeviceList.push(device);
        }
      }
      this.deviceList = updatedDeviceList;
      console.log('Updated deviceList:', JSON.stringify(this.deviceList));
      Prompt.showToast({
        message: `设备状态：${wifiStatus === 'connected' ? '已连接' : '未连接'}`,
        duration: 2000
      });
    } catch (error) {
      const err = error as Error;
      this.errorMessage = '检测设备失败：' + err.message;
      Prompt.showToast({ message: this.errorMessage, duration: 3000 });
      console.error('Error in checkDeviceStatus:', err.message);
    } finally {
      this.isScanning = false;
    }
  }

  private formatSyncTime(timestamp: number | null): string {
    if (timestamp === null) {
      return '未同步';
    }
    const syncDate = new Date(timestamp);
    const now = new Date();
    const isToday = syncDate.getFullYear() === now.getFullYear() &&
      syncDate.getMonth() === now.getMonth() &&
      syncDate.getDate() === now.getDate();
    const hours = String(syncDate.getHours()).padStart(2, '0');
    const minutes = String(syncDate.getMinutes()).padStart(2, '0');
    const seconds = String(syncDate.getSeconds()).padStart(2, '0');
    if (isToday) {
      return `今天 ${hours}:${minutes}`;
    }
    const year = syncDate.getFullYear();
    const month = String(syncDate.getMonth() + 1).padStart(2, '0');
    const day = String(syncDate.getDate()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  private parseJson(jsonString: string): WifiStatusResponse {
    const result: WifiStatusResponse = {
      wifi_status: 'disconnected',
      device_id: 'qqq001',
      lastSyncTime: null
    };
    if (!jsonString || typeof jsonString !== 'string') {
      console.error('Invalid JSON string:', jsonString);
      return result;
    }
    const trimmed = jsonString.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) {
      console.error('JSON format invalid:', trimmed);
      return result;
    }
    try {
      const pairs = trimmed.slice(1, -1).split(',').map(pair => pair.trim()).filter(pair => pair);
      for (const pair of pairs) {
        const parts = pair.split(':');
        if (parts.length < 2) {
          console.warn('Skipping invalid pair:', pair);
          continue;
        }
        const key = parts[0].trim();
        const value = parts.slice(1).join(':').trim();
        if (key === '"wifi_status"') {
          result.wifi_status = value.replace(/"/g, '');
        } else if (key === '"device_id"') {
          result.device_id = value.replace(/"/g, '');
        } else if (key === '"lastSyncTime"') {
          result.lastSyncTime = value === 'null' ? null : Number(value);
        }
      }
    } catch (e) {
      console.error('Error parsing JSON:', e.message, 'Input:', jsonString);
    }
    console.log('Parsed JSON result:', JSON.stringify(result));
    return result;
  }

  private startBluetoothConnection() {
    // TODO: 实现蓝牙搜索逻辑
  }
}

enum DeviceType {
  BAND,
  SCALE,
  OTHER
}

class DeviceInfo {
  id: number = 0;
  name: string = '';
  type: DeviceType = DeviceType.OTHER;
  battery: number = 0;
  connected: boolean = false;
  lastSyncTime: string = '未同步';
}