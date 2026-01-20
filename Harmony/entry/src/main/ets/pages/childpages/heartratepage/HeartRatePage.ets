import { router } from '@kit.ArkUI'

const PRIMARY_TEXT_COLOR: string = '#222831'
const SECONDARY_TEXT_COLOR: string = '#666666'
const ACCENT_COLOR: string = '#007DFF'
const USER_MESSAGE_COLOR: string = '#07C160'
const CARD_BG_GRADIENT: string = 'linear-gradient(135deg, #f5faff 0%, #e3f0ff 100%)'
const NORMAL_HEART_RATE_COLOR: string = '#52C41A'  // 正常心率颜色
const WARNING_HEART_RATE_COLOR: string = '#FAAD14' // 警告心率颜色
const DANGER_HEART_RATE_COLOR: string = '#FF4D4F'  // 危险心率颜色

// 心率状态枚举
enum HeartRateStatus {
  EXCELLENT = '理想心率',
  NORMAL = '正常心率',
  ELEVATED = '略高心率',
  HIGH = '高心率',
  LOW = '低心率',
  IRREGULAR = '不规则心率'
}

// 心率数据接口
interface HeartRateData {
  value: number,         // 当前心率值
  restingValue: number,  // 静息心率值
  variability: number,   // 心率变异性(%)
  maxValue: number,      // 最大心率
  minValue: number,      // 最小心率
  irregularBeats: boolean // 是否存在心率不规则
}

@Entry
@Component
struct HeartRatePage {
  @State currentHeartRate: number = 72 // 当前心率
  @State isMeasuring: boolean = false // 是否正在测量
  @State heartRateHistory: number[] = [72, 75, 80, 78, 76, 72, 70] // 心率历史数据
  @State heartBeat: boolean = false // 心跳动画状态
  @State heartGifPlaying: boolean = false // 动图状态
  @State heartRateStatus: HeartRateStatus = HeartRateStatus.NORMAL // 心率状态
  @State statusScore: number = 85 // 心率健康评分
  @State aiAnalysis: string = '' // AI分析结果
  @State healthTips: string[] = [] // 健康建议
  @State isAnalyzing: boolean = false // 是否正在分析
  @State heartRateData: HeartRateData = { // 心率详细数据
    value: 72,
    restingValue: 68,
    variability: 12,
    maxValue: 85,
    minValue: 65,
    irregularBeats: false
  }
  @State currentChartIndex: number = 0 // 当前图表索引
  @State showScrollHint: boolean = true // 显示滚动提示
  @State scrollHintOpacity: number = 1 // 滚动提示透明度

  // 在页面加载前生成随机心率数据
  aboutToAppear() {
    this.generateRandomHeartRateData();
    this.startScrollHintAnimation();
    this.performAiAnalysis();
  }

  // 生成随机心率数据的方法
  private generateRandomHeartRateData() {
    this.heartRateHistory = [];
    for (let i = 0; i < 7; i++) {
      // 生成60-100之间的随机心率
      const randomRate = Math.floor(Math.random() * 30) + 60;
      this.heartRateHistory.push(randomRate);
    }

    // 生成心率详细数据
    const latestHeartRate = this.heartRateHistory[this.heartRateHistory.length - 1];
    this.currentHeartRate = latestHeartRate;
    this.heartRateData = {
      value: latestHeartRate,
      restingValue: Math.floor(Math.random() * 10) + 60, // 60-70之间的静息心率
      variability: Math.floor(Math.random() * 15) + 5, // 5-20%的心率变异性
      maxValue: Math.max(...this.heartRateHistory),
      minValue: Math.min(...this.heartRateHistory),
      irregularBeats: Math.random() > 0.8 // 20%概率存在心律不齐
    };

    // 重新分析
    this.performAiAnalysis();
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

  // 执行AI分析
  private performAiAnalysis() {
    this.isAnalyzing = true;

    // 模拟AI分析延迟
    setTimeout(() => {
      this.calculateHeartRateStatus();
      this.generateHealthTips();
      this.generateAiAnalysis();
      this.isAnalyzing = false;
    }, 1000);
  }

  // 计算心率状态
  private calculateHeartRateStatus() {
    const hr = this.heartRateData.value;
    const resting = this.heartRateData.restingValue;
    const variability = this.heartRateData.variability;
    const irregular = this.heartRateData.irregularBeats;

    // 计算心率状态评分(0-100)
    let valueScore = 0;
    if (hr >= 60 && hr <= 100) {
      valueScore = 40 - Math.abs(hr - 75) * 0.8; // 75是理想值
    } else if (hr < 60) {
      valueScore = Math.max(0, 40 - (60 - hr) * 2);
    } else {
      valueScore = Math.max(0, 40 - (hr - 100) * 2);
    }

    const restingScore = 30 - Math.abs(resting - 65) * 0.6; // 65是理想静息心率
    const variabilityScore = Math.min(20, variability * 1.2); // 变异性得分
    const irregularScore = irregular ? 0 : 10; // 心律不齐扣10分

    this.statusScore = Math.min(100, Math.max(0,
      Math.round(valueScore + restingScore + variabilityScore + irregularScore)));

    // 根据总分和具体指标判断心率状态
    if (this.statusScore >= 90) {
      this.heartRateStatus = HeartRateStatus.EXCELLENT;
    } else if (this.statusScore >= 75) {
      this.heartRateStatus = HeartRateStatus.NORMAL;
    } else if (hr > 100) {
      this.heartRateStatus = HeartRateStatus.HIGH;
    } else if (hr < 60) {
      this.heartRateStatus = HeartRateStatus.LOW;
    } else if (irregular) {
      this.heartRateStatus = HeartRateStatus.IRREGULAR;
    } else {
      this.heartRateStatus = HeartRateStatus.ELEVATED;
    }
  }

  // 生成健康建议
  private generateHealthTips() {
    const tips = [
      '坚持有规律的有氧运动，如散步、游泳或骑自行车，可以改善心血管健康',
      '保持充足的睡眠（7-9小时），有助于心率恢复正常水平',
      '减少咖啡因、酒精和尼古丁的摄入，它们会影响心率',
      '学习和实践深呼吸、冥想等放松技巧，可以降低静息心率',
      '定期监测心率，特别是在运动前后，了解您的正常心率范围',
      '保持健康体重，避免超重或肥胖，它们会增加心脏负担',
      '控制盐分摄入，过量的钠会增加血压和心脏负担',
      '适当补充镁、钾等电解质，它们对心脏功能至关重要',
      '避免长时间久坐不动，每小时起身活动几分钟',
      '减少精神压力，慢性压力会对心脏健康产生负面影响',
      '增加ω-3脂肪酸的摄入，如深海鱼、亚麻籽等食物',
      '保持良好的水分摄入，脱水会导致心率升高',
      '如发现异常心率波动，请及时咨询医疗专业人士'
    ];

    // 根据心率状态选择不同数量的建议
    let count = 3; // 默认3条建议

    if (this.heartRateStatus === HeartRateStatus.HIGH || 
        this.heartRateStatus === HeartRateStatus.LOW ||
        this.heartRateStatus === HeartRateStatus.IRREGULAR) {
      count = 5;
    } else if (this.heartRateStatus === HeartRateStatus.ELEVATED) {
      count = 4;
    }

    // 随机选择建议
    this.healthTips = [];
    const shuffled = [...tips].sort(() => 0.5 - Math.random());
    this.healthTips = shuffled.slice(0, count);
  }

  // 生成AI分析文本
  private generateAiAnalysis() {
    const avgHeartRate = this.heartRateHistory.reduce((sum, curr) => sum + curr, 0) / this.heartRateHistory.length;

    // 分析文本
    let analysis = `本周您的平均心率为${avgHeartRate.toFixed(0)}次/分钟。`;

    switch (this.heartRateStatus) {
      case HeartRateStatus.EXCELLENT:
        analysis += '您的心率状态非常理想，表明心脏功能健康。';
        break;
      case HeartRateStatus.NORMAL:
        analysis += '您的心率在正常范围内，心脏功能良好。';
        break;
      case HeartRateStatus.ELEVATED:
        analysis += '您的心率略高于理想水平，可能与生活方式或压力有关，建议关注。';
        break;
      case HeartRateStatus.HIGH:
        analysis += '您的心率偏高，可能是多种因素导致，建议调整生活习惯并咨询医生。';
        break;
      case HeartRateStatus.LOW:
        analysis += '您的心率偏低，对于运动员可能是正常的，但如伴有不适症状，请咨询医生。';
        break;
      case HeartRateStatus.IRREGULAR:
        analysis += '检测到心率不规则，建议在专业医疗设备下进一步检查。';
        break;
    }

    // 静息心率分析
    if (this.heartRateData.restingValue < 60) {
      analysis += ' 您的静息心率较低，这在运动员中很常见，表明良好的心肺适能。';
    } else if (this.heartRateData.restingValue > 80) {
      analysis += ' 您的静息心率偏高，可能与身体状况、压力或生活习惯有关。';
    }

    // 心率变异性分析
    if (this.heartRateData.variability < 10) {
      analysis += ' 您的心率变异性较低，可能表明自主神经系统压力增加。';
    } else if (this.heartRateData.variability > 15) {
      analysis += ' 您的心率变异性良好，表明自主神经系统功能平衡。';
    }

    this.aiAnalysis = analysis;
  }

  // 获取心率状态颜色
  private getHeartRateStatusColor(): string {
    if (this.heartRateStatus === HeartRateStatus.EXCELLENT || 
        this.heartRateStatus === HeartRateStatus.NORMAL) {
      return NORMAL_HEART_RATE_COLOR;
    } else if (this.heartRateStatus === HeartRateStatus.ELEVATED) {
      return WARNING_HEART_RATE_COLOR;
    } else {
      return DANGER_HEART_RATE_COLOR;
    }
  }

  // 获取心率柱状图颜色
  private getHeartRateBarColor(rate: number): string {
    if (rate >= 60 && rate <= 100) {
      return NORMAL_HEART_RATE_COLOR;
    } else if ((rate >= 50 && rate < 60) || (rate > 100 && rate <= 110)) {
      return WARNING_HEART_RATE_COLOR;
    } else {
      return DANGER_HEART_RATE_COLOR;
    }
  }

  build() {
    Column() {
      this.buildCustomAppBar() // 顶部栏
      Scroll() {
        Column() {
          this.bulidHeartRate() // 心率检测
          this.buildHeartRateAnalysis() // 心率健康状态分析
          this.buildAiAnalysis() // AI智能分析
          this.buildHistoryChart() // 心率历史柱状图
          this.buildHeartRateVariability() // 心率变异性分析
          this.buildHealthTips() // AI健康建议
          this.healthConsultation() // 健康问诊
          this.understandingHR() // 了解心率
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({
          left: 16,
          right: 16,
          top: 10,
          bottom: 16
        })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
    }.margin({ top: 35 })
    .height('92%')
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
        Text('心率')
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

  //心率检测卡片
  @Builder
  bulidHeartRate() {
    Column() {
      // 心率检测卡片标题
      Row() {
        Image($r('app.media.heart_icon'))
          .width(24)
          .height(24)

        Text('实时心率检测')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15, top: 5 })

      // 修改心率动态图形部分
      Stack() {
        // 底部装饰圆形
        Circle()
          .width(180)
          .height(180)
          .fill('#FFF0F3')
          .opacity(0.6)
        
        // 心率动画图像
        Image(this.heartGifPlaying ? $r("app.media.heart_tran") : $r("app.media.heart_start"))
          .width(150)
          .objectFit(ImageFit.Contain)
          .animation({
            duration: 800,
            tempo: 1.0,
            delay: 0,
            curve: Curve.EaseInOut,
            playMode: PlayMode.Alternate,
            iterations: this.heartBeat ? 1 : -1
          })
          .scale({ x: this.heartBeat ? 1.1 : 1.0, y: this.heartBeat ? 1.1 : 1.0 })
      }
      .margin({ bottom: 15 })

      // 当前心率数值与单位显示
      Column() {
        Text(`${this.currentHeartRate}`)
          .fontSize(40)
          .fontColor('#EF5587')
          .fontWeight(FontWeight.Bold)
        Text('次/分钟')
          .fontSize(18)
          .fontColor(SECONDARY_TEXT_COLOR)
      }
      .margin({ bottom: 20 })
      .alignItems(HorizontalAlign.Center)

      // 心率测量按钮
      Button({ type: ButtonType.Capsule }) {
        Row() {
          if (this.isMeasuring) {
            LoadingProgress()
              .width(24)
              .height(24)
              .color('#FFFFFF')
              .margin({ right: 10 })
            Text('测量中...')
              .fontColor('#FFFFFF')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
          } else {
            Image($r('app.media.heart_icon'))
              .width(22)
              .height(22)
              .fillColor('#FFFFFF')
              .margin({ right: 10 })
            Text('开始测量')
              .fontColor('#FFFFFF')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
          }
        }
      }
      .width(220)
      .height(52)
      .backgroundColor(this.isMeasuring ? '#BBBBBB' : '#EF5587')
      .borderRadius(26)
      .shadow({ radius: 8, color: '#EF558733', offsetY: 4 })
      .onClick(() => {
        this.startMeasurement()
      })
      .margin({ bottom: 20 })
      .enabled(!this.isMeasuring)
      .stateEffect(this.isMeasuring ? false : true)

      // 测量说明文本
      if (!this.isMeasuring) {
        Text('点击开始测量您的实时心率')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ bottom: 5 })
      } else {
        Text('请保持手指稳定放在摄像头上')
          .fontSize(14)
          .fontColor(ACCENT_COLOR)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 5 })
      }
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
  }

  // 心率健康状态分析组件
  @Builder
  buildHeartRateAnalysis() {
    Column() {
      Row() {
        Image($r('app.media.heart_icon'))
          .width(24)
          .height(24)

        Text('心率健康状态')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .margin({ bottom: 15, top: 5 })

      // 心率健康环形进度条
      Row() {
        // 环形进度显示
        Stack() {
          Progress({ value: this.statusScore, total: 100, type: ProgressType.Ring })
            .color(this.getHeartRateStatusColor())
            .backgroundColor('#E9E9E9')
            .style({ strokeWidth: 10 })
            .width(120)
            .height(120)

          Column() {
            Text(`${this.statusScore}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getHeartRateStatusColor())

            Text('健康评分')
              .fontSize(12)
              .fontColor(SECONDARY_TEXT_COLOR)
          }
          .justifyContent(FlexAlign.Center)
        }
        .margin({ right: 20 })

        // 心率状态详情
        Column({ space: 8 }) {
          Row() {
            Text('当前心率:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.heartRateData.value} 次/分钟`)
              .fontSize(14)
          }

          Row() {
            Text('静息心率:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.heartRateData.restingValue} 次/分钟`)
              .fontSize(14)
          }

          Row() {
            Text('最高心率:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.heartRateData.maxValue} 次/分钟`)
              .fontSize(14)
          }

          Row() {
            Text('最低心率:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.heartRateData.minValue} 次/分钟`)
              .fontSize(14)
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 心率状态等级
      Text(this.heartRateStatus)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getHeartRateStatusColor())
        .margin({ top: 12 })
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
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

          Text('AI 心率分析')
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

  // 心率变异性分析组件
  @Builder
  buildHeartRateVariability() {
    Column() {
      Row() {
        Image($r('app.media.heart_rhythm'))
          .width(24)
          .height(24)

        Text('心率变异性分析')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .margin({ bottom: 10, top: 5 })

      // 心率变异性图
      Image($r('app.media.heart_variability'))
        .width('95%')
        .margin({ top: 5, bottom: 10 })

      Row() {
        Column() {
          Text('变异性指数')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)

          Text(`${this.heartRateData.variability}%`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
            .fontColor(this.heartRateData.variability >= 10 ? NORMAL_HEART_RATE_COLOR : WARNING_HEART_RATE_COLOR)
        }

        Column() {
          Text('心律状态')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)

          Text(this.heartRateData.irregularBeats ? '存在异常' : '正常')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
            .fontColor(this.heartRateData.irregularBeats ? DANGER_HEART_RATE_COLOR : NORMAL_HEART_RATE_COLOR)
        }

        Column() {
          Text('心脏负荷')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)

          Text(this.currentHeartRate > 90 ? '中等' : '轻度')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
            .fontColor(this.currentHeartRate > 90 ? WARNING_HEART_RATE_COLOR : NORMAL_HEART_RATE_COLOR)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 5 })
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
  }

  // 心率历史柱状图 (修改版)
  @Builder
  buildHistoryChart() {
    Column() {
      Row() {
        Text('本周心率测量')
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
            this.generateRandomHeartRateData();
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
                .fillColor(this.currentChartIndex > 0 ? ACCENT_COLOR : '#CCCCCC')
            }
            .width(32)
            .height(32)
            .backgroundColor('#F0F0F0')
            .enabled(this.currentChartIndex > 0)
            .onClick(() => {
              if (this.currentChartIndex > 0) {
                this.currentChartIndex--;
              }
            })
          }
          .width('10%')
          .justifyContent(FlexAlign.Center)

          // 心率数据滚动视图
          Swiper() {
            ForEach(this.heartRateHistory, (rate: number, index: number) => {
              Column() {
                // 数值标签
                Row() {
                  Text(`${rate}次/分`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(PRIMARY_TEXT_COLOR)
                }
                .margin({ bottom: 6 })

                // 柱状图
                Column() {
                  Row() {
                    Rect()
                      .width(24)
                      .height(rate * 1.2)
                      .fill(this.getHeartRateBarColor(rate))
                      .radius(8)
                  }
                  .height(150)
                  .alignItems(VerticalAlign.Bottom)

                  // 日期标签
                  Text(`周${index + 1}`)
                    .fontSize(13)
                    .fontColor(SECONDARY_TEXT_COLOR)
                    .margin({ top: 15 })
                }
                .width('80%')
              }
              .height(220)
              .width('100%')
              .justifyContent(FlexAlign.Center)
            })
          }
          .width('80%')
          .height(230)
          .indicator(false) // 隐藏页面指示器
          .displayCount(3) // 一次显示3个
          .itemSpace(0) // 项目之间的间距
          .index(this.currentChartIndex)
          .loop(false) // 不循环滚动
          .duration(300) // 动画时间
          .curve(Curve.Ease) // 动画曲线
          .onChange((index: number) => {
            this.currentChartIndex = index;
          })

          // 右箭头按钮
          Column() {
            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.right2'))
                .width(16)
                .height(16)
                .fillColor(this.currentChartIndex < this.heartRateHistory.length - 1 ? ACCENT_COLOR : '#CCCCCC')
            }
            .width(32)
            .height(32)
            .backgroundColor('#F0F0F0')
            .enabled(this.currentChartIndex < this.heartRateHistory.length - 1)
            .onClick(() => {
              if (this.currentChartIndex < this.heartRateHistory.length - 1) {
                this.currentChartIndex++;
              }
            })
          }
          .width('10%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
      }
      .width('100%')
      .margin({ bottom: 10 })

      // 心率范围说明
      Row({ space: 16 }) {
        Row() {
          Circle().width(10).height(10).fill(NORMAL_HEART_RATE_COLOR)
          Text('正常(60-100)').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill(WARNING_HEART_RATE_COLOR)
          Text('警告(50-60或100-110)').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill(DANGER_HEART_RATE_COLOR)
          Text('异常(<50或>110)').fontSize(12).margin({ left: 4 })
        }
      }
      .margin({ top: 8 })
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
  }

  // 健康小贴士（AI建议）
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

  // 启动心率测量动画与数据模拟 (修改版)
  private startMeasurement() {
    if (this.isMeasuring) {
      return
    }
    this.isMeasuring = true
    this.heartGifPlaying = true // 开始播放动图
    let count = 0
    // 心跳动画定时器
    let beatTimer = setInterval(() => {
      this.heartBeat = !this.heartBeat
    }, 400)
    // 模拟心率测量过程
    const intervalId = setInterval(() => {
      if (count < 10) {
        const baseRate = 70
        const variability = Math.sin((count / 10) * Math.PI) * 10
        this.currentHeartRate = Math.max(60, Math.round(baseRate + variability + Math.random() * 5))
        count++
      } else {
        // 测量结束时
        clearInterval(intervalId)
        clearInterval(beatTimer)
        this.heartGifPlaying = false // 停止动图
        this.isMeasuring = false
        // 更新历史心率数据和当前心率数据
        this.heartRateHistory = [...this.heartRateHistory.slice(1), this.currentHeartRate];
        this.heartRateData.value = this.currentHeartRate;
        this.heartRateData.maxValue = Math.max(this.heartRateData.maxValue, this.currentHeartRate);
        this.heartRateData.minValue = Math.min(this.heartRateData.minValue, this.currentHeartRate);
        // 进行AI分析
        this.performAiAnalysis();
      }
    }, 400)
  }

  // 健康问诊卡片
  @Builder
  healthConsultation() {
    Column() {
      Row({ space: 10 }) {
        Column() {
          Text('心脏健康问诊')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text('专业医生在线咨询')
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

  //了解心率卡片
  @Builder
  understandingHR() {
    Row({ space: 10 }) {
      Text('了解心率与健康')
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