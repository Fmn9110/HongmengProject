import { Toolbar } from '../../component/Toolbar';
import router from '@ohos.router';
import { HealthTrendChart } from './components/HealthTrendChart';
import { RiskAssessment } from './components/RiskAssessment';
import { HealthSuggestion } from './components/HealthSuggestion';

// 颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const DIVIDER_COLOR: ResourceColor = '#E5E5E5';
const LIGHT_BLUE: ResourceColor = '#fff6f8ff';
const RISK_HIGH_COLOR: ResourceColor = '#ff3b30';
const RISK_MEDIUM_COLOR: ResourceColor = '#ff9500';
const RISK_LOW_COLOR: ResourceColor = '#34c759';

// 健康风险等级
enum RiskLevel {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high'
}

// 健康指标数据接口
interface HealthMetric {
  name: string;
  value: number;
  unit: string;
  normalRange: string;
  trend: number; // 变化趋势百分比，正值上升，负值下降
  riskLevel: RiskLevel;
}

// 健康风险项目接口
interface HealthRisk {
  name: string;
  probability: number; // 概率百分比
  level: RiskLevel;
  description: string;
  suggestions: string[];
}

// 异常点数据接口
interface Anomaly {
  date: string;
  metric: string;
  value: number;
  normalRange: string;
}

// MetricData接口
interface MetricData {
  date: string;
  value: number;
}

@Entry
@Component
export default struct HealthAnalysisPage {
  @State isLoading: boolean = true;
  @State overallHealthScore: number = 0;
  @State selectedTimeRange: string = '月';
  @State timeRangeOptions: string[] = ['日', '周', '月', '年'];
  @State healthMetrics: HealthMetric[] = [];
  @State healthRisks: HealthRisk[] = [];
  @State anomalies: Anomaly[] = []; // 异常点数据
  scroller: Scroller = new Scroller();

  aboutToAppear() {
    // 模拟数据加载
    setTimeout(() => {
      this.loadMockData();
      this.isLoading = false;
    }, 1000);
  }

  // 加载模拟数据
  loadMockData() {
    // 模拟健康评分
    this.overallHealthScore = 78;

    // 模拟健康指标数据
    this.healthMetrics = [
      {
        name: '心率',
        value: 72,
        unit: 'BPM',
        normalRange: '60-100',
        trend: -3.5,
        riskLevel: RiskLevel.LOW
      },
      {
        name: '血压',
        value: 135,
        unit: 'mmHg',
        normalRange: '90-120',
        trend: 5.2,
        riskLevel: RiskLevel.MEDIUM
      },
      {
        name: '血氧',
        value: 97,
        unit: '%',
        normalRange: '95-100',
        trend: 0.5,
        riskLevel: RiskLevel.LOW
      },
      {
        name: '体温',
        value: 36.8,
        unit: '°C',
        normalRange: '36.3-37.2',
        trend: 0.1,
        riskLevel: RiskLevel.LOW
      },
      {
        name: '血糖',
        value: 6.2,
        unit: 'mmol/L',
        normalRange: '3.9-6.1',
        trend: 8.7,
        riskLevel: RiskLevel.MEDIUM
      }
    ];

    // 模拟健康风险数据
    this.healthRisks = [
      {
        name: '高血压风险',
        probability: 35,
        level: RiskLevel.MEDIUM,
        description: '您的血压偶尔升高，存在中等程度的高血压风险。',
        suggestions: [
          '定期监测血压',
          '减少盐分摄入',
          '保持适度运动',
          '减轻体重'
        ]
      },
      {
        name: '糖尿病前期',
        probability: 28,
        level: RiskLevel.MEDIUM,
        description: '您的血糖水平略高于正常范围，可能处于糖尿病前期状态。',
        suggestions: [
          '控制碳水化合物摄入',
          '增加膳食纤维',
          '每周进行150分钟中等强度运动',
          '定期监测血糖'
        ]
      },
      {
        name: '睡眠质量问题',
        probability: 62,
        level: RiskLevel.HIGH,
        description: '您的睡眠数据显示睡眠质量较差，可能导致多种健康问题。',
        suggestions: [
          '保持规律的睡眠时间',
          '睡前一小时避免使用电子设备',
          '创造安静、舒适的睡眠环境',
          '考虑使用放松技巧如深呼吸或冥想'
        ]
      }
    ];

    // 模拟异常点数据
    this.anomalies = [
      {
        date: '2023-05-15',
        metric: '心率',
        value: 115,
        normalRange: '60-100'
      },
      {
        date: '2023-05-23',
        metric: '血压',
        value: 145,
        normalRange: '90-120'
      },
      {
        date: '2023-06-02',
        metric: '血糖',
        value: 7.8,
        normalRange: '3.9-6.1'
      }
    ];
  }

  // 获取风险等级对应的颜色
  getRiskColor(level: RiskLevel): ResourceColor {
    switch (level) {
      case RiskLevel.HIGH:
        return RISK_HIGH_COLOR;
      case RiskLevel.MEDIUM:
        return RISK_MEDIUM_COLOR;
      case RiskLevel.LOW:
      default:
        return RISK_LOW_COLOR;
    }
  }

  build() {
    Column() {
      // 自定义顶部栏
      this.buildCustomAppBar()

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(ACCENT_COLOR)
          Text('数据分析中...')
            .fontSize(16)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 10 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Color.White)
      } else {
        Scroll(this.scroller) {
          Column() {
            // 健康评分卡片
            this.buildHealthScoreCard()

            // 时间范围选择器
            this.buildTimeRangeSelector()

            // 健康指标趋势图
            HealthTrendChart({
              timeRange: $selectedTimeRange,
              selectedMetric: '心率',
              metrics: this.convertToMetricData('心率')
            })
              .margin({ top: 20, bottom: 20 })

            // 风险评估区
            RiskAssessment({
              risks: this.healthRisks
            })
              .margin({ bottom: 20 })

            // 健康建议区
            HealthSuggestion({
              metrics: this.healthMetrics,
              risks: this.healthRisks
            })
              .margin({ bottom: 20 })

            // 隐私说明
            this.buildPrivacyNotice()
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 20 })
          .backgroundColor(Color.White)
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1)
        .backgroundColor(Color.White)
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White)
  }

  // 顶部自定义AppBar
  @Builder
  buildCustomAppBar() {
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
        Text('智能健康分析')
          .fontSize(22)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
          .fontColor(PRIMARY_TEXT_COLOR)
        Blank()
        Row() {
          Image($r("app.media.ic_mores"))
            .width(25)
            .height(25)
            .margin({ right: 10 })
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
  }

  @Builder
  buildHealthScoreCard() {
    Column() {
      Text('您的健康评分')
        .fontSize(16)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ bottom: 10 })

      Row() {
        Text(this.overallHealthScore.toString())
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(PRIMARY_TEXT_COLOR)

        Text('/100')
          .fontSize(16)
          .fontColor(SECONDARY_TEXT_COLOR)
          .alignSelf(ItemAlign.End)
          .margin({ bottom: 10 })
      }

      Progress({ value: this.overallHealthScore, total: 100, type: ProgressType.Capsule })
        .color(this.getHealthScoreColor())
        .backgroundColor('#E0E0E0')
        .width('100%')
        .height(10)
        .margin({ top: 10, bottom: 10 })

      Text(this.getHealthScoreComment())
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ top: 5 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ top: 16 })
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  buildTimeRangeSelector() {
    Row() {
      ForEach(this.timeRangeOptions, (option: string) => {
        Text(option)
          .fontSize(14)
          .fontWeight(this.selectedTimeRange === option ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.selectedTimeRange === option ? ACCENT_COLOR : SECONDARY_TEXT_COLOR)
          .backgroundColor(this.selectedTimeRange === option ? '#E8F1FF' : 'transparent')
          .borderRadius(16)
          .padding({
            left: 12,
            right: 12,
            top: 6,
            bottom: 6
          })
          .margin({ right: 8 })
          .onClick(() => {
            this.selectedTimeRange = option;
          })
      })
    }
    .width('100%')
    .margin({ top: 16, bottom: 16 })
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  buildPrivacyNotice() {
    Column() {
      Text('隐私保护')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .margin({ bottom: 8 })

      Text('所有健康数据分析均在本地设备上完成，确保您的隐私安全。我们使用TensorFlow Lite轻量级AI模型进行数据处理，不会将您的健康数据上传至云端。')
        .fontSize(12)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ bottom: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .opacity(0.9)
  }

  // 获取健康评分对应的颜色
  getHealthScoreColor(): ResourceColor {
    if (this.overallHealthScore >= 80) {
      return RISK_LOW_COLOR;
    } else if (this.overallHealthScore >= 60) {
      return RISK_MEDIUM_COLOR;
    } else {
      return RISK_HIGH_COLOR;
    }
  }

  // 获取健康评分评语
  getHealthScoreComment(): string {
    if (this.overallHealthScore >= 80) {
      return '您的健康状况良好，请继续保持健康的生活方式。';
    } else if (this.overallHealthScore >= 60) {
      return '您的健康状况一般，有一些潜在风险需要关注。';
    } else {
      return '您的健康状况需要改善，请关注高风险项并咨询医生。';
    }
  }

  // 将健康指标数据转换为MetricData[]类型
  convertToMetricData(metricName: string): MetricData[] {
    // 为选定指标生成7天的数据点
    const result: MetricData[] = [];
    const metric = this.healthMetrics.find(m => m.name === metricName);

    if (!metric) {
      return [];
    }

    const baseValue = metric.value;
    const variance = baseValue * 0.1; // 基础值的10%作为波动范围
    const today = new Date();

    // 根据时间范围生成不同数量的数据点
    let dataPointCount = 7; // 默认为周视图(7天)

    switch (this.selectedTimeRange) {
      case '日':
        dataPointCount = 24; // 24小时
        break;
      case '周':
        dataPointCount = 7; // 7天
        break;
      case '月':
        dataPointCount = 30; // 30天
        break;
      case '年':
        dataPointCount = 12; // 12个月
        break;
    }

    // 生成历史数据点
    for (let i = dataPointCount - 1; i >= 0; i--) {
      const date = new Date(today);

      // 根据时间范围调整日期
      switch (this.selectedTimeRange) {
        case '日':
          date.setHours(today.getHours() - i);
          break;
        case '周':
          date.setDate(today.getDate() - i);
          break;
        case '月':
          date.setDate(today.getDate() - i);
          break;
        case '年':
          date.setMonth(today.getMonth() - i);
          break;
      }

      // 生成随机波动的值
      const randomVariance = (Math.random() - 0.5) * variance * 2;
      const value = parseFloat((baseValue + randomVariance).toFixed(1));

      result.push({
        date: date.toISOString(),
        value: value
      });
    }

    // 添加异常点数据(如果存在)
    const anomaliesForMetric = this.anomalies.filter(a => a.metric === metricName);
    for (const anomaly of anomaliesForMetric) {
      const anomalyDate = new Date(anomaly.date);
      // 检查异常点是否在当前时间范围内
      if (this.isDateInRange(anomalyDate, this.selectedTimeRange)) {
        // 更新或添加异常点数据
        const existingIndex = result.findIndex(item => {
          const itemDate = new Date(item.date);
          return this.areDatesEqual(itemDate, anomalyDate, this.selectedTimeRange);
        });

        if (existingIndex !== -1) {
          result[existingIndex].value = anomaly.value;
        } else {
          result.push({
            date: anomalyDate.toISOString(),
            value: anomaly.value
          });
        }
      }
    }

    // 按日期排序
    return result.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  }

  // 检查日期是否在当前选择的时间范围内
  isDateInRange(date: Date, timeRange: string): boolean {
    const today = new Date();

    switch (timeRange) {
      case '日':
        return date.getFullYear() === today.getFullYear() &&
          date.getMonth() === today.getMonth() &&
          date.getDate() === today.getDate();
      case '周':
        const weekAgo = new Date(today);
        weekAgo.setDate(today.getDate() - 7);
        return date >= weekAgo && date <= today;
      case '月':
        const monthAgo = new Date(today);
        monthAgo.setDate(today.getDate() - 30);
        return date >= monthAgo && date <= today;
      case '年':
        const yearAgo = new Date(today);
        yearAgo.setFullYear(today.getFullYear() - 1);
        return date >= yearAgo && date <= today;
      default:
        return false;
    }
  }

  // 根据时间范围比较两个日期是否"相等"
  areDatesEqual(date1: Date, date2: Date, timeRange: string): boolean {
    switch (timeRange) {
      case '日':
        return date1.getFullYear() === date2.getFullYear() &&
          date1.getMonth() === date2.getMonth() &&
          date1.getDate() === date2.getDate() &&
          date1.getHours() === date2.getHours();
      case '周':
      case '月':
        return date1.getFullYear() === date2.getFullYear() &&
          date1.getMonth() === date2.getMonth() &&
          date1.getDate() === date2.getDate();
      case '年':
        return date1.getFullYear() === date2.getFullYear() &&
          date1.getMonth() === date2.getMonth();
      default:
        return false;
    }
  }
} 