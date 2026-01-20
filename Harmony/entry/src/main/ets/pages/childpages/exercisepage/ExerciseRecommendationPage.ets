import router from '@ohos.router';
import { ExerciseRecommendation, ExercisePlan } from './ExerciseData';
import exerciseRecommendationService from '../../../services/ExerciseRecommendationService';

// 定义颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = '#222831';
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const DIVIDER_COLOR: ResourceColor = '#E5E5E5';
const LIGHT_BLUE: ResourceColor = '#FAFAFA';
const CARD_BG_GRADIENT: string = 'linear-gradient(135deg, #f5faff 0%, #e3f0ff 100%)';
const EXERCISE_THEME_COLOR: string = '#5971F0'; // 运动主题色，与睡眠页面保持一致

@Entry
@Component
struct ExerciseRecommendationPage {
  @State refreshing: boolean = false;
  @State overscrollOffset: number = 0;
  @State exerciseRecommendations: ExerciseRecommendation[] = [];
  @State recommendedPlans: ExercisePlan[] = [];
  @State userDiseases: string[] = [];
  @State isLoading: boolean = true;
  @State selectedExercisePlan: ExercisePlan | null = null;
  @State isDetailCardVisible: boolean = false;
  @State selectedExercise: ExerciseRecommendation | null = null;
  @State diseaseSeverities: Map<string, string> = new Map();
  @State animateIcon: boolean = false;
  private scroller: Scroller = new Scroller();
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear() {
    this.loadData();
    // 启动图标动画
    this.startIconAnimation();
  }

  // 启动图标动画效果
  startIconAnimation() {
    this.animateIcon = true;
    setTimeout(() => {
      this.animateIcon = false;
    }, 3000);
  }

  async loadData() {
    try {
      this.isLoading = true;
      
      // 从存储加载用户疾病数据
      await exerciseRecommendationService.loadUserDiseasesFromStorage();
      
      // 获取用户疾病列表
      this.userDiseases = exerciseRecommendationService.getUserDiseases();
      this.diseaseSeverities = exerciseRecommendationService.getDiseaseSeverities();
      
      if (this.userDiseases.length === 0) {
        // 如果没有疾病记录，加载一些默认建议
        this.exerciseRecommendations = exerciseRecommendationService.getExerciseRecommendations();
      } else {
        // 基于疾病生成运动建议
        this.exerciseRecommendations = exerciseRecommendationService.getExerciseRecommendations();
      }
      
      // 获取推荐运动计划
      this.recommendedPlans = exerciseRecommendationService.getRecommendedPlans();
      
      // 默认选择第一个推荐计划
      if (this.recommendedPlans.length > 0) {
        this.selectedExercisePlan = this.recommendedPlans[0];
      }
    } catch (error) {
      console.error('加载运动推荐数据失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 显示详情卡片
  showExerciseDetail(exercise: ExerciseRecommendation) {
    this.selectedExercise = exercise;
    this.isDetailCardVisible = true;
  }

  // 处理顶部/底部弹性回弹动画
  private handleOverscroll(edge: Edge): void {
    if (edge === Edge.Bottom || edge === Edge.Top) {
      this.overscrollOffset = edge === Edge.Bottom ? -50 : 50;
      animateTo({
        duration: 600,
        curve: Curve.Friction,
        onFinish: () => {
          this.overscrollOffset = 0;
        }
      }, () => {
        this.overscrollOffset = 0;
      });
    }
  }

  build() {
    Column() {
      this.buildCustomAppBar()
      
      Scroll(this.scroller) {
        Column({ space: 16 }) {
          // 健康状态摘要卡片
          this.buildHealthStatusCard()
          
          // 运动计划卡片
          if (this.recommendedPlans.length > 0) {
            this.buildExercisePlansSection()
          }
          
          // 个性化运动推荐卡片
          this.buildExerciseRecommendationsSection()
          
          // 运动小贴士
          this.buildExerciseTips()
          
          // 底部间隙，处理回弹
          Blank().height(this.overscrollOffset)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 24, top: 10 })
        .backgroundColor(LIGHT_BLUE)
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .onScrollEdge((edge: Edge) => {
        this.handleOverscroll(edge);
      })
      
      // 详情卡片
      if (this.isDetailCardVisible && this.selectedExercise) {
        this.buildExerciseDetailCard()
      }
    }
    .width('100%')
    .height('92%')
    .backgroundColor(LIGHT_BLUE)
    .margin({ top: 35 })
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
        Text('运动推荐')
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
  
  // 健康状态摘要卡片
  @Builder
  buildHealthStatusCard() {
    Column() {
      Row() {
        Column() {
          Text('个性化运动建议')
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor(PRIMARY_TEXT_COLOR)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 8, bottom: 18 })
          
          if (this.isLoading) {
            Row() {
              LoadingProgress()
                .width(24)
                .height(24)
                .margin({ right: 8 })
              Text('加载中...')
                .fontSize(14)
                .fontColor(SECONDARY_TEXT_COLOR)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding(16)
          } else if (this.userDiseases.length > 0) {
            Column({ space: 8 }) {
              Row() {
                Text('基于您的健康记录:')
                  .fontSize(14)
                  .fontColor(SECONDARY_TEXT_COLOR)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              
              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.userDiseases, (disease: string) => {
                  Row() {
                    Text(disease)
                      .fontSize(12)
                      .fontColor(ACCENT_COLOR)
                    Text(`(${this.diseaseSeverities.get(disease) || '轻度'})`)
                      .fontSize(12)
                      .fontColor(SECONDARY_TEXT_COLOR)
                  }
                  .backgroundColor('#E8F3FF')
                  .borderRadius(12)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                })
              }
              .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          } else {
            Row() {
              Text('未检测到健康记录，以下是通用运动建议')
                .fontSize(14)
                .fontColor(SECONDARY_TEXT_COLOR)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }
        }
        .layoutWeight(3)
        
        // 添加运动图标
        Column() {
          Image($r('app.media.run'))
            .width(60)
            .height(60)
            .objectFit(ImageFit.Contain)
            .animation({
              duration: 1000,
              tempo: 3.0,
              delay: 100,
              curve: Curve.EaseInOut,
              playMode: PlayMode.Alternate,
              iterations: this.animateIcon ? 2 : 0
            })
            .scale({ x: this.animateIcon ? 1.1 : 1.0, y: this.animateIcon ? 1.1 : 1.0 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
    }
    .width('95%')
    .backgroundColor(CARD_BG_GRADIENT)
    .borderRadius(18)
    .padding(16)
    .shadow({ radius: 10, color: '#007DFF11' })
    .margin({ bottom: 16 })
  }
  
  // 运动计划部分
  @Builder
  buildExercisePlansSection() {
    Column() {
      Text('推荐运动计划')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 8, bottom: 18 })
      
      Swiper(this.swiperController) {
        ForEach(this.recommendedPlans, (plan: ExercisePlan) => {
          Column() {
            Row() {
              Column({ space: 4 }) {
                Text(plan.planName)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(PRIMARY_TEXT_COLOR)
                
                Text(plan.description)
                  .fontSize(14)
                  .fontColor(SECONDARY_TEXT_COLOR)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                
                Row() {
                  Text(`难度: ${this.getDifficultyText(plan.difficulty)}`)
                    .fontSize(12)
                    .fontColor(EXERCISE_THEME_COLOR)
                  
                  Text(`|`)
                    .fontSize(12)
                    .fontColor(DIVIDER_COLOR)
                    .margin({ left: 8, right: 8 })
                  
                  Text(plan.totalDuration)
                    .fontSize(12)
                    .fontColor(EXERCISE_THEME_COLOR)
                }
                .margin({ top: 4 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              
              Button('查看详情')
                .fontSize(14)
                .fontColor(Color.White)
                .backgroundColor(EXERCISE_THEME_COLOR)
                .borderRadius(16)
                .width(96)
                .height(32)
                .onClick(() => {
                  this.selectedExercisePlan = plan;
                })
            }
            .width('100%')
            .padding(16)
            
            Column() {
              Row() {
                Text('包含:')
                  .fontSize(14)
                  .fontColor(SECONDARY_TEXT_COLOR)
                  .margin({ right: 8 })
                
                ForEach(plan.exercises.slice(0, 3), (exercise: ExerciseRecommendation, index) => {
                  if (index > 0) {
                    Text('、')
                      .fontSize(14)
                      .fontColor(SECONDARY_TEXT_COLOR)
                  }
                  Text(exercise.exerciseName)
                    .fontSize(14)
                    .fontColor(PRIMARY_TEXT_COLOR)
                })
                
                if (plan.exercises.length > 3) {
                  Text('等')
                    .fontSize(14)
                    .fontColor(SECONDARY_TEXT_COLOR)
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .backgroundColor(CARD_BG_GRADIENT)
          .borderRadius(18)
          .shadow({ radius: 10, color: '#007DFF11' })
        })
      }
      .indicator(true)
      .itemSpace(16)
      .displayCount(1)
      .indicatorStyle({ selectedColor: EXERCISE_THEME_COLOR })
      .width('95%')
      .height(180)
      .autoPlay(true)
      .interval(5000)
      
      // 如果有选中的计划，显示计划详情
      if (this.selectedExercisePlan) {
        Column() {
          Text(this.selectedExercisePlan.planName + ' 运动列表')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
            .alignSelf(ItemAlign.Start)
            .margin({ top: 16, bottom: 8 })
          
          List() {
            ForEach(this.selectedExercisePlan.exercises, (exercise: ExerciseRecommendation) => {
              ListItem() {
                this.buildExerciseItem(exercise)
              }
            })
          }
          .width('100%')
          .divider({ strokeWidth: 1, color: DIVIDER_COLOR, startMargin: 16, endMargin: 16 })
        }
        .width('95%')
        .backgroundColor(CARD_BG_GRADIENT)
        .borderRadius(18)
        .padding(16)
        .shadow({ radius: 10, color: '#007DFF11' })
        .margin({ top: 16 })
      }
    }
  }
  
  // 所有运动推荐部分
  @Builder
  buildExerciseRecommendationsSection() {
    Column() {
      Text('适合您的运动')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 8, bottom: 18 })
      
      Column() {
        if (this.isLoading) {
          Row() {
            LoadingProgress()
              .width(24)
              .height(24)
              .margin({ right: 8 })
            Text('加载中...')
              .fontSize(14)
              .fontColor(SECONDARY_TEXT_COLOR)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding(16)
        } else if (this.exerciseRecommendations.length > 0) {
          List() {
            ForEach(this.exerciseRecommendations, (exercise: ExerciseRecommendation) => {
              ListItem() {
                this.buildExerciseItem(exercise)
              }
            })
          }
          .width('100%')
          .divider({ strokeWidth: 1, color: DIVIDER_COLOR, startMargin: 16, endMargin: 16 })
        } else {
          Row() {
            Text('暂无适合您的运动推荐')
              .fontSize(14)
              .fontColor(SECONDARY_TEXT_COLOR)
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding(16)
        }
      }
      .width('95%')
      .backgroundColor(CARD_BG_GRADIENT)
      .borderRadius(18)
      .shadow({ radius: 10, color: '#007DFF11' })
    }
  }
  
  // 运动小贴士
  @Builder
  buildExerciseTips() {
    Column() {
      Text('运动小贴士')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 8, bottom: 18 })
      
      Column({ space: 12 }) {
        this.buildTipItem('开始运动前，请先进行5-10分钟的热身活动')
        this.buildTipItem('运动中如有不适，请立即停止并咨询医生')
        this.buildTipItem('保持良好的水分补充，运动前后都要喝水')
        this.buildTipItem('循序渐进，不要一开始就进行高强度运动')
      }
      .width('100%')
      .padding(16)
    }
    .width('95%')
    .backgroundColor(CARD_BG_GRADIENT)
    .borderRadius(18)
    .shadow({ radius: 10, color: '#007DFF11' })
    .margin({ top: 16, bottom: 16 })
  }
  
  // 小贴士项目
  @Builder
  buildTipItem(tip: string) {
    Row({ space: 8 }) {
      Image($r('app.media.right'))
        .width(18)
        .height(18)
        .objectFit(ImageFit.Contain)
        .fillColor(EXERCISE_THEME_COLOR)
      
      Text(tip)
        .fontSize(14)
        .fontColor(PRIMARY_TEXT_COLOR)
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
  
  // 单个运动项目
  @Builder
  buildExerciseItem(exercise: ExerciseRecommendation) {
    Row() {
      Column({ space: 4 }) {
        Row() {
          Text(exercise.exerciseName)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
          
          Text(`(${exercise.intensity})`)
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ left: 8 })
        }
        
        Text(exercise.description)
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        
        Row() {
          Text(exercise.duration)
            .fontSize(12)
            .fontColor(EXERCISE_THEME_COLOR)
          
          Text(`|`)
            .fontSize(12)
            .fontColor(DIVIDER_COLOR)
            .margin({ left: 8, right: 8 })
          
          Text(exercise.frequency)
            .fontSize(12)
            .fontColor(EXERCISE_THEME_COLOR)
        }
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      Image($r('app.media.right'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .fillColor(EXERCISE_THEME_COLOR)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .onClick(() => {
      this.showExerciseDetail(exercise);
    })
  }
  
  // 运动详情卡片
  @Builder
  buildExerciseDetailCard() {
    Column() {
      Column({ space: 16 }) {
        Row() {
          Text('运动详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
          
          Blank()
          
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            Image($r('app.media.close'))
              .width(16)
              .height(16)
          }
          .width(32)
          .height(32)
          .backgroundColor('#f5f5f5')
          .onClick(() => {
            this.isDetailCardVisible = false;
          })
        }
        .width('100%')
        
        Divider().color(DIVIDER_COLOR)
        
        Column({ space: 16 }) {
          Row() {
            Text('运动名称:')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(SECONDARY_TEXT_COLOR)
              .width(80)
            
            Text(this.selectedExercise?.exerciseName || '')
              .fontSize(16)
              .fontColor(PRIMARY_TEXT_COLOR)
              .layoutWeight(1)
          }
          .width('100%')
          
          this.buildDetailRow('强度:', this.selectedExercise?.intensity || '')
          this.buildDetailRow('时长:', this.selectedExercise?.duration || '')
          this.buildDetailRow('频率:', this.selectedExercise?.frequency || '')
          
          Column({ space: 8 }) {
            Text('描述:')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(SECONDARY_TEXT_COLOR)
            
            Text(this.selectedExercise?.description || '')
              .fontSize(16)
              .fontColor(PRIMARY_TEXT_COLOR)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          
          Column({ space: 8 }) {
            Text('益处:')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(SECONDARY_TEXT_COLOR)
            
            Text(this.selectedExercise?.benefits || '')
              .fontSize(16)
              .fontColor(PRIMARY_TEXT_COLOR)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          
          Column({ space: 8 }) {
            Text('注意事项:')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF5252')
            
            Text(this.selectedExercise?.precautions || '')
              .fontSize(16)
              .fontColor(PRIMARY_TEXT_COLOR)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          
          Column({ space: 8 }) {
            Text('适用疾病:')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(SECONDARY_TEXT_COLOR)
            
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.selectedExercise?.suitableDiseases || [], (disease: string) => {
                Text(disease)
                  .fontSize(14)
                  .fontColor(EXERCISE_THEME_COLOR)
                  .backgroundColor('#E8F3FF')
                  .borderRadius(12)
                  .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                  .margin({ right: 8, bottom: 8 })
              })
            }
            .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .padding({ left: 16, right: 16 })
        
        Button('开始锻炼')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(EXERCISE_THEME_COLOR)
          .borderRadius(20)
          .width('90%')
          .height(40)
          .margin({ top: 16, bottom: 24 })
      }
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0, 0, 0, 0.5)')
    .justifyContent(FlexAlign.Center)
    .position({ x: 0, y: 0 })
    .zIndex(999)
  }
  
  // 详情行
  @Builder
  buildDetailRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(SECONDARY_TEXT_COLOR)
        .width(80)
      
      Text(value)
        .fontSize(16)
        .fontColor(PRIMARY_TEXT_COLOR)
        .layoutWeight(1)
    }
    .width('100%')
  }
  
  // 获取难度文本
  getDifficultyText(difficulty: string): string {
    switch (difficulty) {
      case 'easy':
        return '简单';
      case 'moderate':
        return '中等';
      case 'challenging':
        return '挑战';
      default:
        return '未知';
    }
  }
}