import { router } from '@kit.ArkUI'

const PRIMARY_TEXT_COLOR: string = '#222831'
const SECONDARY_TEXT_COLOR: string = '#666666'
const ACCENT_COLOR: string = '#007DFF'
const USER_MESSAGE_COLOR: string = '#07C160'
const CARD_BG_GRADIENT: string = 'linear-gradient(135deg, #f5faff 0%, #e3f0ff 100%)'
const NORMAL_BS_COLOR: string = '#52C41A' // 正常血糖颜色
const WARNING_BS_COLOR: string = '#FAAD14' // 警告血糖颜色
const DANGER_BS_COLOR: string = '#FF4D4F' // 危险血糖颜色

// 血糖状态枚举
enum BloodSugarStatus {
  NORMAL = '正常血糖',
  ELEVATED = '血糖偏高',
  HIGH = '高血糖',
  LOW = '低血糖',
  UNSTABLE = '血糖不稳定'
}

// 血糖数据接口
interface BloodSugarData {
  value: number, // 当前血糖值
  fasting: number, // 空腹血糖值
  postprandial: number, // 餐后血糖
  maxValue: number, // 最大血糖
  minValue: number, // 最小血糖
  variability: number // 血糖波动性(%)
}

@Entry
@Component
struct BloodSugarPage {
  @State bsHistory: number[] = [3.9, 4.5, 6.1, 4.2, 4.1, 5.4, 5.2] // 历史数据
  @State currentBS: number = 5.2 // 当前血糖值
  @State isMeasuring: boolean = false // 是否正在测量
  @State bloodSugarStatus: BloodSugarStatus = BloodSugarStatus.NORMAL // 血糖状态
  @State statusScore: number = 85 // 血糖健康评分
  @State aiAnalysis: string = '' // AI分析结果
  @State healthTips: string[] = [] // 健康建议
  @State isAnalyzing: boolean = false // 是否正在分析
  @State bloodSugarData: BloodSugarData = {
    // 血糖详细数据
    value: 5.2,
    fasting: 4.8,
    postprandial: 6.3,
    maxValue: 6.8,
    minValue: 4.1,
    variability: 15
  }
  @State currentChartIndex: number = 0 // 当前图表索引
  @State showScrollHint: boolean = true // 显示滚动提示
  @State scrollHintOpacity: number = 1 // 滚动提示透明度

  // 在页面加载前生成随机血糖数据
  aboutToAppear() {
    this.generateRandomBloodSugarData();
    this.startScrollHintAnimation();
    this.performAiAnalysis();
  }

  // 生成随机血糖数据的方法
  private generateRandomBloodSugarData() {
    this.bsHistory = [];
    for (let i = 0; i < 7; i++) {
      // 生成3.5-8.5之间的随机血糖值
      const randomRate = (Math.random() * 5 + 3.5).toFixed(1);
      this.bsHistory.push(Number(randomRate));
    }

    // 生成血糖详细数据
    const latestBloodSugar = this.bsHistory[this.bsHistory.length - 1];
    this.currentBS = latestBloodSugar;
    this.bloodSugarData = {
      value: latestBloodSugar,
      fasting: Number((Math.random() * 1.5 + 4).toFixed(1)), // 4.0-5.5之间的空腹血糖
      postprandial: Number((Math.random() * 2 + 5.5).toFixed(1)), // 5.5-7.5之间的餐后血糖
      maxValue: Math.max(...this.bsHistory),
      minValue: Math.min(...this.bsHistory),
      variability: Number((Math.random() * 20 + 5).toFixed(0)) // 5-25%的血糖变异性
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
      this.calculateBloodSugarStatus();
      this.generateHealthTips();
      this.generateAiAnalysis();
      this.isAnalyzing = false;
    }, 1000);
  }

  // 计算血糖状态
  private calculateBloodSugarStatus() {
    const bs = this.bloodSugarData.value;
    const fasting = this.bloodSugarData.fasting;
    const postprandial = this.bloodSugarData.postprandial;
    const variability = this.bloodSugarData.variability;

    // 计算血糖状态评分(0-100)
    let valueScore = 0;
    if (bs >= 3.9 && bs <= 6.1) {
      valueScore = 40 - Math.abs(bs - 5.0) * 12; // 5.0是理想值
    } else if (bs < 3.9) {
      valueScore = Math.max(0, 40 - (3.9 - bs) * 20);
    } else {
      valueScore = Math.max(0, 40 - (bs - 6.1) * 10);
    }

    const fastingScore = 30 - Math.abs(fasting - 4.5) * 15; // 4.5是理想空腹血糖
    const postprandialScore = 20 - Math.abs(postprandial - 6.0) * 8; // 6.0是理想餐后血糖
    const variabilityScore = Math.max(0, 10 - variability * 0.4); // 变异性得分

    this.statusScore = Math.min(100, Math.max(0,
      Math.round(valueScore + fastingScore + postprandialScore + variabilityScore)));

    // 根据总分和具体指标判断血糖状态
    if (this.statusScore >= 90) {
      this.bloodSugarStatus = BloodSugarStatus.NORMAL;
    } else if (this.statusScore >= 75) {
      this.bloodSugarStatus = BloodSugarStatus.NORMAL;
    } else if (bs > 7.0) {
      this.bloodSugarStatus = BloodSugarStatus.HIGH;
    } else if (bs < 3.9) {
      this.bloodSugarStatus = BloodSugarStatus.LOW;
    } else if (variability > 20) {
      this.bloodSugarStatus = BloodSugarStatus.UNSTABLE;
    } else {
      this.bloodSugarStatus = BloodSugarStatus.ELEVATED;
    }
  }

  // 生成健康建议
  private generateHealthTips() {
    const tips = [
      '保持规律饮食，避免长时间空腹或暴饮暴食',
      '增加膳食纤维摄入，如全谷物、蔬菜和水果',
      '限制精制碳水化合物和加糖食品的摄入',
      '每周进行至少150分钟的中等强度有氧运动',
      '餐后进行适当的轻度活动，如散步15-30分钟',
      '保持健康体重，必要时进行体重管理',
      '避免过度饮酒，酒精会影响血糖水平',
      '监测并控制压力水平，压力可导致血糖升高',
      '定期检测血糖，了解自己的血糖模式',
      '保持充足的睡眠，睡眠不足会影响胰岛素敏感性',
      '咨询医生或营养师，制定个性化的饮食计划',
      '学习认识食物的血糖指数，选择低血糖指数食物',
      '如果您有糖尿病，严格遵循医生的用药建议'
    ];

    // 根据血糖状态选择不同数量的建议
    let count = 3; // 默认3条建议

    if (this.bloodSugarStatus === BloodSugarStatus.HIGH ||
      this.bloodSugarStatus === BloodSugarStatus.LOW) {
      count = 5;
    } else if (this.bloodSugarStatus === BloodSugarStatus.ELEVATED ||
      this.bloodSugarStatus === BloodSugarStatus.UNSTABLE) {
      count = 4;
    }

    // 随机选择建议
    this.healthTips = [];
    const shuffled = [...tips].sort(() => 0.5 - Math.random());
    this.healthTips = shuffled.slice(0, count);
  }

  // 生成AI分析文本
  private generateAiAnalysis() {
    const avgBloodSugar = this.bsHistory.reduce((sum, curr) => sum + curr, 0) / this.bsHistory.length;

    // 分析文本
    let analysis = `本周您的平均血糖为${avgBloodSugar.toFixed(1)}mmol/L。`;

    switch (this.bloodSugarStatus) {
      case BloodSugarStatus.NORMAL:
        analysis += '您的血糖水平在正常范围内，表明您的糖代谢功能良好。';
        break;
      case BloodSugarStatus.ELEVATED:
        analysis += '您的血糖水平略高于理想范围，建议关注饮食结构和活动量。';
        break;
      case BloodSugarStatus.HIGH:
        analysis += '您的血糖水平偏高，可能需要调整生活方式，必要时咨询医生。';
        break;
      case BloodSugarStatus.LOW:
        analysis += '您的血糖水平偏低，应避免长时间空腹，并确保摄入足够的碳水化合物。';
        break;
      case BloodSugarStatus.UNSTABLE:
        analysis += '您的血糖波动较大，应注意饮食规律性，避免高糖食物。';
        break;
    }

    // 空腹血糖分析
    if (this.bloodSugarData.fasting < 4.0) {
      analysis += ' 您的空腹血糖偏低，可能需要调整早餐结构。';
    } else if (this.bloodSugarData.fasting > 5.6) {
      analysis += ' 您的空腹血糖偏高，建议控制晚餐摄入，并考虑晚饭后轻度活动。';
    }

    // 餐后血糖分析
    if (this.bloodSugarData.postprandial > 7.8) {
      analysis += ' 您的餐后血糖升高较明显，可能需要控制碳水化合物的摄入速度和总量。';
    }

    this.aiAnalysis = analysis;
  }

  // 获取血糖状态颜色
  private getBloodSugarStatusColor(): string {
    if (this.bloodSugarStatus === BloodSugarStatus.NORMAL) {
      return NORMAL_BS_COLOR;
    } else if (this.bloodSugarStatus === BloodSugarStatus.ELEVATED ||
      this.bloodSugarStatus === BloodSugarStatus.UNSTABLE) {
      return WARNING_BS_COLOR;
    } else {
      return DANGER_BS_COLOR;
    }
  }

  // 获取血糖柱状图颜色
  private getBloodSugarBarColor(bs: number): string {
    if (bs >= 3.9 && bs <= 6.1) {
      return NORMAL_BS_COLOR;
    } else if ((bs >= 3.5 && bs < 3.9) || (bs > 6.1 && bs <= 7.0)) {
      return WARNING_BS_COLOR;
    } else {
      return DANGER_BS_COLOR;
    }
  }

  build() {
    Column() {
      this.buildCustomAppBar()

      Scroll() {
        Column() {
          this.buildBloodSugarMeasurement() // 血糖测量
          this.buildHistoryChart() // 血糖历史图表
          this.buildAiAnalysis() // AI分析
          this.buildBloodSugarAnalysis() // 血糖健康状态分析
          this.buildHealthTips() // 健康建议
          this.healthConsultation() // 健康问诊
          this.understandingBS() // 了解血糖
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
        Text('血糖')
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

  // 血糖测量组件
  @Builder
  buildBloodSugarMeasurement() {
    Column() {
      // 血糖测量卡片标题
      Row() {
        Image($r('app.media.blood_sugar'))
          .width(24)
          .height(24)

        Text('实时血糖测量')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15, top: 5 })

      // 血糖测量图示和数值
      Stack() {
        // 底部装饰圆形
        Circle()
          .width(180)
          .height(180)
          .fill('#FFF8F0')
          .opacity(0.6)

        // 血糖仪图示
        Image($r("app.media.blood_sugar"))
          .width(120)
          .objectFit(ImageFit.Contain)
          .animation({
            duration: 500,
            tempo: 1.0,
            delay: 0,
            curve: Curve.EaseInOut,
            playMode: PlayMode.Alternate,
            iterations: this.isMeasuring ? -1 : 0
          })
          .opacity(this.isMeasuring ? 0.7 : 1.0)
      }
      .margin({ bottom: 15 })

      // 当前血糖数值与单位显示
      Column() {
        Text(`${this.currentBS}`)
          .fontSize(40)
          .fontColor('#EF8C5E')
          .fontWeight(FontWeight.Bold)
        Text('mmol/L')
          .fontSize(18)
          .fontColor(SECONDARY_TEXT_COLOR)
      }
      .margin({ bottom: 20 })
      .alignItems(HorizontalAlign.Center)

      // 血糖测量按钮
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
            Image($r('app.media.blood_sugar'))
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
      .backgroundColor(this.isMeasuring ? '#BBBBBB' : '#EF8C5E')
      .borderRadius(26)
      .shadow({ radius: 8, color: '#EF8C5E33', offsetY: 4 })
      .onClick(() => {
        this.startMeasurement()
      })
      .margin({ bottom: 20 })
      .enabled(!this.isMeasuring)
      .stateEffect(this.isMeasuring ? false : true)

      // 测量说明文本
      if (!this.isMeasuring) {
        Text('点击开始测量您的血糖水平')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ bottom: 5 })
      } else {
        Text('请保持手指稳定并放在传感器上')
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

  // 启动血糖测量动画与数据模拟
  private startMeasurement() {
    if (this.isMeasuring) {
      return
    }
    this.isMeasuring = true
    let count = 0

    // 模拟血糖测量过程
    const intervalId = setInterval(() => {
      if (count < 10) {
        if (count < 5) {
          // 前5秒显示测量过程中的数值变化
          this.currentBS = Number((Math.random() * 0.5 + 4.5).toFixed(1)); // 模拟测量中的数值波动
        }
        count++;
      } else {
        // 测量结束时
        clearInterval(intervalId);
        this.isMeasuring = false;

        // 生成最终测量结果
        this.currentBS = Number((Math.random() * 3 + 3.8).toFixed(1));

        // 更新历史血糖数据和当前血糖数据
        this.bsHistory = [...this.bsHistory.slice(1), this.currentBS];
        this.bloodSugarData.value = this.currentBS;
        this.bloodSugarData.maxValue = Math.max(this.bloodSugarData.maxValue, this.currentBS);
        this.bloodSugarData.minValue = Math.min(this.bloodSugarData.minValue, this.currentBS);

        // 进行AI分析
        this.performAiAnalysis();
      }
    }, 600);
  }

  // 血糖历史柱状图
  @Builder
  buildHistoryChart() {
    Column() {
      Row() {
        Text('本周血糖测量')
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
            this.generateRandomBloodSugarData();
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

          // 血糖数据滚动视图
          Swiper() {
            ForEach(this.bsHistory, (bs: number, index: number) => {
              Column() {
                // 数值标签
                Row() {
                  Text(`${bs} mmol/L`)
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
                      .height(bs * 20)
                      .fill(this.getBloodSugarBarColor(bs))
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
          .height(220)
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
                .fillColor(this.currentChartIndex < this.bsHistory.length - 1 ? ACCENT_COLOR : '#CCCCCC')
            }
            .width(32)
            .height(32)
            .backgroundColor('#F0F0F0')
            .enabled(this.currentChartIndex < this.bsHistory.length - 1)
            .onClick(() => {
              if (this.currentChartIndex < this.bsHistory.length - 1) {
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

      // 血糖范围说明
      Row({ space: 6 }) {
        Row() {
          Circle().width(10).height(10).fill(NORMAL_BS_COLOR)
          Text('正常(3.9-6.1)').fontSize(12).margin({ left: 2 })
        }

        Row() {
          Circle().width(10).height(10).fill(WARNING_BS_COLOR)
          Text('警告(3.5-3.9/6.1-7.0)').fontSize(12).margin({ left: 2 })
        }

        Row() {
          Circle().width(10).height(10).fill(DANGER_BS_COLOR)
          Text('异常(<3.5/>7.0)').fontSize(12).margin({ left: 2 })
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

  // AI分析组件
  @Builder
  buildAiAnalysis() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ai_icon'))
            .width(24)
            .height(24)

          Text('AI 血糖分析')
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

  // 血糖健康状态分析组件
  @Builder
  buildBloodSugarAnalysis() {
    Column() {
      Row() {
        Image($r('app.media.blood_sugar'))
          .width(24)
          .height(24)

        Text('血糖健康状态')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .margin({ bottom: 15, top: 5 })

      // 血糖健康环形进度条
      Row() {
        // 环形进度显示
        Stack() {
          Progress({ value: this.statusScore, total: 100, type: ProgressType.Ring })
            .color(this.getBloodSugarStatusColor())
            .backgroundColor('#E9E9E9')
            .style({ strokeWidth: 10 })
            .width(120)
            .height(120)

          Column() {
            Text(`${this.statusScore}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getBloodSugarStatusColor())

            Text('健康评分')
              .fontSize(12)
              .fontColor(SECONDARY_TEXT_COLOR)
          }
          .justifyContent(FlexAlign.Center)
        }
        .margin({ right: 20 })

        // 血糖状态详情
        Column({ space: 8 }) {
          Row() {
            Text('当前血糖:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.bloodSugarData.value} mmol/L`)
              .fontSize(14)
          }

          Row() {
            Text('空腹血糖:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.bloodSugarData.fasting} mmol/L`)
              .fontSize(14)
          }

          Row() {
            Text('餐后血糖:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.bloodSugarData.postprandial} mmol/L`)
              .fontSize(14)
          }

          Row() {
            Text('波动幅度:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.bloodSugarData.variability}%`)
              .fontSize(14)
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 血糖状态等级
      Text(this.bloodSugarStatus)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getBloodSugarStatusColor())
        .margin({ top: 12 })
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

  //健康问诊卡片
  @Builder
  healthConsultation() {
    Column() {
      Row({ space: 10 }) {
        Column() {
          Text('血糖健康问诊')
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

  //了解血糖卡片
  @Builder
  understandingBS() {
    Column() {
      Row({ space: 10 }) {
        Text('了解血糖与健康')
          .margin({ left: 15 })
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Image($r('app.media.right'))
          .width(15)
      }
      .padding(10)
      .justifyContent(FlexAlign.SpaceBetween)
      .height(50)
      .width('100%')

      // 血糖知识卡片
      Column() {
        Text('常见血糖范围参考值：')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 10 })
          .alignSelf(ItemAlign.Start)

        Row() {
          Text('空腹血糖：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('20%')
          Text('3.9-6.1 mmol/L')
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
        }
        .margin({ bottom: 6 })
        .alignSelf(ItemAlign.Start)

        Row() {
          Text('餐后2小时：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('20%')
          Text('< 7.8 mmol/L')
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
        }
        .margin({ bottom: 6 })
        .alignSelf(ItemAlign.Start)

        Row() {
          Text('糖尿病前期：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('20%')
          Text('空腹6.1-7.0 mmol/L')
            .fontSize(14)
            .fontColor(WARNING_BS_COLOR)
        }
        .margin({ bottom: 6 })
        .alignSelf(ItemAlign.Start)

        Row() {
          Text('糖尿病：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('20%')
          Text('空腹≥7.0 mmol/L 或餐后≥11.1 mmol/L')
            .fontSize(14)
            .fontColor(DANGER_BS_COLOR)
        }
        .margin({ bottom: 6 })
        .alignSelf(ItemAlign.Start)
      }
      .margin({ top: 10, bottom: 15 })
      .padding({ left: 15, right: 15 })
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor('#FFFFFF')
    .width('95%')
    .borderRadius(15)
    .margin({ bottom: 15 })
  }
}

