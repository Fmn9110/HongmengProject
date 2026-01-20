import { Toolbar } from '../../component/Toolbar';
import { router } from '@kit.ArkUI';
import http from '@ohos.net.http';
import { BusinessError } from '@kit.BasicServicesKit';
import { globalState } from '../../component/HW_user';
import HW_User from '../../component/HW_user';
// 导入健康警告服务
import { healthAlertService } from '../../component/HealthAlert';
// 导入简单警告服务
import { simpleAlertService } from '../../component/SimpleAlert';
import { ApiConfig } from '../../config/ApiConfig';

// 设备属性接口
interface DeviceProperties {
  HeartRate: string;
  Temperature: string;
  BloodOxygen: string;
  RespiratoryRate: string;
  State: string;
}

const IMAGE_AREA_WIDTH: number = 180;
const IMAGE_AREA_HEIGHT: number = 300;
const SCAN_INTERVAL: number = 5000; // 扫描间隔
const SCAN_DURATION: number = 3000; // 扫描动画时长

// 颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const DIVIDER_COLOR: ResourceColor = '#E5E5E5';
const GAUGE_RED: ResourceColor = '#FF0000';
const LIGHT_BLUE: ResourceColor = '#fff6f8ff';

// 定义家庭成员类型
enum FamilyMember {
  FATHER = 0,
  MOTHER = 1
}

interface health_data {
  id: number;
  heart_rate: number;
  temperature: number;
  blood_oxygen: number;
  respiratory_rate: number;
  health_index: number;
  recorded_at: string;
}

@Entry
@Component
export default struct HealthMonitorPage {
  @State healthHistory: health_data[] = [];
  scroller: Scroller = new Scroller();
  // 健康数据状态
  @State gaugeValue: number = 50; // 健康指数
  @State heartRate: string = ''; // 心率
  @State temperature: string = ''; // 体温
  @State bloodOxygen: string = ''; // 血氧
  @State respiratoryRate: string = ''; // 呼吸频率
  @State state: string = ''; // 健康状态
  @State dataVersion: number = 0; // 数据版本，用于强制触发渲染
  @State properties: DeviceProperties = {
    HeartRate: '',
    Temperature: '',
    BloodOxygen: '',
    RespiratoryRate: '',
    State: '',
  };
  @State HW_token: string = '';
  @State isLoading: boolean = true; // 加载状态
  @State error: string = '';
  // 动画与交互状态
  @State scanPosition: number = 0; // 扫描线位置
  @State isScanning: boolean = false; // 是否正在扫描
  @State isExpanded: boolean = false; // 详情是否展开
  @State isRefreshing: boolean = false; // 是否刷新中
  @State pressedCard: number = -1; // 当前按下的卡片索引
  @State overscrollOffset: number = 0; // 超滚动偏移
  // 定时器
  private scanIntervalTimer: number = -1;
  private scanAnimationTimer: number = -1;
  // Canvas上下文
  private scanContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true));
  // 家庭成员切换
  @State currentMember: FamilyMember = FamilyMember.FATHER;
  @State memberName: string = '父亲'; // 当前显示的家庭成员名称

  // 页面出现时初始化
  async aboutToAppear() {
    try {
      await this.getIAMUser(); // 获取IAM用户token
      await this.getDeviceShadowData(); // 获取设备影子数据
      this.startScanCycle(); // 启动扫描动画
    } catch (e) {
      this.error = '初始化失败，请重试。';
      this.isLoading = false;
      console.error('初始化失败:', e);
    }
  }

  // 页面消失时清理定时器
  aboutToDisappear() {
    if (this.scanIntervalTimer !== -1) {
      clearInterval(this.scanIntervalTimer);
    }
    if (this.scanAnimationTimer !== -1) {
      clearInterval(this.scanAnimationTimer);
    }
  }

  // 启动扫描周期，移除数据刷新定时器
  private startScanCycle() {
    this.performScanAnimation();
    this.scanIntervalTimer = setInterval(() => {
      this.performScanAnimation();
    }, SCAN_INTERVAL + SCAN_DURATION);
  }

  // 执行扫描动画
  private performScanAnimation() {
    this.isScanning = true;
    const framesPerSecond = 60;
    const frameInterval = 1000 / framesPerSecond;
    let startTime = Date.now();

    if (this.scanAnimationTimer !== -1) {
      clearInterval(this.scanAnimationTimer);
    }

    this.scanAnimationTimer = setInterval(() => {
      const currentTime = Date.now();
      const elapsed = currentTime - startTime;

      if (elapsed >= SCAN_DURATION) {
        clearInterval(this.scanAnimationTimer);
        this.scanAnimationTimer = -1;
        this.scanPosition = 0;
        this.isScanning = false;
        this.drawScan();
        return;
      }

      const progress = elapsed / SCAN_DURATION;
      this.scanPosition = progress * IMAGE_AREA_HEIGHT;
      this.drawScan();
    }, frameInterval);
  }

  // 绘制扫描线
  private drawScan() {
    const ctx = this.scanContext;
    const width = IMAGE_AREA_WIDTH;
    const height = IMAGE_AREA_HEIGHT;

    ctx.clearRect(0, 0, width, height);

    if (this.isScanning) {
      const scanLineHeight = 2;
      ctx.fillStyle = 'rgba(0, 125, 255, 0.5)';
      ctx.fillRect(0, this.scanPosition, width, scanLineHeight);

      let gradient = ctx.createLinearGradient(0, this.scanPosition - 10, 0, this.scanPosition + 10);
      gradient.addColorStop(0, 'rgba(0, 125, 255, 0)');
      gradient.addColorStop(0.5, 'rgba(0, 125, 255, 0.5)');
      gradient.addColorStop(1, 'rgba(0, 125, 255, 0)');
      ctx.fillStyle = gradient;
      ctx.fillRect(0, this.scanPosition - 10, width, 20);
    }
  }

  // 扫描动画组件
  @Builder
  ScanAnimation(height: number, width: number) {
    Canvas(this.scanContext)
      .width(width)
      .height(height)
      .onReady(() => {
        this.drawScan();
      });
  }

  // 健康数据行组件
  @Builder
  HealthDataRow(label: string, value: string, valueColor: ResourceColor) {
    Row({ space: 8 }) {
      Text(label + '：')
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
        .width(80)
        .textAlign(TextAlign.Start);
      Text(value || 'N/A')
        .fontSize(14)
        .margin({ left: -10 })
        .fontColor(valueColor)
        .fontWeight(FontWeight.Medium);
    }.width('100%');
  }

  // 健康卡片组件
  @Builder
  HealthCard(index: number, icon: Resource, title: string, subtitle: string, status: string,
    statusColor: ResourceColor) {
    Column() {
      Column({ space: 10 }) {
        Image(icon)
          .width(30)
          .height(30);
        Column() {
          Text(title)
            .fontSize(16)
            .fontColor(PRIMARY_TEXT_COLOR)
            .fontWeight(FontWeight.Bold);
          Text(subtitle)
            .margin({ top: 10 })
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR);
        }
        .layoutWeight(1);

        Text(status)
          .fontSize(10)
          .fontColor(statusColor);
      }
      .padding(10);
    }
    .height(120)
    .width('45%')
    .backgroundColor(this.pressedCard === index ? '#D3D3D3' : Color.White) // Gray when pressed, white otherwise
    .borderRadius(10)
    .margin(5)
    .scale({
      x: this.pressedCard === index ? 0.95 : 1,
      y: this.pressedCard === index ? 0.95 : 1
    }) // Shrink when pressed
    .shadow({ radius: this.pressedCard === index ? 8 : 4, color: '#00000020' })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressedCard = index;
      } else if (event.type === TouchType.Up) {
        this.pressedCard = -1;
      }
    })
    .onClick(() => {
      if (title === '心率') {
        router.pushUrl({
          url: 'pages/childpages/heartratepage/HeartRatePage',
        });
      }
      if (title === '睡眠') {
        router.pushUrl({
          url: 'pages/childpages/sleeptimepage/SleepTimePage',
        });
      }
      if (title === '血压') {
        router.pushUrl({
          url: 'pages/childpages/bloodpressurepage/BloodPressurePage',
        });
      }
      if (title === '血糖') {
        router.pushUrl({
          url: 'pages/childpages/bloodsugarpage/BloodSugarPage',
        });
      }
      if (title === '血氧饱和度') {
        router.pushUrl({
          url: 'pages/childpages/bloodoxygenpage/BloodOxygenPage',
        });
      }
      if (title === '体重') {
        router.pushUrl({
          url: 'pages/childpages/weightpage/WeightPage',
        });
      }
    });
  }

  // 切换家庭成员
  private switchFamilyMember() {
    this.currentMember = this.currentMember === FamilyMember.FATHER ? FamilyMember.MOTHER : FamilyMember.FATHER;
    this.memberName = this.currentMember === FamilyMember.FATHER ? '父亲' : '母亲';
  }

  // 获取健康状态文本
  private getStatusText(): string {
    if (this.gaugeValue >= 85) {
      return '优秀';
    } else if (this.gaugeValue >= 70) {
      return '良好';
    } else if (this.gaugeValue >= 50) {
      return '一般';
    } else {
      return '较差';
    }
  }

  // 处理超滚动弹性效果
  private handleOverscroll(edge: Edge) {
    if (edge === Edge.Bottom || edge === Edge.Top) {
      this.overscrollOffset = edge === Edge.Bottom ? -50 : 50;
      animateTo({
        duration: 600,
        curve: Curve.Friction,
        onFinish: () => {
          this.overscrollOffset = 0;
        },
      }, () => {
        this.overscrollOffset = 0;
      });
    }
  }

  // 计算健康指数
  private calculateHealthIndex(props: DeviceProperties): number {
    let score = 0;
    const heartRate = parseFloat(props.HeartRate.replace(/[^0-9.]/g, ''));
    const temperature = parseFloat(props.Temperature.replace(/[^0-9.]/g, ''));
    const bloodOxygen = parseFloat(props.BloodOxygen.replace(/[^0-9.]/g, ''));
    const respiratoryRate = parseFloat(props.RespiratoryRate.replace(/[^0-9.]/g, ''));

    // 心率评分
    if (!isNaN(heartRate)) {
      if (51 <= heartRate && heartRate <= 90) {
        score += 0;
      } else if ((41 <= heartRate && heartRate <= 50) || (91 <= heartRate && heartRate <= 110)) {
        score += 1;
      } else if (heartRate <= 40 || (111 <= heartRate && heartRate <= 130)) {
        score += 2;
      } else {
        score += 3;
      }
    } else {
      score += 3;
    }

    // 体温评分
    if (!isNaN(temperature)) {
      if (36.1 <= temperature && temperature <= 38.0) {
        score += 0;
      } else if ((35.1 <= temperature && temperature <= 36.0) || (38.1 <= temperature && temperature <= 39.0)) {
        score += 1;
      } else if (temperature <= 35.0 || temperature >= 39.1) {
        score += 2;
      } else {
        score += 3;
      }
    } else {
      score += 3;
    }

    // 血氧评分
    if (!isNaN(bloodOxygen)) {
      if (bloodOxygen >= 96) {
        score += 0;
      } else if (94 <= bloodOxygen && bloodOxygen <= 95) {
        score += 1;
      } else if (92 <= bloodOxygen && bloodOxygen <= 93) {
        score += 2;
      } else {
        score += 3;
      }
    } else {
      score += 3;
    }

    // 呼吸评分
    if (!isNaN(respiratoryRate)) {
      if (12 <= respiratoryRate && respiratoryRate <= 20) {
        score += 0;
      } else if ((9 <= respiratoryRate && respiratoryRate <= 11) || (21 <= respiratoryRate && respiratoryRate <= 24)) {
        score += 1;
      } else if (respiratoryRate <= 8 || respiratoryRate >= 25) {
        score += 2;
      } else {
        score += 3;
      }
    } else {
      score += 3;
    }

    // 氧气补充（如有可扩展）
    const supplementalOxygen = false;
    if (supplementalOxygen) {
      score += 2;
    }

    // 计算健康指数（0-100分）
    const maxScore = 14;
    const healthIndex = Math.max(0, 100 - (score / maxScore * 100));
    return Math.round(healthIndex);
  }

  build() {
    Column() {
      Toolbar({ title: '健康监测' }) {
        Refresh({ refreshing: this.isRefreshing, offset: 100, friction: 0.4 }) {
          Scroll(this.scroller) {
            Column() {
              if (this.isLoading) {
                Image('/images/love.png')
                  .width('50%')
                  .height('40%')
                  .padding({ top: 100 })
                Text('守护您与家人的健康！')
                  .height("40%")
                  .fontSize(16)
                  .fontColor('#ff8a4622')
                  .padding(20)
                  .margin({ top: -100 })
                Text('下拉刷新页面...')
                  .height("30%")
                  .fontSize(16)
                  .fontColor(ACCENT_COLOR)
                  .padding(20)
              } else if (this.error) {
                Column({ space: 16 }) {
                  Image($r('app.media.error_icon') ?? $r('app.media.ai_icon'))
                    .width(100)
                    .height(100)
                    .opacity(0.8)
                    .margin({ top: 80 })
                    .onError(() => {
                      // 图片加载失败时的处理
                      console.warn('错误图标加载失败');
                    })

                  Text(this.error)
                    .fontSize(18)
                    .fontColor(GAUGE_RED)
                    .padding(20)
                    .textAlign(TextAlign.Center);

                  Text('可能原因：\n1. 网络连接问题\n2. 设备离线或未注册\n3. 用户凭证已过期')
                    .fontSize(14)
                    .fontColor(SECONDARY_TEXT_COLOR)
                    .padding(20)
                    .textAlign(TextAlign.Center)
                    .opacity(0.8);

                  Button('重试连接')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .backgroundColor(ACCENT_COLOR)
                    .fontColor(Color.White)
                    .width(160)
                    .height(48)
                    .margin({ top: 20 })
                    .borderRadius(24)
                    .stateEffect(true)
                    .onClick(async () => {
                      this.isLoading = true;
                      this.error = '';
                      try {
                        await this.getIAMUser(); // 重新获取IAM用户token
                        await this.getDeviceShadowData(); // 重新获取设备影子数据
                      } catch (e) {
                        console.error('重试连接失败:', e);
                      } finally {
                        this.isLoading = false;
                      }
                    });
                }
                .width('100%')
                .alignItems(HorizontalAlign.Center)
              } else {
                Column({ space: 15 }) {
                  // 主内容区
                  Row({ space: 12 }) {
                    Column() {
                      Stack() {
                        Image(this.currentMember === FamilyMember.FATHER ? 'images/body_outline.jpg' :
                          'images/body_outline2.jpg')
                          .width(IMAGE_AREA_WIDTH)
                          .height(IMAGE_AREA_HEIGHT)
                          .objectFit(ImageFit.Contain);
                        this.ScanAnimation(IMAGE_AREA_HEIGHT, IMAGE_AREA_WIDTH);

                        // 添加一个小提示文本在图片上
                        Text(this.memberName)
                          .fontSize(15)
                          .fontColor(ACCENT_COLOR)
                          .backgroundColor('rgba(255, 255, 255, 0.7)')
                          .borderRadius(8)
                          .padding({
                            left: 8,
                            right: 8,
                            top: 2,
                            bottom: 2
                          })
                          .position({ x: 5, y: 5 });
                      }
                      .padding(6)
                      .onClick(() => {
                        // 点击Stack区域切换家庭成员
                        animateTo({
                          duration: 300,
                          curve: Curve.EaseInOut,
                          iterations: 1,
                          playMode: PlayMode.Normal,
                        }, () => {
                          this.switchFamilyMember();
                        })
                      })
                      .gesture(
                        TapGesture()
                          .onAction(() => {
                            // 额外添加手势确保点击响应
                            this.switchFamilyMember();
                          })
                      )
                    }
                    .alignItems(HorizontalAlign.Center)

                    // 右侧健康数据
                    Column({ space: 10 }) {
                      Stack() {
                        Gauge({ value: this.gaugeValue, min: 0, max: 100 })
                          .width(140)
                          .height(140)
                          .startAngle(150)
                          .endAngle(30)
                          .strokeWidth(14)
                          .colors(
                            new LinearGradient([
                              { color: '#FF0000', offset: 0.0 },
                              { color: '#FF9900', offset: 0.33 },
                              { color: '#ffe5e518', offset: 0.66 },
                              { color: '#ff048a04', offset: 1.0 }
                            ])
                          )

                        Text(`健康指数:${this.gaugeValue}`)
                          .fontSize(14)
                          .fontColor(ACCENT_COLOR)
                          .textAlign(TextAlign.Center)
                          .width(140)
                          .height(140)
                          .layoutWeight(1)
                          .align(Alignment.Center);
                      }

                      Column({ space: 8 }) {
                        this.HealthDataRow('心率', this.heartRate, ACCENT_COLOR);
                        this.HealthDataRow('体温', this.temperature, ACCENT_COLOR);
                        this.HealthDataRow('血氧', this.bloodOxygen, ACCENT_COLOR);
                        this.HealthDataRow('呼吸频率', this.respiratoryRate, ACCENT_COLOR);
                        this.HealthDataRow('状态', this.state, ACCENT_COLOR);
                      }
                      .width(150)
                      .padding({ top: 6 });

                      Text('查看历史数据 >')
                        .fontSize(14)
                        .fontColor('#8af13d3d')
                        .padding({ right: 19 })
                        .onClick(() => {
                          // 跳转到历史数据页面
                          router.pushUrl({
                            url: 'pages/showhistory/showHistory',
                          });
                        });
                    }
                  }.padding({ top: 10 });

                  // 可折叠详情
                  Column() {
                    Row() {
                      Text('正常范围说明')
                        .fontSize(14)
                        .fontColor(SECONDARY_TEXT_COLOR)
                        .textAlign(TextAlign.Start);
                      Image(this.isExpanded ? $r('app.media.up_arrow') : $r('app.media.down_arrow'))
                        .width(16)
                        .height(16)
                        .margin({ left: 8 });
                    }
                    .width('100%')
                    .padding(10)
                    .border({ width: 1, color: DIVIDER_COLOR, radius: 8 })
                    .onClick(() => {
                      this.isExpanded = !this.isExpanded;
                    });

                    if (this.isExpanded) {
                      Text('心率: 51-90 bpm\n体温: 36.1-38.0 °C\n血氧: ≥96%\n呼吸: 12-20 次/分')
                        .fontSize(12)
                        .margin({ top: 10 })
                        .fontColor(SECONDARY_TEXT_COLOR)
                        .padding({ left: 10, right: 10, bottom: 10 });
                    }
                  }
                  .width('100%');
                }
                .borderRadius(10)
                .backgroundColor(Color.White);

                // 健康功能卡片区
                Column({ space: 10 }) {
                  Row({ space: 10 }) {
                    this.HealthCard(0, $r('app.media.sleep'), '睡眠', '记录您的睡眠数据', '查看报告 >', '#007DFF');
                    this.HealthCard(1, $r('app.media.heart_rate'), '心率', '记录您的心率数据', '查看报告 >', '#FF4500');
                  }

                  Row({ space: 10 }) {
                    this.HealthCard(2, $r('app.media.blood_pressure'), '血压', '记录您的血压数据', '查看报告 >',
                      '#FF4500');
                    this.HealthCard(3, $r('app.media.blood_sugar'), '血糖', '记录您的血糖数据', '查看报告 >',
                      '#FF4500');
                  }

                  Row({ space: 10 }) {
                    this.HealthCard(4, $r('app.media.blood_o2'), '血氧饱和度', '记录您的血氧数据', '查看报告 >',
                      '#FF4500');
                    this.HealthCard(5, $r('app.media.weight'), '体重', '记录您的体重数据', '查看报告 >', '#FF4500');
                  }
                }
                .padding({ top: 5, bottom: 20 })
                .backgroundColor(LIGHT_BLUE);

                Blank()
                  .height(this.overscrollOffset);

                // 智能健康分析按钮
                Button('智能健康分析')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .backgroundColor(ACCENT_COLOR)
                  .fontColor(Color.White)
                  .width('90%')
                  .height(48)
                  .margin({ top: 16, bottom: 24 })
                  .borderRadius(24)
                  .stateEffect(true)
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/healthanalysis/HealthAnalysisPage',
                    });
                  })
                  .shadow({
                    radius: 4,
                    color: 'rgba(0, 125, 255, 0.3)',
                    offsetX: 0,
                    offsetY: 2
                  });

                Row() {
                  Text('AI驱动 · 个性化健康分析报告')
                    .fontSize(14)
                    .fontColor(SECONDARY_TEXT_COLOR)
                    .textAlign(TextAlign.Center)
                  Image($r('app.media.ai_icon'))
                    .width(18)
                    .height(18)
                    .margin({ left: 4 })
                }
                .margin({ bottom: 80 });
              }
            }
            .width('100%')
            .backgroundColor(LIGHT_BLUE)
            .padding({ left: 8, right: 8 });
          }
          .edgeEffect(EdgeEffect.Spring)
          .onScrollEdge((edge: Edge) => {
            this.handleOverscroll(edge);
          });
        }
        .onRefreshing(() => {
          this.isRefreshing = true;
          this.isLoading = true;
          this.getDeviceShadowData().finally(() => {
            this.isRefreshing = false;
            this.isLoading = false;
          });
        });
      }
    }
  }

  // 获取设备影子数据
  async getDeviceShadowData(): Promise<void> {
    try {
      let url: string =
        'https://e67f5f21c0.st1.iotda-app.cn-east-3.myhuaweicloud.com/v5/iot/03a288b2c9904c66b1b6c5c51f9814f1/devices/qqq001/shadow';
      let httpRequest = http.createHttp();
      let options: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.OBJECT,
        header: {
          'Content-Type': 'application/json',
          'X-Auth-Token': this.HW_token,
          'Cache-Control': 'no-cache', // 禁用缓存
        },
      };

      const data = await new Promise<http.HttpResponse>((resolve, reject) => {
        httpRequest.request(url, options, (err: BusinessError, data: http.HttpResponse) => {
          if (!err) {
            resolve(data);
          } else {
            reject(err);
          }
          httpRequest.destroy();
        });
      });

      const props: DeviceProperties = data.result['shadow'][0].reported.properties || {};
      console.info(`[${new Date().toISOString()}] 获取设备影子数据:`, JSON.stringify(props));

      // 创建新对象以强制触发状态更新
      const newProperties: DeviceProperties = {
        HeartRate: props.HeartRate || '',
        Temperature: props.Temperature || '',
        BloodOxygen: props.BloodOxygen || '',
        RespiratoryRate: props.RespiratoryRate || '',
        State: '',
      };

      // 更新健康指数
      this.gaugeValue = this.calculateHealthIndex(newProperties);
      newProperties.State = this.getStatusText();

      // 更新独立的状态变量，强制转换为新字符串
      this.heartRate = newProperties.HeartRate + '';
      this.temperature = newProperties.Temperature + '';
      this.bloodOxygen = newProperties.BloodOxygen + '';
      this.respiratoryRate = newProperties.RespiratoryRate + '';
      this.state = newProperties.State + '';

      // 更新 properties 以保持一致性
      this.properties = newProperties;

      // 递增 dataVersion 以强制触发 UI 渲染
      this.dataVersion++;

      // 检查心率是否异常，如果异常则显示警告弹窗并震动
      simpleAlertService.checkHeartRate(this.heartRate, `${this.memberName}`);

      // 更新全局状态
      globalState.deviceProperties = {
        HeartRate: newProperties.HeartRate,
        Temperature: newProperties.Temperature,
        BloodOxygen: newProperties.BloodOxygen,
        RespiratoryRate: newProperties.RespiratoryRate,
        State: newProperties.State,
      };
      this.error = '';

      // 保存到数据库
      const saveUrl = ApiConfig.SAVE_HEALTH_DATA;
      const saveRequest = http.createHttp();
      const body = JSON.stringify({
        userId: globalState.userId,
        heartRate: parseFloat(newProperties.HeartRate.replace(/[^0-9.]/g, '')) || null,
        temperature: parseFloat(newProperties.Temperature.replace(/[^0-9.]/g, '')) || null,
        bloodOxygen: parseFloat(newProperties.BloodOxygen.replace(/[^0-9.]/g, '')) || null,
        respiratoryRate: parseFloat(newProperties.RespiratoryRate.replace(/[^0-9.]/g, '')) || null,
        healthIndex: this.gaugeValue,
      });
      saveRequest.request(saveUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${globalState.JWTtoken}`,
        },
        extraData: body,
      }, (err) => {
        if (err) {
          console.error('保存健康数据失败:', err);
        }
        saveRequest.destroy();
      });
    } catch (err) {
      this.error = '设备数据获取失败。';
      console.error('获取设备数据失败:', err);
    }
  }

  // 获取IAM用户token
  async getIAMUser(): Promise<void> {
    try {
      let hw_user: HW_User = new HW_User('hhh', 'h123456', 'hid_7wv04o5jfj6t7vg');
      let httpRequest = http.createHttp();
      let options: http.HttpRequestOptions = {
        method: http.RequestMethod.POST,
        extraData: hw_user,
        expectDataType: http.HttpDataType.OBJECT,
        header: {
          'Content-Type': 'application/json',
        },
      };

      const data = await new Promise<http.HttpResponse>((resolve, reject) => {
        httpRequest.request('https://iam.myhuaweicloud.com/v3/auth/tokens', options,
          (err: BusinessError, data: http.HttpResponse) => {
            if (!err) {
              resolve(data);
            } else {
              reject(err);
            }
            httpRequest.destroy();
          });
      });

      this.HW_token = data.header['x-subject-token'] || '';
      globalState.token = this.HW_token; // 存储到全局状态
      console.info('获取IAM用户token成功:', this.HW_token);
    } catch (err) {
      console.error('获取IAM用户token失败:', err);
    }
  }
}