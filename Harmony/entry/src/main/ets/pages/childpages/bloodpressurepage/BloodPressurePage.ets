import { router } from '@kit.ArkUI'

const PRIMARY_TEXT_COLOR: string = '#222831'
const SECONDARY_TEXT_COLOR: string = '#666666'
const ACCENT_COLOR: string = '#007DFF'
const SYSTOLIC_COLOR: string = '#007DFF' // 收缩压颜色（蓝色）
const DIASTOLIC_COLOR: string = '#FF4D4F' // 舒张压颜色（红色）
const LOW_RISK_COLOR: string = '#52C41A' // 低风险颜色
const MEDIUM_RISK_COLOR: string = '#FAAD14' // 中风险颜色
const HIGH_RISK_COLOR: string = '#FF4D4F' // 高风险颜色

interface bp {
  systolic: number, // 收缩压
  diastolic: number
}

// 血压风险级别
enum BpRiskLevel {
  NORMAL = '正常',
  ELEVATED = '偏高',
  HYPERTENSION_1 = '高血压一级',
  HYPERTENSION_2 = '高血压二级',
  HYPERTENSIVE_CRISIS = '高血压危象'
}

@Entry
@Component
struct BloodPressurePage {
  @State bpHistory: bp[] = []
  @State sleepHistory: number[] = [7.3, 5.5, 8.0, 7.8, 9.6, 7.2, 8.5] // 心率历史数据
  @State currentIndex: number = 0;
  @State aiAnalysis: string = '';
  @State riskLevel: BpRiskLevel = BpRiskLevel.NORMAL;
  @State riskPercentage: number = 0;
  @State healthTips: string[] = [];
  @State isAnalyzing: boolean = false;
  @State scrollHintOpacity: number = 1;
  @State showScrollHint: boolean = true;
  private swiperImages: Resource[] = [
    $r('app.media.award1'),
    $r('app.media.award2'),
    $r('app.media.award3')
  ];

  aboutToAppear() {
    this.generateRandomData();
    this.performAiAnalysis();
    this.startScrollHintAnimation();
  }

  // 开始滑动提示动画
  private startScrollHintAnimation() {
    // 3秒后淡出提示文本
    setTimeout(() => {
      animateTo({ duration: 1000 }, () => {
        this.scrollHintOpacity = 0;
      });

      // 完全淡出后隐藏提示
      setTimeout(() => {
        this.showScrollHint = false;
      }, 1000);
    }, 3000);
  }

  // 生成随机血压数据
  private generateRandomData() {
    this.bpHistory = [];
    for (let i = 0; i < 7; i++) {
      // 收缩压范围通常为90-140，舒张压范围通常为60-90
      const systolic = Math.floor(Math.random() * 50) + 100;
      const diastolic = Math.floor(Math.random() * 30) + 65;
      this.bpHistory.push({ systolic, diastolic });
    }

    // 重新分析新数据
    this.performAiAnalysis();
  }

  // 执行AI分析
  private performAiAnalysis() {
    this.isAnalyzing = true;

    // 模拟AI分析延迟
    setTimeout(() => {
      this.calculateRiskLevel();
      this.generateHealthTips();
      this.generateAiAnalysis();
      this.isAnalyzing = false;
    }, 1000);
  }

  // 计算风险等级
  private calculateRiskLevel() {
    // 获取最近一次血压数据进行分析
    const latestBp = this.bpHistory[this.bpHistory.length - 1];
    const systolic = latestBp.systolic;
    const diastolic = latestBp.diastolic;

    // 根据美国心脏协会指南确定风险级别
    if (systolic < 120 && diastolic < 80) {
      this.riskLevel = BpRiskLevel.NORMAL;
      this.riskPercentage = 10;
    } else if ((systolic >= 120 && systolic <= 129) && diastolic < 80) {
      this.riskLevel = BpRiskLevel.ELEVATED;
      this.riskPercentage = 30;
    } else if ((systolic >= 130 && systolic <= 139) || (diastolic >= 80 && diastolic <= 89)) {
      this.riskLevel = BpRiskLevel.HYPERTENSION_1;
      this.riskPercentage = 60;
    } else if ((systolic >= 140 && systolic <= 180) || (diastolic >= 90 && diastolic <= 120)) {
      this.riskLevel = BpRiskLevel.HYPERTENSION_2;
      this.riskPercentage = 80;
    } else if (systolic > 180 || diastolic > 120) {
      this.riskLevel = BpRiskLevel.HYPERTENSIVE_CRISIS;
      this.riskPercentage = 95;
    }
  }

  // 生成健康建议
  private generateHealthTips() {
    const tips = [
      '坚持低盐饮食，每日盐摄入量控制在5克以下',
      '规律进行有氧运动，每周至少150分钟',
      '保持健康体重，减轻体重可有效降低血压',
      '减少酒精摄入，限制咖啡因摄入量',
      '戒烟并避免二手烟环境',
      '增加蔬菜水果摄入，适量摄入富含钾的食物',
      '保持良好睡眠习惯，每晚睡眠7-8小时',
      '学习压力管理技巧，如冥想和深呼吸练习',
      '按时服用医生处方的降压药物',
      '每天按时测量并记录血压数据'
    ];

    // 根据风险级别选择不同数量的建议
    let count = 3; // 默认3条建议

    if (this.riskLevel === BpRiskLevel.HYPERTENSION_1) {
      count = 4;
    } else if (this.riskLevel === BpRiskLevel.HYPERTENSION_2 ||
      this.riskLevel === BpRiskLevel.HYPERTENSIVE_CRISIS) {
      count = 5;
    }

    // 随机选择建议
    this.healthTips = [];
    const shuffled = [...tips].sort(() => 0.5 - Math.random());
    this.healthTips = shuffled.slice(0, count);
  }

  // 生成AI分析文本
  private generateAiAnalysis() {
    const avgSystolic = this.bpHistory.reduce((sum, curr) => sum + curr.systolic, 0) / this.bpHistory.length;
    const avgDiastolic = this.bpHistory.reduce((sum, curr) => sum + curr.diastolic, 0) / this.bpHistory.length;

    // 分析文本
    let analysis = `本周您的平均血压为${avgSystolic.toFixed(0)}/${avgDiastolic.toFixed(0)}mmHg。`;

    switch (this.riskLevel) {
      case BpRiskLevel.NORMAL:
        analysis += '您的血压处于正常范围，继续保持健康的生活方式。';
        break;
      case BpRiskLevel.ELEVATED:
        analysis += '您的血压略有偏高，建议增加运动量并减少盐分摄入。';
        break;
      case BpRiskLevel.HYPERTENSION_1:
        analysis += '您的血压属于高血压一级，建议咨询医生并调整生活方式。';
        break;
      case BpRiskLevel.HYPERTENSION_2:
        analysis += '您的血压属于高血压二级，请务必遵循医嘱服药并定期复查。';
        break;
      case BpRiskLevel.HYPERTENSIVE_CRISIS:
        analysis += '您的血压处于危险高值，请立即就医！';
        break;
    }

    // 添加趋势分析
    const firstDay = this.bpHistory[0];
    const lastDay = this.bpHistory[this.bpHistory.length - 1];

    if (lastDay.systolic - firstDay.systolic > 10) {
      analysis += ' 本周您的收缩压呈上升趋势，请注意监测。';
    } else if (firstDay.systolic - lastDay.systolic > 10) {
      analysis += ' 本周您的收缩压呈下降趋势，效果不错。';
    } else {
      analysis += ' 本周您的血压较为稳定。';
    }

    this.aiAnalysis = analysis;
  }

  build() {
    Column() {
      this.buildCustomAppBar()

      Scroll() {
        Column() {
          this.buildHistoryChart()
          this.buildAiAnalysis()
          this.buildRiskPrediction()
          this.buildHealthTips()
          this.healthConsultation()
          this.understandingBp()
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .height('92%')
    .margin({ top: 35 })
    .width('100%')
    .backgroundColor('#FAFAFA')
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
        Text('血压')
          .fontSize(22)
          .margin({ left: 15 })
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
      .backgroundColor('#FFFFFF')
      .zIndex(100)
      .border({ width: 0, color: '#00000000' })
      .shadow({ radius: 4, color: '#00000010' })

      // 底部分割线
      Divider().color('#ff968989').height(1).width('100%')
    }
  }

  // 血压历史柱状图
  @Builder
  buildHistoryChart() {
    Column() {
      Row() {
        Text('本周血压测量')
          .fontSize(22)
          .fontColor(PRIMARY_TEXT_COLOR)
          .fontWeight(FontWeight.Medium)

        Blank()

        Button('刷新', { type: ButtonType.Normal, stateEffect: true })
          .width(60)
          .height(32)
          .backgroundColor(ACCENT_COLOR)
          .fontColor('#FFFFFF')
          .borderRadius(16)
          .fontSize(14)
          .onClick(() => {
            this.generateRandomData();
          })
      }
      .width('95%')
      .margin({ bottom: 18 })

      // 水平滚动视图
      Column() {
        if (this.showScrollHint) {
          Row() {
            Text('← 左右滑动查看全部数据 →')
              .fontSize(12)
              .fontColor(ACCENT_COLOR)
              .fontStyle(FontStyle.Italic)
              .opacity(this.scrollHintOpacity)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ bottom: 5 })
        }

        Row() {
          // 左箭头按钮
          Column() {
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.left2'))
                .width(16)
                .height(16)
                .fillColor(this.currentIndex > 0 ? ACCENT_COLOR : '#CCCCCC')
            }
            .width(32)
            .height(32)
            .backgroundColor('#F0F0F0')
            .enabled(this.currentIndex > 0)
            .onClick(() => {
              if (this.currentIndex > 0) {
                this.currentIndex--;
              }
            })
          }
          .width('10%')
          .justifyContent(FlexAlign.Center)

          // 使用Swiper组件代替List，提供更好的滑动体验
          Swiper() {
            ForEach(this.bpHistory, (item: bp, index: number) => {
              Row() {
                Column() {
                  // 数值标签
                  Row() {
                    Row() {
                      Text(`${item.systolic}`)
                        .fontSize(12)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#007DFF')
                    }
                    .width(30)
                    .justifyContent(FlexAlign.Center)

                    Row() {
                      Text(`${item.diastolic}`)
                        .fontSize(12)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FF4D4F')
                    }
                    .width(30)
                    .justifyContent(FlexAlign.Center)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .margin({ bottom: 6 })

                  // 双柱形容器
                  Row({ space: 2 }) { // 横向排列
                    // 收缩压柱形
                    Column() {
                      // 添加一个空的Blank作为顶部边距，确保不会与数字重叠
                      Blank().height(4)

                      Rect()
                        .width(14)
                        .height(item.systolic * 0.8)// 调整比例系数，稍微降低高度
                        .fill('#007DFF')
                        .radius(6)
                      Rect()
                        .width(14)
                        .height(10)
                        .fill('#007DFF')
                        .margin({ top: -10 })
                    }

                    // 舒张压柱形
                    Column() {
                      // 添加一个空的Blank作为顶部边距，确保不会与数字重叠
                      Blank().height(4)

                      Rect()
                        .width(14)
                        .height(item.diastolic * 0.8)// 调整比例系数，稍微降低高度
                        .fill('#FF4D4F')
                        .radius(6)
                      Rect()
                        .width(14)
                        .height(10)
                        .fill('#FF4D4F')
                        .margin({ top: -10 })
                    }
                  }
                  .height(140) // 稍微降低柱形图容器的高度
                  .alignItems(VerticalAlign.Bottom) // 底部对齐

                  // 日期标签
                  Text(`周${index + 1}`)
                    .fontSize(13)
                    .fontColor(SECONDARY_TEXT_COLOR)
                    .margin({ top: 6 })
                }
                .height(180)
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            })
          }
          .width('80%')
          .height(190)
          .indicator(false) // 隐藏页面指示器
          .displayCount(3) // 一次显示3个
          .itemSpace(0) // 项目之间的间距
          .index(this.currentIndex)
          .loop(false) // 不循环滚动
          .duration(300) // 动画时间
          .curve(Curve.Ease) // 动画曲线
          .onChange((index: number) => {
            this.currentIndex = index;
          })

          // 右箭头按钮
          Column() {
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.right2'))
                .width(16)
                .height(16)
                .fillColor(this.currentIndex < this.bpHistory.length - 1 ? ACCENT_COLOR : '#CCCCCC')
            }
            .width(32)
            .height(32)
            .backgroundColor('#F0F0F0')
            .enabled(this.currentIndex < this.bpHistory.length - 1)
            .onClick(() => {
              if (this.currentIndex < this.bpHistory.length - 1) {
                this.currentIndex++;
              }
            })
          }
          .width('10%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')

      }
      .width('95%')
      .margin({ bottom: 8 })

      // 图例说明
      Row({ space: 20 }) {
        Row() {
          Circle().width(10).height(10).fill('#007DFF')
          Text('收缩压').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill('#FF4D4F')
          Text('舒张压').fontSize(12).margin({ left: 4 })
        }
      }
      .margin({ top: 10 })
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ top: 15, bottom: 15 })
  }

  // AI分析组件
  @Builder
  buildAiAnalysis() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ai_icon'))
            .width(24)
            .height(24)

          Text('AI 血压分析')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ left: 8 })
        }

        if (this.isAnalyzing) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(ACCENT_COLOR)
        } else {
          Image($r('app.media.refresh'))
            .width(20)
            .height(20)
            .onClick(() => this.performAiAnalysis())
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10, top: 5 })

      Text(this.aiAnalysis)
        .fontSize(15)
        .lineHeight(22)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ bottom: 10 })
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
  }

  // 风险预测组件
  @Builder
  buildRiskPrediction() {
    Column() {
      Row() {
        Image($r('app.media.risk_icon'))
          .width(24)
          .height(24)

        Text('血压风险评估')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .margin({ bottom: 15, top: 5 })

      // 进度条风险指示器
      Column() {
        Text(this.riskLevel)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getRiskColor())
          .margin({ bottom: 8 })

        Progress({ value: this.riskPercentage, total: 100 })
          .color(this.getRiskColor())
          .backgroundColor('#E9E9E9')
          .height(10)
          .width('100%')
          .style({ strokeWidth: 10, scaleCount: 10, scaleWidth: 1 })

        Row() {
          Text('低风险')
            .fontSize(12)
            .fontColor(LOW_RISK_COLOR)

          Blank()

          Text('中风险')
            .fontSize(12)
            .fontColor(MEDIUM_RISK_COLOR)

          Blank()

          Text('高风险')
            .fontSize(12)
            .fontColor(HIGH_RISK_COLOR)
        }
        .width('100%')
        .margin({ top: 5 })
      }
      .width('100%')
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
  }

  // 获取风险颜色
  private getRiskColor(): string {
    switch (this.riskLevel) {
      case BpRiskLevel.NORMAL:
        return LOW_RISK_COLOR;
      case BpRiskLevel.ELEVATED:
        return MEDIUM_RISK_COLOR;
      case BpRiskLevel.HYPERTENSION_1:
        return MEDIUM_RISK_COLOR;
      case BpRiskLevel.HYPERTENSION_2:
        return HIGH_RISK_COLOR;
      case BpRiskLevel.HYPERTENSIVE_CRISIS:
        return HIGH_RISK_COLOR;
      default:
        return ACCENT_COLOR;
    }
  }

  // 健康建议组件
  @Builder
  buildHealthTips() {
    Column() {
      Row() {
        Image($r('app.media.tips_icon'))
          .width(24)
          .height(24)

        Text('AI 健康建议')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .margin({ bottom: 15, top: 5 })

      List() {
        ForEach(this.healthTips, (tip: string, index: number) => {
          ListItem() {
            Row({ space: 8 }) {
              Text(`${index + 1}.`)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor(ACCENT_COLOR)

              Text(tip)
                .fontSize(14)
                .lineHeight(20)
                .fontColor(SECONDARY_TEXT_COLOR)
            }
            .alignItems(VerticalAlign.Top)
            .padding({ top: 4, bottom: 4 })
          }
        })
      }
      .width('100%')
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
  }

  //健康问诊卡片
  @Builder
  healthConsultation() {
    Column() {
      Row({ space: 10 }) {
        Column() {
          Text('专家问诊')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text('血压问题咨询专业医生')
            .margin({ top: 7 })
            .fontSize(15)
            .fontColor('#ff929090')
        }
        .height(100)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Start)
        .margin({ left: 25, top: 15 })

        Image($r('app.media.doctor2'))
          .width(75)
          .margin({ right: 30, top: 15 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor('#FFFFFF')
    .width('95%')
    .borderRadius(15)
    .margin({ bottom: 15 })
  }

  //了解血压卡片
  @Builder
  understandingBp() {
    Row({ space: 10 }) {
      Text('了解更多血压知识')
        .margin({ left: 15 })
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Image($r('app.media.right'))
        .width(15)
    }
    .padding(10)
    .justifyContent(FlexAlign.SpaceBetween)
    .height(50)
    .backgroundColor('#FFFFFF')
    .width('95%')
    .borderRadius(15)
    .margin({ bottom: 15 })
  }
}

