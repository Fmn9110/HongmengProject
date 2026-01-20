// 疾病饮食关联数据文件
import { DiseaseTemplate, getAllDiseaseNames, getDiseaseByName } from '../medicalhistorypage/DiseaseData';

// 定义疾病饮食建议接口
export interface DiseaseDietSuggestion {
  diseaseName: string;
  category: string;
  dietPrinciples: string[];
  recommendedFoods: string[];
  restrictedFoods: string[];
  mealPlanSample: string;
}

// 疾病饮食建议数据库
export const diseaseDietSuggestions: DiseaseDietSuggestion[] = [
  // 心血管疾病
  {
    diseaseName: '高血压',
    category: '心血管疾病',
    dietPrinciples: [
      '严格控制钠盐摄入，每日不超过5克',
      '增加钾、钙、镁的摄入',
      '保持健康体重',
      '限制酒精摄入',
      '采用DASH饮食模式'
    ],
    recommendedFoods: [
      '新鲜蔬菜和水果',
      '低脂乳制品',
      '全谷物',
      '瘦肉、鱼类和家禽',
      '坚果和豆类',
      '橄榄油等健康油脂'
    ],
    restrictedFoods: [
      '腌制食品',
      '加工肉类',
      '罐头食品',
      '方便面和速食产品',
      '咸味零食',
      '酱油、味精等高钠调味品'
    ],
    mealPlanSample: '早餐：全麦面包配低脂奶酪、鸡蛋白和新鲜蔬菜；一小杯蓝莓；无糖绿茶\n上午加餐：一个苹果和少量无盐坚果\n午餐：烤鲑鱼配藜麦和蒸西兰花；混合绿叶沙拉配橄榄油和柠檬汁\n下午加餐：低脂希腊酸奶配少量坚果和浆果\n晚餐：烤鸡胸肉配糙米和炒混合蔬菜；一小碗新鲜水果沙拉'
  },
  {
    diseaseName: '冠心病',
    category: '心血管疾病',
    dietPrinciples: [
      '控制总热量摄入，维持健康体重',
      '限制饱和脂肪和反式脂肪摄入',
      '增加不饱和脂肪酸摄入',
      '增加膳食纤维摄入',
      '限制钠盐摄入'
    ],
    recommendedFoods: [
      '富含omega-3脂肪酸的鱼类（如三文鱼、沙丁鱼）',
      '橄榄油、亚麻籽油等植物油',
      '坚果和种子',
      '全谷物',
      '新鲜蔬菜和水果',
      '豆类'
    ],
    restrictedFoods: [
      '高饱和脂肪食物（如肥肉、全脂乳制品）',
      '反式脂肪（如人造黄油、油炸食品）',
      '高钠食品',
      '精制碳水化合物',
      '添加糖'
    ],
    mealPlanSample: '早餐：燕麦粥配蓝莓、香蕉和少量杏仁；无糖绿茶\n上午加餐：一个橙子和少量核桃\n午餐：地中海沙拉配烤鸡胸肉、橄榄油和藜麦；一片全麦面包\n下午加餐：低脂酸奶配少量浆果\n晚餐：烤三文鱼配蒸芦笋和糙米；一小碗新鲜水果'
  },
  {
    diseaseName: '心律失常',
    category: '心血管疾病',
    dietPrinciples: [
      '保持电解质平衡，特别是钾、钙和镁',
      '避免刺激性物质',
      '规律进餐，避免过度饥饿或饱食',
      '控制钠盐摄入',
      '维持健康体重'
    ],
    recommendedFoods: [
      '富含钾的食物（如香蕉、土豆、菠菜）',
      '富含镁的食物（如全谷物、坚果、绿叶蔬菜）',
      '富含钙的食物（如低脂乳制品、豆腐）',
      '橄榄油等健康脂肪',
      '新鲜蔬果'
    ],
    restrictedFoods: [
      '咖啡因（如咖啡、茶、可乐）',
      '酒精',
      '高糖食品',
      '高钠食品',
      '过度加工食品'
    ],
    mealPlanSample: '早餐：全麦吐司配低脂奶酪和煮鸡蛋；一根香蕉；淡茶\n上午加餐：一把杏仁和一个苹果\n午餐：烤鸡胸肉配糙米和炒菠菜；一小杯低脂酸奶\n下午加餐：一个橙子和少量无盐坚果\n晚餐：烤鱼配蒸土豆和混合蔬菜；一小碗新鲜水果'
  },

  // 代谢性疾病
  {
    diseaseName: '糖尿病',
    category: '代谢性疾病',
    dietPrinciples: [
      '控制碳水化合物摄入总量和质量',
      '选择低血糖指数食物',
      '规律进餐，避免长时间空腹',
      '控制总热量摄入',
      '增加膳食纤维摄入'
    ],
    recommendedFoods: [
      '非淀粉类蔬菜',
      '全谷物（如燕麦、糙米、藜麦）',
      '豆类',
      '坚果和种子',
      '健康脂肪（如橄榄油、牛油果）',
      '瘦肉和鱼类'
    ],
    restrictedFoods: [
      '精制碳水化合物（如白面包、白米饭、糕点）',
      '添加糖（如糖果、甜点、含糖饮料）',
      '高糖水果（如葡萄干、芒果）',
      '油炸食品',
      '高脂肪乳制品'
    ],
    mealPlanSample: '早餐：燕麦粥配少量坚果、肉桂和少量浆果；煮鸡蛋；无糖绿茶\n上午加餐：一小把杏仁和一个小橙子\n午餐：烤鸡胸肉沙拉配混合绿叶、鹰嘴豆、橄榄油和醋\n下午加餐：低脂奶酪配少量全麦饼干\n晚餐：清蒸鱼配扁豆和炒非淀粉类蔬菜；一小块黑巧克力（70%以上可可含量）'
  },
  {
    diseaseName: '高脂血症',
    category: '代谢性疾病',
    dietPrinciples: [
      '限制饱和脂肪和反式脂肪摄入',
      '增加不饱和脂肪酸摄入',
      '增加可溶性纤维摄入',
      '控制总热量摄入',
      '限制胆固醇摄入'
    ],
    recommendedFoods: [
      '富含可溶性纤维的食物（如燕麦、苹果、豆类）',
      '富含omega-3脂肪酸的食物（如三文鱼、亚麻籽）',
      '橄榄油和菜籽油',
      '坚果和种子',
      '全谷物',
      '新鲜蔬果'
    ],
    restrictedFoods: [
      '富含饱和脂肪的食物（如全脂乳制品、肥肉、椰子油）',
      '富含反式脂肪的食物（如油炸食品、人造黄油）',
      '高胆固醇食物（如内脏、蛋黄）',
      '精制碳水化合物',
      '添加糖'
    ],
    mealPlanSample: '早餐：燕麦粥配少量浆果和亚麻籽；一杯低脂牛奶\n上午加餐：一个苹果和少量杏仁\n午餐：烤鸡胸肉（去皮）配藜麦和蒸西兰花；混合绿叶沙拉配橄榄油\n下午加餐：低脂酸奶配少量浆果\n晚餐：烤三文鱼配烤甜薯和炒菠菜；一小碗新鲜水果'
  },

  // 骨骼疾病
  {
    diseaseName: '骨质疏松',
    category: '骨骼疾病',
    dietPrinciples: [
      '确保充足的钙摄入',
      '维生素D对钙吸收至关重要',
      '适量蛋白质有助于骨骼健康',
      '控制钠和咖啡因摄入',
      '适量运动增强骨密度'
    ],
    recommendedFoods: [
      '低脂乳制品',
      '强化豆浆和豆腐',
      '小鱼干（带骨）',
      '绿叶蔬菜（如羽衣甘蓝、菠菜）',
      '富含维生素D的食物（如蛋黄、脂肪鱼类）',
      '坚果和种子'
    ],
    restrictedFoods: [
      '高咖啡因饮料',
      '碳酸饮料',
      '过量酒精',
      '高盐食品',
      '过量红肉'
    ],
    mealPlanSample: '早餐：高钙强化豆浆配全麦面包；煮鸡蛋；一小把坚果；维生素D强化橙汁\n上午加餐：一杯低脂酸奶配少量亚麻籽\n午餐：沙丁鱼（带骨）配全麦面包和混合沙拉；一个橙子\n下午加餐：一小杯低脂奶酪和一个苹果\n晚餐：豆腐炒菠菜配糙米；一杯低脂牛奶'
  },
  {
    diseaseName: '关节炎',
    category: '骨骼疾病',
    dietPrinciples: [
      '增加抗炎食物摄入',
      '控制体重，减轻关节负担',
      '确保充足的omega-3脂肪酸摄入',
      '增加抗氧化物质摄入',
      '避免可能引起炎症的食物'
    ],
    recommendedFoods: [
      '富含omega-3脂肪酸的鱼类（如三文鱼、沙丁鱼）',
      '橄榄油',
      '坚果和种子',
      '新鲜水果和蔬菜（尤其是浆果和绿叶蔬菜）',
      '姜黄、生姜等抗炎香料',
      '全谷物'
    ],
    restrictedFoods: [
      '加工肉类',
      '精制碳水化合物',
      '油炸食品',
      '添加糖',
      '对部分人可能引起炎症的食物（如茄科植物、乳制品）'
    ],
    mealPlanSample: '早餐：姜黄燕麦粥配蓝莓和核桃；无糖绿茶\n上午加餐：一个苹果和少量杏仁\n午餐：烤三文鱼配藜麦和炒混合蔬菜；一小杯浆果\n下午加餐：低脂希腊酸奶配少量蜂蜜和亚麻籽\n晚餐：地中海风味炖菜（橄榄油、豆类、蔬菜）配糙米；一小碗新鲜水果'
  },

  // 呼吸系统疾病
  {
    diseaseName: '哮喘',
    category: '呼吸系统疾病',
    dietPrinciples: [
      '增加抗氧化物质摄入',
      '增加omega-3脂肪酸摄入',
      '维持健康体重',
      '避免食物过敏原',
      '保持充分水分'
    ],
    recommendedFoods: [
      '富含维生素C和E的水果蔬菜',
      '富含omega-3脂肪酸的鱼类和坚果',
      '姜黄、生姜等抗炎食物',
      '大蒜、洋葱等含硫食物',
      '绿茶'
    ],
    restrictedFoods: [
      '可能含有硫酸盐的食物（如干果、葡萄酒）',
      '人工添加剂和防腐剂',
      '已知的个人食物过敏原',
      '过度加工食品',
      '酒精'
    ],
    mealPlanSample: '早餐：全麦吐司配牛油果和煮鸡蛋；一杯蓝莓；绿茶\n上午加餐：一个橙子和少量核桃\n午餐：姜黄烤鸡胸肉配糙米和炒西兰花；混合水果沙拉\n下午加餐：低脂酸奶配少量蜂蜜和亚麻籽\n晚餐：烤三文鱼配蒸红薯和炒菠菜；一小碗新鲜水果'
  },
  {
    diseaseName: '慢性阻塞性肺疾病',
    category: '呼吸系统疾病',
    dietPrinciples: [
      '确保充足的蛋白质摄入',
      '控制碳水化合物摄入',
      '选择易于咀嚼和吞咽的食物',
      '增加抗氧化物质摄入',
      '保持充分水分'
    ],
    recommendedFoods: [
      '优质蛋白质（如鸡肉、鱼类、豆类、蛋类）',
      '富含抗氧化物质的水果蔬菜',
      '健康脂肪（如橄榄油、牛油果）',
      '全谷物',
      '强化食品'
    ],
    restrictedFoods: [
      '气胀食物（如豆类、洋葱、卷心菜）',
      '油炸和高脂食品',
      '过度加工食品',
      '咖啡因',
      '酒精'
    ],
    mealPlanSample: '早餐：蛋白质奶昔（蛋白粉、香蕉、低脂牛奶、蓝莓）\n上午加餐：一小杯酸奶和软水果\n午餐：炖鸡肉配软煮蔬菜和少量糙米；一杯果汁\n下午加餐：鹰嘴豆泥配软面包条\n晚餐：烤鱼配蒸红薯和炒菠菜；一小碗果冻'
  },

  // 消化系统疾病
  {
    diseaseName: '胃食管反流病',
    category: '消化系统疾病',
    dietPrinciples: [
      '少量多餐，避免过度进食',
      '避免在睡前3小时进食',
      '避免刺激性食物',
      '减少高脂肪食物摄入',
      '保持健康体重'
    ],
    recommendedFoods: [
      '低脂蛋白质（如鸡肉、鱼类、豆腐）',
      '非酸性水果（如香蕉、苹果、梨）',
      '蔬菜（避免番茄和洋葱）',
      '全谷物',
      '低脂乳制品'
    ],
    restrictedFoods: [
      '辛辣食物',
      '柑橘类和番茄等酸性食物',
      '咖啡、茶和碳酸饮料',
      '巧克力',
      '高脂食物',
      '酒精'
    ],
    mealPlanSample: '早餐：燕麦粥配香蕉和少量蜂蜜；淡茶\n上午加餐：一个苹果和少量杏仁\n午餐：烤鸡胸肉配糙米和蒸胡萝卜；一小杯低脂酸奶\n下午加餐：梨和少量低脂奶酪\n晚餐（至少在睡前3小时）：烤鱼配蒸土豆和西兰花；一小碗非酸性水果'
  },
  {
    diseaseName: '消化性溃疡',
    category: '消化系统疾病',
    dietPrinciples: [
      '规律进餐，避免长时间空腹',
      '避免刺激胃酸分泌的食物',
      '减少对胃黏膜的刺激',
      '选择易消化的食物',
      '避免进食过快'
    ],
    recommendedFoods: [
      '高纤维食物（如全谷物、蔬菜、水果）',
      '低脂蛋白质（如鸡肉、鱼类、豆腐）',
      '富含益生菌的食物（如酸奶）',
      '橄榄油',
      '非酸性水果'
    ],
    restrictedFoods: [
      '辛辣食物',
      '酸性食物',
      '咖啡和浓茶',
      '酒精',
      '巧克力',
      '碳酸饮料',
      '油炸和高脂食品'
    ],
    mealPlanSample: '早餐：燕麦粥配香蕉和少量蜂蜜；淡茶\n上午加餐：一个苹果和少量杏仁\n午餐：蒸鸡胸肉配糙米和炒胡萝卜；一小杯低脂酸奶\n下午加餐：全麦饼干配低脂奶酪\n晚餐：清蒸鱼配蒸土豆和西兰花；一小碗非酸性水果'
  },

  // 多疾病组合的饮食建议
  {
    diseaseName: '高血压和糖尿病',
    category: '多系统疾病',
    dietPrinciples: [
      '严格控制钠盐和碳水化合物摄入',
      '选择低血糖指数和低钠食物',
      '增加膳食纤维摄入',
      '规律进餐，控制总热量',
      '增加抗氧化物质摄入'
    ],
    recommendedFoods: [
      '非淀粉类蔬菜（如绿叶蔬菜、西兰花、芦笋）',
      '低血糖指数全谷物（如燕麦、藜麦）（限量）',
      '富含健康脂肪的食物（如橄榄油、牛油果）',
      '瘦肉和鱼类',
      '低脂乳制品',
      '低糖水果（如浆果、苹果）（适量）'
    ],
    restrictedFoods: [
      '高钠食品（如腌制食品、加工肉类、罐头食品）',
      '精制碳水化合物（如白面包、白米饭）',
      '添加糖（如糖果、甜点、含糖饮料）',
      '高糖水果（如葡萄干、芒果、香蕉）',
      '油炸食品和高脂食品'
    ],
    mealPlanSample: '早餐：无糖燕麦粥配少量蓝莓和杏仁；煮鸡蛋白；无糖绿茶\n上午加餐：一个小苹果\n午餐：烤鸡胸肉（少盐调味）配1/3碗糙米和蒸西兰花；混合绿叶沙拉配橄榄油和柠檬汁\n下午加餐：低脂无糖酸奶配少量核桃\n晚餐：清蒸鱼（少盐）配蒸胡萝卜和芦笋；1/4碗藜麦；一小碗新鲜水果沙拉'
  },
  {
    diseaseName: '高血压和骨质疏松',
    category: '多系统疾病',
    dietPrinciples: [
      '控制钠盐摄入，同时确保充足钙质',
      '增加钾、镁摄入，有助于骨骼健康和血压控制',
      '确保维生素D充足，促进钙吸收',
      '选择富含抗氧化物质的食物',
      '保持健康体重，减轻关节和心脏负担'
    ],
    recommendedFoods: [
      '低脂高钙乳制品',
      '富含钾的蔬果（如香蕉、菠菜、土豆）',
      '富含镁的食物（如全谷物、坚果、豆类）',
      '富含维生素D的食物（如脂肪鱼类、蛋黄）',
      '富含钙的非乳制品（如豆腐、小鱼干、强化豆浆）',
      '健康脂肪来源（如橄榄油、亚麻籽）'
    ],
    restrictedFoods: [
      '高钠食品（如腌制食品、加工肉类）',
      '高咖啡因饮料',
      '碳酸饮料（尤其是可乐类）',
      '过量酒精',
      '高盐调味品'
    ],
    mealPlanSample: '早餐：高钙低脂酸奶配无盐坚果和少量浆果；全麦吐司；维生素D强化橙汁\n上午加餐：一个香蕉和少量杏仁\n午餐：烤三文鱼配蒸西兰花和少量糙米；混合绿叶沙拉配橄榄油和柠檬汁\n下午加餐：一小杯低脂奶酪和一个苹果\n晚餐：豆腐炒菠菜（少盐）配糙米；一杯低脂牛奶'
  },
  {
    diseaseName: '糖尿病和骨质疏松',
    category: '多系统疾病',
    dietPrinciples: [
      '控制碳水化合物摄入，同时确保充足钙质',
      '选择低血糖指数和高钙食物',
      '确保维生素D充足，促进钙吸收',
      '增加膳食纤维摄入',
      '适量优质蛋白质，有助于骨骼健康和血糖控制'
    ],
    recommendedFoods: [
      '低脂高钙乳制品（无添加糖）',
      '富含钙的非乳制品（如豆腐、小鱼干、强化豆浆）',
      '低血糖指数全谷物（如燕麦、藜麦）（限量）',
      '富含维生素D的食物（如脂肪鱼类、蛋黄）',
      '非淀粉类蔬菜',
      '低糖水果（如浆果、苹果）（适量）'
    ],
    restrictedFoods: [
      '精制碳水化合物（如白面包、白米饭）',
      '添加糖（如糖果、甜点、含糖饮料）',
      '高糖水果（如葡萄干、芒果）',
      '高咖啡因饮料',
      '碳酸饮料',
      '过量酒精'
    ],
    mealPlanSample: '早餐：低脂高钙无糖酸奶配少量蓝莓和亚麻籽；煮鸡蛋；无糖绿茶\n上午加餐：一小把杏仁\n午餐：烤三文鱼配1/4碗藜麦和蒸西兰花；混合绿叶沙拉配橄榄油\n下午加餐：低脂奶酪配少量全麦饼干\n晚餐：豆腐炖菜配各种蔬菜；1/4碗糙米；一小块黑巧克力（70%以上可可含量）'
  },
  {
    diseaseName: '高血压、糖尿病和骨质疏松',
    category: '多系统疾病',
    dietPrinciples: [
      '严格控制钠盐和碳水化合物摄入，同时确保充足钙质',
      '选择低血糖指数、低钠和高钙食物',
      '确保维生素D充足，促进钙吸收',
      '增加膳食纤维和抗氧化物质摄入',
      '规律进餐，控制总热量'
    ],
    recommendedFoods: [
      '低脂高钙乳制品（无添加糖）',
      '富含钙的非乳制品（如豆腐、小鱼干、强化豆浆）',
      '非淀粉类蔬菜（如绿叶蔬菜、西兰花、芦笋）',
      '低血糖指数全谷物（如燕麦、藜麦）（严格限量）',
      '富含维生素D的食物（如脂肪鱼类、蛋黄）',
      '富含健康脂肪的食物（如橄榄油、少量坚果）',
      '低糖水果（如浆果、苹果）（严格限量）'
    ],
    restrictedFoods: [
      '高钠食品（如腌制食品、加工肉类、罐头食品）',
      '精制碳水化合物（如白面包、白米饭）',
      '添加糖（如糖果、甜点、含糖饮料）',
      '高糖水果（如葡萄干、芒果、香蕉）',
      '高咖啡因饮料',
      '碳酸饮料',
      '过量酒精',
      '油炸食品和高脂食品'
    ],
    mealPlanSample: '早餐：低脂高钙无糖酸奶配少量蓝莓和亚麻籽；煮蛋白；无糖绿茶\n上午加餐：一小把无盐杏仁\n午餐：烤三文鱼（少盐）配1/5碗藜麦和蒸西兰花；混合绿叶沙拉配橄榄油和柠檬汁\n下午加餐：低脂无糖酸奶\n晚餐：豆腐炖菜（少盐）配各种非淀粉类蔬菜；1/5碗糙米；一小块黑巧克力（85%以上可可含量）'
  }
];

// 根据疾病名称获取饮食建议
export function getDietSuggestionForDisease(diseaseName: string): DiseaseDietSuggestion | undefined {
  return diseaseDietSuggestions.find(suggestion => suggestion.diseaseName === diseaseName);
}

// 根据疾病类别获取饮食建议列表
export function getDietSuggestionsByCategory(category: string): DiseaseDietSuggestion[] {
  return diseaseDietSuggestions.filter(suggestion => suggestion.category === category);
}

// 获取所有疾病类别
export function getAllDietCategories(): string[] {
  const categories = new Set<string>();
  diseaseDietSuggestions.forEach(suggestion => {
    categories.add(suggestion.category);
  });
  return Array.from(categories);
}

// 获取综合饮食建议
export function getComprehensiveDietSuggestion(diseaseNames: string[]): DiseaseDietSuggestion | undefined {
  // 如果没有疾病，返回undefined
  if (!diseaseNames || diseaseNames.length === 0) {
    return undefined;
  }
  
  // 如果只有一个疾病，直接返回该疾病的饮食建议
  if (diseaseNames.length === 1) {
    return getDietSuggestionForDisease(diseaseNames[0]);
  }
  
  // 检查是否有多疾病组合的饮食建议
  // 首先，对疾病名称进行排序，以便匹配
  const sortedDiseaseNames = [...diseaseNames].sort();
  
  // 高血压、糖尿病和骨质疏松的组合
  if (sortedDiseaseNames.includes('高血压') && 
      sortedDiseaseNames.includes('糖尿病') && 
      sortedDiseaseNames.includes('骨质疏松')) {
    return getDietSuggestionForDisease('高血压、糖尿病和骨质疏松');
  }
  
  // 高血压和糖尿病的组合
  if (sortedDiseaseNames.includes('高血压') && sortedDiseaseNames.includes('糖尿病')) {
    return getDietSuggestionForDisease('高血压和糖尿病');
  }
  
  // 高血压和骨质疏松的组合
  if (sortedDiseaseNames.includes('高血压') && sortedDiseaseNames.includes('骨质疏松')) {
    return getDietSuggestionForDisease('高血压和骨质疏松');
  }
  
  // 糖尿病和骨质疏松的组合
  if (sortedDiseaseNames.includes('糖尿病') && sortedDiseaseNames.includes('骨质疏松')) {
    return getDietSuggestionForDisease('糖尿病和骨质疏松');
  }
  
  // 如果没有找到匹配的组合，返回第一个疾病的饮食建议
  return getDietSuggestionForDisease(diseaseNames[0]);
}
