import { FoodItem, getComprehensiveDietRecommendation, getDietRecommendationForDisease as getFoodDietRecommendation } from '../pages/childpages/dietpage/FoodData';
import {
  DiseaseTemplate,
  getAllDiseaseNames,
  getDiseaseByName
} from '../pages/childpages/medicalhistorypage/DiseaseData';
import { 
  DiseaseDietSuggestion, 
  getDietSuggestionForDisease, 
  getComprehensiveDietSuggestion 
} from '../pages/childpages/dietpage/DiseaseDietData';

// 定义推荐结果类型
interface DietRecommendationResult {
  recommended: FoodItem[];
  restricted: FoodItem[];
  principles: string[];
}

// 定义模块类型接口
interface FoodDataModule {
  getDietRecommendationForDisease: (diseaseName: string) => DietRecommendationResult | undefined;
}

// 餐饮建议类型
export interface DietRecommendation {
  recommendedFoods: FoodItem[];
  restrictedFoods: FoodItem[];
  dietPrinciples: string[];
  diseaseBased: string[]; // 基于哪些疾病做出的推荐
}

// 餐饮推荐服务
export class DietRecommendationService {
  // 用户的疾病列表，可以从用户配置文件或医疗记录中获取
  private userDiseases: string[] = [];
  
  // 用户疾病的严重程度
  private diseaseSeverities: Record<string, string> = {};

  // 设置用户疾病
  setUserDiseases(diseases: string[]): void {
    this.userDiseases = diseases;
  }

  // 设置疾病严重程度
  setDiseaseSeverities(severities: Record<string, string>): void {
    // 创建新对象
    this.diseaseSeverities = {};
    
    // 使用Object.keys()代替for...in循环
    const keys = Object.keys(severities);
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      this.diseaseSeverities[key] = severities[key];
    }
    
    console.info('DietRecommendationService: 设置疾病严重程度:', JSON.stringify(this.diseaseSeverities));
  }

  // 获取用户疾病
  getUserDiseases(): string[] {
    return this.userDiseases;
  }

  // 获取疾病严重程度
  getDiseaseSeverity(diseaseName: string): string {
    // 使用Object.keys().indexOf()代替in操作符
    if (this.diseaseSeverities && Object.keys(this.diseaseSeverities).indexOf(diseaseName) >= 0) {
      return this.diseaseSeverities[diseaseName];
    }
    return '轻度'; // 默认为轻度
  }

  // 添加用户疾病
  addUserDisease(disease: string): void {
    if (!this.userDiseases.includes(disease)) {
      this.userDiseases.push(disease);
    }
  }

  // 移除用户疾病
  removeUserDisease(disease: string): void {
    this.userDiseases = this.userDiseases.filter((d: string) => d !== disease);
  }

  // 获取个性化饮食推荐
  getPersonalizedDietRecommendation(): DietRecommendation {
    // 如果没有疾病记录，返回空推荐
    if (this.userDiseases.length === 0) {
      return {
        recommendedFoods: [],
        restrictedFoods: [],
        dietPrinciples: ['请在病史管理中添加您的健康状况，以获取个性化饮食建议'],
        diseaseBased: []
      };
    }

    // 使用食物数据模块中的函数获取综合饮食建议
    const recommendation: DietRecommendationResult = getComprehensiveDietRecommendation(this.userDiseases);

    return {
      recommendedFoods: recommendation.recommended,
      restrictedFoods: recommendation.restricted,
      dietPrinciples: recommendation.principles,
      diseaseBased: this.userDiseases
    };
  }

  // 获取单个疾病的饮食推荐
  getDietRecommendationForSingleDisease(diseaseName: string): DietRecommendation | undefined {
    // 直接使用导入的函数
    const recommendation = getFoodDietRecommendation(diseaseName);
    if (!recommendation) {
      return undefined;
    }
    
    return {
      recommendedFoods: recommendation.recommended,
      restrictedFoods: recommendation.restricted,
      dietPrinciples: recommendation.principles,
      diseaseBased: [diseaseName]
    };
  }

  // 获取疾病的饮食推荐
  getDietRecommendationForDisease(): string {
    try {
      // 获取疾病对象列表
      const diseaseObjects: DiseaseTemplate[] = [];
      for (let i = 0; i < this.userDiseases.length; i++) {
        const disease = getDiseaseByName(this.userDiseases[i]);
        if (disease) {
          diseaseObjects.push(disease);
        }
      }
      
      // 使用疾病对象列表生成AI推荐
      return this.simulateAIRecommendation(diseaseObjects);
    } catch (error) {
      console.error('Error generating diet recommendation:', error);
      return "生成饮食推荐时出错，请稍后再试。";
    }
  }

  // 获取疾病的详细饮食建议
  getDetailedDietSuggestion(): DiseaseDietSuggestion | undefined {
    if (this.userDiseases.length === 0) {
      return undefined;
    }
    
    // 使用新的疾病饮食数据获取综合建议
    return getComprehensiveDietSuggestion(this.userDiseases);
  }

  // 模拟AI生成的饮食建议
  simulateAIRecommendation(diseases: DiseaseTemplate[]): string {
    // 如果没有疾病数据，返回通用建议
    if (!diseases || diseases.length === 0) {
      return "为了给您提供个性化的饮食建议，我需要了解您的健康状况。请在\"健康记录\"中添加您的健康信息，以便我能为您制定更适合的饮食计划。\n\n目前，我建议您遵循均衡饮食原则：每天摄入充足的蔬菜水果、优质蛋白质和全谷类食物，控制盐分和糖分摄入，保持充分水分，规律进餐。";
    }

    // 生成AI风格的介绍
    let introduction = this._generateAIIntroduction(diseases);
    
    // 生成核心饮食原则
    let corePrinciples = "【核心饮食原则】\n";
    
    // 根据疾病类别添加特定的核心原则
    const diseaseCategories = new Set<string>();
    const diseaseNames = new Set<string>();
    
    // 获取疾病信息和严重程度
    for (const disease of diseases) {
      diseaseCategories.add(disease.category);
      diseaseNames.add(disease.name);
    }
    
    // 基础原则
    corePrinciples += "• 规律进餐，每日三餐定时定量\n";
    
    // 根据疾病类别和严重程度添加特定原则
    if (diseaseCategories.has('心血管疾病')) {
      corePrinciples += "• 严格控制钠盐摄入，每日不超过5克\n";
      
      if (diseaseNames.has('高血压')) {
        const severity = this.getDiseaseSeverity('高血压');
        
        if (severity === '中度' || severity === '重度') {
          corePrinciples += "• 每日监测血压，记录波动情况\n";
          corePrinciples += "• 完全避免高钠食品，如加工肉类、罐头食品\n";
        }
        
        corePrinciples += "• 选择健康脂肪，增加不饱和脂肪酸摄入\n";
      }
    }
    
    if (diseaseCategories.has('代谢性疾病')) {
      if (diseaseNames.has('糖尿病')) {
        const severity = this.getDiseaseSeverity('糖尿病');
        
        corePrinciples += "• 控制碳水化合物摄入，选择低血糖指数食物\n";
        
        if (severity === '中度' || severity === '重度') {
          corePrinciples += "• 严格监测血糖水平，遵循医生制定的饮食计划\n";
          corePrinciples += "• 精确计算每餐碳水化合物摄入量\n";
        } else {
          corePrinciples += "• 适量控制碳水化合物摄入，避免精制糖\n";
        }
      }
      
      corePrinciples += "• 均衡饮食，控制总热量摄入\n";
    }
    
    if (diseaseCategories.has('骨骼疾病')) {
      if (diseaseNames.has('骨质疏松')) {
        const severity = this.getDiseaseSeverity('骨质疏松');
        
        corePrinciples += "• 确保充足的钙和维生素D摄入\n";
        
        if (severity === '中度' || severity === '重度') {
          corePrinciples += "• 每日补充1000-1200mg钙和800-1000IU维生素D\n";
          corePrinciples += "• 减少咖啡因摄入，避免过量饮酒\n";
        } else {
          corePrinciples += "• 增加富含钙的食物摄入，如奶制品、豆腐、小鱼干\n";
        }
      }
    }
    
    if (diseaseCategories.has('消化系统疾病')) {
      corePrinciples += "• 少量多餐，避免过度进食\n";
      corePrinciples += "• 细嚼慢咽，减轻消化系统负担\n";
    }
    
    // 通用原则
    corePrinciples += "• 增加膳食纤维摄入，每天摄入25-30克\n";
    corePrinciples += "• 限制添加糖摄入，每日不超过25克\n";
    corePrinciples += "• 保持充足水分，每日 饮水1500-2000ml\n";
    
    // 生成推荐食物列表
    let recommendedFoods = "【推荐食物】\n";
    
    if (diseaseNames.has('高血压')) {
      const severity = this.getDiseaseSeverity('高血压');
      
      recommendedFoods += "• 低钠食物：新鲜蔬菜、水果、无盐坚果\n";
      recommendedFoods += "• 富含钾的食物：香蕉、土豆、菠菜、牛油果\n";
      
      if (severity === '中度' || severity === '重度') {
        recommendedFoods += "• 严格遵循DASH饮食：全谷物、低脂乳制品、瘦肉、大量蔬果\n";
      } else {
        recommendedFoods += "• DASH饮食推荐：全谷物、低脂乳制品、瘦肉\n";
      }
    }
    
    if (diseaseNames.has('糖尿病')) {
      const severity = this.getDiseaseSeverity('糖尿病');
      
      if (severity === '中度' || severity === '重度') {
        recommendedFoods += "• 严格控制碳水化合物：非淀粉类蔬菜为主，精确计量全谷物摄入\n";
        recommendedFoods += "• 高纤维食物：豆类、燕麦、糙米（注意控制份量）\n";
      } else {
        recommendedFoods += "• 低血糖指数食物：燕麦、糙米、豆类、大部分非淀粉类蔬菜\n";
        recommendedFoods += "• 健康脂肪来源：橄榄油、坚果、鱼类\n";
      }
      
      recommendedFoods += "• 优质蛋白质：豆腐、鸡胸肉、鱼类、蛋类\n";
    }
    
    if (diseaseNames.has('骨质疏松')) {
      const severity = this.getDiseaseSeverity('骨质疏松');
      
      if (severity === '中度' || severity === '重度') {
        recommendedFoods += "• 高钙食物（每日必选）：低脂奶制品、强化豆浆、小鱼干、豆腐\n";
        recommendedFoods += "• 富含维生素D的食物：鱼肝油、脂肪鱼类、蛋黄、强化食品\n";
      } else {
        recommendedFoods += "• 富含钙的食物：低脂奶制品、豆腐、小鱼干、绿叶蔬菜\n";
        recommendedFoods += "• 富含维生素D的食物：蛋黄、脂肪鱼类、强化食品\n";
      }
      
      recommendedFoods += "• 富含镁的食物：坚果、种子、全谷物\n";
    }
    
    // 如果没有特定疾病匹配，提供通用推荐
    if (recommendedFoods === "【推荐食物】\n") {
      recommendedFoods += "• 新鲜蔬菜和水果：每天至少5份，多样化选择\n";
      recommendedFoods += "• 全谷物：糙米、燕麦、全麦面包、藜麦\n";
      recommendedFoods += "• 健康蛋白质：鱼类、豆类、坚果、种子、瘦肉\n";
      recommendedFoods += "• 健康脂肪：橄榄油、牛油果、坚果、种子\n";
    }
    
    // 生成限制食物列表
    let restrictedFoods = "【限制食物】\n";
    
    if (diseaseNames.has('高血压')) {
      const severity = this.getDiseaseSeverity('高血压');
      
      if (severity === '中度' || severity === '重度') {
        restrictedFoods += "• 严禁高钠食物：加工肉类、罐头食品、咸味零食、快餐\n";
        restrictedFoods += "• 完全避免：腌制食品、咸菜、泡菜、腌肉\n";
        restrictedFoods += "• 限制调味品：酱油、味精、腌制调味料（建议使用替代品）\n";
      } else {
        restrictedFoods += "• 高钠食物：加工肉类、罐头食品、咸味零食、快餐\n";
        restrictedFoods += "• 腌制食品：咸菜、泡菜、腌肉\n";
        restrictedFoods += "• 调味品：酱油、味精、腌制调味料（适量使用）\n";
      }
    }
    
    if (diseaseNames.has('糖尿病')) {
      const severity = this.getDiseaseSeverity('糖尿病');
      
      if (severity === '中度' || severity === '重度') {
        restrictedFoods += "• 严禁精制碳水化合物：白面包、白米饭、糕点、甜点\n";
        restrictedFoods += "• 禁止添加糖：糖果、含糖饮料、甜点、蜂蜜、糖浆\n";
        restrictedFoods += "• 限制高糖水果：葡萄干、芒果、香蕉、菠萝（完全避免或严格控制份量）\n";
      } else {
        restrictedFoods += "• 精制碳水化合物：白面包、白米饭、糕点\n";
        restrictedFoods += "• 添加糖：糖果、甜点、含糖饮料\n";
        restrictedFoods += "• 高糖水果：葡萄干、芒果、香蕉（适量食用）\n";
      }
    }
    
    if (diseaseNames.has('骨质疏松')) {
      const severity = this.getDiseaseSeverity('骨质疏松');
      
      if (severity === '中度' || severity === '重度') {
        restrictedFoods += "• 严禁过量咖啡因：咖啡、浓茶、能量饮料\n";
        restrictedFoods += "• 避免酒精：所有酒精饮料\n";
        restrictedFoods += "• 限制高盐食品：加工食品、腌制食品、方便面\n";
        restrictedFoods += "• 减少碳酸饮料：可乐、汽水等\n";
      } else {
        restrictedFoods += "• 过量咖啡因：咖啡、浓茶（适量饮用）\n";
        restrictedFoods += "• 酒精：限制饮酒量\n";
        restrictedFoods += "• 高盐食品：减少摄入\n";
      }
    }
    
    // 如果没有特定疾病匹配，提供通用限制
    if (restrictedFoods === "【限制食物】\n") {
      restrictedFoods += "• 高糖食品：糖果、甜点、含糖饮料\n";
      restrictedFoods += "• 高盐食品：加工食品、腌制食品、咸味零食\n";
      restrictedFoods += "• 不健康脂肪：油炸食品、反式脂肪、过多饱和脂肪\n";
      restrictedFoods += "• 过度加工食品：方便面、即食食品、加工肉类\n";
    }
    
    // 生成饮食计划示例
    let mealPlan = "【一日饮食计划示例】\n";
    
    // 根据疾病组合生成不同的饮食计划
    if (diseaseNames.has('高血压') && diseaseNames.has('糖尿病')) {
      const hbpSeverity = this.getDiseaseSeverity('高血压');
      const dmSeverity = this.getDiseaseSeverity('糖尿病');
      
      let strictLevel = (hbpSeverity === '重度' || dmSeverity === '重度') ? '严格' : 
                        (hbpSeverity === '中度' || dmSeverity === '中度') ? '中度' : '一般';
      
      if (strictLevel === '严格') {
        mealPlan += "早餐：无糖无盐燕麦粥配少量蓝莓；煮蛋白；无糖绿茶\n";
        mealPlan += "上午加餐：一个小苹果\n";
        mealPlan += "午餐：无盐烤鸡胸肉配1/4碗糙米和蒸西兰花；混合绿叶沙拉配橄榄油和柠檬汁（不加盐）\n";
        mealPlan += "下午加餐：低脂无糖酸奶（不加任何甜味剂）\n";
        mealPlan += "晚餐：清蒸鱼（用香草替代盐）配蒸胡萝卜和芦笋；1/5碗藜麦；一小碗新鲜浆果\n";
      } else if (strictLevel === '中度') {
        mealPlan += "早餐：无糖燕麦粥配少量蓝莓和杏仁；煮鸡蛋白；无糖绿茶\n";
        mealPlan += "上午加餐：一个小苹果\n";
        mealPlan += "午餐：烤鸡胸肉（少盐调味）配1/3碗糙米和蒸西兰花；混合绿叶沙拉配橄榄油和柠檬汁\n";
        mealPlan += "下午加餐：低脂无糖酸奶配少量核桃\n";
        mealPlan += "晚餐：清蒸鱼（少盐）配蒸胡萝卜和芦笋；1/4碗藜麦；一小碗新鲜水果沙拉\n";
      } else {
        mealPlan += "早餐：无糖燕麦粥配少量蓝莓和杏仁；煮鸡蛋；无糖绿茶\n";
        mealPlan += "上午加餐：一个小苹果\n";
        mealPlan += "午餐：烤鸡胸肉（少盐调味）配1/3碗糙米和蒸西兰花；混合绿叶沙拉配橄榄油和柠檬汁\n";
        mealPlan += "下午加餐：低脂无糖酸奶配少量核桃\n";
        mealPlan += "晚餐：清蒸鱼（少盐）配蒸胡萝卜和芦笋；1/3碗藜麦；一小碗新鲜水果沙拉\n";
      }
    } else if (diseaseNames.has('高血压') && diseaseNames.has('骨质疏松')) {
      const hbpSeverity = this.getDiseaseSeverity('高血压');
      const osteoSeverity = this.getDiseaseSeverity('骨质疏松');
      
      let strictLevel = (hbpSeverity === '重度' || osteoSeverity === '重度') ? '严格' : 
                        (hbpSeverity === '中度' || osteoSeverity === '中度') ? '中度' : '一般';
      
      if (strictLevel === '严格' || strictLevel === '中度') {
        mealPlan += "早餐：低脂高钙牛奶燕麦粥配少量坚果；一片全麦吐司（不加盐）；无糖绿茶\n";
        mealPlan += "上午加餐：低脂奶酪配一个小橙子\n";
        mealPlan += "午餐：低盐三文鱼配蒸西兰花和1/3碗糙米；混合绿叶沙拉配橄榄油和柠檬汁\n";
        mealPlan += "下午加餐：低脂酸奶配少量坚果和维生素D强化食品\n";
        mealPlan += "晚餐：豆腐炒菠菜（少盐或无盐）；1/3碗糙米；一杯低脂牛奶\n";
      } else {
        mealPlan += "早餐：低脂牛奶燕麦粥配少量坚果；一片全麦吐司；无糖绿茶\n";
        mealPlan += "上午加餐：低脂奶酪配一个小橙子\n";
        mealPlan += "午餐：低盐三文鱼配蒸西兰花和1/3碗糙米；混合绿叶沙拉配橄榄油和柠檬汁\n";
        mealPlan += "下午加餐：低脂酸奶配少量坚果\n";
        mealPlan += "晚餐：豆腐炒菠菜（少盐）；1/3碗糙米；一小碗新鲜水果\n";
      }
    } else if (diseaseNames.has('糖尿病') && diseaseNames.has('骨质疏松')) {
      const dmSeverity = this.getDiseaseSeverity('糖尿病');
      const osteoSeverity = this.getDiseaseSeverity('骨质疏松');
      
      let strictLevel = (dmSeverity === '重度' || osteoSeverity === '重度') ? '严格' : 
                        (dmSeverity === '中度' || osteoSeverity === '中度') ? '中度' : '一般';
      
      if (strictLevel === '严格') {
        mealPlan += "早餐：低脂高钙无糖酸奶配少量蓝莓和亚麻籽；煮鸡蛋；无糖绿茶\n";
        mealPlan += "上午加餐：一小把杏仁\n";
        mealPlan += "午餐：烤三文鱼配1/5碗藜麦和蒸西兰花；混合绿叶沙拉配橄榄油\n";
        mealPlan += "下午加餐：低脂奶酪（无添加糖）\n";
        mealPlan += "晚餐：豆腐炖菜配各种非淀粉类蔬菜；1/5碗糙米；一小块黑巧克力（85%以上可可含量）\n";
      } else {
        mealPlan += "早餐：低脂高钙酸奶配少量蓝莓和亚麻籽；煮鸡蛋；无糖绿茶\n";
        mealPlan += "上午加餐：一小把杏仁\n";
        mealPlan += "午餐：烤三文鱼配1/4碗藜麦和蒸西兰花；混合绿叶沙拉配橄榄油\n";
        mealPlan += "下午加餐：低脂奶酪配少量全麦饼干\n";
        mealPlan += "晚餐：豆腐炖菜配各种蔬菜；1/4碗糙米；一小块黑巧克力（70%以上可可含量）\n";
      }
    } else if (diseaseNames.has('高血压')) {
      const severity = this.getDiseaseSeverity('高血压');
      
      if (severity === '中度' || severity === '重度') {
        mealPlan += "早餐：无盐燕麦粥配香蕉和少量杏仁；煮蛋白；无糖绿茶\n";
        mealPlan += "上午加餐：一个苹果\n";
        mealPlan += "午餐：无盐烤鸡胸肉配糙米和蒸西兰花；混合绿叶沙拉配橄榄油和柠檬汁（不加盐）\n";
        mealPlan += "下午加餐：低脂无盐酸奶\n";
        mealPlan += "晚餐：清蒸鱼（使用香草替代盐）配蒸蔬菜和少量糙米；一小碗新鲜水果沙拉\n";
      } else {
        mealPlan += "早餐：全麦面包配低脂奶酪、鸡蛋白和新鲜蔬菜；一小杯蓝莓；无糖绿茶\n";
        mealPlan += "上午加餐：一个苹果和少量无盐坚果\n";
        mealPlan += "午餐：烤鲑鱼配藜麦和蒸西兰花；混合绿叶沙拉配橄榄油和柠檬汁\n";
        mealPlan += "下午加餐：低脂希腊酸奶配少量坚果和浆果\n";
        mealPlan += "晚餐：烤鸡胸肉配糙米和炒混合蔬菜；一小碗新鲜水果沙拉\n";
      }
    } else if (diseaseNames.has('糖尿病')) {
      const severity = this.getDiseaseSeverity('糖尿病');
      
      if (severity === '中度' || severity === '重度') {
        mealPlan += "早餐：小份无糖燕麦粥配少量蓝莓；煮鸡蛋；无糖绿茶\n";
        mealPlan += "上午加餐：一小把杏仁\n";
        mealPlan += "午餐：烤鸡胸肉配1/4碗糙米和大份炒非淀粉类蔬菜；一小份混合绿叶沙拉\n";
        mealPlan += "下午加餐：低脂无糖酸奶\n";
        mealPlan += "晚餐：烤鱼配大份炒菠菜和1/4碗藜麦；一小块黑巧克力（85%以上可可含量）\n";
      } else {
        mealPlan += "早餐：燕麦粥配少量坚果、肉桂和少量浆果；煮鸡蛋；无糖绿茶\n";
        mealPlan += "上午加餐：一小把杏仁和一个小橙子\n";
        mealPlan += "午餐：烤鸡胸肉沙拉配混合绿叶、鹰嘴豆、橄榄油和醋\n";
        mealPlan += "下午加餐：低脂奶酪配少量全麦饼干\n";
        mealPlan += "晚餐：清蒸鱼配扁豆和炒非淀粉类蔬菜；一小块黑巧克力（70%以上可可含量）\n";
      }
    } else if (diseaseNames.has('骨质疏松')) {
      const severity = this.getDiseaseSeverity('骨质疏松');
      
      if (severity === '中度' || severity === '重度') {
        mealPlan += "早餐：高钙强化豆浆配全麦面包；煮鸡蛋；一小把坚果；维生素D强化橙汁\n";
        mealPlan += "上午加餐：一杯低脂酸奶配少量亚麻籽\n";
        mealPlan += "午餐：沙丁鱼（带骨）配全麦面包和混合沙拉；一个橙子\n";
        mealPlan += "下午加餐：一小杯低脂奶酪和一个苹果\n";
        mealPlan += "晚餐：豆腐炒菠菜配糙米；一杯低脂牛奶\n";
      } else {
        mealPlan += "早餐：高钙强化豆浆配全麦面包；煮鸡蛋；一小把坚果\n";
        mealPlan += "上午加餐：一杯低脂酸奶配少量坚果\n";
        mealPlan += "午餐：沙丁鱼（带骨）配全麦面包和混合沙拉；一个橙子\n";
        mealPlan += "下午加餐：一小杯低脂奶酪和一个苹果\n";
        mealPlan += "晚餐：豆腐炒菠菜配糙米；一杯低脂牛奶\n";
      }
    } else {
      // 通用饮食计划
      mealPlan += "早餐：全麦面包配鸡蛋和牛油果；一小杯浆果；绿茶\n";
      mealPlan += "上午加餐：一个苹果和少量坚果\n";
      mealPlan += "午餐：烤鸡胸肉配糙米和蒸蔬菜；混合绿叶沙拉配橄榄油\n";
      mealPlan += "下午加餐：低脂酸奶配少量蜂蜜和浆果\n";
      mealPlan += "晚餐：烤鱼配藜麦和炒混合蔬菜；一小碗新鲜水果沙拉\n";
    }
    
    // 组合所有部分
    return introduction + "\n\n" + corePrinciples + "\n" + recommendedFoods + "\n" + restrictedFoods + "\n" + mealPlan;
  }
  
  // 生成AI风格的介绍
  private _generateAIIntroduction(diseases: DiseaseTemplate[]): string {
    // 收集疾病名称
    const diseaseNames = diseases.map(d => d.name).join('、');
    
    // 介绍语句模板
    const introTemplates = [
      `根据您的健康记录，我发现您患有${diseaseNames}。我已为您制定了一份个性化的饮食方案，旨在帮助您管理这些健康状况并改善整体健康。`,
      `基于您的${diseaseNames}病史，我为您定制了以下饮食建议。这些建议旨在帮助您通过饮食管理来改善健康状况。`,
      `考虑到您的${diseaseNames}，我设计了这份个性化饮食计划。遵循这些建议可以帮助您更好地管理健康状况。`,
      `针对您的${diseaseNames}，我提供以下饮食指导。这些建议基于最新的营养科学研究，旨在通过饮食调整来辅助您的健康管理。`
    ];
    
    // 随机选择一个介绍模板
    const randomIntro = introTemplates[Math.floor(Math.random() * introTemplates.length)];
    
    // 添加个性化提示
    let personalizedTips = "";
    
    if (diseases.some(d => d.name === '高血压')) {
      personalizedTips += "对于高血压患者，控制钠盐摄入和保持健康体重尤为重要。";
    }
    
    if (diseases.some(d => d.name === '糖尿病')) {
      if (personalizedTips) personalizedTips += " ";
      personalizedTips += "对于糖尿病患者，控制碳水化合物的质量和数量是饮食管理的关键。";
    }
    
    if (diseases.some(d => d.name === '骨质疏松')) {
      if (personalizedTips) personalizedTips += " ";
      personalizedTips += "对于骨质疏松患者，确保充足的钙和维生素D摄入对骨骼健康至关重要。";
    }
    
    // 组合介绍和个性化提示
    return randomIntro + (personalizedTips ? " " + personalizedTips : "");
  }
}

export default new DietRecommendationService(); 