import { router } from "@kit.ArkUI";
import { Prompt, AlertDialog } from '@kit.ArkUI';
import { scanCore, scanBarcode } from '@kit.ScanKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import deviceInfo from '@ohos.deviceInfo';

const PRIMARY_TEXT_COLOR: string = '#000000';

// 定义扫码结果接口
interface ScanDeviceInfo {
  deviceId?: string;
  deviceName?: string;
  deviceType?: string;
  macAddress?: string;
  version?: string;
  rawResult?: string;
}

@Component
export struct Toolbar {
  @Prop title: string = '';

  @Builder
  defaultBuilder() {
    Text('默认值')
      .fontSize(16)
      .fontColor(PRIMARY_TEXT_COLOR)
  }

  @BuilderParam children: () => void = this.defaultBuilder;
  @State isMenuVisible: boolean = false; // 控制下拉菜单显示
  @State isScanning: boolean = false; // 控制扫描状态
  @State scanResult: string = ''; // 扫描结果
  @State errorMessage: string = ''; // 错误信息

  // 定义扫码参数选项
  private scanOptions: scanBarcode.ScanOptions = {
    scanTypes: [scanCore.ScanType.ALL],
    enableMultiMode: true,
    enableAlbum: true,
  };

  build() {
    Stack() {
      // 顶部栏及子内容
      Column() {
        // 顶部工具栏
        Column() {
          Row({ space: 10 }) {
            Text(this.title)
              .fontSize(28)
              .fontColor(PRIMARY_TEXT_COLOR)
              .padding({ top: 10, bottom: 10, left: 20 })
              .textAlign(TextAlign.Start)
              .borderRadius(10)
              .backgroundColor(Color.White)
            Blank()
            Image($r('app.media.ic_add'))
              .width(25)
              .height(25)
              .margin({ right: 20 })
              .onClick(() => {
                // 菜单弹出动画
                animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
                  this.isMenuVisible = !this.isMenuVisible;
                });
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .backgroundColor(Color.White)
        }
        .height(60)
        .width('100%')
        // 菜单弹出时模糊处理
        .blur(this.isMenuVisible ? 10 : 0)
        .backgroundColor(this.isMenuVisible ? 'rgba(255, 255, 255, 0.2)' : 'transparent')
        .shadow(this.isMenuVisible ? { radius: 5, color: 'rgba(0, 0, 0, 0.1)' } : { radius: 0 })

        // 子内容区域
        this.children()
      }
      .width('100%')
      .height('100%')
      .zIndex(10)

      // 毛玻璃遮罩层（菜单弹出时显示）
      if (this.isMenuVisible) {
        Column()
          .width('100%')
          .height('100%')
          .blur(10)
          .zIndex(15)
          .onClick(() => {
            // 点击遮罩关闭菜单
            animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
              this.isMenuVisible = false;
            });
          })
      }

      // 下拉菜单（菜单内容）
      if (this.isMenuVisible) {
        Column({ space: 8 }) {
          Text('添加设备')
            .fontSize(16)
            .fontColor(Color.Black)
            .padding({
              left: 16,
              right: 16,
              top: 8,
              bottom: 8
            })
            .backgroundColor(Color.White)
            .borderRadius(8)
          
          Text('扫一扫')
            .fontSize(16)
            .fontColor(Color.Black)
            .padding({
              left: 16,
              right: 16,
              top: 8,
              bottom: 8
            })
            .backgroundColor(Color.White)
            .borderRadius(8)
            .onClick(() => {
              animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
                this.isMenuVisible = false;
              });
              // 调用扫码功能
              this.startScan();
            })
        }
        .width('130')
        .position({ x: '100%', y: 50 })
        .translate({ x: -150 })
        .backgroundColor(Color.White)
        .shadow({ radius: 4, color: '#00000020' })
        .zIndex(20)
        .borderRadius(10)
      }
    }
    .width('100%')
    .height('100%')
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
}