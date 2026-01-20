import { router } from '@kit.ArkUI'

const PRIMARY_TEXT_COLOR: string = '#222831'
const SECONDARY_TEXT_COLOR: string = '#666666'
const ACCENT_COLOR: string = '#007DFF'
const GOOD_SLEEP_COLOR: string = '#52C41A' // 良好睡眠颜色
const MEDIUM_SLEEP_COLOR: string = '#FAAD14' // 一般睡眠颜色
const POOR_SLEEP_COLOR: string = '#FF4D4F' // 较差睡眠颜色

// 睡眠质量级别
enum SleepQualityLevel {
  EXCELLENT = '优质睡眠',
  GOOD = '良好睡眠',
  FAIR = '一般睡眠',
  POOR = '较差睡眠',
  VERY_POOR = '睡眠不足'
}

// 睡眠数据接口
interface SleepData {
  duration: number, // 睡眠时长(小时)
  deepSleep: number, // 深度睡眠比例(%)
  efficiency: number, // 睡眠效率(%)
  awakeTimes: number // 夜间清醒次数
}


@Entry
@Component
struct SleepPage {
  @State sleepHistory: number[] = [] // 初始化为空数组
  @State currentIndex: number = 0;
  @State opacities: number[] = [1, 0, 0]; // 每张图片的透明度
  @State sleepQuality: SleepQualityLevel = SleepQualityLevel.GOOD;
  @State qualityScore: number = 85;
  @State aiAnalysis: string = '';
  @State healthTips: string[] = [];
  @State isAnalyzing: boolean = false;
  @State sleepData: SleepData = {
    duration: 0,
    deepSleep: 0,
    efficiency: 0,
    awakeTimes: 0
  };
  @State scrollHintOpacity: number = 1;
  @State showScrollHint: boolean = true;
  @State currentChartIndex: number = 0;
  private swiperImages: Resource[] = [
    $r('app.media.round1'),
    $r('app.media.round2'),
    $r('app.media.round3'),
    $r('app.media.round4'),
    $r('app.media.round5'),
    $r('app.media.round6')
  ];

  // 在页面加载前生成随机睡眠数据
  aboutToAppear() {
    this.generateRandomSleepData();
    this.startScrollHintAnimation();
    this.performAiAnalysis();
  }

  // 生成随机睡眠数据的方法
  private generateRandomSleepData() {
    this.sleepHistory = [];
    for (let i = 0; i < 7; i++) {
      // 生成5.0-10.0之间的随机睡眠时间，保留一位小数
      const randomSleep = (Math.random() * 5 + 5).toFixed(1);
      this.sleepHistory.push(parseFloat(randomSleep));
    }

    // 生成睡眠详细数据
    const latestSleepDuration = this.sleepHistory[this.sleepHistory.length - 1];
    this.sleepData = {
      duration: latestSleepDuration,
      deepSleep: Math.floor(Math.random() * 25) + 15, // 15-40% 深度睡眠
      efficiency: Math.floor(Math.random() * 20) + 75, // 75-95% 睡眠效率
      awakeTimes: Math.floor(Math.random() * 5) // 0-4次醒来
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
      this.calculateSleepQuality();
      this.generateHealthTips();
      this.generateAiAnalysis();
      this.isAnalyzing = false;
    }, 1000);
  }

  // 计算睡眠质量
  private calculateSleepQuality() {
    // 计算睡眠质量评分(0-100)
    const durationScore = this.calculateDurationScore(this.sleepData.duration); // 0-40分
    const deepSleepScore = Math.min(this.sleepData.deepSleep, 40) * 0.75; // 0-30分
    const efficiencyScore = (this.sleepData.efficiency - 70) * 0.6; // 0-15分
    const awakeScore = Math.max(0, 15 - this.sleepData.awakeTimes * 3.75); // 0-15分

    this.qualityScore = Math.min(100, Math.max(0,
      Math.round(durationScore + deepSleepScore + efficiencyScore + awakeScore)));

    // 根据总分判断睡眠质量
    if (this.qualityScore >= 90) {
      this.sleepQuality = SleepQualityLevel.EXCELLENT;
    } else if (this.qualityScore >= 75) {
      this.sleepQuality = SleepQualityLevel.GOOD;
    } else if (this.qualityScore >= 60) {
      this.sleepQuality = SleepQualityLevel.FAIR;
    } else if (this.qualityScore >= 40) {
      this.sleepQuality = SleepQualityLevel.POOR;
    } else {
      this.sleepQuality = SleepQualityLevel.VERY_POOR;
    }
  }

  // 计算睡眠时长得分
  private calculateDurationScore(duration: number): number {
    if (duration >= 7 && duration <= 8) {
      return 40; // 理想睡眠时间
    } else if (duration > 8 && duration <= 9) {
      return 35; // 稍微超过理想时间
    } else if (duration >= 6 && duration < 7) {
      return 30; // 稍微不足
    } else if (duration > 9) {
      return 25; // 睡眠过多
    } else if (duration >= 5 && duration < 6) {
      return 20; // 睡眠不足
    } else {
      return 10; // 严重睡眠不足
    }
  }

  // 生成健康建议
  private generateHealthTips() {
    const tips = [
      '尝试在固定时间入睡和起床，培养规律的睡眠习惯',
      '睡前1小时避免使用电子设备，蓝光会抑制褪黑激素的产生',
      '确保卧室环境安静、黑暗且温度适宜(18-20°C为宜)',
      '睡前避免摄入咖啡因和酒精，它们会干扰睡眠质量',
      '白天保持适量运动，但避免睡前3小时内进行剧烈运动',
      '睡前可以做一些放松活动，如冥想、深呼吸或听轻音乐',
      '如果20分钟内无法入睡，建议起床做一些放松活动后再尝试',
      '睡前避免大量进食，特别是辛辣或高脂肪食物',
      '尝试睡前泡个温水澡，有助于身体降温促进睡眠',
      '睡前保持心情平静，可记录当天的烦恼以释放压力',
      '白天短暂午休(20-30分钟)有助于提高警觉性，但避免长时间午睡',
      '创建舒适的睡眠环境，选择合适的床垫和枕头',
      '如出现长期睡眠问题，建议咨询专业医生'
    ];

    // 根据睡眠质量选择不同数量的建议
    let count = 3; // 默认3条建议

    if (this.sleepQuality === SleepQualityLevel.POOR) {
      count = 4;
    } else if (this.sleepQuality === SleepQualityLevel.VERY_POOR) {
      count = 5;
    }

    // 随机选择建议
    this.healthTips = [];
    const shuffled = [...tips].sort(() => 0.5 - Math.random());
    this.healthTips = shuffled.slice(0, count);
  }

  // 生成AI分析文本
  private generateAiAnalysis() {
    const avgDuration = this.sleepHistory.reduce((sum, curr) => sum + curr, 0) / this.sleepHistory.length;

    // 分析文本
    let analysis = `本周您的平均睡眠时间为${avgDuration.toFixed(1)}小时。`;

    switch (this.sleepQuality) {
      case SleepQualityLevel.EXCELLENT:
        analysis += '您的睡眠质量非常优秀，继续保持这样的睡眠习惯。';
        break;
      case SleepQualityLevel.GOOD:
        analysis += '您的睡眠质量良好，保持规律的作息可以维持健康。';
        break;
      case SleepQualityLevel.FAIR:
        analysis += '您的睡眠质量一般，尝试优化睡眠环境可以提高睡眠质量。';
        break;
      case SleepQualityLevel.POOR:
        analysis += '您的睡眠质量较差，建议调整睡眠习惯并减少睡前刺激。';
        break;
      case SleepQualityLevel.VERY_POOR:
        analysis += '您的睡眠严重不足，可能影响身体健康，请尽快调整作息时间。';
        break;
    }

    // 深度睡眠分析
    if (this.sleepData.deepSleep < 20) {
      analysis += ' 您的深度睡眠比例偏低，可能影响身体恢复，建议提高睡眠质量。';
    } else if (this.sleepData.deepSleep > 35) {
      analysis += ' 您的深度睡眠比例良好，有利于身体恢复和记忆巩固。';
    }

    // 睡眠中断分析
    if (this.sleepData.awakeTimes > 3) {
      analysis += ' 您的睡眠中断较频繁，可能影响整体睡眠质量，建议找出原因并改善。';
    }

    this.aiAnalysis = analysis;
  }

  // 获取睡眠质量颜色
  private getSleepQualityColor(): string {
    if (this.qualityScore >= 75) {
      return GOOD_SLEEP_COLOR;
    } else if (this.qualityScore >= 60) {
      return MEDIUM_SLEEP_COLOR;
    } else {
      return POOR_SLEEP_COLOR;
    }
  }

  build() {
    Column() {
      this.buildCustomAppBar()

      Scroll() {
        Column() {
          this.buildHistoryChart()
          this.buildSleepQualityAnalysis()
          this.buildAiAnalysis()
          this.buildSleepPatternAnalysis()
          this.buildHealthTips()
          this.sleepingAnimals()
          this.healthConsultation()
          this.understandingSleep()
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
        Text('睡眠')
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

  // 睡眠历史柱状图
  @Builder
  buildHistoryChart() {
    Column() {
      Row() {
        Text('本周睡眠测量')
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
            this.generateRandomSleepData();
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

          // 睡眠数据滚动视图
          Swiper() {
            ForEach(this.sleepHistory, (rate: number, index: number) => {
              Column() {
                // 数值标签
                Row() {
                  Text(`${rate}小时`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(PRIMARY_TEXT_COLOR)
                }
                .margin({ bottom: 6 })

                // 柱状图
                Column() {
                  // 根据睡眠时间显示不同颜色
                  Row() {
                    Rect()
                      .width(24)
                      .height(rate * 14)
                      .fill(this.getSleepBarColor(rate))
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
                .fillColor(this.currentChartIndex < this.sleepHistory.length - 1 ? ACCENT_COLOR : '#CCCCCC')
            }
            .width(32)
            .height(32)
            .backgroundColor('#F0F0F0')
            .enabled(this.currentChartIndex < this.sleepHistory.length - 1)
            .onClick(() => {
              if (this.currentChartIndex < this.sleepHistory.length - 1) {
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

      // 睡眠时长说明
      Row({ space: 16 }) {
        Row() {
          Circle().width(10).height(10).fill('#52C41A')
          Text('充足(≥7小时)').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill('#FAAD14')
          Text('一般(6-7小时)').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill('#FF4D4F')
          Text('不足(<6小时)').fontSize(12).margin({ left: 4 })
        }
      }
      .margin({ top: 8 })
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ top: 20, bottom: 15 })
  }

  // 获取睡眠柱状图颜色
  private getSleepBarColor(duration: number): string {
    if (duration >= 7) {
      return GOOD_SLEEP_COLOR;
    } else if (duration >= 6) {
      return MEDIUM_SLEEP_COLOR;
    } else {
      return POOR_SLEEP_COLOR;
    }
  }

  // 睡眠质量分析组件
  @Builder
  buildSleepQualityAnalysis() {
    Column() {
      Row() {
        Image($r('app.media.sleep_quality'))
          .width(24)
          .height(24)

        Text('睡眠质量评估')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .margin({ bottom: 15, top: 5 })

      // 睡眠质量环形进度条
      Row() {
        // 环形进度显示
        Stack() {
          Progress({ value: this.qualityScore, total: 100, type: ProgressType.Ring })
            .color(this.getSleepQualityColor())
            .backgroundColor('#E9E9E9')
            .style({ strokeWidth: 10 })
            .width(120)
            .height(120)

          Column() {
            Text(`${this.qualityScore}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getSleepQualityColor())

            Text('质量评分')
              .fontSize(12)
              .fontColor(SECONDARY_TEXT_COLOR)
          }
          .justifyContent(FlexAlign.Center)
        }
        .margin({ right: 20 })

        // 睡眠质量详情
        Column({ space: 8 }) {
          Row() {
            Text('睡眠时长:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.sleepData.duration}小时`)
              .fontSize(14)
          }

          Row() {
            Text('深度睡眠:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.sleepData.deepSleep}%`)
              .fontSize(14)
          }

          Row() {
            Text('睡眠效率:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.sleepData.efficiency}%`)
              .fontSize(14)
          }

          Row() {
            Text('清醒次数:')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)

            Text(`${this.sleepData.awakeTimes}次`)
              .fontSize(14)
          }
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      // 睡眠质量等级
      Text(this.sleepQuality)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getSleepQualityColor())
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

          Text('AI 睡眠分析')
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

  // 睡眠模式分析组件
  @Builder
  buildSleepPatternAnalysis() {
    Column() {
      Row() {
        Image($r('app.media.sleep_pattern'))
          .width(24)
          .height(24)

        Text('睡眠周期分析')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .margin({ bottom: 10, top: 5 })

      // 睡眠周期图
      Image($r('app.media.sleep_cycle'))
        .width('95%')

        .margin({ top: 5, bottom: 10 })

      Row() {
        Column() {
          Text('入睡时间')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)

          Text('23:15')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }

        Column() {
          Text('起床时间')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)

          Text('07:00')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
        }

        Column() {
          Text('睡眠时长')
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)

          Text(`${this.sleepData.duration}小时`)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 4 })
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

  // 健康建议组件
  @Builder
  buildHealthTips() {
    Column() {
      Row() {
        Image($r('app.media.tips_icon'))
          .width(24)
          .height(24)

        Text('AI 睡眠建议')
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

  //轮播图组件
  @Builder
  buildBanner() {
    Stack() {
      Swiper() {
        ForEach(this.swiperImages, (image: Resource, index: number) => {
          Image(image)
            .width(110)
            .height(110)
            .borderRadius(50)
            .objectFit(ImageFit.Cover)
            .margin({ left: 16, right: 16 })
            .opacity(this.opacities[index] ?? 1) // 每张图片独立透明度
        })
      }
      .index(this.currentIndex)
      .autoPlay(true)
      .interval(3500) // 增加间隔，避免动画重叠
      .indicator(false)
      .loop(true)
      .cachedCount(this.swiperImages.length) // 缓存所有图片
      .onChange((newIndex: number) => {
        console.log('Swiper changing to index:', newIndex);
        // 保存当前透明度
        const prevIndex = this.currentIndex;
        // 更新索引
        this.currentIndex = newIndex;
        // 动画：当前图片淡出，下一张淡入
        animateTo({
          duration: 500,
          curve: Curve.EaseInOut,
          onFinish: () => {
            this.opacities[prevIndex] = 0;
            this.opacities[newIndex] = 1;
            console.log('Animation finished, opacities:', this.opacities);
          }
        }, () => {
          this.opacities[prevIndex] = 1; // 上一张淡出
          this.opacities[newIndex] = 1; // 当前张淡入
        });
      })
    }
    .height(220)
    .margin({ top: 10, bottom: 24 })
  }

  //睡眠动物卡片
  @Builder
  sleepingAnimals() {
    Column({ space: 10 }) {
      Row() {
        Text('探索睡眠动物')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
      }.width('90%').margin({ top: 9 })

      Row() {
        //圆形轮播图
        this.buildBanner()

        Column() {
          Text('哪种睡眠动物属于您?')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 6 })
          Text('获得更多睡眠分析，需使用穿戴设备记录7晚睡眠')
            .fontSize(13)
            .width(180)// 设置固定宽度（超出后自动换行）
            .textOverflow({ overflow: TextOverflow.None }) // 禁用溢出截断
        }
        .margin({ left: 4 })
        .alignItems(HorizontalAlign.Start)
      }
      .borderRadius(15)
      .height(130)
      .margin(10)
      .width('95%')
      .backgroundColor('#FFFFFF')
    }
    .justifyContent(FlexAlign.SpaceAround)
    .margin({ bottom: 15 })
    .height(170)
    .width('95%')
    .backgroundColor('#DEE6E9')
    .borderRadius(15)

  }

  //健康问诊卡片
  @Builder
  healthConsultation() {
    Column() {
      Row({ space: 10 }) {
        Column() {
          Text('睡眠专家问诊')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          Text('睡眠问题咨询专业医生')
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

  //了解睡眠卡片
  @Builder
  understandingSleep() {
    Row({ space: 10 }) {
      Text('了解更多睡眠知识')
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

