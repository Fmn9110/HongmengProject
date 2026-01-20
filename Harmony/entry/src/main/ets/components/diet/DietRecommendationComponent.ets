import dietRecommendationService, { DietRecommendation } from '../../services/DietRecommendationService';
import { FoodItem } from '../../pages/childpages/dietpage/FoodData';
import { getDiseaseByName, DiseaseTemplate } from '../../pages/childpages/medicalhistorypage/DiseaseData';

// 定义Section接口用于分割内容
interface Section {
  title: string;
  content: string;
}

@Component
export default struct DietRecommendationComponent {
  @State recommendation: DietRecommendation = {
    recommendedFoods: [],
    restrictedFoods: [],
    dietPrinciples: [],
    diseaseBased: []
  };
  @State aiRecommendation: string = '';
  @State isLoading: boolean = true;
  @State userDiseases: string[] = [];
  
  aboutToAppear() {
    // 模拟数据加载延迟，实际项目中可能是从服务器获取数据
    setTimeout(() => {
      this.userDiseases = dietRecommendationService.getUserDiseases();
      this.recommendation = dietRecommendationService.getPersonalizedDietRecommendation();
      
      // 获取疾病对象列表
      const diseaseObjects: DiseaseTemplate[] = [];
      for (let i = 0; i < this.userDiseases.length; i++) {
        const disease = getDiseaseByName(this.userDiseases[i]);
        if (disease) {
          diseaseObjects.push(disease);
        }
      }
      
      this.aiRecommendation = dietRecommendationService.getDietRecommendationForDisease();
      this.isLoading = false;
    }, 1000);
  }
  
  build() {
    Column() {
      if (this.isLoading) {
        Column({ space: 10 }) {
          LoadingProgress()
            .width(50)
            .height(50)
          
          Text('加载个性化饮食推荐中...')
            .fontSize(16)
            .opacity(0.6)
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else if (this.recommendation.diseaseBased.length === 0) {
        Column() {
          Image($r('app.media.medical'))
            .width(120)
            .height(120)
            .margin({ bottom: 16 })
          
          Text('暂无个性化饮食推荐')
            .fontSize(18)
            .fontWeight(500)
            .margin({ bottom: 8 })
          
          Text('请在病史管理页面添加您的健康信息，以获取针对性的饮食建议')
            .fontSize(14)
            .opacity(0.6)
            .textAlign(TextAlign.Center)
            .padding({ left: 20, right: 20 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else {
        this.renderAIRecommendation()
        this.renderDietPrinciples()
        this.renderFoodRecommendations()
      }
    }
    .width('100%')
    .padding(16)
  }
  
  @Builder
  renderAIRecommendation() {
    Column() {
      if (this.isLoading) {
        this.buildLoadingState()
      } else if (this.aiRecommendation && this.aiRecommendation.trim().length > 0) {
        Column() {
          Row() {
            Image($r('app.media.icon'))
              .width(24)
              .height(24)
              .margin({ right: 8 })
            Text('AI个性化饮食建议')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
          }
          .width('100%')
          .margin({ top: 16, bottom: 8 })

          // 解析AI推荐内容
          this.parseAIRecommendation(this.aiRecommendation)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
      } else {
        this.buildEmptyState('暂无AI饮食建议，请添加健康记录')
      }
    }
    .width('100%')
  }
  
  @Builder
  parseAIRecommendation(content: string) {
    Column() {
      ForEach(this.splitContentToSections(content), (section: Section) => {
        Column() {
          if (section.title) {
            Text(section.title)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 12, bottom: 4 })
              .width('100%')
          }
          
          if (section.content) {
            Text(section.content)
              .fontSize(14)
              .lineHeight(20)
              .margin({ bottom: 8 })
              .width('100%')
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
  
  private splitContentToSections(content: string): Section[] {
    let sections: Section[] = [];
    
    // 使用正则表达式匹配标题和内容
    const regex = /【(.*?)】|(\n\n)/g;
    let matches = content.split(regex);
    
    // 处理匹配结果
    let currentTitle = '';
    let currentContent = '';
    
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
      // 检查是否是一日饮食安排部分
      else if (line.includes('一日饮食安排') || line.includes('饮食计划') || line.includes('膳食计划')) {
        // 如果已有内容，保存之前的部分
        if (currentContent) {
          sections.push({
            title: currentTitle,
            content: currentContent.trim()
          });
        }
        
        // 设置新标题
        currentTitle = '一日饮食安排';
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
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(24)
        .height(24)
        .margin({ bottom: 8 })
      
      Text('加载中...')
        .fontSize(14)
        .opacity(0.6)
    }
    .width('100%')
    .height(100)
    .justifyContent(FlexAlign.Center)
  }
  
  @Builder
  buildEmptyState(message: string) {
    Column() {
      Image($r('app.media.medical'))
        .width(60)
        .height(60)
        .opacity(0.6)
        .margin({ bottom: 12 })
      
      Text(message)
        .fontSize(14)
        .opacity(0.6)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(150)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
  
  @Builder
  renderDietPrinciples() {
    Column() {
      Text('饮食指导原则')
        .fontSize(18)
        .fontWeight(500)
        .margin({ bottom: 12 })
      
      List() {
        ForEach(this.recommendation.dietPrinciples, (principle: string) => {
          ListItem() {
            Row({ space: 8 }) {
              Image($r('app.media.icon_checked'))
                .width(20)
                .height(20)
              
              Text(principle)
                .fontSize(15)
                .lineHeight(22)
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
          }
        })
      }
      .divider({ strokeWidth: 1, color: '#EEEEEE', startMargin: 28 })
    }
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(16)
    .margin({ bottom: 16 })
  }
  
  @Builder
  renderFoodRecommendations() {
    Column() {
      // 推荐食物
      if (this.recommendation.recommendedFoods.length > 0) {
        Column() {
          Text('推荐食物')
            .fontSize(18)
            .fontWeight(500)
            .margin({ bottom: 12 })
          
          Swiper() {
            ForEach(this.createFoodGroups(this.recommendation.recommendedFoods, 2), (foodGroup: FoodItem[]) => {
              Row({ space: 12 }) {
                ForEach(foodGroup, (food: FoodItem) => {
                  this.FoodCard(food, true)
                })
              }
              .width('100%')
            })
          }
          .indicator(true)
          .loop(false)
          .itemSpace(0)
          .index(0)
          .height(180)
        }
        .margin({ bottom: 16 })
      }
      
      // 限制食物
      if (this.recommendation.restrictedFoods.length > 0) {
        Column() {
          Text('建议限制食物')
            .fontSize(18)
            .fontWeight(500)
            .margin({ bottom: 12 })
          
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.recommendation.restrictedFoods, (food: FoodItem) => {
              this.RestrictedFoodTag(food)
            })
          }
        }
      }
    }
  }
  
  // 创建食物分组 - 用于Swiper按行显示
  private createFoodGroups(foods: FoodItem[], itemsPerGroup: number): FoodItem[][] {
    const groups: FoodItem[][] = [];
    for (let i = 0; i < foods.length; i += itemsPerGroup) {
      groups.push(foods.slice(i, i + itemsPerGroup));
    }
    return groups;
  }
  
  @Builder
  FoodCard(food: FoodItem, isRecommended: boolean) {
    Column() {
      Row() {
        Image(food.imageUrl || $r('app.media.food'))
          .width(60)
          .height(60)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
        
        Column({ space: 4 }) {
          Text(food.name)
            .fontSize(16)
            .fontWeight(500)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(food.nutrients.slice(0, 2).join('、'))
            .fontSize(12)
            .opacity(0.6)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          Text(food.benefits.slice(0, 2).join('、'))
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
      .height(80)
      .padding(10)
    }
    .width('48%')
    .borderRadius(12)
    .backgroundColor(isRecommended ? '#F0F9F4' : '#FFF5F5')
    .border({ width: 1, color: isRecommended ? '#C9E7D8' : '#FFD8D8' })
  }
  
  @Builder
  RestrictedFoodTag(food: FoodItem) {
    Text(food.name)
      .fontSize(14)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .margin({ right: 8, bottom: 8 })
      .borderRadius(16)
      .backgroundColor('#FFF0F0')
      .border({ width: 1, color: '#FFD8D8' })
  }
} 