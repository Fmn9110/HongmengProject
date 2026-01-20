// 风险评估组件
// 用于展示健康风险评估结果

// 颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const RISK_HIGH_COLOR: ResourceColor = '#ff3b30';
const RISK_MEDIUM_COLOR: ResourceColor = '#ff9500';
const RISK_LOW_COLOR: ResourceColor = '#34c759';

// 健康风险等级
enum RiskLevel {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high'
}

// 健康风险项目接口
interface HealthRisk {
  name: string;
  probability: number; // 概率百分比
  level: RiskLevel;
  description: string;
  suggestions: string[];
}

@Component
export struct RiskAssessment {
  @Prop risks: HealthRisk[];
  @State expandedRiskIndex: number = -1;
  
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
      // 标题
      Text('健康风险评估')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .margin({ bottom: 16 })
      
      // 风险列表
      if (this.risks.length > 0) {
        ForEach(this.risks, (risk: HealthRisk, index: number) => {
          this.buildRiskItem(risk, index)
        })
      } else {
        // 没有风险数据
        Column() {
          Image($r('app.media.check'))
            .width(48)
            .height(48)
            .margin({ bottom: 8 })
            .fillColor('#34c759')
          
          Text('暂未检测到明显健康风险')
            .fontSize(16)
            .fontColor(SECONDARY_TEXT_COLOR)
        }
        .width('100%')
        .padding(24)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 2 })
  }
  
  @Builder
  buildRiskItem(risk: HealthRisk, index: number) {
    Column() {
      // 风险项目头部（始终显示）
      Row() {
        Column() {
          Row({ space: 8 }) {
            Text(risk.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_TEXT_COLOR)
            
            Text(`${risk.probability}%`)
              .fontSize(14)
              .fontWeight(FontWeight.Normal)
              .fontColor(this.getRiskColor(risk.level))
          }
          
          Progress({ value: risk.probability, total: 100, type: ProgressType.Linear })
            .color(this.getRiskColor(risk.level))
            .backgroundColor('#E0E0E0')
            .width('100%')
            .height(4)
            .margin({ top: 8, bottom: 8 })
          
          Text(this.getRiskLevelText(risk.level))
            .fontSize(12)
            .fontColor(this.getRiskColor(risk.level))
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(this.getRiskLevelBgColor(risk.level))
            .borderRadius(12)
        }
        .layoutWeight(1)
        
        // 展开/收起图标
        Image(this.expandedRiskIndex === index ? $r('app.media.ic_arrow_up') : $r('app.media.ic_arrow_down'))
          .width(24)
          .height(24)
          .margin({ left: 8 })
      }
      .width('100%')
      .onClick(() => {
        this.expandedRiskIndex = this.expandedRiskIndex === index ? -1 : index;
      })
      
      // 详细内容（点击后展开）
      if (this.expandedRiskIndex === index) {
        Column() {
          Text(risk.description)
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 12, bottom: 12 })
          
          // 建议列表
          Column() {
            Text('建议')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_TEXT_COLOR)
              .margin({ bottom: 8 })
            
            ForEach(risk.suggestions, (suggestion: string) => {
              Row({ space: 8 }) {
                Circle({ width: 6, height: 6 })
                  .fill(ACCENT_COLOR)
                  .margin({ top: 6 })
                
                Text(suggestion)
                  .fontSize(14)
                  .fontColor(SECONDARY_TEXT_COLOR)
                  .layoutWeight(1)
              }
              .alignItems(VerticalAlign.Top)
              .margin({ bottom: 6 })
            })
          }
          .width('100%')
          .backgroundColor('#F5F9FF')
          .borderRadius(8)
          .padding(12)
        }
        .width('100%')
        .margin({ top: 12 })
        .animation({
          duration: 200,
          curve: Curve.EaseOut
        })
      }
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .margin({ bottom: index < this.risks.length - 1 ? 8 : 0 })
    .borderRadius(12)
    .backgroundColor(Color.White)
    .border({
      width: 1,
      color: '#E0E0E0',
      style: BorderStyle.Solid
    })
    .padding(12)
  }
  
  // 获取风险等级文本
  getRiskLevelText(level: RiskLevel): string {
    switch (level) {
      case RiskLevel.HIGH:
        return '高风险';
      case RiskLevel.MEDIUM:
        return '中风险';
      case RiskLevel.LOW:
      default:
        return '低风险';
    }
  }
  
  // 获取风险等级背景色
  getRiskLevelBgColor(level: RiskLevel): ResourceColor {
    switch (level) {
      case RiskLevel.HIGH:
        return 'rgba(255, 59, 48, 0.1)';
      case RiskLevel.MEDIUM:
        return 'rgba(255, 149, 0, 0.1)';
      case RiskLevel.LOW:
      default:
        return 'rgba(52, 199, 89, 0.1)';
    }
  }
} 