import { router } from '@kit.ArkUI'

const PRIMARY_TEXT_COLOR: string = '#222831'
const SECONDARY_TEXT_COLOR: string = '#666666'
const ACCENT_COLOR: string = '#007DFF'
const USER_MESSAGE_COLOR: string = '#07C160'
const CARD_BG_GRADIENT: string = 'linear-gradient(135deg, #f5faff 0%, #e3f0ff 100%)'
const NORMAL_WEIGHT_COLOR: string = '#52C41A' // 正常体重颜色
const OVERWEIGHT_COLOR: string = '#FAAD14' // 超重颜色
const UNDERWEIGHT_COLOR: string = '#1890FF' // 偏瘦颜色
const OBESE_COLOR: string = '#FF4D4F' // 肥胖颜色
const WEIGHT_COLOR: string = '#4ed01c' // 体重曲线颜色

// 体重状态枚举
enum WeightStatus {
  UNDERWEIGHT = '体重偏轻',
  NORMAL = '体重正常',
  OVERWEIGHT = '体重超标',
  OBESE = '体重肥胖',
  SEVERELY_OBESE = '重度肥胖'
}

// BMI分类
enum BMICategory {
  UNDERWEIGHT = '偏瘦',
  NORMAL = '正常',
  OVERWEIGHT = '超重',
  OBESE_1 = '肥胖一级',
  OBESE_2 = '肥胖二级',
  OBESE_3 = '肥胖三级'
}

// 体重数据接口
interface WeightData {
  value: number, // 当前体重值(kg)
  height: number, // 身高(cm)
  bmi: number, // BMI指数
  bodyFat: number, // 体脂率(%)
  muscle: number, // 肌肉含量(%)
  water: number, // 水分含量(%)
  bone: number, // 骨量(kg)
  protein: number, // 蛋白质(%)
  idealWeight: number, // 理想体重(kg)
  maxHistory: number, // 最大历史体重
  minHistory: number, // 最小历史体重
  weightStatus: WeightStatus, // 体重状态
  statusDescription: string, // 体重状态描述
  healthTips: string, // 健康小贴士
  aiAnalysis: string // AI分析报告
}

@Entry
@Component
struct WeightPage {
  @State weightHistory: number[] = [60, 61, 62, 61, 60, 59, 58] // 历史数据
  @State currentWeight: number = 58 // 当前体重值
  @State isMeasuring: boolean = false // 是否正在测量
  @State weightStatus: WeightStatus = WeightStatus.NORMAL // 体重状态
  @State bmiCategory: BMICategory = BMICategory.NORMAL // BMI分类
  @State statusScore: number = 85 // 体重健康评分
  @State aiAnalysis: string = '' // AI分析结果
  @State healthTips: string[] = [] // 健康建议
  @State isAnalyzing: boolean = false // 是否正在分析
  @State weightData: WeightData = {
    // 体重详细数据
    value: 58,
    height: 170,
    bmi: 20.1,
    bodyFat: 18.5,
    muscle: 42.3,
    water: 55.2,
    bone: 2.8,
    protein: 16.5,
    idealWeight: 63.8,
    maxHistory: 62,
    minHistory: 58,
    weightStatus: WeightStatus.NORMAL,
    statusDescription: '体重正常',
    healthTips: '保持规律饮食，遵循均衡膳食原则',
    aiAnalysis: ''
  }
  @State currentChartIndex: number = 0 // 当前图表索引
  @State showScrollHint: boolean = true // 显示滚动提示
  @State scrollHintOpacity: number = 1 // 滚动提示透明度

  // 在页面加载前生成随机体重数据
  aboutToAppear() {
    this.generateRandomWeightData();
    this.startScrollHintAnimation();
    this.performAiAnalysis();
  }

  // 生成随机体重数据的方法
  private generateRandomWeightData() {
    // 随机身高160-185
    const height = Math.floor(Math.random() * 25 + 160);
    // 基于身高计算理想体重范围
    const idealWeight = (height - 105).toFixed(1);
    // 理想体重上下浮动范围
    const weightVariation = Math.floor(Math.random() * 15) - 7;

    // 生成随机体重历史数据
    this.weightHistory = [];
    const baseWeight = Number(idealWeight) + weightVariation;

    for (let i = 0; i < 7; i++) {
      // 生成在基准体重上下2kg范围内的随机值
      const randomWeight = (baseWeight + (Math.random() * 4 - 2)).toFixed(1);
      this.weightHistory.push(Number(randomWeight));
    }

    // 生成当前体重和详细数据
    const currentWeight = this.weightHistory[this.weightHistory.length - 1];
    this.currentWeight = currentWeight;

    // 计算BMI
    const bmi = (currentWeight / ((height / 100) * (height / 100))).toFixed(1);

    // 基于BMI随机生成其他体重相关数据
    const bodyFat = (18 + Math.random() * 10).toFixed(1);
    const muscle = (40 + Math.random() * 10).toFixed(1);
    const water = (50 + Math.random() * 10).toFixed(1);
    const bone = (2.5 + Math.random() * 1).toFixed(1);
    const protein = (15 + Math.random() * 5).toFixed(1);

    // 更新体重数据
    this.weightData = {
      value: currentWeight,
      height: height,
      bmi: Number(bmi),
      bodyFat: Number(bodyFat),
      muscle: Number(muscle),
      water: Number(water),
      bone: Number(bone),
      protein: Number(protein),
      idealWeight: Number(idealWeight),
      maxHistory: Math.max(...this.weightHistory),
      minHistory: Math.min(...this.weightHistory),
      weightStatus: WeightStatus.NORMAL,
      statusDescription: '体重正常',
      healthTips: '保持规律饮食，遵循均衡膳食原则',
      aiAnalysis: ''
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
      this.calculateWeightStatus();
      this.generateHealthTips();
      this.generateAiAnalysis();
      this.isAnalyzing = false;
    }, 1000);
  }

  // 计算体重状态
  private calculateWeightStatus() {
    const weight = this.weightData.value;
    const height = this.weightData.height;
    const bmi = this.weightData.bmi;
    const bodyFat = this.weightData.bodyFat;

    // 更新BMI值
    this.weightData.bmi = Number((weight / ((height / 100) * (height / 100))).toFixed(1));

    // 分类BMI
    if (bmi < 18.5) {
      this.bmiCategory = BMICategory.UNDERWEIGHT;
    } else if (bmi >= 18.5 && bmi < 24) {
      this.bmiCategory = BMICategory.NORMAL;
    } else if (bmi >= 24 && bmi < 28) {
      this.bmiCategory = BMICategory.OVERWEIGHT;
    } else if (bmi >= 28 && bmi < 30) {
      this.bmiCategory = BMICategory.OBESE_1;
    } else if (bmi >= 30 && bmi < 40) {
      this.bmiCategory = BMICategory.OBESE_2;
    } else {
      this.bmiCategory = BMICategory.OBESE_3;
    }

    // 计算体重状态评分(0-100)
    let bmiScore = 0;
    if (bmi >= 18.5 && bmi <= 24) {
      // 正常BMI范围内，距离理想BMI(22)越近，分数越高
      bmiScore = 50 - Math.abs(bmi - 22) * 5;
    } else if (bmi < 18.5) {
      // 偏瘦，基础分较低
      bmiScore = Math.max(10, 30 - (18.5 - bmi) * 5);
    } else {
      // 超重或肥胖，基础分较低并随BMI增加而降低
      bmiScore = Math.max(0, 30 - (bmi - 24) * 3);
    }

    // 体脂率评分
    let bodyFatScore = 0;
    // 假定理想体脂率为男性15-20%，女性20-25%，这里取中间值
    const idealBodyFat = 20;
    if (bodyFat >= 15 && bodyFat <= 25) {
      bodyFatScore = 30 - Math.abs(bodyFat - idealBodyFat) * 1.5;
    } else if (bodyFat < 15) {
      bodyFatScore = Math.max(10, 20 - (15 - bodyFat) * 2);
    } else {
      bodyFatScore = Math.max(0, 20 - (bodyFat - 25) * 1);
    }

    // 肌肉率和其他指标评分
    const otherScore = Math.min(20, (this.weightData.muscle / 50) * 10 + (this.weightData.water / 60) * 10);

    this.statusScore = Math.min(100, Math.max(0, Math.round(bmiScore + bodyFatScore + otherScore)));

    // 根据评分和BMI共同确定体重状态
    if (this.statusScore >= 85) {
      this.weightStatus = WeightStatus.NORMAL;
    } else if (bmi < 18.5) {
      this.weightStatus = WeightStatus.UNDERWEIGHT;
    } else if (bmi >= 24 && bmi < 28) {
      this.weightStatus = WeightStatus.OVERWEIGHT;
    } else if (bmi >= 28 && bmi < 35) {
      this.weightStatus = WeightStatus.OBESE;
    } else if (bmi >= 35) {
      this.weightStatus = WeightStatus.SEVERELY_OBESE;
    } else {
      // BMI正常但评分不高，可能是肌肉率或体脂率问题
      this.weightStatus = this.weightData.muscle < 38 ? WeightStatus.UNDERWEIGHT : WeightStatus.NORMAL;
    }

    // 更新体重数据中的状态
    this.weightData.weightStatus = this.weightStatus;

    // 生成状态描述文本
    let statusDescription = '';
    switch (this.weightStatus) {
      case WeightStatus.UNDERWEIGHT:
        statusDescription = `偏瘦 (BMI: ${bmi.toFixed(1)})，建议适当增重`;
        break;
      case WeightStatus.NORMAL:
        statusDescription = `体重正常 (BMI: ${bmi.toFixed(1)})，继续保持`;
        break;
      case WeightStatus.OVERWEIGHT:
        statusDescription = `体重超标 (BMI: ${bmi.toFixed(1)})，建议控制饮食`;
        break;
      case WeightStatus.OBESE:
        statusDescription = `体重肥胖 (BMI: ${bmi.toFixed(1)})，需要减重`;
        break;
      case WeightStatus.SEVERELY_OBESE:
        statusDescription = `重度肥胖 (BMI: ${bmi.toFixed(1)})，建议咨询医生`;
        break;
    }

    // 更新状态描述
    this.weightData.statusDescription = statusDescription;
  }

  // 生成健康建议
  private generateHealthTips() {
    const tips = [
      '保持规律饮食，遵循均衡膳食原则',
      '增加蛋白质摄入，有助肌肉生长与维持',
      '控制碳水化合物摄入，尤其是晚餐后',
      '每周进行至少150分钟的有氧运动',
      '结合力量训练，每周2-3次，增强肌肉',
      '保持充足的水分摄入，成年人每日建议2000ml',
      '减少高糖、高脂肪食品的摄入',
      '选择全谷类食物，增加膳食纤维摄入',
      '多摄入蔬菜水果，提供维生素和矿物质',
      '避免久坐，每小时起身活动5-10分钟',
      '控制饮食速度，细嚼慢咽有助于控制进食量',
      '不要过度减肥，以健康的速度(每周0.5-1kg)为宜',
      '增肌减脂应该同时进行，不要单纯追求体重数字',
      '增加日常活动量，步行代替乘车，走楼梯替代电梯',
      '定期记录体重变化，建立长期健康习惯',
      '保持良好的睡眠质量，睡眠不足会影响体重控制'
    ];

    // 根据体重状态选择不同数量的建议
    let count = 3; // 默认3条建议

    if (this.weightStatus === WeightStatus.OBESE ||
      this.weightStatus === WeightStatus.SEVERELY_OBESE) {
      count = 5;
    } else if (this.weightStatus === WeightStatus.OVERWEIGHT ||
      this.weightStatus === WeightStatus.UNDERWEIGHT) {
      count = 4;
    }

    // 随机选择建议
    this.healthTips = [];
    const shuffled = [...tips].sort(() => 0.5 - Math.random());
    this.healthTips = shuffled.slice(0, count);

    // 更新健康小贴士
    this.weightData.healthTips = this.healthTips.join('\n• ');
    if (this.weightData.healthTips.length > 0) {
      this.weightData.healthTips = '• ' + this.weightData.healthTips;
    }
  }

  // 生成AI分析文本
  private generateAiAnalysis() {
    const avgWeight = this.weightHistory.reduce((sum, curr) => sum + curr, 0) / this.weightHistory.length;
    const bmi = this.weightData.bmi;
    const height = this.weightData.height;
    const bodyFat = this.weightData.bodyFat;
    const idealWeight = this.weightData.idealWeight;

    // 分析文本
    let analysis = `本周您的平均体重为${avgWeight.toFixed(1)}kg，身高${height}cm，BMI指数为${bmi}。`;
    let weightTrend = '';

    // 分析体重趋势
    const recentWeights = this.weightHistory.slice(-3);
    if (recentWeights[2] > recentWeights[0]) {
      weightTrend = '体重呈上升趋势';
    } else if (recentWeights[2] < recentWeights[0]) {
      weightTrend = '体重呈下降趋势';
    } else {
      weightTrend = '体重保持稳定';
    }

    analysis += ` 最近${weightTrend}。`;

    // 基于BMI和体重状态的分析
    switch (this.bmiCategory) {
      case BMICategory.UNDERWEIGHT:
        analysis += `您的BMI低于18.5，属于${this.bmiCategory}范围，建议适当增加营养摄入。`;
        break;
      case BMICategory.NORMAL:
        analysis += `您的BMI在18.5-24之间，属于${this.bmiCategory}范围，请继续保持良好的饮食习惯和运动习惯。`;
        break;
      case BMICategory.OVERWEIGHT:
        analysis += `您的BMI在24-28之间，属于${this.bmiCategory}范围，建议注意饮食控制并增加运动量。`;
        break;
      case BMICategory.OBESE_1:
      case BMICategory.OBESE_2:
      case BMICategory.OBESE_3:
        analysis += `您的BMI超过28，属于${this.bmiCategory}范围，建议咨询专业医生制定减重计划。`;
        break;
    }

    // 体脂率分析
    if (bodyFat < 15) {
      analysis += ` 您的体脂率偏低(${bodyFat}%)，可能影响身体健康，建议增加适当优质脂肪摄入。`;
    } else if (bodyFat > 25) {
      analysis += ` 您的体脂率偏高(${bodyFat}%)，建议增加运动量并调整饮食结构。`;
    } else {
      analysis += ` 您的体脂率(${bodyFat}%)在健康范围内。`;
    }

    // 理想体重建议
    const weightDiff = this.weightData.value - idealWeight;
    if (Math.abs(weightDiff) > 5) {
      if (weightDiff > 0) {
        analysis += ` 建议逐步减重至${idealWeight}kg左右，每周减重0.5-1kg为宜。`;
      } else {
        analysis += ` 建议适度增重至${idealWeight}kg左右，注重增加肌肉而非脂肪。`;
      }
    } else if (Math.abs(weightDiff) > 2) {
      analysis += ` 您的体重接近理想范围，微调至${idealWeight}kg左右可能更加健康。`;
    } else {
      analysis += ` 您的体重已处于理想范围内。`;
    }

    // 更新AI分析报告
    this.weightData.aiAnalysis = analysis;
  }

  // 获取体重状态颜色
  private getWeightStatusColor(): string {
    switch (this.bmiCategory) {
      case BMICategory.UNDERWEIGHT:
        return UNDERWEIGHT_COLOR;
      case BMICategory.NORMAL:
        return NORMAL_WEIGHT_COLOR;
      case BMICategory.OVERWEIGHT:
        return OVERWEIGHT_COLOR;
      default:
        return OBESE_COLOR;
    }
  }

  // 获取体重柱状图颜色
  private getWeightBarColor(weight: number): string {
    // 基于身高计算各个体重范围对应的BMI
    const height = this.weightData.height / 100; // 转换为米
    const underweightThreshold = 18.5 * height * height;
    const normalThreshold = 24 * height * height;
    const overweightThreshold = 28 * height * height;

    if (weight < underweightThreshold) {
      return UNDERWEIGHT_COLOR;
    } else if (weight >= underweightThreshold && weight < normalThreshold) {
      return NORMAL_WEIGHT_COLOR;
    } else if (weight >= normalThreshold && weight < overweightThreshold) {
      return OVERWEIGHT_COLOR;
    } else {
      return OBESE_COLOR;
    }
  }

  build() {
    Column() {
      // 页面内容在滚动视图中展示
      Scroll() {
        Column() {
          // 自定义顶部栏
          this.buildCustomAppBar()

          // 体重测量组件
          this.buildWeightMeasurement()

          // 体重历史图表
          this.buildHistoryChart()

          // AI体重分析
          this.weightAnalysis()

          // 健康咨询
          this.healthConsultation()

          // 了解BMI
          this.understandingBMI()

          // 底部空间，确保内容不被遮挡
          Row().height(20)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('92%')
      .align(Alignment.TopStart)
      .onScroll((offset: number) => {
        // 当用户滚动页面时，隐藏滚动提示
        if (offset > 5 && this.showScrollHint) {
          this.showScrollHint = false;
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .margin({ top: 35 })
    .onAppear(() => {
      this.generateRandomWeightData();
      this.startScrollHintAnimation();
    })
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

        Text('体重')
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
    .width('100%')
    .margin({ bottom: 10 })
  }

  // 体重测量组件
  @Builder
  buildWeightMeasurement() {
    Column() {
      // 体重测量卡片标题
      Row() {
        Image($r('app.media.weight'))
          .width(24)
          .height(24)

        Text('实时体重测量')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15, top: 5 })

      // 体重测量图示和数值
      Stack() {
        // 底部装饰圆形
        Circle()
          .width(180)
          .height(180)
          .fill('#F0F9EB')
          .opacity(0.8)

        // 体重秤图示
        Image($r("app.media.weight"))
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

      // 当前体重数值与单位显示
      Column() {
        Text(`${this.currentWeight}`)
          .fontSize(40)
          .fontColor('#4ED01C')
          .fontWeight(FontWeight.Bold)
        Text('kg')
          .fontSize(18)
          .fontColor(SECONDARY_TEXT_COLOR)
      }
      .margin({ bottom: 20 })
      .alignItems(HorizontalAlign.Center)

      // 体重测量按钮
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
            Image($r('app.media.weight'))
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
      .backgroundColor(this.isMeasuring ? '#BBBBBB' : '#4ED01C')
      .borderRadius(26)
      .shadow({ radius: 8, color: '#4ED01C33', offsetY: 4 })
      .onClick(() => {
        this.startMeasurement()
      })
      .margin({ bottom: 20 })
      .enabled(!this.isMeasuring)
      .stateEffect(this.isMeasuring ? false : true)

      // 测量说明文本
      if (!this.isMeasuring) {
        Text('点击开始测量您的体重')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ bottom: 5 })
      } else {
        Text('请站在体重秤上保持稳定')
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

  // 启动体重测量动画与数据模拟
  private startMeasurement() {
    if (this.isMeasuring) {
      return
    }
    this.isMeasuring = true
    let count = 0

    // 模拟体重测量过程
    const intervalId = setInterval(() => {
      if (count < 10) {
        if (count < 5) {
          // 前5秒显示测量过程中的数值变化
          const baseWeight = this.currentWeight;
          this.currentWeight = Number((baseWeight + (Math.random() * 0.4 - 0.2)).toFixed(1)); // 模拟测量中的数值波动
        }
        count++;
      } else {
        // 测量结束时
        clearInterval(intervalId);
        this.isMeasuring = false;

        // 生成最终测量结果
        const baseWeight = this.weightData.idealWeight;
        // 在理想体重上下8kg范围内随机生成体重
        this.currentWeight = Number((baseWeight + (Math.random() * 16 - 8)).toFixed(1));

        // 更新历史体重数据和当前体重数据
        this.weightHistory = [...this.weightHistory.slice(1), this.currentWeight];
        this.weightData.value = this.currentWeight;
        this.weightData.maxHistory = Math.max(this.weightData.maxHistory, this.currentWeight);
        this.weightData.minHistory = Math.min(this.weightData.minHistory, this.currentWeight);

        // 进行AI分析
        this.performAiAnalysis();
      }
    }, 600);
  }

  // 体重历史柱状图
  @Builder
  buildHistoryChart() {
    Column() {
      Row() {
        Text('本周体重测量')
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
            this.generateRandomWeightData();
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

          // 体重数据滚动视图
          Swiper() {
            ForEach(this.weightHistory, (weight: number, index: number) => {
              Column() {
                // 数值标签
                Row() {
                  Text(`${weight}kg`)
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
                      .height(weight * 2)
                      .fill(this.getWeightBarColor(weight))
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
              .height(200)
              .width('100%')
              .justifyContent(FlexAlign.Center)
            })
          }
          .width('80%')
          .height(200)
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
                .fillColor(this.currentChartIndex < this.weightHistory.length - 1 ? ACCENT_COLOR : '#CCCCCC')
            }
            .width(32)
            .height(32)
            .backgroundColor('#F0F0F0')
            .enabled(this.currentChartIndex < this.weightHistory.length - 1)
            .onClick(() => {
              if (this.currentChartIndex < this.weightHistory.length - 1) {
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

      // BMI范围说明
      Row({ space: 16 }) {
        Row() {
          Circle().width(10).height(10).fill(UNDERWEIGHT_COLOR)
          Text('偏瘦(<18.5)').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill(NORMAL_WEIGHT_COLOR)
          Text('正常(18.5-24)').fontSize(12).margin({ left: 4 })
        }

        Row() {
          Circle().width(10).height(10).fill(OVERWEIGHT_COLOR)
          Text('超重(>24)').fontSize(12).margin({ left: 4 })
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

  // 体重分析卡片
  @Builder
  weightAnalysis() {
    Column() {
      // 体重分析标题
      Row() {
        Image($r('app.media.ai_icon'))
          .width(24)
          .height(24)

        Text('AI 体重分析')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15, top: 5 })

      // AI分析结果展示
      Column({ space: 16 }) {
        // 体重状态卡片
        Column() {
          Row() {
            Text('当前体重状态')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_TEXT_COLOR)

            Blank()

            Row() {
              Text(`BMI: ${this.weightData.bmi.toFixed(1)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getWeightStatusColor())
            }
          }
          .width('100%')

          // 体重状态条
          Row() {
            // BMI指示器背景
            Stack() {
              // 背景渐变色
              Row() {
                Row().width('33%').height(10).backgroundColor('#81C784')
                Row().width('34%').height(10).backgroundColor('#4CAF50')
                Row().width('33%').height(10).backgroundColor('#FF9800')
              }
              .width('100%')
              .height(10)
              .borderRadius(5)

              // 当前位置指示器
              Column() {
                Circle()
                  .width(20)
                  .height(20)
                  .fill(this.getWeightStatusColor())
                  .stroke('#FFFFFF')
                  .strokeWidth(2)
              }
              .position({
                x: `${Math.min(Math.max((this.weightData.bmi - 15) / 15 * 100, 0), 100)}%`
              })
            }
            .height(20)
            .width('100%')
            .margin({ top: 15, bottom: 10 })
          }

          // BMI指示标签
          Row() {
            Text('偏瘦').fontSize(12).fontColor(UNDERWEIGHT_COLOR)
            Blank()
            Text('标准').fontSize(12).fontColor(NORMAL_WEIGHT_COLOR)
            Blank()
            Text('超重').fontSize(12).fontColor(OVERWEIGHT_COLOR)
          }
          .width('100%')
          .margin({ bottom: 5 })

          // 体重评价
          Row() {
            Text(this.weightData.statusDescription)
              .fontSize(14)
              .fontColor(this.getWeightStatusColor())
              .fontWeight(FontWeight.Medium)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ top: 10 })
        }
        .padding(15)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .width('100%')

        // 体脂率卡片
        Column() {
          Row() {
            Text('体脂率分析')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_TEXT_COLOR)

            Blank()

            Row() {
              Text(`${this.weightData.bodyFat}%`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getWeightStatusColor())
            }
          }
          .width('100%')
          .margin({ bottom: 10 })

          Text(this.weightData.bodyFat < 20 ? '您的体脂率处于正常范围，继续保持良好的生活习惯。' :
            '您的体脂率偏高，建议增加有氧运动来减少体脂。')
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .textAlign(TextAlign.Start)
            .width('100%')
        }
        .padding(15)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .width('100%')

        // 健康小贴士
        Column() {
          Row() {
            Image($r('app.media.light'))
              .width(20)
              .height(20)
            Text('健康小贴士')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_TEXT_COLOR)
              .margin({ left: 5 })
          }
          .margin({ bottom: 10 })
          .width('100%')

          Text(this.weightData.healthTips)
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ bottom: 10 })
        }
        .padding(15)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .width('100%')

        // AI分析报告
        Column() {
          Row() {
            Image($r('app.media.ai_icon'))
              .width(20)
              .height(20)
            Text('AI 报告解析')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_TEXT_COLOR)
              .margin({ left: 5 })
          }
          .margin({ bottom: 10 })
          .width('100%')

          Text(this.weightData.aiAnalysis)
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .textAlign(TextAlign.Start)
            .width('100%')
            .margin({ bottom: 5 })
        }
        .padding(15)
        .backgroundColor('#F5F5F5')
        .borderRadius(12)
        .width('100%')
      }
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
  }

  // 健康咨询
  @Builder
  healthConsultation() {
    Column() {
      Row() {
        Image($r('app.media.doctor'))
          .width(24)
          .height(24)

        Text('健康咨询')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })

        Blank()

        Button() {
          Text('咨询专家')
            .fontSize(14)
            .fontColor('#FFFFFF')
        }
        .height(32)
        .width(70)
        .backgroundColor(ACCENT_COLOR)
        .borderRadius(16)
        .onClick(() => {
          router.pushUrl({ url: 'pages/childpages/consultpage/ConsultPage' });
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15, top: 5 })

      Row() {
        // 在线咨询选项
        Column() {
          Image($r('app.media.chat'))
            .width(36)
            .height(36)
            .margin({ bottom: 10 })

          Text('在线咨询')
            .fontSize(14)
            .fontColor(PRIMARY_TEXT_COLOR)
        }
        .width('33%')
        .height(80)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 处理在线咨询点击
        })

        // 预约门诊选项
        Column() {
          Image($r('app.media.calendar'))
            .width(36)
            .height(36)
            .margin({ bottom: 10 })

          Text('预约门诊')
            .fontSize(14)
            .fontColor(PRIMARY_TEXT_COLOR)
        }
        .width('33%')
        .height(80)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 处理预约门诊点击
        })

        // 电话咨询选项
        Column() {
          Image($r('app.media.phone'))
            .width(36)
            .height(36)
            .margin({ bottom: 10 })

          Text('电话咨询')
            .fontSize(14)
            .fontColor(PRIMARY_TEXT_COLOR)
        }
        .width('33%')
        .height(80)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 处理电话咨询点击
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

  //了解BMI卡片
  @Builder
  understandingBMI() {
    Column() {
      Row() {
        Image($r('app.media.info'))
          .width(24)
          .height(24)

        Text('了解BMI')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 15, top: 5 })

      Column({ space: 12 }) {
        Text('什么是BMI？')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(PRIMARY_TEXT_COLOR)
          .textAlign(TextAlign.Start)
          .width('100%')

        Text('BMI（身体质量指数）是评估人体肥胖程度和健康风险的常用指标，计算方式为：体重(kg)/身高²(m²)')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .textAlign(TextAlign.Start)
          .width('100%')

        Text('BMI分类标准：')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(PRIMARY_TEXT_COLOR)
          .textAlign(TextAlign.Start)
          .width('100%')
          .margin({ top: 10 })

        // BMI分类表格
        Column() {
          // 表头
          Row() {
            Text('分类')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('40%')
              .textAlign(TextAlign.Center)
              .padding(8)
              .backgroundColor('#F5F5F5')

            Text('BMI范围')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .width('60%')
              .textAlign(TextAlign.Center)
              .padding(8)
              .backgroundColor('#F5F5F5')
          }

          // 偏瘦
          Row() {
            Text('偏瘦')
              .fontSize(14)
              .width('40%')
              .textAlign(TextAlign.Center)
              .padding(8)

            Text('< 18.5')
              .fontSize(14)
              .width('60%')
              .textAlign(TextAlign.Center)
              .padding(8)
          }
          .backgroundColor('#F8F8F8')

          // 正常
          Row() {
            Text('正常范围')
              .fontSize(14)
              .width('40%')
              .textAlign(TextAlign.Center)
              .padding(8)

            Text('18.5 - 24.0')
              .fontSize(14)
              .width('60%')
              .textAlign(TextAlign.Center)
              .padding(8)
          }

          // 超重
          Row() {
            Text('超重')
              .fontSize(14)
              .width('40%')
              .textAlign(TextAlign.Center)
              .padding(8)

            Text('24.0 - 28.0')
              .fontSize(14)
              .width('60%')
              .textAlign(TextAlign.Center)
              .padding(8)
          }
          .backgroundColor('#F8F8F8')

          // 肥胖
          Row() {
            Text('肥胖')
              .fontSize(14)
              .width('40%')
              .textAlign(TextAlign.Center)
              .padding(8)

            Text('≥ 28.0')
              .fontSize(14)
              .width('60%')
              .textAlign(TextAlign.Center)
              .padding(8)
          }
        }
        .width('100%')
        .borderRadius(8)
        .clip(true)
        .margin({ bottom: 10 })

        Text('注意：BMI指数仅作为参考，不考虑个体差异、肌肉比例等因素')
          .fontSize(14)
          .fontStyle(FontStyle.Italic)
          .fontColor('#888888')
          .width('100%')
          .margin({ top: 5 })
      }
    }
    .padding(15)
    .backgroundColor('#FFFFFF')
    .borderRadius(15)
    .width('95%')
    .margin({ bottom: 15 })
  }
}

