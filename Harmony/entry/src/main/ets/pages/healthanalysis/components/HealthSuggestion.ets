// 健康建议组件
// 提供基于健康数据分析的个性化建议

// 颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const SUGGESTION_CARD_COLORS: ResourceColor[] = [
  '#fff8d4', // 淡黄色
  '#d9f5ff', // 淡蓝色
  '#e4ffec', // 淡绿色
  '#ffe4e1'  // 淡红色
];

// 健康指标数据接口
interface HealthMetric {
  name: string;
  value: number;
  unit: string;
  normalRange: string;
  trend: number;
  riskLevel: string;
}

// 健康风险项目接口
interface HealthRisk {
  name: string;
  probability: number;
  level: string;
  description: string;
  suggestions: string[];
}

// 健康建议类型
interface HealthSuggestionItem {
  id: number;
  title: string;
  content: string;
  icon: Resource;
  category: string; // 分类：饮食、运动、睡眠、医疗
  importance: number; // 重要程度：1-5
}

@Component
export struct HealthSuggestion {
  @Prop metrics: HealthMetric[];
  @Prop risks: HealthRisk[];
  @State suggestions: HealthSuggestionItem[] = [];
  @State selectedCategory: string = '全部';
  @State categories: string[] = ['全部', '饮食', '运动', '睡眠', '医疗'];

  aboutToAppear() {
    this.generateSuggestions();
  }

  generateSuggestions() {
    // 基于健康指标和风险生成个性化建议
    let allSuggestions: HealthSuggestionItem[] = [];
    
    // 先添加一些基础建议
    allSuggestions.push({
      id: 1,
      title: '每日活动目标',
      content: '保持每天30分钟中等强度活动，如快走、游泳或骑自行车，可以改善心血管健康。',
      icon: $r('app.media.heart_icon'),
      category: '运动',
      importance: 4
    });

    allSuggestions.push({
      id: 2,
      title: '规律作息',
      content: '每晚保持7-8小时充足睡眠，建议22:30前入睡，有助于身体恢复和免疫系统健康。',
      icon: $r('app.media.sleep_quality'),
      category: '睡眠',
      importance: 3
    });

    // 基于血压添加建议
    const bloodPressureMetric = this.metrics.find(m => m.name === '血压');
    if (bloodPressureMetric && bloodPressureMetric.value > 130) {
      allSuggestions.push({
        id: 3,
        title: '控制钠盐摄入',
        content: '您的血压偏高，建议限制每日钠盐摄入量不超过5克，减少加工食品和外卖的摄入。',
        icon: $r('app.media.food'),
        category: '饮食',
        importance: 5
      });
    }

    // 基于血糖添加建议
    const bloodSugarMetric = this.metrics.find(m => m.name === '血糖');
    if (bloodSugarMetric && bloodSugarMetric.value > 5.6) {
      allSuggestions.push({
        id: 4,
        title: '控制碳水化合物',
        content: '您的血糖水平偏高，建议选择低GI值的碳水化合物食物，如全麦面包、糙米等，避免精制糖。',
        icon: $r('app.media.food2'),
        category: '饮食',
        importance: 5
      });
    }

    // 基于心率添加建议
    const heartRateMetric = this.metrics.find(m => m.name === '心率');
    if (heartRateMetric) {
      if (heartRateMetric.value > 90) {
        allSuggestions.push({
          id: 5,
          title: '静心放松',
          content: '您的静息心率偏高，建议尝试每天10-15分钟的深呼吸或冥想练习，有助于降低心率和压力。',
          icon: $r('app.media.heart_rhythm'),
          category: '睡眠',
          importance: 4
        });
      } else if (heartRateMetric.value < 60) {
        allSuggestions.push({
          id: 6,
          title: '心率监测',
          content: '您的静息心率偏低，如无不适感可能是良好体能的表现，但建议定期监测心率变化。',
          icon: $r('app.media.heart_variability'),
          category: '医疗',
          importance: 3
        });
      }
    }

    // 基于风险添加建议
    for (const risk of this.risks) {
      if (risk.level === 'high' && risk.name === '睡眠质量问题') {
        allSuggestions.push({
          id: 7,
          title: '改善睡眠环境',
          content: '您的睡眠质量较差，建议保持卧室安静、黑暗、凉爽，睡前避免咖啡因和电子设备。',
          icon: $r('app.media.sleep_pattern'),
          category: '睡眠',
          importance: 5
        });
      }

      if (risk.name === '高血压风险' && risk.probability > 30) {
        allSuggestions.push({
          id: 8,
          title: '定期测量血压',
          content: '您存在高血压风险，建议每周至少测量2-3次血压，并记录数值以便医生评估。',
          icon: $r('app.media.medical'),
          category: '医疗',
          importance: 5
        });
      }

      if (risk.name === '糖尿病前期' && risk.probability > 20) {
        allSuggestions.push({
          id: 9,
          title: '减少加工食品',
          content: '建议减少加工食品和精制碳水化合物的摄入，增加蔬菜、水果和全谷物的比例。',
          icon: $r('app.media.food'),
          category: '饮食',
          importance: 4
        });
      }
    }

    // 添加通用建议
    allSuggestions.push({
      id: 10,
      title: '补充足够水分',
      content: '每天饮水1.5-2升，保持良好的水分平衡，有助于新陈代谢和毒素排出。',
      icon: $r('app.media.info'),
      category: '饮食',
      importance: 3
    });

    allSuggestions.push({
      id: 11,
      title: '每日伸展',
      content: '每天进行5-10分钟的全身伸展，有助于提高灵活性和减轻肌肉紧张。',
      icon: $r('app.media.tips_icon'),
      category: '运动',
      importance: 3
    });

    // 按重要性排序
    this.suggestions = allSuggestions.sort((a, b) => b.importance - a.importance);
  }

  getFilteredSuggestions(): HealthSuggestionItem[] {
    if (this.selectedCategory === '全部') {
      return this.suggestions;
    }
    return this.suggestions.filter(s => s.category === this.selectedCategory);
  }

  build() {
    Column() {
      // 标题
      Text('AI个性化健康建议')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .margin({ bottom: 16 })

      // 分类选择器
      Row() {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(14)
            .fontWeight(this.selectedCategory === category ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedCategory === category ? ACCENT_COLOR : SECONDARY_TEXT_COLOR)
            .backgroundColor(this.selectedCategory === category ? '#E8F1FF' : 'transparent')
            .borderRadius(16)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8 })
            .onClick(() => {
              this.selectedCategory = category;
            })
        })
      }
      .width('100%')
      .margin({ bottom: 16 })
      .justifyContent(FlexAlign.Start)

      // 建议列表
      if (this.getFilteredSuggestions().length > 0) {
        ForEach(this.getFilteredSuggestions(), (suggestion: HealthSuggestionItem, index: number) => {
          this.buildSuggestionCard(suggestion, index)
        })
      } else {
        // 没有建议
        Column() {
          Image($r('app.media.info'))
            .width(48)
            .height(48)
            .margin({ bottom: 8 })
            .fillColor(SECONDARY_TEXT_COLOR)
          
          Text('暂无此类别的健康建议')
            .fontSize(16)
            .fontColor(SECONDARY_TEXT_COLOR)
        }
        .width('100%')
        .padding(24)
        .justifyContent(FlexAlign.Center)
      }

      // AI解释说明
      Text('* 建议基于您的健康数据使用智能算法生成，仅供参考，不构成医疗建议')
        .fontSize(12)
        .fontColor(SECONDARY_TEXT_COLOR)
        .fontStyle(FontStyle.Italic)
        .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
  }
  
  @Builder
  buildSuggestionCard(suggestion: HealthSuggestionItem, index: number) {
    Column() {
      Row() {
        // 图标
        Image(suggestion.icon)
          .width(32)
          .height(32)
          .fillColor(ACCENT_COLOR)
        
        // 标题
        Text(suggestion.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(PRIMARY_TEXT_COLOR)
          .margin({ left: 12 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 8 })
      
      // 内容
      Text(suggestion.content)
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ bottom: 4 })
      
      // 标签
      Row() {
        Text(suggestion.category)
          .fontSize(12)
          .fontColor(ACCENT_COLOR)
          .backgroundColor('#E8F1FF')
          .borderRadius(12)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(SUGGESTION_CARD_COLORS[index % SUGGESTION_CARD_COLORS.length])
    .borderRadius(12)
    .margin({ bottom: 12 })
  }
} 