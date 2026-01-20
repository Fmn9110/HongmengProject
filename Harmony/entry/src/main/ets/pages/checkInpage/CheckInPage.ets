import http from '@ohos.net.http';
import promptAction from '@ohos.promptAction';
import { globalState } from '../../component/HW_user';
import router from '@ohos.router';
import intl from '@ohos.intl';
import { ApiConfig, ApiParams } from '../../config/ApiConfig';

// 签到历史记录接口
interface CheckInRecord {
  date: string;
  points: number;
}

// 积分API响应接口
interface PointsResponse {
  totalPoints: number;
  checkInHistory: CheckInRecord[];
  checkInStreak: number;
}

// 签到API响应接口
interface CheckInResponse {
  success: boolean;
  pointsEarned?: number | string;
  message?: string;
  checkInStreak?: number;
  error?: string;
}

// 日历数据接口
interface CalendarDay {
  day: number;
  date: string;
  isSelectedMonth: boolean;
}

@Entry
@Component
struct CheckInPage {
  @State checkInHistory: CheckInRecord[] = [];
  @State totalPoints: number = 0;
  @State isCheckedInToday: boolean = false;
  @State checkInStreak: number = 0;
  @State isMonthPanelOpen: boolean = false;
  @State selectedMonth: string = new Date().toISOString().slice(0, 7); // 默认当前月份，格式如 "2025-05"

  // 规范化日期格式为 YYYY-MM-DD
  private normalizeDate(dateStr: string): string {
    try {
      const date = new Date(dateStr);
      if (isNaN(date.getTime())) {
        console.error('Invalid date:', dateStr);
        return '';
      }
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const formattedDate = `${year}-${month}-${day}`;
      console.log(`Normalized ${dateStr} to ${formattedDate}`);
      return formattedDate;
    } catch (error) {
      console.error('Error normalizing date:', dateStr, error);
      return '';
    }
  }

  // 获取当前月份加上过去 6 个月的月份列表（总共 7 个月）
  private getMonthOptions(): string[] {
    const months: string[] = [];
    const today = new Date();
    // 添加当前月份
    months.push(today.toISOString().slice(0, 7));
    // 添加过去 6 个月
    for (let i = 0; i <= 4; i++) {
      const date = new Date(today.getFullYear(), today.getMonth() - i, 1);
      months.push(date.toISOString().slice(0, 7));
    }
    console.log('Generated month options:', JSON.stringify(months));
    return months;
  }

  // 页面出现时自动获取积分信息
  async aboutToAppear(): Promise<void> {
    await this.fetchPoints();
  }

  // 获取积分和签到历史
  async fetchPoints(): Promise<void> {
    try {
      if (!globalState.JWTtoken) {
        promptAction.showToast({ message: '请先登录', duration: 2000 });
        router.pushUrl({ url: 'pages/Login' });
        return;
      }
      const httpRequest: http.HttpRequest = http.createHttp();
      const url = ApiConfig.buildUrlWithParams(ApiConfig.POINTS, { 'month': this.selectedMonth } as Record<string, string>);
      console.log('Requesting URL:', url);
      const response: http.HttpResponse = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Authorization': `Bearer ${globalState.JWTtoken}` }
      });
      const data: PointsResponse = JSON.parse(response.result.toString());
      console.log('Raw Points response:', JSON.stringify(data));
      this.checkInHistory = (data.checkInHistory ?? []).map((record: CheckInRecord): CheckInRecord => ({
        date: this.normalizeDate(record.date),
        points: record.points
      })).filter((record: CheckInRecord): boolean => record.date !== '');
      console.log('Normalized checkInHistory dates:', JSON.stringify(this.checkInHistory));
      this.totalPoints = data.totalPoints ?? 0;
      this.checkInStreak = data.checkInStreak ?? 0;
      const formatter: intl.DateTimeFormat = new intl.DateTimeFormat('zh-CN', {
        timeZone: 'Asia/Shanghai',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
      });
      const today: string = formatter.format(new Date()).replace(/(\d{4})\/(\d{2})\/(\d{2})/, '$1-$2-$3');
      this.isCheckedInToday = this.checkInHistory.some((item: CheckInRecord): boolean => {
        const isMatch = item.date === today;
        console.log(`Checking today ${today} against ${item.date}, match: ${isMatch}`);
        return isMatch;
      });
      console.log('Today:', today, 'isCheckedInToday:', this.isCheckedInToday);
      httpRequest.destroy();
    } catch (error) {
      console.error('Error in fetchPoints:', JSON.stringify(error));
      promptAction.showToast({ message: '获取积分失败', duration: 2000 });
    }
  }

  // 签到处理
  async handleCheckIn(): Promise<void> {
    try {
      if (!globalState.JWTtoken || !globalState.userId) {
        promptAction.showToast({ message: '请先登录', duration: 2000 });
        router.pushUrl({ url: 'pages/Login' });
        return;
      }
      const httpRequest: http.HttpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(ApiConfig.CHECK_IN, {
        method: http.RequestMethod.POST,
        header: { 'Authorization': `Bearer ${globalState.JWTtoken}` },
        extraData: { userId: globalState.userId }
      });
      const data: CheckInResponse = JSON.parse(response.result.toString());
      console.log('Check-in response:', JSON.stringify(data));
      if (data.success && data.pointsEarned !== undefined && data.message !== undefined &&
        data.checkInStreak !== undefined) {
        const pointsEarned: number =
          typeof data.pointsEarned === 'string' ? parseInt(data.pointsEarned, 10) : Number(data.pointsEarned);
        if (isNaN(pointsEarned) || pointsEarned < 0) {
          console.error('Invalid pointsEarned:', data.pointsEarned);
          promptAction.showToast({ message: '积分数据无效', duration: 2000 });
          return;
        }
        this.checkInStreak = data.checkInStreak;
        await this.fetchPoints();
        promptAction.showToast({ message: data.message, duration: 2000 });
      } else {
        promptAction.showToast({ message: data.error || '签到失败', duration: 2000 });
      }
      httpRequest.destroy();
    } catch (error) {
      console.error('Check-in error:', JSON.stringify(error));
      promptAction.showToast({ message: '签到失败，请重试', duration: 2000 });
    }
  }

  // 生成日历数据
  private generateCalendar(): CalendarDay[] {
    const formatter: intl.DateTimeFormat = new intl.DateTimeFormat('zh-CN', {
      timeZone: 'Asia/Shanghai',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    });
    const parts = this.selectedMonth.split('-');
    const year = parts[0];
    const month = parts[1];
    const selectedDate = new Date(parseInt(year), parseInt(month) - 1, 1);
    const firstDay: number = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1).getDay();
    const daysInMonth: number = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 0).getDate();

    const calendar: CalendarDay[] = [];

    for (let i = firstDay - 1; i >= 0; i--) {
      const prevDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), -i);
      calendar.push({
        day: prevDate.getDate(),
        date: formatter.format(prevDate).replace(/(\d{4})\/(\d{2})\/(\d{2})/, '$1-$2-$3'),
        isSelectedMonth: false
      });
    }

    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), day);
      calendar.push({
        day,
        date: formatter.format(date).replace(/(\d{4})\/(\d{2})\/(\d{2})/, '$1-$2-$3'),
        isSelectedMonth: true
      });
    }

    const remaining: number = (7 - (calendar.length % 7)) % 7;
    for (let i = 1; i <= remaining; i++) {
      const nextDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, i);
      calendar.push({
        day: nextDate.getDate(),
        date: formatter.format(nextDate).replace(/(\d{4})\/(\d{2})\/(\d{2})/, '$1-$2-$3'),
        isSelectedMonth: false
      });
    }

    console.log('Generated calendar for month:', this.selectedMonth, JSON.stringify(calendar));
    return calendar;
  }

  build() {
    Column() {
      Row() {
        Image($r("app.media.ic_back_black"))
          .width(22)
          .height(22)
          .margin({ left: 5 })
          .onClick((): void => {
            router.back();
          })

        Text(`签到`)
          .fontSize(22)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .width('70%')// 占据中间部分
          .padding({ left: 50 })

        Column() {
          Button('签到历史')
            .type(ButtonType.Capsule)
            .height(30)
            .width(80)
            .backgroundColor('#007DFF')
            .fontColor('#FFFFFF')
            .fontSize(12)
            .margin({ right: 20 })
            .onClick((): void => {
              this.isMonthPanelOpen = !this.isMonthPanelOpen;
              console.log('Month panel open:', this.isMonthPanelOpen);
            })

          if (this.isMonthPanelOpen) {
            Column() {
              ForEach(this.getMonthOptions(), (month: string): void => {
                Text(month)
                  .fontSize(11)
                  .fontColor('#333333')
                  .padding(10)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(5)
                  .margin({ bottom: 5 })
                  .onClick((): void => {
                    this.selectedMonth = month;
                    this.isMonthPanelOpen = false;
                    this.fetchPoints();
                    console.log('Selected month:', month);
                  })
              }, (month: string): string => month)
            }
            .width(85)
            .height(240)
            .padding(10)
            .backgroundColor('#ffececff')
            .borderRadius(10)
            .position({ x: -5, y: 40 }) // 显示在按钮下方
            .alignItems(HorizontalAlign.End)
            .zIndex(1000) // 确保不被遮挡
          }
        }
        .zIndex(1000) // 提高按钮和菜单的层级
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#FFFFFF')
      .zIndex(100)
      .border({ width: 0, color: '#00000000' })
      .shadow({ radius: 4, color: '#00000010' })

      Scroll() {
        Column({ space: 15 }) {
          Column() {
            Text(`当前积分：${this.totalPoints}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#007DFF')
            Text(`连续签到：${this.checkInStreak}天`)
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 5 })
          }
          .padding(15)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .shadow({ radius: 5, color: '#00000020' })
          .width('90%')
          .align(Alignment.Center)

          Column() {
            Row() {
              Text('签到日历')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 10, left: 140 })
              Row() {
                Text('当前查看:')
                  .fontSize(12)
                Text(this.selectedMonth)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#007DFF')
              }
              .margin({ bottom: 10, left: 30 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start) // Align items to the start

            Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(['日', '一', '二', '三', '四', '五', '六'], (day: string): void => {
                Text(day)
                  .fontSize(14)
                  .fontColor('#666666')
                  .width('14%')
                  .textAlign(TextAlign.Center)
              }, (day: string): string => day)
            }
            .width('90%')
            .zIndex(0) // 降低日历层级

            Grid() {
              ForEach(this.generateCalendar(), (item: CalendarDay): void => {
                GridItem() {
                  Text(`${item.day}`)
                    .fontSize(14)
                    .fontWeight(this.checkInHistory.some((h: CheckInRecord): boolean => h.date === item.date) ?
                    FontWeight.Bold : FontWeight.Regular)
                    .fontColor(item.isSelectedMonth ?
                      (this.checkInHistory.some((h: CheckInRecord): boolean => h.date === item.date) ? '#FFFFFF' :
                        '#333333') : '#AAAAAA')
                    .backgroundColor(this.checkInHistory.some((h: CheckInRecord): boolean => h.date === item.date) ?
                      '#07C160' : '#F5F5F5')
                    .width(40)
                    .height(40)
                    .borderRadius(20)
                    .textAlign(TextAlign.Center)
                    .lineHeight(40)
                    .onClick((): void => {
                      console.log(`Clicked date: ${item.date}, isCheckedIn: ${this.checkInHistory.some((h: CheckInRecord): boolean => h.date ===
                      item.date)}`);
                    })
                }
              }, (item: CalendarDay): string => item.date)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
            .rowsGap(8)
            .columnsGap(8)
            .width('90%')
            .padding({ top: 8, bottom: 10 })
            .backgroundColor('#FFFFFF')
            .borderRadius(10)
            .shadow({ radius: 5, color: '#00000020' })
            .zIndex(0) // 降低日历层级
          }
          .width('100%')

          Button(this.isCheckedInToday ? '今日已签到' : '立即签到')
            .type(ButtonType.Capsule)
            .height(48)
            .width(160)
            .backgroundColor(this.isCheckedInToday ? '#CCCCCC' : '#007DFF')
            .fontColor('#FFFFFF')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 10 })
            .enabled(!this.isCheckedInToday)
            .shadow({ radius: 3, color: '#00000020' })
            .onClick((): void => {
              this.handleCheckIn();
            })

          Column() {
            Text('签到规则')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .margin({ bottom: 10 })

            Text('每日签到即可获得积分奖励，连续签到7天可累积800积分！积分可用于兑换健康礼品或服务。具体规则如下：')
              .fontSize(14)
              .fontColor('#666666')
              .height(20)
              .textAlign(TextAlign.Start)
              .width('90%')

            Column({ space: 8 }) {
              Text('• 周一：60积分，开启健康一周')
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
              Text('• 周二：90积分，稳步提升')
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
              Text('• 周三：120积分，健康加倍')
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
              Text('• 周四：150积分，持续坚持')
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
              Text('• 周五：180积分，迈向目标')
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
              Text('• 周六：220积分，享受周末')
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
              Text('• 周日：280积分，完美收官')
                .fontSize(14)
                .fontColor('#666666')
                .textAlign(TextAlign.Start)
              Text('• 连续签到7天可获得额外奖励，敬请期待！')
                .fontSize(14)
                .fontColor('#007DFF')
                .textAlign(TextAlign.Start)
            }
            .width('90%')
            .margin({ top: 30, left: 30 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#FFFFFF')
          .borderRadius(10)
          .shadow({ radius: 5, color: '#00000020' })
          .margin({ top: 15 })
        }
        .width('100%')
        .padding({
          top: 20,
          bottom: 20,
          left: 16,
          right: 16
        })
        .backgroundColor('#F6F8FF')
      }
      .width('100%')
      .height('92%')
    }

    .padding({ top: 35 })
  }
}