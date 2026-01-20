// 健康趋势图表组件
// 用于显示健康指标的历史趋势

// 定义更明确的类型
type ResourceColor = Resource | string | Color;

// 颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const ACCENT_COLOR_LIGHT: ResourceColor = '#E8F1FF';
const GRID_COLOR: ResourceColor = '#E0E0E0';
const ABNORMAL_COLOR: ResourceColor = '#FF3B30';

// 指标数据接口
interface MetricData {
  date: string;
  value: number;
}

// 时间范围类型
enum TimeRange {
  DAY = '日',
  WEEK = '周',
  MONTH = '月',
  YEAR = '年'
}

@Component
export struct HealthTrendChart {
  @Prop metrics: MetricData[];
  @Prop selectedMetric: string;
  @Link timeRange: string;
  @State timeRangeOptions: string[] = [TimeRange.DAY, TimeRange.WEEK, TimeRange.MONTH, TimeRange.YEAR];
  @State chartWidth: number = 0; // 容器宽度
  @State chartHeight: number = 160; // 图表高度
  @State showDataTip: boolean = false; // 是否显示数据提示
  @State selectedIndex: number = -1; // 当前选中的数据点索引
  @State pointSpacing: number = 0; // 数据点之间的间距
  @State previousTimeRange: string = ''; // 用于检测时间范围变化
  @State renderKey: number = 0; // 用于强制重新渲染组件
  @State initialScroll: boolean = true; // 用于控制初始滚动位置
  @State scrollPosition: number = 0; // 记录滚动位置
  @State barWidth: number = 16; // 柱形图宽度
  
  aboutToAppear() {
    // 在组件即将出现时，根据不同时间范围预设不同的初始间距
    this.previousTimeRange = this.timeRange;
    this.updatePointSpacing();
    this.initialScroll = true;
  }
  
  build() {
    Column() {
      // 指标选择和时间范围
      Row() {
        Text(this.selectedMetric)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(PRIMARY_TEXT_COLOR)
        
        Blank()
        
        // 时间范围选择器
        Row() {
          ForEach(this.timeRangeOptions, (option: string) => {
            Text(option)
              .fontSize(14)
              .fontWeight(this.timeRange === option ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.timeRange === option ? ACCENT_COLOR : SECONDARY_TEXT_COLOR)
              .backgroundColor(this.timeRange === option ? ACCENT_COLOR_LIGHT : 'transparent')
              .borderRadius(16)
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .margin({ right: 8 })
              .onClick(() => {
                // 切换时间范围
                this.timeRange = option;
                // 处理时间范围变化
                this.handleTimeRangeChange();
              })
          })
          
          // 下拉箭头
          Image($r('app.media.ic_arrow_down'))
            .width(16)
            .height(16)
            .fillColor(ACCENT_COLOR)
        }
        .height(32)
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 16 })
      
      // 滚动视图容器
      Column() {
        // 固定Y轴标签
        Row() {
          // Y轴标签和网格线
          Column() {
            ForEach([0, 1, 2, 3], (i: number) => {
              Row() {
                Text(this.getYAxisLabel(3 - i))
                  .fontSize(10)
                  .fontColor(SECONDARY_TEXT_COLOR)
                  .width(30)
                  .textAlign(TextAlign.Start)
              }
              .width('100%')
              .position({ y: i * this.chartHeight / 3 })
            })
          }
          .width(30)
          .height(this.chartHeight)
          
          // 可滚动的图表内容
          Scroll() {
            Column() {
              Stack({ alignContent: Alignment.TopStart }) {
                // 绘制网格线
                Column() {
                  ForEach([0, 1, 2, 3], (i: number) => {
                    Divider()
                      .width('100%')
                      .strokeWidth(1)
                      .color(GRID_COLOR)
                      .opacity(0.6)
                      .position({ y: i * this.chartHeight / 3 })
                  })
                }
                .width(this.getScrollContentWidth())
                .height(this.chartHeight)
                
                // 柱状图
                Row() {
                  ForEach(this.getFormattedData(), (item: MetricData, index: number) => {
                    Column() {
                      Column()
                        .width(this.barWidth)
                        .height(this.getNormalizedValue(item.value) * this.chartHeight)
                        .backgroundColor(this.isAbnormalValue(item.value) ? ABNORMAL_COLOR : ACCENT_COLOR)
                        .borderRadius({ topLeft: 4, topRight: 4 })
                        .onClick(() => {
                          this.showDataTip = true;
                          this.selectedIndex = index;
                        })
                    }
                    .alignItems(HorizontalAlign.Center)
                    .width(this.pointSpacing)
                    .height('100%')
                    .justifyContent(FlexAlign.End)
                  })
                }
                .width(this.getScrollContentWidth())
                .height(this.chartHeight)
                
                // 数据提示标记
                if (this.showDataTip && this.selectedIndex >= 0) {
                  Column() {
                    Text(`${this.getFormattedData()[this.selectedIndex].value}`)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.isAbnormalValue(this.getFormattedData()[this.selectedIndex].value) ? ABNORMAL_COLOR : ACCENT_COLOR)
                    
                    Text(this.formatDate(this.getFormattedData()[this.selectedIndex].date))
                      .fontSize(10)
                      .fontColor(SECONDARY_TEXT_COLOR)
                  }
                  .padding(8)
                  .backgroundColor(Color.White)
                  .borderRadius(6)
                  .border({ width: 1, color: GRID_COLOR })
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: 2 })
                  .position({
                    x: this.selectedIndex * this.pointSpacing + this.pointSpacing / 2 - 30,
                    y: this.chartHeight - this.getNormalizedValue(this.getFormattedData()[this.selectedIndex].value) * this.chartHeight - 60
                  })
                  .onClick(() => {
                    this.showDataTip = false;
                  })
                }
                
                // X轴日期标签 - 放在图表下方
                Column() {
                  Row() {
                    ForEach(this.getFormattedData(), (item: MetricData, index: number) => {
                      // 根据时间范围和索引决定是否显示完整标签
                      Text(this.shouldShowFullLabel(index) ? this.formatDate(item.date) : '')
                        .fontSize(10)
                        .fontColor(SECONDARY_TEXT_COLOR)
                        .width(this.pointSpacing)
                        .textAlign(TextAlign.Center)
                    })
                  }
                  .width(this.getScrollContentWidth())
                  .height(20)
                }
                .width(this.getScrollContentWidth())
                .position({ y: this.chartHeight + 5 })
              }
              .width(this.getScrollContentWidth())
              .height(this.chartHeight + 30)
            }
            .width(this.getScrollContentWidth())
            .alignItems(HorizontalAlign.Start)
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
          .onAppear(() => {
            if (this.initialScroll) {
              // 初始时检查是否需要滚动到最新数据
              if (this.getScrollContentWidth() > this.chartWidth) {
                this.initialScroll = false;
              }
            }
          })
        }
        .width('100%')
        .height(this.chartHeight + 30)
      }
      .width('100%')
      .padding({ top: 16, right: 16, bottom: 16 })
      .backgroundColor('#F5F9FF')
      .borderRadius(8)
      .onAreaChange((oldArea: Area, newArea: Area) => {
        // 当大小变化时更新
        if (newArea.width !== oldArea.width || newArea.height !== oldArea.height) {
          this.chartWidth = newArea.width as number - 32;
          this.updatePointSpacing();
        }
      })
      
      // 数据分析说明
      this.buildAnalysis()
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
  }
  
  // 获取滚动内容的总宽度
  getScrollContentWidth(): number {
    const dataCount = this.getFormattedData().length;
    return dataCount * this.pointSpacing;
  }
  
  // 值归一化处理（转为0-1之间的值）
  getNormalizedValue(value: number): number {
    const minValue = this.getMinValue() * 0.9; // 留出10%下边距
    const maxValue = this.getMaxValue() * 1.1; // 留出10%上边距
    const range = maxValue - minValue;
    
    if (range === 0) {
      return 0.5; // 避免除以零
    }
    
    return (value - minValue) / range;
  }
  
  // 获取Y轴标签
  getYAxisLabel(index: number): string {
    const minValue = this.getMinValue() * 0.9;
    const maxValue = this.getMaxValue() * 1.1;
    const step = (maxValue - minValue) / 3;
    const value = minValue + index * step;
    
    return value.toFixed(1);
  }
  
  // 判断是否为异常值
  isAbnormalValue(value: number): boolean {
    const avgValue = this.getAvgValue();
    const stdDev = this.getStdDeviation();
    return Math.abs(value - avgValue) > stdDev * 2; // 偏离2个标准差认为是异常
  }
  
  // 获取平均值
  getAvgValue(): number {
    const data = this.getFormattedData();
    if (data.length === 0) return 0;
    
    const sum = data.reduce((acc: number, item: MetricData) => acc + item.value, 0);
    return sum / data.length;
  }
  
  // 获取标准差
  getStdDeviation(): number {
    const data = this.getFormattedData();
    if (data.length <= 1) return 0;
    
    const avg = this.getAvgValue();
    const squaredDiffs = data.map((item: MetricData): number => Math.pow(item.value - avg, 2));
    const variance = squaredDiffs.reduce((acc: number, val: number) => acc + val, 0) / data.length;
    return Math.sqrt(variance);
  }
  
  // 格式化显示的数据
  getFormattedData(): MetricData[] {
    // 根据时间范围过滤数据
    if (this.metrics.length === 0) {
      return this.generateMockData();
    }
    return this.metrics.slice(-this.getDataPointCount());
  }
  
  // 获取最小值
  getMinValue(): number {
    const data = this.getFormattedData();
    if (data.length === 0) return 0;
    
    return Math.min(...data.map((item: MetricData): number => item.value));
  }
  
  // 获取最大值
  getMaxValue(): number {
    const data = this.getFormattedData();
    if (data.length === 0) return 100;
    
    return Math.max(...data.map((item: MetricData): number => item.value));
  }
  
  // 获取数据点数量
  getDataPointCount(): number {
    switch (this.timeRange) {
      case TimeRange.DAY:
        return 24; // 每小时一个点
      case TimeRange.WEEK:
        return 7; // 每天一个点
      case TimeRange.MONTH:
        return 30; // 每天一个点
      case TimeRange.YEAR:
        return 12; // 每月一个点
      default:
        return 7;
    }
  }
  
  // 判断是否应该显示完整X轴标签
  // 根据时间范围和数据量，减少标签显示，避免重叠
  shouldShowFullLabel(index: number): boolean {
    const data = this.getFormattedData();
    if (data.length === 0) return false;
    
    switch (this.timeRange) {
      case TimeRange.DAY:
        // 对于日视图，每3小时显示一次标签
        return index % 3 === 0 || index === data.length - 1;
        
      case TimeRange.WEEK:
        // 周视图所有点都显示
        return true;
        
      case TimeRange.MONTH:
        // 对于月视图，每5天或关键日期显示
        return index % 5 === 0 || index === data.length - 1;
        
      case TimeRange.YEAR:
        // 对于年视图，每个月都显示
        return true;
        
      default:
        return index % 2 === 0; // 默认每隔一个显示
    }
  }
  
  // 格式化X轴日期显示，确保适合不同时间范围
  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    
    switch (this.timeRange) {
      case TimeRange.DAY:
        // 对于日视图，显示小时
        const hour: number = date.getHours();
        return `${hour}:00`;
        
      case TimeRange.WEEK:
        // 对于周视图，显示星期几
        return ['周日', '周一', '周二', '周三', '周四', '周五', '周六'][date.getDay()];
        
      case TimeRange.MONTH:
        // 对于月视图，显示日期
        const day: number = date.getDate();
        return `${day}日`;
        
      case TimeRange.YEAR:
        // 对于年视图，显示月份
        return `${date.getMonth() + 1}月`;
        
      default:
        return dateStr;
    }
  }
  
  // 生成模拟数据（当没有真实数据时使用）
  generateMockData(): MetricData[] {
    const result: MetricData[] = [];
    const count = this.getDataPointCount();
    const now = new Date();
    
    for (let i = 0; i < count; i++) {
      const date = new Date();
      
      switch (this.timeRange) {
        case TimeRange.DAY:
          date.setHours(now.getHours() - (count - i - 1));
          break;
        case TimeRange.WEEK:
          date.setDate(now.getDate() - (count - i - 1));
          break;
        case TimeRange.MONTH:
          date.setDate(now.getDate() - (count - i - 1));
          break;
        case TimeRange.YEAR:
          date.setMonth(now.getMonth() - (count - i - 1));
          break;
      }
      
      // 生成更符合真实数据分布的数据
      let value: number;
      
      switch (this.timeRange) {
        case TimeRange.DAY:
          // 日内变化 - 早晨和晚上低，中午和下午高
          const hour: number = date.getHours();
          const baseValue: number = 50;
          const amplitude: number = 20;
          value = baseValue + amplitude * Math.sin((hour - 6) / 24 * Math.PI * 2);
          value += (Math.random() - 0.5) * 5; // 轻微随机波动
          break;
          
        case TimeRange.WEEK:
          // 周内变化 - 工作日逐步升高，周末下降
          const day: number = date.getDay();
          value = 50 + (day <= 5 ? day * 5 : (7 - day) * 5);
          value += (Math.random() - 0.5) * 8; // 随机波动
          break;
          
        case TimeRange.MONTH:
          // 月内变化 - 波浪形变化
          const dayOfMonth: number = date.getDate();
          value = 50 + 15 * Math.sin(dayOfMonth / 30 * Math.PI * 2);
          value += (Math.random() - 0.5) * 10; // 随机波动
          break;
          
        case TimeRange.YEAR:
          // 年内变化 - 季节性变化
          const month: number = date.getMonth();
          value = 50 + 20 * Math.sin((month / 12) * Math.PI * 2);
          value += (Math.random() - 0.5) * 12; // 随机波动
          break;
          
        default:
          value = 50 + (Math.random() - 0.5) * 20;
      }
      
      // 添加异常值，但保证只在视图范围内出现1-2个明显异常
      if ((this.timeRange === TimeRange.DAY && i === 14) || 
          (this.timeRange === TimeRange.WEEK && i === 3) || 
          (this.timeRange === TimeRange.MONTH && i === 15) || 
          (this.timeRange === TimeRange.YEAR && i === 7)) {
        value += 25; // 添加明显异常值
      }
      
      result.push({
        date: date.toISOString(),
        value: parseFloat(value.toFixed(1))
      });
    }
    
    return result;
  }
  
  @Builder
  buildAnalysis() {
    Column() {
      Text('数据分析')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .margin({ top: 16, bottom: 8 })
      
      Row() {
        Column() {
          Text('平均值')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)
          
          Text(this.getAvgValue().toFixed(1))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        Divider()
          .vertical(true)
          .height(40)
          .color(GRID_COLOR)
        
        Column() {
          Text('最大值')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)
          
          Text(this.getMaxValue().toFixed(1))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        Divider()
          .vertical(true)
          .height(40)
          .color(GRID_COLOR)
        
        Column() {
          Text('最小值')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)
          
          Text(this.getMinValue().toFixed(1))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ top: 12, bottom: 12 })
      .margin({ bottom: 12 })
      .borderRadius(8)
      .backgroundColor('#F9FAFC')
      
      Text('根据您的' + this.selectedMetric + '历史数据分析，当前指标整体呈现' + this.getTrendDescription() + '。' + this.getAbnormalDescription())
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
    }
    .width('100%')
    .margin({ top: 8 })
  }
  
  // 获取趋势描述
  getTrendDescription(): string {
    const data = this.getFormattedData();
    if (data.length < 2) return "稳定趋势";
    
    const firstHalf = data.slice(0, Math.floor(data.length / 2));
    const secondHalf = data.slice(Math.floor(data.length / 2));
    
    const firstAvg = firstHalf.reduce((sum: number, item: MetricData) => sum + item.value, 0) / firstHalf.length;
    const secondAvg = secondHalf.reduce((sum: number, item: MetricData) => sum + item.value, 0) / secondHalf.length;
    
    const diff = secondAvg - firstAvg;
    const percentage = Math.abs(diff / firstAvg * 100).toFixed(1);
    
    if (Math.abs(diff) < this.getStdDeviation() * 0.5) {
      return "稳定趋势";
    } else if (diff > 0) {
      return `上升趋势（增加${percentage}%）`;
    } else {
      return `下降趋势（减少${percentage}%）`;
    }
  }
  
  // 获取异常值描述
  getAbnormalDescription(): string {
    const data = this.getFormattedData();
    const abnormalPoints = data.filter((item: MetricData): boolean => this.isAbnormalValue(item.value));
    
    if (abnormalPoints.length === 0) {
      return "近期变化在正常范围内";
    } else if (abnormalPoints.length === 1) {
      const abnormal = abnormalPoints[0];
      const date = this.formatDate(abnormal.date);
      return `${date}出现一个异常值${abnormal.value}，建议关注`;
    } else {
      return `期间出现${abnormalPoints.length}个异常值，建议定期监测`;
    }
  }
  
  // 处理时间范围变化
  handleTimeRangeChange() {
    if (this.timeRange !== this.previousTimeRange) {
      // 重置数据提示标记
      this.showDataTip = false;
      this.selectedIndex = -1;
      
      // 更新点间距
      this.updatePointSpacing();
      
      // 更新previousTimeRange
      this.previousTimeRange = this.timeRange;
      
      // 增加renderKey强制重新渲染
      this.renderKey++;
      
      // 重置滚动状态
      this.initialScroll = true;
    }
  }
  
  // 动态更新点间距
  updatePointSpacing() {
    const dataCount = this.getDataPointCount();
    const minSpacing = 20; // 最小间距
    let calculatedSpacing = 0;
    
    // 根据时间范围和容器宽度动态调整点间距
    switch (this.timeRange) {
      case TimeRange.DAY:
        // 日视图点多，间距小一些
        calculatedSpacing = Math.max(minSpacing, Math.min(60, this.chartWidth / Math.max(dataCount, 1)));
        break;
      case TimeRange.WEEK:
        // 周视图适中间距
        calculatedSpacing = Math.max(minSpacing, Math.min(80, this.chartWidth / Math.max(dataCount, 1)));
        break;
      case TimeRange.MONTH:
        // 月视图点多，需要较小间距
        calculatedSpacing = Math.max(minSpacing, Math.min(50, this.chartWidth / Math.max(dataCount, 1)));
        break;
      case TimeRange.YEAR:
        // 年视图点少，间距大一些
        calculatedSpacing = Math.max(minSpacing, Math.min(90, this.chartWidth / Math.max(dataCount, 1)));
        break;
      default:
        calculatedSpacing = Math.max(minSpacing, this.chartWidth / Math.max(dataCount, 10));
    }
    
    // 设置点间距，并确保最小值有保障
    this.pointSpacing = Math.max(calculatedSpacing, minSpacing);
    
    // 根据间距调整柱形宽度
    this.barWidth = Math.min(16, this.pointSpacing * 0.6);
  }
}