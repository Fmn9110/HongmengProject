import router from '@ohos.router';
import DietRecommendationComponent from '../../../components/diet/DietRecommendationComponent';
import dietRecommendationService from '../../../services/DietRecommendationService';
import { getDiseaseByName } from '../../childpages/medicalhistorypage/DiseaseData';
import { DiseaseDietSuggestion } from './DiseaseDietData';
import { foodDatabase, FOOD_ICONS } from './FoodData';
import common from '@ohos.app.ability.common';
import image from '@ohos.multimedia.image';

// 常量定义 - 使用统一的颜色方案
const BACKGROUND_COLOR = '#F8F8F8';
const CARD_BACKGROUND = '#FFFFFF';
const PRIMARY_COLOR = '#4CAF50';
const SECONDARY_COLOR = '#81C784';
const ACCENT_COLOR = '#FF9800';
const TEXT_PRIMARY = '#333333';
const TEXT_SECONDARY = '#666666';
const BORDER_RADIUS = 12;
const SHADOW_COLOR = 'rgba(0, 0, 0, 0.08)';

// 定义食物项接口
interface FoodItem {
  name: string;
  description?: string;
  tags?: string[];
  image?: Resource;
  imageUrl?: string;
}

// 定义Section接口用于分割内容
interface Section {
  title: string;
  content: string;
}

// 定义疾病记录接口
interface DiseaseRecord {
  name: string;
  diagnosisDate: string;
  severity: string;
  description: string;
  status: string;
}

// 定义路由参数接口
interface RouteParams {
  diseaseRecords?: DiseaseRecord[];
}

// 食物图标映射
const FOOD_ICON_MAP: Record<string, Resource> = {
  '燕麦': $r('app.media.oatmeal'),
  '糙米': $r('app.media.brown_rice'),
  '藜麦': $r('app.media.quinoa'),
  '全麦面包': $r('app.media.whole_wheat_bread'),
  '燕麦麸': $r('app.media.oatmeal2'),
  '三文鱼': $r('app.media.salmon'),
  '沙丁鱼': $r('app.media.salmon2'),
  '豆腐': $r('app.media.tofu'),
  '鸡胸肉': $r('app.media.chicken_breast'),
  '鸡蛋': $r('app.media.eggs'),
  '希腊酸奶': $r('app.media.greek_yogurt'),
  '扁豆': $r('app.media.lentils'),
  '鹰嘴豆': $r('app.media.lentils2'),
  '牛油果': $r('app.media.avocado'),
  '橄榄油': $r('app.media.olive_oil'),
  '亚麻籽': $r('app.media.flaxseeds'),
  '核桃': $r('app.media.walnuts'),
  '杏仁': $r('app.media.almonds'),
  '菠菜': $r('app.media.spinach'),
  '西兰花': $r('app.media.broccoli'),
  '羽衣甘蓝': $r('app.media.kale'),
  '甜椒': $r('app.media.bell_peppers'),
  '番茄': $r('app.media.tomatoes'),
  '胡萝卜': $r('app.media.carrots'),
  '芦笋': $r('app.media.asparagus'),
  '蓝莓': $r('app.media.blueberries'),
  '苹果': $r('app.media.apple'),
  '柑橘类水果': $r('app.media.orange'),
  '草莓': $r('app.media.strawberries'),
  '梨': $r('app.media.pear'),
  '绿茶': $r('app.media.green_tea'),
  '姜茶': $r('app.media.ginger_tea'),
  '强化豆浆': $r('app.media.soy_milk'),
  '低脂牛奶': $r('app.media.low_fat_milk'),
  '姜黄': $r('app.media.turmeric'),
  '肉桂': $r('app.media.cinnamon'),
  '大蒜': $r('app.media.garlic'),
  '生姜': $r('app.media.ginger'),
  '黑巧克力': $r('app.media.dark_chocolate'),
  '红酒': $r('app.media.red_wine')
};

// 获取食物图标
function getFoodIcon(name: string): Resource {
  return FOOD_ICON_MAP[name] || $r('app.media.food');
}

// 根据FoodData.ts中的图片路径获取资源名称
function getResourceNameFromPath(path: string): string {
  if (!path) {
    return 'food';
  }

  // 从路径中提取文件名（不含扩展名）
  const parts = path.split('/');
  const fileName = parts[parts.length - 1];
  const nameWithoutExt = fileName.split('.')[0];

  return nameWithoutExt;
}

@Entry
@Component
struct AiDietRecommendationPage {
  @State isLoading: boolean = true;
  @State userDiseases: DiseaseRecord[] = [];
  @State aiRecommendation: string = '';
  @State recommendedFoods: FoodItem[] = [];
  @State detailedDietSuggestion: DiseaseDietSuggestion | undefined = undefined;
  // 用于跟踪上次的疾病记录，以便检测变化
  private lastDiseaseNames: string[] = [];
  private lastDiseaseRecords: DiseaseRecord[] = [];

  aboutToAppear() {
    // 获取路由参数中的疾病记录
    this.loadDiseaseRecords();

    // 生成饮食建议
    this.generateDietRecommendations();
  }

  // 每次页面显示时调用，用于检查疾病记录是否有变化
  onPageShow() {
    // 重新加载疾病记录
    this.loadDiseaseRecords();

    // 获取当前疾病名称列表
    const currentDiseaseNames = this.userDiseases.map(disease => disease.name);

    // 检查疾病列表是否有变化（名称或数量）
    let hasChanges = this.lastDiseaseNames.length !== currentDiseaseNames.length ||
      !this.lastDiseaseNames.every(name => currentDiseaseNames.includes(name));

    // 如果疾病名称没有变化，检查严重程度是否有变化
    if (!hasChanges && this.lastDiseaseRecords.length > 0) {
      // 检查是否有疾病的严重程度发生了变化
      for (const currentDisease of this.userDiseases) {
        const lastDisease = this.lastDiseaseRecords.find(d => d.name === currentDisease.name);
        if (lastDisease && lastDisease.severity !== currentDisease.severity) {
          hasChanges = true;
          break;
        }
      }
    }

    // 如果有变化，重新生成饮食建议
    if (hasChanges) {
      this.isLoading = true;
      this.generateDietRecommendations();

      // 更新上次的疾病名称列表和记录
      this.lastDiseaseNames = [...currentDiseaseNames];
      this.lastDiseaseRecords = JSON.parse(JSON.stringify(this.userDiseases)) as DiseaseRecord[];
    }
  }

  // 加载疾病记录
  private loadDiseaseRecords() {
    // 从路由参数中获取疾病记录数据，如果没有则使用模拟数据
    const params = router.getParams() as RouteParams;
    if (params && params.diseaseRecords && params.diseaseRecords.length > 0) {
      this.userDiseases = params.diseaseRecords;
      console.info('从路由参数获取到疾病记录:', JSON.stringify(this.userDiseases));
    } else {
      // 使用模拟数据，与图二中显示的疾病记录一致
      this.userDiseases = [
        {
          name: '高血压',
          diagnosisDate: '2023-01-15',
          severity: '中度',
          description: '血压波动较大，需要定期监测',
          status: '持续治疗中'
        },
        {
          name: '糖尿病',
          diagnosisDate: '2022-05-20',
          severity: '轻度',
          description: '需控制碳水化合物摄入',
          status: '持续治疗中'
        },
        {
          name: '骨质疏松',
          diagnosisDate: '2023-08-10',
          severity: '中度',
          description: '需要增加负重运动',
          status: '持续治疗中'
        }
      ];
      console.info('使用默认疾病记录数据');
    }

    // 初始化时保存疾病名称列表和记录，用于后续检测变化
    if (this.lastDiseaseNames.length === 0) {
      this.lastDiseaseNames = this.userDiseases.map(disease => disease.name);
      this.lastDiseaseRecords = JSON.parse(JSON.stringify(this.userDiseases)) as DiseaseRecord[];
    }
  }

  // 根据疾病记录生成饮食建议
  private generateDietRecommendations() {
    // 设置服务中的用户疾病名称
    const diseaseNames = this.userDiseases.map(disease => disease.name);

    // 同时传递疾病严重程度信息，便于生成更精确的建议
    const diseaseSeverities: Record<string, string> = {};
    this.userDiseases.forEach(disease => {
      // 直接设置属性，避免使用Object.assign
      diseaseSeverities[disease.name] = disease.severity;
    });

    // 设置疾病名称到服务中
    dietRecommendationService.setUserDiseases(diseaseNames);

    // 如果有可用的方法，也设置疾病严重程度
    if (typeof dietRecommendationService.setDiseaseSeverities === 'function') {
      dietRecommendationService.setDiseaseSeverities(diseaseSeverities);
    }

    // 获取AI推荐
    if (diseaseNames.length > 0) {
      this.aiRecommendation = dietRecommendationService.getDietRecommendationForDisease();

      // 获取详细饮食建议
      this.detailedDietSuggestion = dietRecommendationService.getDetailedDietSuggestion();

      // 获取推荐食物
      const dietRec = dietRecommendationService.getPersonalizedDietRecommendation();

      console.info('获取到的推荐食物数量:', dietRec.recommendedFoods.length);

      // 记录食物数据结构
      if (dietRec.recommendedFoods.length > 0) {
        console.info('第一个食物的数据结构:', JSON.stringify(dietRec.recommendedFoods[0]));
      }

      // 创建临时数组存储转换后的食物项
      const tempFoods: FoodItem[] = [];

      // 转换前5个推荐食物
      for (let i = 0; i < Math.min(dietRec.recommendedFoods.length, 5); i++) {
        const food = dietRec.recommendedFoods[i];

        // 尝试通过名称获取资源图标
        let foodIcon = FOOD_ICON_MAP[food.name];

        // 如果通过名称找不到，尝试从imageUrl提取资源名称
        if (!foodIcon && food.imageUrl) {
          const resourceName = getResourceNameFromPath(food.imageUrl);
          try {
            // 尝试使用提取的资源名称获取资源
            foodIcon = $r(`app.media.${resourceName}`);
            console.info(`使用imageUrl提取的资源名称: ${resourceName}`);
          } catch (e) {
            console.error(`资源不存在: app.media.${resourceName}`);
            // 使用默认图标
            foodIcon = $r('app.media.food');
          }
        }

        console.info(`食物 ${food.name} 的图标已分配`);

        tempFoods.push({
          name: food.name,
          description: food.benefits.join('，'),
          tags: [food.category],
          image: foodIcon  // 使用资源图标
        });
      }

      console.info('转换后的食物数据:', JSON.stringify(tempFoods));

      // 设置转换后的食物数组
      this.recommendedFoods = tempFoods;
    } else {
      this.aiRecommendation = '';
      this.recommendedFoods = [];
      this.detailedDietSuggestion = undefined;
    }

    // 完成加载
    this.isLoading = false;

    console.info('饮食建议已更新，疾病数:', diseaseNames.length);
  }

  build() {
    Column() {
      // 顶部状态栏占位
      Column()
        .width('100%')
        .height(24)
        .backgroundColor(CARD_BACKGROUND)

      // 导航栏
      Row() {
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .fillColor(TEXT_PRIMARY)
            .onClick(() => {
              try {
                router.back();
              } catch (err) {
                console.error(`Failed to go back. Code: ${err.message}`);
              }
            })
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .borderRadius(18)
        .backgroundColor(BACKGROUND_COLOR)
        .margin({ right: 16 })

        Text('AI 智能饮食推荐')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(CARD_BACKGROUND)
      .shadow({ radius: 6, color: SHADOW_COLOR, offsetY: 2 })

      // 内容区域
      Scroll() {
        Column() {
          // 用户疾病信息
          if (this.userDiseases.length > 0) {
            Column() {
              Row() {
                Image($r('app.media.medical'))
                  .width(24)
                  .height(24)
                  .margin({ right: 8 })

                Text('基于您的健康记录')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(TEXT_PRIMARY)
              }
              .width('100%')
              .margin({ bottom: 12 })

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.userDiseases, (disease: DiseaseRecord) => {
                  Column() {
                    Text(disease.name)
                      .fontSize(14)
                      .fontColor(TEXT_PRIMARY)
                      .backgroundColor('#FFE0B2')
                      .padding({
                        left: 12,
                        right: 12,
                        top: 6,
                        bottom: 6
                      })
                      .borderRadius(16)
                      .margin({ bottom: 4 })

                    Row() {
                      Text(`诊断日期: ${disease.diagnosisDate}`)
                        .fontSize(12)
                        .fontColor(TEXT_SECONDARY)
                    }
                    .margin({ bottom: 2 })

                    Row() {
                      Text(disease.severity)
                        .fontSize(12)
                        .fontColor(this.getSeverityColor(disease.severity))
                        .fontWeight(FontWeight.Medium)
                    }
                    .margin({ bottom: 2 })

                    Row() {
                      Text(disease.status)
                        .fontSize(12)
                        .fontColor('#2196F3')
                        .backgroundColor('#E3F2FD')
                        .padding({
                          left: 8,
                          right: 8,
                          top: 2,
                          bottom: 2
                        })
                        .borderRadius(10)
                    }
                  }
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor(CARD_BACKGROUND)
                  .borderRadius(8)
                  .padding(8)
                  .margin({ right: 12, bottom: 12 })
                  .width('45%')
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(CARD_BACKGROUND)
            .borderRadius(BORDER_RADIUS)
            .margin({ bottom: 16 })
            .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })
          }

          // AI饮食建议
          if (this.isLoading) {
            Column() {
              LoadingProgress()
                .width(36)
                .height(36)
                .color(PRIMARY_COLOR)
                .margin({ bottom: 12 })

              Text('正在生成个性化饮食建议...')
                .fontSize(16)
                .fontColor(TEXT_SECONDARY)
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(CARD_BACKGROUND)
            .borderRadius(BORDER_RADIUS)
            .margin({ bottom: 16 })
            .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })
          } else if (this.aiRecommendation && this.aiRecommendation.trim().length > 0) {
            Column() {
              Row() {
                Image($r('app.media.proposal'))
                  .width(24)
                  .height(24)
                  .margin({ right: 8 })

                Text('AI 个性化饮食方案')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(PRIMARY_COLOR)
              }
              .width('100%')
              .margin({ bottom: 16 })

              this.renderAIRecommendationContent()
            }
            .width('100%')
            .padding(16)
            .backgroundColor(CARD_BACKGROUND)
            .borderRadius(BORDER_RADIUS)
            .margin({ bottom: 16 })
            .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })
          } else {
            Column() {
              Image($r('app.media.medical'))
                .width(80)
                .height(80)
                .opacity(0.6)
                .margin({ bottom: 16 })

              Text('暂无饮食建议')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(TEXT_PRIMARY)
                .margin({ bottom: 8 })

              Text('请在健康记录中添加您的健康信息，以获取个性化饮食建议')
                .fontSize(14)
                .fontColor(TEXT_SECONDARY)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .height(300)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(CARD_BACKGROUND)
            .borderRadius(BORDER_RADIUS)
            .padding(16)
            .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })
          }

          // 详细饮食建议
          if (this.detailedDietSuggestion) {
            this.buildDetailedDietSuggestion()
          }

          // 食物推荐区域
          if (this.recommendedFoods.length > 0) {
            Column() {
              Row() {
                Text('推荐食物')
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(TEXT_PRIMARY)

                Blank()

                Text('查看全部')
                  .fontSize(14)
                  .fontColor(PRIMARY_COLOR)
                  .onClick(() => {
                    // 跳转到食物列表页面
                  })
              }
              .width('100%')
              .margin({ bottom: 16 })

              Column() {
                ForEach(this.recommendedFoods, (item: FoodItem) => {
                  this.buildFoodCard(item)
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(CARD_BACKGROUND)
            .borderRadius(BORDER_RADIUS)
            .margin({ top: 8, bottom: 16 })
            .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })
          }
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16,
          bottom: 24,
          top: 16
        })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BACKGROUND_COLOR)
  }

  // 根据疾病严重程度返回不同的颜色
  getSeverityColor(severity: string): string {
    switch (severity) {
      case '轻度':
        return '#4CAF50'; // 绿色
      case '中度':
        return '#FF9800'; // 橙色
      case '重度':
        return '#F44336'; // 红色
      default:
        return TEXT_SECONDARY;
    }
  }

  @Builder
  renderAIRecommendationContent() {
    ForEach(this.splitContentToSections(this.aiRecommendation), (section: Section) => {
      Column() {
        if (section.title) {
          Row() {
            Divider()
              .vertical(false)
              .strokeWidth(3)
              .color(ACCENT_COLOR)
              .width(3)
              .height(18)
              .margin({ right: 8 })

            Text(section.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(TEXT_PRIMARY)
          }
          .alignItems(VerticalAlign.Center)
          .margin({ top: 16, bottom: 8 })
          .width('100%')
        }

        if (section.content) {
          Text(section.content)
            .fontSize(15)
            .fontColor(TEXT_SECONDARY)
            .lineHeight(24)
            .margin({ bottom: 8 })
            .width('100%')
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 4, right: 4 })
    })
  }

  private splitContentToSections(content: string): Section[] {
    let sections: Section[] = [];

    // 添加介绍部分（第一段）
    let introEnd = content.indexOf('【');
    if (introEnd > 0) {
      let intro = content.substring(0, introEnd).trim();
      if (intro) {
        sections.push({
          title: '个性化建议',
          content: intro
        });
      }
    }

    // 处理其余部分
    let lines = content.split('\n');
    let currentTitle = '';
    let currentContent = '';

    for (let i = 0; i < lines.length; i++) {
      let line = lines[i].trim();

      // 检查是否是标题行
      if (line.startsWith('【') && line.includes('】')) {
        // 如果已有内容，保存之前的部分
        if (currentContent) {
          sections.push({
            title: currentTitle,
            content: currentContent.trim()
          });
        }

        // 提取新标题
        currentTitle = line;
        currentContent = '';
      }
      // 添加内容到当前部分
      else if (line) {
        currentContent += line + '\n';
      }
    }

    // 添加最后一部分
    if (currentContent) {
      sections.push({
        title: currentTitle,
        content: currentContent.trim()
      });
    }

    return sections;
  }

  @Builder
  buildFoodCard(item: FoodItem) {
    Row() {
      // 食物图片显示
      Stack() {
        // 圆形背景
        Circle()
          .fill('#E8F5E9')// 浅绿色背景
          .width(80)
          .height(80)

        // 显示食物图片
        if (item.image) {
          Image(item.image)
            .width(60)
            .height(60)
            .objectFit(ImageFit.Contain)
            .onError(() => {
              console.error(`图片加载失败，使用默认图标`);
            })
        } else {
          // 如果没有图片，显示默认图标
          Image($r('app.media.food'))
            .width(40)
            .height(40)
            .objectFit(ImageFit.Contain)
        }
      }
      .margin({ right: 16 })

      Column() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .margin({ bottom: 4 })

        Text(item.description || '富含多种营养素，有助于健康饮食')
          .fontSize(14)
          .fontColor(TEXT_SECONDARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 6 })

        // 分类标签
        Text(item.tags && item.tags.length > 0 ? item.tags[0] : '全谷物')
          .fontSize(12)
          .fontColor(PRIMARY_COLOR)
          .backgroundColor('#E8F5E9')
          .padding({
            left: 10,
            right: 10,
            top: 4,
            bottom: 4
          })
          .borderRadius(12)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(8)
    .margin({ bottom: 12 })
  }

  @Builder
  buildDetailedDietSuggestion() {
    if (this.detailedDietSuggestion) {
      Column() {
        // 饮食原则
        Column() {
          Row() {
            Image($r('app.media.icon_checked'))
              .width(24)
              .height(24)
              .margin({ right: 8 })

            Text('核心饮食原则')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_COLOR)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Column() {
            ForEach(this.detailedDietSuggestion.dietPrinciples, (principle: string) => {
              Row() {
                Text('•')
                  .fontSize(16)
                  .fontColor(ACCENT_COLOR)
                  .margin({ right: 8 })

                Text(principle)
                  .fontSize(15)
                  .fontColor(TEXT_SECONDARY)
                  .lineHeight(24)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
              .margin({ bottom: 8 })
            })
          }
          .width('100%')
          .padding({ left: 4, right: 4 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor(CARD_BACKGROUND)
        .borderRadius(BORDER_RADIUS)
        .margin({ bottom: 16 })
        .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })

        // 推荐食物
        Column() {
          Row() {
            Image($r('app.media.food'))
              .width(24)
              .height(24)
              .margin({ right: 8 })

            Text('推荐食物')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_COLOR)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.detailedDietSuggestion.recommendedFoods, (food: string) => {
              Text(food)
                .fontSize(14)
                .fontColor(TEXT_PRIMARY)
                .backgroundColor('#E8F5E9')
                .padding({
                  left: 12,
                  right: 12,
                  top: 6,
                  bottom: 6
                })
                .borderRadius(16)
                .margin({ right: 8, bottom: 8 })
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(CARD_BACKGROUND)
        .borderRadius(BORDER_RADIUS)
        .margin({ bottom: 16 })
        .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })

        // 限制食物
        Column() {
          Row() {
            Image($r('app.media.xianzhi'))
              .width(24)
              .height(24)
              .margin({ right: 8 })

            Text('限制食物')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_COLOR)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.detailedDietSuggestion.restrictedFoods, (food: string) => {
              Text(food)
                .fontSize(14)
                .fontColor(TEXT_PRIMARY)
                .backgroundColor('#FFCCBC')
                .padding({
                  left: 12,
                  right: 12,
                  top: 6,
                  bottom: 6
                })
                .borderRadius(16)
                .margin({ right: 8, bottom: 8 })
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(CARD_BACKGROUND)
        .borderRadius(BORDER_RADIUS)
        .margin({ bottom: 16 })
        .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })

        // 一日饮食计划示例
        Column() {
          Row() {
            Image($r('app.media.DietPlan'))
              .width(24)
              .height(24)
              .margin({ right: 8 })

            Text('一日饮食计划示例')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_COLOR)
          }
          .width('100%')
          .margin({ bottom: 12 })

          Text(this.detailedDietSuggestion.mealPlanSample)
            .fontSize(15)
            .fontColor(TEXT_SECONDARY)
            .lineHeight(24)
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(CARD_BACKGROUND)
        .borderRadius(BORDER_RADIUS)
        .margin({ bottom: 16 })
        .shadow({ radius: 4, color: SHADOW_COLOR, offsetY: 1 })
      }
      .width('100%')
    }
  }
} 