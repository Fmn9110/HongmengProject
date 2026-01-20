import { Prompt, router } from '@kit.ArkUI';
import http from '@ohos.net.http';
import { globalState } from '../../component/HW_user';
import imageOptimizer from '../../component/ImageOptimizer';
import { ApiConfig } from '../../config/ApiConfig';

// 健康数据类型
interface HealthData {
  id: number;
  user_id: number;
  heart_rate: number;
  temperature: number;
  blood_oxygen: number;
  respiratory_rate: number;
  health_index: number;
  recorded_at: string;
}

// 接口响应类型
interface ApiResponse {
  data?: HealthData[];
  error?: string;
}

// 删除健康数据响应类型
interface DeleteHealthDataResponse {
  success?: boolean;
  deletedCount?: number;
  error?: string;
}

// 定义路由参数类型
interface RouteParams {
  startDate?: string;
  endDate?: string;
}

// 颜色常量
const DIVIDER_COLOR: ResourceColor = '#E8ECEF';
const PRIMARY_TEXT_COLOR: ResourceColor = '#1A1A1A';
const SECONDARY_TEXT_COLOR: ResourceColor = '#6B7280';
const ACCENT_COLOR: ResourceColor = '#2563EB';
const LIGHT_BLUE: ResourceColor = '#F8FAFC';
const BUTTON_COLOR: ResourceColor = '#10B981';
const GAUGE_RED: ResourceColor = '#EF4444';

interface choosedata {
  startDate: string;
  endDate: string;
  limit: number;
}

interface Interface_1 {
  limit: number;
}

interface ImageLoadTask {
  recordId: number;
  imagePath: string;
}

@Entry
@Component
struct ShowHistory {
  @State healthData: HealthData[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State backButtonScale: number = 1;
  @State isSelectMode: boolean = false;
  @State selectedIds: Set<number> = new Set();
  @State startDate: string = '';
  @State endDate: string = '';
  @State isRefreshing: boolean = false;
  @State imageResources: Map<number, Resource> = new Map();
  @State imageLoadQueue: ImageLoadTask[] = [];
  @State loadingImages: Set<number> = new Set();
  private maxConcurrentLoads: number = 20; // 增加并发加载数量以确保更多图片同时加载

  aboutToAppear() {
    if (!globalState.JWTtoken) {
      Prompt.showToast({ message: '请重新登录', duration: 2000 });
      router.pushUrl({ url: 'pages/PhoneNumberLogin' });
      return;
    }

    const params = router.getParams() as RouteParams;
    if (params && params.startDate && params.endDate) {
      this.startDate = params.startDate;
      this.endDate = params.endDate;
    }
    this.fetchHealthHistory();
  }

  async fetchHealthHistory() {
    this.isLoading = true;
    this.errorMessage = '';
    this.imageResources.clear();
    this.imageLoadQueue = [];
    this.loadingImages.clear();

    try {
      const httpRequest = http.createHttp();
      const extraData = this.startDate && this.endDate ?
        { startDate: this.startDate, endDate: this.endDate, limit: 1000 } as choosedata :
        { limit: 1000 } as Interface_1;
      const response = await httpRequest.request(ApiConfig.GET_HEALTH_HISTORY, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${globalState.JWTtoken}`
        },
        extraData: JSON.stringify(extraData)
      });

      const result: ApiResponse = JSON.parse(response.result as string);

      if (response.responseCode === 200) {
        this.healthData = result.data || [];
        if (this.healthData.length === 0) {
          this.errorMessage = '暂无健康记录';
        } else {
          // 立即将所有图片加入加载队列
          this.healthData.forEach((record, index) => {
            const imagePath = `app.media.p${(index % 8) + 1}`;
            this.enqueueImageLoad(record.id, imagePath);
          });
        }
      } else {
        this.errorMessage = result.error || '获取历史数据失败';
        if (response.responseCode === 401 || response.responseCode === 403) {
          Prompt.showToast({ message: '登录已过期，请重新登录', duration: 2000 });
          router.pushUrl({ url: 'pages/PhoneNumberLogin' });
        }
      }
      httpRequest.destroy();
    } catch (error) {
      this.errorMessage = '网络错误，请稍后重试';
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  async handleRefresh() {
    this.isRefreshing = true;
    this.startDate = '';
    this.endDate = '';
    this.imageResources.clear();
    this.imageLoadQueue = [];
    this.loadingImages.clear();
    await this.fetchHealthHistory();
  }

  private formatDateToLocalString(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private openDatePicker(isStart: boolean) {
    DatePickerDialog.show({
      start: new Date('2020-01-01'),
      end: new Date(),
      selected: isStart ? (this.startDate ? new Date(this.startDate) : new Date()) :
        (this.endDate ? new Date(this.endDate) : new Date()),
      onDateAccept: (value: Date) => {
        const selectedDate = this.formatDateToLocalString(value);
        if (isStart) {
          this.startDate = selectedDate;
        } else {
          this.endDate = selectedDate;
        }
      }
    });
  }

  private applyFilter() {
    if (this.startDate && this.endDate) {
      if (new Date(this.startDate) > new Date(this.endDate)) {
        Prompt.showToast({ message: '开始日期不能晚于结束日期', duration: 2000 });
        return;
      }
      this.imageResources.clear();
      this.imageLoadQueue = [];
      this.loadingImages.clear();
      this.fetchHealthHistory();
    } else {
      Prompt.showToast({ message: '请选择开始和结束日期', duration: 2000 });
    }
  }

  async deleteSelectedRecords(): Promise<void> {
    if (this.selectedIds.size === 0) {
      Prompt.showToast({ message: '请选择要删除的记录', duration: 2000 });
      return;
    }

    const selectedIdsArray = Array.from(this.selectedIds);
    try {
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(ApiConfig.DELETE_HEALTH_DATA, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${globalState.JWTtoken}`
        },
        extraData: { ids: selectedIdsArray }
      });

      if (response.responseCode === 200) {
        const result: DeleteHealthDataResponse = JSON.parse(response.result as string);
        if (result.success) {
          this.healthData = this.healthData.filter(record => !this.selectedIds.has(record.id));
          this.selectedIds.clear();
          this.isSelectMode = false;
          Prompt.showToast({ message: `删除成功，删除了${result.deletedCount || 0}条记录`, duration: 2000 });
          this.imageResources.clear();
          this.imageLoadQueue = [];
          this.loadingImages.clear();
        } else {
          Prompt.showToast({ message: result.error || '删除失败', duration: 2000 });
        }
      } else if (response.responseCode === 401 || response.responseCode === 403) {
        Prompt.showToast({ message: '登录已过期，请重新登录', duration: 2000 });
        router.pushUrl({ url: 'pages/PhoneNumberLogin' });
      } else {
        Prompt.showToast({ message: '删除失败', duration: 2000 });
      }
      httpRequest.destroy();
    } catch (error) {
      Prompt.showToast({ message: '网络错误，请稍后重试', duration: 2000 });
    }
  }

  selectAllRecords(): void {
    if (this.isSelectMode) {
      if (this.selectedIds.size === this.healthData.length) {
        this.selectedIds.clear();
      } else {
        this.selectedIds = new Set(this.healthData.map(record => record.id));
      }
    }
  }

  formatDateTime(dateTime: string): string {
    const date = new Date(dateTime);
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
  }

  onRecordClick(recordId: number): void {
    if (this.isSelectMode) {
      if (this.selectedIds.has(recordId)) {
        this.selectedIds.delete(recordId);
      } else {
        this.selectedIds.add(recordId);
      }
    }
  }

  onRecordLongPress(recordId: number): void {
    if (!this.isSelectMode) {
      this.isSelectMode = true;
      this.selectedIds.add(recordId);
    }
  }

  private async loadImage(task: ImageLoadTask) {
    if (this.loadingImages.has(task.recordId)) {
      return;
    }
    this.loadingImages.add(task.recordId);
    try {
      const resource: Resource = await imageOptimizer.getOptimizedImage(task.imagePath, true);
      this.imageResources.set(task.recordId, resource);
    } catch (error) {
      console.error(`Failed to load image for record ${task.recordId}: ${error}`);
      this.imageResources.set(task.recordId, $r('app.media.placeholder'));
    } finally {
      this.loadingImages.delete(task.recordId);
      this.processNextLoadTask();
    }
  }

  private processNextLoadTask() {
    if (this.imageLoadQueue.length > 0 && this.loadingImages.size < this.maxConcurrentLoads) {
      const nextTask = this.imageLoadQueue.shift();
      if (nextTask) {
        this.loadImage(nextTask);
      }
    }
  }

  private enqueueImageLoad(recordId: number, imagePath: string) {
    if (!this.imageResources.has(recordId) && !this.loadingImages.has(recordId)) {
      this.imageLoadQueue.push({ recordId, imagePath });
      this.processNextLoadTask();
    }
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
          .scale({ x: this.backButtonScale, y: this.backButtonScale })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.backButtonScale = 0.95;
            } else if (event.type === TouchType.Up) {
              this.backButtonScale = 1;
            }
          })

        Text('历史健康记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(PRIMARY_TEXT_COLOR)
          .flexGrow(1)
          .textAlign(TextAlign.Center)
          .margin({ left: 20 })

        Button('筛选', { type: ButtonType.Normal })
          .height(30)
          .width(60)
          .backgroundColor(BUTTON_COLOR)
          .borderRadius('50%')
          .fontSize(13)
          .fontColor(Color.White)
          .margin({ right: 16 })
          .onClick(() => {
            this.applyFilter();
          })
      }
      .width('100%')
      .height(56)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Refresh({ refreshing: this.isRefreshing }) {
        Column() {
          Row() {
            Row() {
              Button('开始日期', { type: ButtonType.Normal })
                .height(30)
                .width(90)
                .backgroundColor(ACCENT_COLOR)
                .fontSize(12)
                .fontColor(Color.White)
                .onClick(() => this.openDatePicker(true))
                .borderRadius('10%')
              Text(this.startDate || '未选择')
                .fontSize(12)
                .fontColor(SECONDARY_TEXT_COLOR)
                .margin({ left: 8 })
                .width(75)
            }
            .width('45%')
            .justifyContent(FlexAlign.Start)
            .padding({ left: 16, right: 16, top: 8 })

            Row() {
              Button('结束日期', { type: ButtonType.Normal })
                .height(30)
                .width(90)
                .backgroundColor(ACCENT_COLOR)
                .fontSize(12)
                .fontColor(Color.White)
                .onClick(() => this.openDatePicker(false))
                .borderRadius('10%')
              Text(this.endDate || '未选择')
                .fontSize(12)
                .fontColor(SECONDARY_TEXT_COLOR)
                .margin({ left: 8 })
                .width(75)
            }
            .width('45%')
            .justifyContent(FlexAlign.Start)
            .padding({ left: 16, right: 16, top: 8 })
          }
          .margin({ left: 20, bottom: 5 })
          .width('100%')
          .backgroundColor(Color.White)

          if (this.isLoading) {
            LoadingProgress()
              .height(70)
              .color('#ff4cc4f6')
              .margin({ top: 250 })
          }

          if (this.errorMessage && !this.isLoading) {
            Text(this.errorMessage)
              .fontSize(16)
              .fontColor(GAUGE_RED)
              .margin({ top: 20 })
          }

          if (!this.isLoading && this.healthData.length > 0) {
            Scroll() {
              Column() {
                ForEach(this.healthData, (record: HealthData, index: number) => {
                  Row() {
                    if (this.isSelectMode) {
                      Image(this.selectedIds.has(record.id) ? $r('app.media.icon_checked') :
                      $r('app.media.icon_unchecked'))
                        .width(24)
                        .height(24)
                        .margin({ right: 8 })
                    }
                    Column() {
                      Row() {
                        Column() {
                          Text(this.formatDateTime(record.recorded_at))
                            .fontSize(14)
                            .fontColor(SECONDARY_TEXT_COLOR)
                            .width('100%')
                            .textAlign(TextAlign.Start)
                            .margin({ bottom: 8 })

                          Row() {
                            Text(`心率: ${record.heart_rate} 次/分钟`)
                              .fontSize(16)
                              .fontColor(PRIMARY_TEXT_COLOR)
                            Blank()
                          }
                          .width('100%')
                          .padding({ top: 4, bottom: 4 })

                          Row() {
                            Text(`体温: ${record.temperature} °C`)
                              .fontSize(16)
                              .fontColor(PRIMARY_TEXT_COLOR)
                            Blank()
                          }
                          .width('100%')
                          .padding({ top: 4, bottom: 4 })

                          Row() {
                            Text(`血氧: ${record.blood_oxygen}%`)
                              .fontSize(16)
                              .fontColor(PRIMARY_TEXT_COLOR)
                            Blank()
                          }
                          .width('100%')
                          .padding({ top: 4, bottom: 4 })

                          Row() {
                            Text(`呼吸频率: ${record.respiratory_rate} 次/分钟`)
                              .fontSize(16)
                              .fontColor(PRIMARY_TEXT_COLOR)
                            Blank()
                          }
                          .width('100%')
                          .padding({ top: 4, bottom: 4 })

                          Row() {
                            Text(`健康指数: ${record.health_index}`)
                              .fontSize(16)
                              .fontColor(PRIMARY_TEXT_COLOR)
                            Blank()
                          }
                          .width('100%')
                          .padding({ top: 4, bottom: 4 })
                        }
                        .layoutWeight(1)

                        // 使用 Stack 包裹 Image，确保占位图尺寸受控
                        Stack() {
                          Image(this.imageResources.has(record.id) && this.imageResources.get(record.id) ?
                            this.imageResources.get(record.id)! : $r('app.media.placeholder'))
                            .width(this.imageResources.has(record.id) && this.imageResources.get(record.id) ? 150 : 10)
                            .height(this.imageResources.has(record.id) && this.imageResources.get(record.id) ? 200 : 10)
                            .margin({ left: 15 })
                            .borderRadius(15)
                            .objectFit(ImageFit.Contain)// 强制图片适配指定尺寸
                            .backgroundColor(this.imageResources.has(record.id) ? Color.Transparent :
                            Color.Gray)// 占位图添加灰色背景便于调试
                            .onAppear(() => {
                              console.log(`Image onAppear: recordId=${record.id}, hasImage=${this.imageResources.has(record.id)}, image=${this.imageResources.get(record.id) ||
                                'placeholder'}`);
                              const imagePath = `app.media.p${(index % 8) + 1}`;
                              this.enqueueImageLoad(record.id, imagePath);
                            })
                        }
                        .width(this.imageResources.has(record.id) && this.imageResources.get(record.id) ? 150 : 10)
                        .height(this.imageResources.has(record.id) && this.imageResources.get(record.id) ? 200 : 10)
                        .clip(true) // 裁剪超出尺寸的内容
                      }
                      .width('100%')
                    }
                    .width('100%')
                  }
                  .width('90%')
                  .padding(16)
                  .backgroundColor(this.selectedIds.has(record.id) ? '#E0F7FA' : Color.White)
                  .borderRadius(12)
                  .shadow({ radius: 8, color: '#00000015' })
                  .margin({ bottom: 12 })
                  .onClick(() => this.onRecordClick(record.id))
                  .gesture(
                    LongPressGesture({ repeat: false, duration: 500 })
                      .onAction(() => this.onRecordLongPress(record.id))
                  )
                }, (record: HealthData) => record.id.toString())
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .height('85%')
          }

          if (this.isSelectMode) {
            Row() {
              Button('全选', { type: ButtonType.Normal })
                .height(30)
                .width(70)
                .backgroundColor(BUTTON_COLOR)
                .borderRadius(10)
                .fontSize(13)
                .fontColor(Color.White)
                .margin({ left: 16 })
                .onClick(() => {
                  this.selectAllRecords();
                })

              Blank()

              Button(this.selectedIds.size > 0 ? '删除' : '取消', { type: ButtonType.Normal })
                .height(30)
                .width(70)
                .backgroundColor(GAUGE_RED)
                .borderRadius(10)
                .fontSize(13)
                .fontColor(Color.White)
                .margin({ right: 16 })
                .onClick(() => {
                  if (this.selectedIds.size === 0) {
                    this.isSelectMode = false;
                    this.selectedIds.clear();
                  } else {
                    AlertDialog.show({
                      message: `確定删除 ${this.selectedIds.size} 条记录？`,
                      confirm: {
                        value: '确定',
                        action: () => this.deleteSelectedRecords()
                      }
                    });
                  }
                })
            }
            .width('90%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ bottom: 10, top: 5 })
          }
        }
        .width('100%')
      }
      .onRefreshing(() => {
        this.handleRefresh();
      })
    }
    .width('100%')
    .height('92%')
    .margin({ top: 35 })
    .backgroundColor(LIGHT_BLUE)
    .alignItems(HorizontalAlign.Center)
  }
}