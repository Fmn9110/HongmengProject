import router from '@ohos.router';
import dietRecommendationService from '../../services/DietRecommendationService';
import { FoodItem } from '../childpages/dietpage/FoodData';
import { DiseaseTemplate, getAllDiseaseNames, getDiseaseByName } from '../childpages/medicalhistorypage/DiseaseData';
import { loadMedicalRecordsFromStorage } from '../childpages/medicalhistorypage/MedicalHistoryModel';

// 定义颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const LIGHT_BLUE: ResourceColor = '#f6f8ff';
const DIVIDER_COLOR: ResourceColor = '#ff989898';
const TOP_BAR_COLOR: ResourceColor = '#007DFF'; // 替换渐变为纯色
const GLASS_WHITE: ResourceColor = '#33FFFFFF'; // 20% 透明度的白色
const GLASS_BORDER: ResourceColor = '#80FFFFFF'; // 50% 透明度的白色

// 饮食记录数据格式
interface FoodRecord {
  id: number;
  mealType: '早餐' | '午餐' | '晚餐' | '其他';
  foodName: string;
  calories: number;
  recordedAt: string;
}

// 营养分析数据格式
interface NutritionSummary {
  totalCalories: number;
  protein: number;
  fat: number;
  carbohydrates: number;
}

// 添加DiseaseRecordDTO接口用于传递给饮食推荐页面
interface DiseaseRecordDTO {
  name: string;
  diagnosisDate: string;
  severity: string;
  description: string;
  status: string;
}

// 餐饮管理页面主组件
@Entry
@Component
struct FoodManagementPage {
  @State foodRecords: FoodRecord[] = [
    {
      id: 1,
      mealType: '早餐',
      foodName: '燕麦粥',
      calories: 200,
      recordedAt: '2025-05-12 08:00'
    },
    {
      id: 2,
      mealType: '午餐',
      foodName: '鸡胸肉沙拉',
      calories: 350,
      recordedAt: '2025-05-12 12:30'
    },
    {
      id: 3,
      mealType: '晚餐',
      foodName: '清蒸鱼',
      calories: 300,
      recordedAt: '2025-05-12 18:30'
    }
  ];
  @State nutritionSummary: NutritionSummary = {
    totalCalories: 850,
    protein: 60,
    fat: 25,
    carbohydrates: 100
  };
  @State refreshing: boolean = false;
  @State overscrollOffset: number = 0;
  @State aiRecommendation: string = '';
  @State isLoadingRecommendation: boolean = true;
  @State userDiseases: string[] = [];
  @State recommendedFoods: FoodItem[] = [];
  @State diseaseWithSeverity: Map<string, string> = new Map(); // 新增疾病和严重程度的映射
  private dailyCalorieGoal: number = 2000; // 每日推荐热量

  aboutToAppear() {
    // 从病史记录获取真实的用户疾病数据
    this.loadUserDiseases();
  }

  // 当页面显示时（如从病史管理页面返回）重新加载数据
  onPageShow() {
    // 重新加载最新的用户疾病数据
    this.loadUserDiseases();
  }

  // 新增加载用户疾病记录的方法
  async loadUserDiseases() {
    try {
      // 从存储中加载医疗记录
      const records = await loadMedicalRecordsFromStorage();
      if (records && records.length > 0) {
        // 提取疾病名称
        this.userDiseases = records.map(record => record.diseaseName);

        // 提取疾病严重程度并保存到映射中
        const severities: Record<string, string> = {};
        for (let i = 0; i < records.length; i++) {
          const record = records[i];
          this.diseaseWithSeverity.set(record.diseaseName, record.severity);
          severities[record.diseaseName] = record.severity;
        }

        // 设置疾病严重程度到推荐服务
        dietRecommendationService.setDiseaseSeverities(severities);
      } else {
        this.userDiseases = [];
      }

      // 将用户疾病设置到餐饮推荐服务
      dietRecommendationService.setUserDiseases(this.userDiseases);

      // 生成AI推荐
      this.generateAIRecommendation();
    } catch (error) {
      console.error('Failed to load user diseases:', error);
      // 使用默认示例数据作为后备
      this.userDiseases = ['高血压', '糖尿病'];
      dietRecommendationService.setUserDiseases(this.userDiseases);
      this.generateAIRecommendation();
    }
  }

  // 生成AI推荐内容
  private generateAIRecommendation() {
    // 获取疾病对象列表
    const diseaseObjects: DiseaseTemplate[] = [];
    for (let i = 0; i < this.userDiseases.length; i++) {
      const disease = getDiseaseByName(this.userDiseases[i]);
      if (disease) {
        diseaseObjects.push(disease);
      }
    }

    this.aiRecommendation = dietRecommendationService.simulateAIRecommendation(diseaseObjects);
    // 更新推荐食物列表
    const recommendation = dietRecommendationService.getPersonalizedDietRecommendation();
    this.recommendedFoods = recommendation.recommendedFoods.slice(0, 4);
    this.isLoadingRecommendation = false;
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

  // 删除饮食记录
  private deleteRecord(id: number): void {
    const recordToDelete = this.foodRecords.find(record => record.id === id);
    if (recordToDelete) {
      this.foodRecords = this.foodRecords.filter(record => record.id !== id);
      this.updateNutritionSummary(-recordToDelete.calories);
    }
  }

  // 编辑饮食记录
  private editRecord(id: number): void {
    const recordToEdit = this.foodRecords.find(record => record.id === id);
    if (recordToEdit) {
      router.pushUrl({
        url: 'pages/editFoodRecord/EditFoodRecordPage',
        params: { record: recordToEdit }
      });
    }
  }

  // 更新营养分析
  private updateNutritionSummary(caloriesChange: number): void {
    this.nutritionSummary.totalCalories += caloriesChange;
    this.nutritionSummary.protein += caloriesChange * 0.1;
    this.nutritionSummary.fat += caloriesChange * 0.05;
    this.nutritionSummary.carbohydrates += caloriesChange * 0.15;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        // 自定义顶部栏（与运动推荐页面保持一致）
        this.buildCustomAppBar()

        Refresh({ refreshing: this.refreshing, offset: 50, friction: 0.6 }) {
          Scroll() {
            Column({ space: 12 }) {
              this.buildNutritionSummaryCard()
              this.buildFoodRecordsCard()
              this.buildAIDietRecommendationCard()
              this.buildDietAdviceCard()
              this.buildDailyGoalCard()
              this.buildActionButtons()
              Blank()
                .height(this.overscrollOffset)
              Blank()
                .height(100)
            }
            .width('100%')
            .backgroundColor(LIGHT_BLUE)
            .padding({ left: 8, right: 8 })
          }
          .edgeEffect(EdgeEffect.Spring)
          .onScrollEdge((edge: Edge) => {
            this.handleOverscroll(edge);
          })
        }
        .onRefreshing(() => {
          this.refreshing = true;

          // 重新加载用户疾病数据
          this.loadUserDiseases();

          this.foodRecords = [
            {
              id: 1,
              mealType: '早餐',
              foodName: '燕麦粥',
              calories: 200,
              recordedAt: '2025-05-12 08:00'
            },
            {
              id: 2,
              mealType: '午餐',
              foodName: '鸡胸肉沙拉',
              calories: 350,
              recordedAt: '2025-05-12 12:30'
            },
            {
              id: 3,
              mealType: '晚餐',
              foodName: '清蒸鱼',
              calories: 300,
              recordedAt: '2025-05-12 18:30'
            }
          ];

          this.nutritionSummary = {
            totalCalories: 850,
            protein: 60,
            fat: 25,
            carbohydrates: 100
          };

          // 延迟结束刷新状态
          setTimeout(() => {
            this.refreshing = false;
          }, 1000);
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('92%')
    .margin({ top: 35 })
  }

  // 顶部自定义AppBar（与运动推荐页面保持一致）
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
        Text('餐饮管理')
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

  // 营养分析卡片
  @Builder
  buildNutritionSummaryCard() {
    Column() {
      Row() {
        Text('今日营养分析')
          .fontSize(20)
          .fontColor(ACCENT_COLOR)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('查看历史 >')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .onClick(() => {
            router.pushUrl({ url: 'pages/foodHistory/FoodHistoryPage' });
          })
      }
      .width('100%')

      Divider()
        .color(DIVIDER_COLOR)
        .margin({ top: 8, bottom: 8 })

      Row() {
        Text(`摄入热量: ${this.nutritionSummary.totalCalories} kcal / ${this.dailyCalorieGoal} kcal`)
          .fontSize(16)
          .fontColor(PRIMARY_TEXT_COLOR)
      }
      .width('100%')
      .padding({ bottom: 8 })

      Row({ space: 12 }) {
        this.buildNutritionItem(`${this.nutritionSummary.protein}g`, '蛋白质')
        this.buildNutritionItem(`${this.nutritionSummary.fat}g`, '脂肪')
        this.buildNutritionItem(`${this.nutritionSummary.carbohydrates}g`, '碳水')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding(16)
    .margin({ left: 8, right: 8, top: 12 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#00000020',
      offsetX: 4,
      offsetY: 4
    })
    .shadow({
      radius: 8,
      color: '#FFFFFF80',
      offsetX: -4,
      offsetY: -4
    })
  }

  // 单个营养数据项
  @Builder
  buildNutritionItem(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontColor(ACCENT_COLOR)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 5 })
      Text(label)
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
    }
  }

  // 饮食记录卡片
  @Builder
  buildFoodRecordsCard() {
    Column() {
      Row() {
        Text('今日饮食记录')
          .fontSize(20)
          .fontColor(ACCENT_COLOR)
          .fontWeight(FontWeight.Bold)
        Blank()
      }
      .width('100%')

      Divider()
        .color(DIVIDER_COLOR)
        .margin({ top: 8, bottom: 20 })

      if (this.foodRecords.length === 0) {
        Text('暂无饮食记录')
          .fontSize(16)
          .fontColor(SECONDARY_TEXT_COLOR)
          .padding(20)
      } else {
        ForEach(this.foodRecords, (record: FoodRecord, index: number) => {
          Row() {
            Text(this.getMealText(record.mealType))
              .fontSize(24)
              .margin({ right: 12 })

            Column({ space: 4 }) {
              Text(record.mealType)
                .fontSize(18)
                .fontColor(PRIMARY_TEXT_COLOR)
                .fontWeight(FontWeight.Bold)
              Text(record.foodName)
                .fontSize(14)
                .fontColor(SECONDARY_TEXT_COLOR)
              Text(record.recordedAt)
                .fontSize(12)
                .fontColor(SECONDARY_TEXT_COLOR)
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
            .layoutWeight(1)

            Column() {
              Text() {
                Span(`${record.calories} `)
                  .fontSize(20)
                  .fontColor(ACCENT_COLOR)
                  .fontWeight(FontWeight.Medium)
                Span('kcal')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
              }

            }
            .margin({ right: 20 })

            Column({ space: 8 }) {
              Text('编辑')
                .fontSize(12)
                .fontColor(Color.White)
                .backgroundColor('#ff688dec')
                .padding({
                  left: 8,
                  right: 8,
                  top: 4,
                  bottom: 4
                })
                .borderRadius(4)
                .onClick(() => this.editRecord(record.id))
              Text('删除')
                .fontSize(12)
                .fontColor(Color.White)
                .backgroundColor('#ffff6868')
                .padding({
                  left: 8,
                  right: 8,
                  top: 4,
                  bottom: 4
                })
                .borderRadius(4)
                .onClick(() => this.deleteRecord(record.id))
            }
          }
          .width('100%')
          .padding(12)
          .borderRadius(8)
          .backgroundColor('#f9f9f9')
          .margin({ bottom: 16 })
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
        }, (record: FoodRecord) => record.id.toString())
      }
    }
    .padding(16)
    .margin({ left: 8, right: 8 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#00000020',
      offsetX: 4,
      offsetY: 4
    })
    .shadow({
      radius: 8,
      color: '#FFFFFF80',
      offsetX: -4,
      offsetY: -4
    })
  }

  // 获取疾病严重程度文本
  private getDiseaseWithSeverity(disease: string): string {
    return this.diseaseWithSeverity.has(disease) ? this.diseaseWithSeverity.get(disease) || '轻度' : '轻度';
  }

  // AI餐饮推荐卡片
  @Builder
  buildAIDietRecommendationCard() {
    Column() {
      if (this.isLoadingRecommendation) {
        Column({ space: 10 }) {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#4CAF50')

          Text('加载个性化饮食推荐中...')
            .fontSize(16)
            .opacity(0.6)
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else if (this.userDiseases.length === 0) {
        Column() {
          Image($r('app.media.medical'))
            .width(80)
            .height(80)
            .margin({ bottom: 16 })

          Text('暂无个性化饮食推荐')
            .fontSize(18)
            .fontWeight(500)
            .margin({ bottom: 8 })

          Text('请在病史管理页面添加您的健康信息，以获取针对性的饮食建议')
            .fontSize(14)
            .opacity(0.6)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })

          Button('前往病史管理')
            .width('60%')
            .height(40)
            .backgroundColor('#4CAF50')
            .borderRadius(20)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/childpages/medicalhistorypage/MedicalHistoryPage'
              }).catch((err: Error) => {
                console.error(`Failed to navigate to medical history page: ${err.message}`);
              });
            })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        // 显示用户疾病标签
        Column() {
          Text('基于您的健康记录')
            .fontSize(16)
            .fontWeight(500)
            .margin({ bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.userDiseases, (disease: string) => {
              Row() {
                Text(disease)
                  .fontSize(14)
                  .padding({
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: 4
                  })
                  .textAlign(TextAlign.Center)

                // 显示疾病严重程度标签
                if (this.diseaseWithSeverity.has(disease)) {
                  Text(this.getDiseaseWithSeverity(disease))
                    .fontSize(12)
                    .fontColor(this.getSeverityColor(this.getDiseaseWithSeverity(disease)))
                    .backgroundColor(this.getSeverityBgColor(this.getDiseaseWithSeverity(disease)))
                    .borderRadius(10)
                    .padding({
                      left: 6,
                      right: 6,
                      top: 2,
                      bottom: 2
                    })
                    .margin({ left: 4 })
                }
              }
              .backgroundColor('#F0F9FF')
              .borderRadius(16)
              .margin({ right: 8, bottom: 8 })
              .padding({
                right: 4
              })
            })
          }
        }
        .width('100%')
        .padding(16)

        // 显示AI推荐摘要
        if (this.aiRecommendation) {
          Column() {
            Row() {
              Image($r('app.media.aifood'))
                .width(24)
                .height(24)
                .margin({ right: 8 })

              Text('AI营养师建议')
                .fontSize(16)
                .fontWeight(500)
            }
            .width('100%')
            .margin({ top: 16, bottom: 12 })

            Text(this.getAIRecommendationSummary())
              .fontSize(14)
              .lineHeight(22)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .width('100%')
          .padding(16)
        }

        // 查看详细推荐按钮
        Button('查看详细饮食推荐', { type: ButtonType.Normal })
          .width('100%')
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .backgroundColor(ACCENT_COLOR)
          .borderRadius(22)
          .shadow({ radius: 8, color: 'rgba(0, 114, 245, 0.2)', offsetY: 2 })
          .margin({ top: 16 })
          .onClick(() => {
            // 将疾病记录转换为AiDietRecommendationPage需要的格式
            const diseaseRecords: DiseaseRecordDTO[] = [];
            for (let i = 0; i < this.userDiseases.length; i++) {
              const disease = this.userDiseases[i];
              const severity = this.getDiseaseWithSeverity(disease);

              // 创建疾病记录对象
              diseaseRecords.push({
                name: disease,
                diagnosisDate: '', // 餐饮管理页面没有诊断日期信息，留空
                severity: severity,
                description: '', // 餐饮管理页面没有详细描述，留空
                status: '慢性病' // 默认状态
              } as DiseaseRecordDTO);
            }

            // 跳转到餐饮推荐页面，传递疾病记录
            router.pushUrl({
              url: 'pages/childpages/dietpage/AiDietRecommendationPage',
              params: {
                diseaseRecords: diseaseRecords
              }
            }).catch((err: Error) => {
              console.error(`Failed to navigate to diet recommendation page: ${err.message}`);
            });
          })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ bottom: 16 })
  }

  // 获取严重程度对应的颜色
  getSeverityColor(severity: string): string {
    switch (severity) {
      case '轻度':
        return '#22C55E'
      case '中度':
        return '#F59E0B'
      case '重度':
        return '#EF4444'
      default:
        return '#22C55E'
    }
  }

  // 获取严重程度对应的背景颜色
  getSeverityBgColor(severity: string): string {
    switch (severity) {
      case '轻度':
        return 'rgba(34, 197, 94, 0.1)'
      case '中度':
        return 'rgba(245, 158, 11, 0.1)'
      case '重度':
        return 'rgba(239, 68, 68, 0.1)'
      default:
        return 'rgba(34, 197, 94, 0.1)'
    }
  }

  // 食物卡片
  @Builder
  FoodCard(food: FoodItem) {
    Column() {
      Row() {
        // Image(food.imageUrl || $r('app.media.default_food'))
        //   .width(50)
        //   .height(50)
        //   .borderRadius(8)
        //   .objectFit(ImageFit.Cover)

        Column({ space: 4 }) {
          Text(food.name)
            .fontSize(16)
            .fontWeight(500)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(food.benefits.slice(0, 1).join(''))
            .fontSize(12)
            .opacity(0.6)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .padding({ left: 12 })
      }
      .width('100%')
      .padding(10)
    }
    .width('48%')
    .borderRadius(12)
    .backgroundColor('#F0F9F4')
    .border({ width: 1, color: '#C9E7D8' })
  }

  // 饮食建议卡片
  @Builder
  buildDietAdviceCard() {
    Column() {
      Text('饮食建议')
        .fontSize(20)
        .fontColor(ACCENT_COLOR)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      Divider()
        .color(DIVIDER_COLOR)
        .margin({ bottom: 16 })

      Text('• 保持饮食均衡，多摄入蔬菜和水果。')
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ bottom: 8 })

      Text('• 控制每日热量摄入，避免过量。')
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ bottom: 8 })

      Text('• 定时定量，养成良好的饮食习惯。')
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
    }
    .width('95%')
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .margin({ left: 8, right: 8 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#00000020',
      offsetX: 4,
      offsetY: 4
    })
    .shadow({
      radius: 8,
      color: '#FFFFFF80',
      offsetX: -4,
      offsetY: -4
    })
  }

  // 每日饮食目标卡片
  @Builder
  buildDailyGoalCard() {
    Column() {
      Text('每日饮食目标')
        .fontSize(20)
        .fontColor(ACCENT_COLOR)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      Divider()
        .color(DIVIDER_COLOR)
        .margin({ bottom: 8 })

      Row() {
        Text(`热量进度: ${this.nutritionSummary.totalCalories} / ${this.dailyCalorieGoal} kcal`)
          .fontSize(16)
          .fontColor(PRIMARY_TEXT_COLOR)
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Row()
          .width(`${Math.min((this.nutritionSummary.totalCalories / this.dailyCalorieGoal) * 100, 100)}%`)
          .height(8)
          .backgroundColor(ACCENT_COLOR)
          .borderRadius(4)
          .animation({
            duration: 500,
            curve: Curve.EaseInOut
          })
        Blank()
      }
      .width('100%')
      .height(8)
      .backgroundColor('#E5E5E5')
      .borderRadius(4)
    }
    .padding(16)
    .margin({ left: 8, right: 8 })
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#00000020',
      offsetX: 4,
      offsetY: 4
    })
    .shadow({
      radius: 8,
      color: '#FFFFFF80',
      offsetX: -4,
      offsetY: -4
    })
  }

  // 获取餐类型文字表示
  private getMealText(mealType: string): string {
    switch (mealType) {
      case '早餐':
        return '🍳';
      case '午餐':
        return '🍽️';
      case '晚餐':
        return '🍴';
      default:
        return '🍲';
    }
  }

  // 操作按钮
  @Builder
  buildActionButtons() {
    Row({ space: 12 }) {
      Button('添加饮食记录', { type: ButtonType.Normal })
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor(TOP_BAR_COLOR)
        .padding({
          left: 20,
          right: 20,
          top: 12,
          bottom: 12
        })
        .borderRadius(10)
        .shadow({ radius: 10, color: '#00000020' })
        .layoutWeight(1)
        .onClick(() => {
          router.pushUrl({ url: 'pages/addFoodRecord/AddFoodRecordPage' });
        })

      Button('病史管理', { type: ButtonType.Normal })
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor(TOP_BAR_COLOR)
        .padding({
          left: 20,
          right: 20,
          top: 12,
          bottom: 12
        })
        .borderRadius(10)
        .shadow({ radius: 10, color: '#00000020' })
        .layoutWeight(1)
        .onClick(() => {
          router.pushUrl({ url: 'pages/childpages/medicalhistorypage/MedicalHistoryPage' });
        })
    }
    .width('100%')
    .padding(16)
  }

  // 获取AI推荐摘要
  private getAIRecommendationSummary(): string {
    // 如果没有推荐内容，返回空字符串
    if (!this.aiRecommendation) {
      return '';
    }

    // 提取AI推荐的前150个字符作为摘要
    let summary = this.aiRecommendation;
    if (summary.length > 150) {
      summary = summary.substring(0, 150) + '...';
    }

    return summary;
  }
}