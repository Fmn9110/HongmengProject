import { router } from '@kit.ArkUI'

const PRIMARY_TEXT_COLOR: string = '#222831'
const SECONDARY_TEXT_COLOR: string = '#666666'
const ACCENT_COLOR: string = '#007DFF'
const USER_MESSAGE_COLOR: string = '#07C160'
const CARD_BG_GRADIENT: string = 'linear-gradient(135deg, #f5faff 0%, #e3f0ff 100%)'
const NORMAL_BO_COLOR: string = '#52C41A'  // 正常血氧颜色
const WARNING_BO_COLOR: string = '#FAAD14' // 警告血氧颜色
const DANGER_BO_COLOR: string = '#FF4D4F'  // 危险血氧颜色

// 血氧状态枚举
enum BloodOxygenStatus {
  NORMAL = '血氧正常',
  MILD_HYPOXIA = '轻度缺氧',
  MODERATE_HYPOXIA = '中度缺氧',
  SEVERE_HYPOXIA = '严重缺氧'
}

// 血氧数据接口
interface BloodOxygenData {
  value: number,         // 当前血氧值
  rest: number,          // 静息血氧值
  activity: number,      // 活动血氧值
  maxValue: number,      // 最大血氧
  minValue: number,      // 最小血氧
  variability: number    // 血氧波动性(%)
}

@Entry
@Component
struct BloodOxygenPage {
  @State boHistory: number[] = [96, 98, 97, 98, 97, 95, 99] // 历史数据
  @State currentBO: number = 98 // 当前血氧值
  @State isMeasuring: boolean = false // 是否正在测量
  @State bloodOxygenStatus: BloodOxygenStatus = BloodOxygenStatus.NORMAL // 血氧状态
  @State statusScore: number = 92 // 血氧健康评分
  @State aiAnalysis: string = '' // AI分析结果
  @State healthTips: string[] = [] // 健康建议
  @State isAnalyzing: boolean = false // 是否正在分析
  @State bloodOxygenData: BloodOxygenData = { // 血氧详细数据
    value: 98,
    rest: 97,
    activity: 95,
    maxValue: 99,
    minValue: 94,
    variability: 5
  }
  @State currentChartIndex: number = 0 // 当前图表索引
  @State showScrollHint: boolean = true // 显示滚动提示
  @State scrollHintOpacity: number = 1 // 滚动提示透明度

  // 在页面加载前生成随机血氧数据
  aboutToAppear() {
    this.generateRandomBloodOxygenData();
    this.startScrollHintAnimation();
    this.performAiAnalysis();
  }

  // 生成随机血氧数据的方法
  private generateRandomBloodOxygenData() {
    this.boHistory = [];
    for (let i = 0; i < 7; i++) {
      // 生成90-100之间的随机血氧值
      const randomRate = Math.floor(Math.random() * 10 + 90);
      this.boHistory.push(Number(randomRate));
    }

    // 生成血氧详细数据
    const latestBloodOxygen = this.boHistory[this.boHistory.length - 1];
    this.currentBO = latestBloodOxygen;
    this.bloodOxygenData = {
      value: latestBloodOxygen,
      rest: Math.floor(Math.random() * 5 + 94), // 94-99之间的静息血氧
      activity: Math.floor(Math.random() * 8 + 90), // 90-98之间的活动血氧
      maxValue: Math.max(...this.boHistory),
      minValue: Math.min(...this.boHistory),
      variability: Math.floor(Math.random() * 8 + 2) // 2-10%的血氧变异性
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
      this.calculateBloodOxygenStatus();
      this.generateHealthTips();
      this.generateAiAnalysis();
      this.isAnalyzing = false;
    }, 1000);
  }

  // 计算血氧状态
  private calculateBloodOxygenStatus() {
    const bo = this.bloodOxygenData.value;
    const rest = this.bloodOxygenData.rest;
    const activity = this.bloodOxygenData.activity;
    const variability = this.bloodOxygenData.variability;

    // 计算血氧状态评分(0-100)
    let valueScore = 0;
    if (bo >= 95 && bo <= 100) {
      valueScore = 50; // 正常血氧范围满分
    } else if (bo >= 90 && bo < 95) {
      valueScore = 30; // 轻度低氧
    } else if (bo >= 85 && bo < 90) {
      valueScore = 15; // 中度低氧
    } else {
      valueScore = 0; // 严重低氧
    }

    const restScore = rest >= 95 ? 20 : (rest >= 90 ? 10 : 5); // 静息血氧得分
    const activityScore = activity >= 92 ? 20 : (activity >= 88 ? 10 : 5); // 活动血氧得分
    const variabilityScore = Math.max(0, 10 - variability); // 变异性得分，波动越小越好

    this.statusScore = Math.min(100, Math.max(0,
      Math.round(valueScore + restScore + activityScore + variabilityScore)));

    // 根据总分和具体指标判断血氧状态
    if (this.statusScore >= 90) {
      this.bloodOxygenStatus = BloodOxygenStatus.NORMAL;
    } else if (this.statusScore >= 70) {
      this.bloodOxygenStatus = BloodOxygenStatus.MILD_HYPOXIA;
    } else if (this.statusScore >= 50) {
      this.bloodOxygenStatus = BloodOxygenStatus.MODERATE_HYPOXIA;
    } else {
      this.bloodOxygenStatus = BloodOxygenStatus.SEVERE_HYPOXIA;
    }
  }

  // 生成健康建议
  private generateHealthTips() {
    const tips = [
      '保持规律作息，确保充足的睡眠时间',
      '定期进行有氧运动，提高心肺功能',
      '避免长时间处于密闭环境，保持室内空气流通',
      '戒烟限酒，烟草会降低血红蛋白携氧能力',
      '在高海拔地区需逐步适应，避免快速登高',
      '保持良好的坐姿，避免长时间同一姿势',
      '深呼吸练习有助于提高血氧饱和度',
      '饮食均衡，摄入富含铁质的食物如瘦肉、豆类',
      '保持心情愉悦，减少精神紧张和焦虑',
      '如果您有慢性疾病，请按时服药并定期复查',
      '避免剧烈运动后立即测量血氧，可能导致读数不稳定',
      '在早晚各测量一次血氧，比较数据变化',
      '如果您有睡眠呼吸暂停的症状，建议咨询医生',
      '高龄人士应定期检测血氧水平，及时发现问题'
    ];

    // 根据血氧状态选择不同数量的建议
    let count = 3; // 默认3条建议

    if (this.bloodOxygenStatus === BloodOxygenStatus.MODERATE_HYPOXIA || 
        this.bloodOxygenStatus === BloodOxygenStatus.SEVERE_HYPOXIA) {
      count = 5;
    } else if (this.bloodOxygenStatus === BloodOxygenStatus.MILD_HYPOXIA) {
      count = 4;
    }

    // 随机选择建议
    this.healthTips = [];
    const shuffled = [...tips].sort(() => 0.5 - Math.random());
    this.healthTips = shuffled.slice(0, count);
  }

  // 生成AI分析文本
  private generateAiAnalysis() {
    const avgBloodOxygen = this.boHistory.reduce((sum, curr) => sum + curr, 0) / this.boHistory.length;

    // 分析文本
    let analysis = `本周您的平均血氧饱和度为${avgBloodOxygen.toFixed(1)}%。`;

    switch (this.bloodOxygenStatus) {
      case BloodOxygenStatus.NORMAL:
        analysis += '您的血氧水平处于正常范围，表明您的肺部和循环系统功能良好。';
        break;
      case BloodOxygenStatus.MILD_HYPOXIA:
        analysis += '您的血氧水平略低于理想范围，建议增加适量运动并注意呼吸质量。';
        break;
      case BloodOxygenStatus.MODERATE_HYPOXIA:
        analysis += '您的血氧水平处于中度缺氧状态，应考虑调整生活习惯，必要时咨询医生。';
        break;
      case BloodOxygenStatus.SEVERE_HYPOXIA:
        analysis += '您的血氧水平较低，存在严重缺氧风险，建议尽快就医检查。';
        break;
    }

    // 静息血氧分析
    if (this.bloodOxygenData.rest < 95) {
      analysis += ' 您的静息状态下血氧偏低，可能与呼吸系统疾病或贫血等因素有关。';
    }

    // 活动血氧分析
    if (this.bloodOxygenData.activity < 90) {
      analysis += ' 您在活动状态下血氧下降明显，可能表明心肺功能储备不足。';
    }

    // 波动性分析
    if (this.bloodOxygenData.variability > 8) {
      analysis += ' 您的血氧饱和度波动较大，建议规律作息并避免剧烈活动后快速休息。';
    }

    this.aiAnalysis = analysis;
  }

  // 获取血氧状态颜色
  private getBloodOxygenStatusColor(): string {
    if (this.bloodOxygenStatus === BloodOxygenStatus.NORMAL) {
      return NORMAL_BO_COLOR;
    } else if (this.bloodOxygenStatus === BloodOxygenStatus.MILD_HYPOXIA) {
      return WARNING_BO_COLOR;
    } else {
      return DANGER_BO_COLOR;
    }
  }

  // 获取血氧柱状图颜色
  private getBloodOxygenBarColor(bo: number): string {
    if (bo >= 95) {
      return NORMAL_BO_COLOR;
    } else if (bo >= 90 && bo < 95) {
      return WARNING_BO_COLOR;
    } else {
      return DANGER_BO_COLOR;
    }
  }

  build() {
    Column() {
      this.buildCustomAppBar()
      
      Scroll() {
        Column() {
          this.buildBloodOxygenMeasurement() // 血氧测量
          this.buildHistoryChart() // 血氧历史图表
          this.buildAiAnalysis() // AI分析
          this.buildBloodOxygenAnalysis() // 血氧健康状态分析
          this.buildHealthTips() // 健康建议
          this.healthConsultation() // 健康问诊
          this.understandingBO() // 了解血氧
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
        Text('血氧饱和度')
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

  // 血氧测量组件
  @Builder
  buildBloodOxygenMeasurement() {
    Column() {
      // 血氧测量卡片标题
      Row() {
        Image($r('app.media.blood_o2'))
          .width(24)
          .height(24)

        Text('实时血氧测量')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15, top: 5 })

      // 血氧测量图示和数值
      Stack() {
        // 底部装饰圆形
        Circle()
          .width(180)
          .height(180)
          .fill('#E6F7FF')
          .opacity(0.8)
        
        // 血氧仪图示
        Image($r("app.media.blood_o2"))
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

      // 当前血氧数值与单位显示
      Column() {
        Text(`${this.currentBO}%`)
          .fontSize(40)
          .fontColor('#1890FF')
          .fontWeight(FontWeight.Bold)
        Text('血氧饱和度')
          .fontSize(18)
          .fontColor(SECONDARY_TEXT_COLOR)
      }
      .margin({ bottom: 20 })
      .alignItems(HorizontalAlign.Center)

      // 血氧测量按钮
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
            Image($r('app.media.blood_o2'))
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
      .backgroundColor(this.isMeasuring ? '#BBBBBB' : '#1890FF')
      .borderRadius(26)
      .shadow({ radius: 8, color: '#1890FF33', offsetY: 4 })
      .onClick(() => {
        this.startMeasurement()
      })
      .margin({ bottom: 20 })
      .enabled(!this.isMeasuring)
      .stateEffect(this.isMeasuring ? false : true)

      // 测量说明文本
      if (!this.isMeasuring) {
        Text('点击开始测量您的血氧饱和度')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ bottom: 5 })
      } else {
        Text('请将手指平放在传感器上保持稳定')
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

  // 启动血氧测量动画与数据模拟
  private startMeasurement() {
    if (this.isMeasuring) {
      return
    }
    this.isMeasuring = true
    let count = 0
    
    // 模拟血氧测量过程
    const intervalId = setInterval(() => {
      if (count < 10) {
        if (count < 5) {
          // 前5秒显示测量过程中的数值变化
          this.currentBO = Math.floor(Math.random() * 3 + 93); // 模拟测量中的数值波动
        }
        count++;
      } else {
        // 测量结束时
        clearInterval(intervalId);
        this.isMeasuring = false;
        
        // 生成最终测量结果
        this.currentBO = Math.floor(Math.random() * 10 + 90);
        
        // 更新历史血氧数据和当前血氧数据
        this.boHistory = [...this.boHistory.slice(1), this.currentBO];
        this.bloodOxygenData.value = this.currentBO;
        this.bloodOxygenData.maxValue = Math.max(this.bloodOxygenData.maxValue, this.currentBO);
        this.bloodOxygenData.minValue = Math.min(this.bloodOxygenData.minValue, this.currentBO);
        
        // 进行AI分析
        this.performAiAnalysis();
      }
    }, 600);
  }

  // 血氧历史柱状图
  @Builder
  buildHistoryChart() {
    Column() {
      Row() {
        Text('本周血氧测量')
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
            this.generateRandomBloodOxygenData();
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

          // 血氧数据滚动视图
          Swiper() {
            ForEach(this.boHistory, (bo: number, index: number) => {
              Column() {
                // 数值标签
                Row() {
                  Text(`${bo}%`)
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
                      .height(bo)
                      .fill(this.getBloodOxygenBarColor(bo))
                      .radius(8)
                  }
                  .height(120)
                  .alignItems(VerticalAlign.Bottom)

                  // 日期标签
                  Text(`周${index + 1}`)
                    .fontSize(13)
                    .fontColor(SECONDARY_TEXT_COLOR)
                    .margin({ top: 15 })
                }
                .width('80%')
              }
              .height(180)
              .width('100%')
              .justifyContent(FlexAlign.Center)
            })
          }
          .width('80%')
          .height(180)
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
                .fillColor(this.currentChartIndex < this.boHistory.length - 1 ? ACCENT_COLOR : '#CCCCCC')
            }
            .width(32)
            .height(32)
            .backgroundColor('#F0F0F0')
            .enabled(this.currentChartIndex < this.boHistory.length - 1)
            .onClick(() => {
              if (this.currentChartIndex < this.boHistory.length - 1) {
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

      // 血氧范围说明
      Row({ space: 16 }) {
        Row() {
          Circle().width(10).height(10).fill(NORMAL_BO_COLOR)
          Text('正常(≥95%)').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill(WARNING_BO_COLOR)
          Text('警告(90-94%)').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill(DANGER_BO_COLOR)
          Text('异常(<90%)').fontSize(12).margin({ left: 4 })
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

          Text('AI 血氧分析')
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

  // 血氧健康状态分析组件
  @Builder
  buildBloodOxygenAnalysis() {
    Column() {
      Row() {
        Image($r('app.media.blood_o2'))
          .width(24)
          .height(24)

        Text('血氧健康状态')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .margin({ bottom: 15, top: 5 })

      // 血氧健康环形进度条
      Row() {
        // 环形进度显示
        Stack() {
          Progress({ value: this.statusScore, total: 100, type: ProgressType.Ring })
            .color(this.getBloodOxygenStatusColor())
            .backgroundColor('#E9E9E9')
            .style({ strokeWidth: 10 })
            .width(120)
            .height(120)

          Column() {
            Text(`${this.statusScore}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getBloodOxygenStatusColor())

            Text('健康评分')
              .fontSize(12)
              .fontColor(SECONDARY_TEXT_COLOR)
          }
          .justifyContent(FlexAlign.Center)
        }
        .margin({ right: 20 })

        // 血氧状态详情
        Column({ space: 8 }) {
          Row() {
            Text('当前血氧:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.bloodOxygenData.value}%`)
              .fontSize(14)
          }

          Row() {
            Text('静息血氧:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.bloodOxygenData.rest}%`)
              .fontSize(14)
          }

          Row() {
            Text('活动血氧:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.bloodOxygenData.activity}%`)
              .fontSize(14)
          }

          Row() {
            Text('波动幅度:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.bloodOxygenData.variability}%`)
              .fontSize(14)
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 血氧状态等级
      Text(this.bloodOxygenStatus)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getBloodOxygenStatusColor())
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
          Text('血氧健康问诊')
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

  //了解血氧卡片
  @Builder
  understandingBO() {
    Column() {
      Row({ space: 10 }) {
        Text('了解血氧与健康')
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
      
      // 血氧知识卡片
      Column() {
        Text('血氧饱和度范围参考值：')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 10 })
          .alignSelf(ItemAlign.Start)
          
        Row() {
          Text('正常范围：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('25%')
          Text('95-100%')
            .fontSize(14)
            .fontColor(NORMAL_BO_COLOR)
        }
        .margin({ bottom: 6 })
        .alignSelf(ItemAlign.Start)
        
        Row() {
          Text('轻度缺氧：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('25%')
          Text('90-94%')
            .fontSize(14)
            .fontColor(WARNING_BO_COLOR)
        }
        .margin({ bottom: 6 })
        .alignSelf(ItemAlign.Start)
        
        Row() {
          Text('中度缺氧：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('25%')
          Text('85-89%')
            .fontSize(14)
            .fontColor(DANGER_BO_COLOR)
        }
        .margin({ bottom: 6 })
        .alignSelf(ItemAlign.Start)
        
        Row() {
          Text('重度缺氧：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('25%')
          Text('<85%')
            .fontSize(14)
            .fontColor(DANGER_BO_COLOR)
            .fontWeight(FontWeight.Bold)
        }
        .margin({ bottom: 6 })
        .alignSelf(ItemAlign.Start)

        Row() {
          Text('注意：')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .width('25%')
          Text('健康成人的血氧饱和度通常应保持在95%或以上。低于90%可能需要氧气支持和医疗干预。')
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .width('75%')
        }
        .margin({ bottom: 6, top: 6 })
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

