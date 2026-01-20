// 导入疾病数据模块
import { getDiseaseByName } from '../medicalhistorypage/DiseaseData';

// 餐饮类型定义
export interface FoodItem {
  id: string;
  name: string;
  category: string; // 食物分类：主食、蛋白质、蔬菜、水果、零食、饮料等
  nutrients: string[]; // 主要营养素
  benefits: string[]; // 健康益处
  imageUrl?: string; // 食物图片URL
  isRecommended?: boolean; // 是否推荐食用
  cautionForDiseases?: string[]; // 对哪些疾病需要谨慎食用
  goodForDiseases?: string[]; // 对哪些疾病有益
  description: string; // 食物描述
}

// 食物分类
export const FOOD_CATEGORIES = [
  '主食', '蛋白质食物', '蔬菜', '水果', '坚果', '饮品', '零食', '调味品'
];

// 食物数据库
export const foodDatabase: FoodItem[] = [
  {
    id: '1001',
    name: '燕麦',
    category: '全谷物',
    nutrients: ['β-葡聚糖', '膳食纤维', '蛋白质', '锰', '磷'],
    benefits: ['降低胆固醇', '稳定血糖', '促进饱腹感'],
    imageUrl: '../../../images/foods/oatmeal.png',
    goodForDiseases: ['糖尿病', '高脂血症', '冠心病', '便秘'],
    description: '燕麦富含β-葡聚糖，有助于降低胆固醇和稳定血糖，适合心血管疾病和糖尿病患者。'
  },
  {
    id: '1002',
    name: '糙米',
    category: '全谷物',
    nutrients: ['复合碳水化合物', '膳食纤维', 'B族维生素', '矿物质'],
    benefits: ['稳定血糖', '促进肠道健康', '提供持久能量'],
    imageUrl: '../../../images/foods/brown_rice.png',
    goodForDiseases: ['糖尿病', '高血压', '高脂血症', '肥胖'],
    description: '糙米保留了胚芽和麸皮，营养价值高，血糖指数低于白米，适合糖尿病患者适量食用。'
  },
  {
    id: '1003',
    name: '藜麦',
    category: '全谷物',
    nutrients: ['完全蛋白质', '膳食纤维', '镁', '铁', '锌'],
    benefits: ['提供全面营养', '无麸质', '低血糖指数'],
    imageUrl: '../../../images/foods/quinoa.png',
    goodForDiseases: ['糖尿病', '乳糜泻', '素食者营养不良'],
    description: '藜麦含有所有必需氨基酸，是优质植物蛋白来源，富含镁、锌等矿物质，血糖指数低。'
  },
  {
    id: '1004',
    name: '全麦面包',
    category: '全谷物',
    nutrients: ['复合碳水化合物', '膳食纤维', '蛋白质', 'B族维生素'],
    benefits: ['提供持久能量', '促进消化健康'],
    imageUrl: '../../../images/foods/whole_wheat_bread.png',
    cautionForDiseases: ['乳糜泻', '小麦过敏'],
    description: '全麦面包保留了小麦的所有营养成分，膳食纤维含量高，有助于控制血糖和胆固醇。'
  },
  {
    id: '1005',
    name: '燕麦麸',
    category: '全谷物',
    nutrients: ['极高的可溶性纤维', '降低胆固醇', '稳定血糖'],
    benefits: ['极高的可溶性纤维', '降低胆固醇', '稳定血糖'],
    imageUrl: '../../../images/foods/oatmeal2.png',
    goodForDiseases: ['糖尿病', '高脂血症', '冠心病', '便秘'],
    description: '燕麦麸是燕麦的外层，含有最高浓度的可溶性纤维，特别有效降低胆固醇和稳定血糖。'
  },

  // 蛋白质食物
  {
    id: '2001',
    name: '三文鱼',
    category: '蛋白质食物',
    nutrients: ['欧米茄-3脂肪酸', '优质蛋白质', '维生素D', '硒'],
    benefits: ['抗炎', '心脏健康', '脑健康'],
    imageUrl: '../../../images/foods/salmon.png',
    goodForDiseases: ['心血管疾病', '关节炎', '高脂血症', '抑郁症'],
    description: '三文鱼富含EPA和DHA，有助于降低炎症和血压，富含维生素D，对骨骼健康至关重要。'
  },
  {
    id: '2002',
    name: '沙丁鱼',
    category: '蛋白质食物',
    nutrients: ['钙质', 'omega-3脂肪酸', '维生素D'],
    benefits: ['富含钙质', 'omega-3脂肪酸', '维生素D'],
    imageUrl: '../../../images/foods/salmon2.png',
    goodForDiseases: ['骨质疏松', '心血管疾病', '高血压'],
    description: '带骨沙丁鱼是极佳的钙源和omega-3脂肪酸来源，特别适合骨质疏松和心血管疾病患者。'
  },
  {
    id: '2003',
    name: '豆腐',
    category: '蛋白质食物',
    nutrients: ['植物蛋白质', '钙', '铁', '镁', '异黄酮'],
    benefits: ['心脏健康', '骨骼健康', '激素平衡'],
    imageUrl: '../../../images/foods/tofu.png',
    goodForDiseases: ['骨质疏松', '绝经期症状', '高胆固醇'],
    description: '豆腐是优质植物蛋白和钙的良好来源，低热量低饱和脂肪，适合多种慢性病患者。'
  },
  {
    id: '2004',
    name: '鸡胸肉',
    category: '蛋白质食物',
    nutrients: ['瘦蛋白质', '低脂肪', '维生素B群'],
    benefits: ['瘦蛋白质', '低脂肪', '维生素B群'],
    imageUrl: '../../../images/foods/chicken_breast.png',
    goodForDiseases: ['肥胖', '肌肉萎缩', '贫血'],
    description: '去皮鸡胸肉是优质瘦蛋白质来源，低脂肪，富含维生素B群，适合需要控制脂肪摄入的患者。'
  },
  {
    id: '2005',
    name: '鸡蛋',
    category: '蛋白质食物',
    nutrients: ['完全蛋白质', '胆碱', '硒', '维生素D', '叶黄素', '玉米黄质'],
    benefits: ['大脑健康', '眼睛健康', '肌肉修复'],
    imageUrl: '../../../images/foods/eggs.png',
    cautionForDiseases: ['高胆固醇血症'],
    goodForDiseases: ['肌肉萎缩', '近视', '记忆力减退'],
    description: '鸡蛋提供高质量蛋白质和多种营养素，蛋黄含有维生素D和胆碱，适量食用有益健康。'
  },
  {
    id: '2006',
    name: '希腊酸奶',
    category: '蛋白质食物',
    nutrients: ['高蛋白', '钙质', '益生菌'],
    benefits: ['高蛋白', '钙质', '益生菌'],
    imageUrl: '../../../images/foods/greek_yogurt.png',
    goodForDiseases: ['骨质疏松', '心血管疾病', '高血压'],
    description: '希腊酸奶蛋白质含量高，脂肪含量低，富含钙质和益生菌，有助于骨骼健康和肠道健康。'
  },
  {
    id: '2007',
    name: '扁豆',
    category: '蛋白质食物',
    nutrients: ['植物蛋白质', '膳食纤维', '铁', '锌', '叶酸'],
    benefits: ['稳定血糖', '肠道健康', '心脏健康'],
    imageUrl: '../../../images/foods/lentils.png',
    goodForDiseases: ['糖尿病', '贫血', '高胆固醇'],
    description: '扁豆富含植物蛋白和膳食纤维，血糖指数低，富含铁、锌、镁等矿物质，适合糖尿病患者。'
  },
  {
    id: '2008',
    name: '鹰嘴豆',
    category: '蛋白质食物',
    nutrients: ['植物蛋白质', '膳食纤维', '矿物质'],
    benefits: ['植物蛋白质', '膳食纤维', '矿物质'],
    imageUrl: '../../../images/foods/lentils2.png',
    goodForDiseases: ['糖尿病', '贫血', '高胆固醇'],
    description: '鹰嘴豆富含植物蛋白和膳食纤维，有助于控制血糖和胆固醇，富含钾、镁等矿物质。'
  },

  // 蔬菜
  {
    id: '3001',
    name: '牛油果',
    category: '健康脂肪',
    nutrients: ['单不饱和脂肪', '膳食纤维', '钾'],
    benefits: ['单不饱和脂肪', '膳食纤维', '钾'],
    imageUrl: '../../../images/foods/avocado.png',
    goodForDiseases: ['高血压', '高胆固醇', '代谢综合征'],
    description: '牛油果富含单不饱和脂肪酸和膳食纤维，有助于降低胆固醇，富含钾质，有助于控制血压。'
  },
  {
    id: '3002',
    name: '橄榄油',
    category: '健康脂肪',
    nutrients: ['单不饱和脂肪', '抗氧化物', '抗炎特性'],
    benefits: ['单不饱和脂肪', '抗氧化物', '抗炎特性'],
    imageUrl: '../../../images/foods/olive_oil.png',
    goodForDiseases: ['高血压', '高胆固醇', '心血管疾病'],
    description: '特级初榨橄榄油富含单不饱和脂肪酸和抗氧化物，有助于降低炎症和改善心血管健康。'
  },
  {
    id: '3003',
    name: '亚麻籽',
    category: '健康脂肪',
    nutrients: ['植物性omega-3', '膳食纤维', '木酚素'],
    benefits: ['植物性omega-3', '膳食纤维', '木酚素'],
    imageUrl: '../../../images/foods/flaxseeds.png',
    goodForDiseases: ['心血管疾病', '高胆固醇', '代谢综合征'],
    description: '亚麻籽是植物性omega-3脂肪酸ALA的最佳来源之一，富含可溶性纤维和木酚素，有助于心血管健康。'
  },
  {
    id: '3004',
    name: '核桃',
    category: '健康脂肪',
    nutrients: ['植物性omega-3', '抗氧化物', '蛋白质'],
    benefits: ['植物性omega-3', '抗氧化物', '蛋白质'],
    imageUrl: '../../../images/foods/walnuts.png',
    goodForDiseases: ['心血管疾病', '认知功能障碍', '高胆固醇'],
    description: '核桃含有植物性omega-3脂肪酸、抗氧化物和优质蛋白质，有助于心血管健康和认知功能。'
  },
  {
    id: '3005',
    name: '杏仁',
    category: '健康脂肪',
    nutrients: ['单不饱和脂肪', '维生素E', '镁'],
    benefits: ['单不饱和脂肪', '维生素E', '镁'],
    imageUrl: '../../../images/foods/almonds.png',
    cautionForDiseases: ['坚果过敏'],
    goodForDiseases: ['心血管疾病', '糖尿病', '高胆固醇'],
    description: '杏仁富含单不饱和脂肪酸、维生素E和镁，有助于控制胆固醇和血糖，适合心血管疾病和糖尿病患者。'
  },

  // 水果
  {
    id: '4001',
    name: '菠菜',
    category: '蔬菜',
    nutrients: ['铁', '钙', '维生素K', '维生素A', '叶酸', '抗氧化剂'],
    benefits: ['抗炎', '抗氧化', '骨骼健康', '眼睛健康'],
    imageUrl: '../../../images/foods/spinach.png',
    cautionForDiseases: ['肾结石', '血液稀释药物使用者'],
    goodForDiseases: ['贫血', '骨质疏松', '年龄相关性黄斑变性'],
    description: '菠菜富含叶酸、钙、铁和抗氧化物，有助于骨骼健康和心血管健康，钾含量高有助于控制血压。'
  },
  {
    id: '4002',
    name: '西兰花',
    category: '蔬菜',
    nutrients: ['维生素C', '维生素K', '叶酸', '纤维', '硫化物'],
    benefits: ['解毒', '抗癌', '抗炎', '心脏健康'],
    imageUrl: '../../../images/foods/broccoli.png',
    goodForDiseases: ['高血压', '高胆固醇', '结肠癌高风险'],
    description: '西兰花富含抗氧化物和多种维生素矿物质，具有抗炎特性，有助于心血管健康和骨骼健康。'
  },
  {
    id: '4003',
    name: '羽衣甘蓝',
    category: '蔬菜',
    nutrients: ['钙', '维生素K', '抗氧化物'],
    benefits: ['钙', '维生素K', '抗氧化物'],
    imageUrl: '../../../images/foods/kale.png',
    goodForDiseases: ['骨质疏松', '心血管疾病', '高血压'],
    description: '羽衣甘蓝是植物性钙和维生素K的极佳来源，富含抗氧化物，特别有益于骨骼健康和心血管健康。'
  },
  {
    id: '4004',
    name: '甜椒',
    category: '蔬菜',
    nutrients: ['维生素C', '维生素A', '维生素B6', '叶酸', '抗氧化剂'],
    benefits: ['免疫健康', '视力健康', '抗炎', '皮肤健康'],
    imageUrl: '../../../images/foods/bell_peppers.png',
    goodForDiseases: ['免疫系统疾病', '眼睛健康问题', '皮肤病'],
    description: '甜椒是维生素C的极佳来源，富含抗氧化物和膳食纤维，热量低，适合多种慢性病患者。'
  },
  {
    id: '4005',
    name: '番茄',
    category: '蔬菜',
    nutrients: ['番茄红素', '钾', '维生素C'],
    benefits: ['番茄红素', '钾', '维生素C'],
    imageUrl: '../../../images/foods/tomatoes.png',
    goodForDiseases: ['心血管疾病', '高血压', '前列腺疾病'],
    description: '番茄富含番茄红素和抗氧化物，有助于心血管健康，钾含量高有助于控制血压。'
  },
  {
    id: '4006',
    name: '胡萝卜',
    category: '蔬菜',
    nutrients: ['β-胡萝卜素', '维生素A', '纤维', '钾'],
    benefits: ['视力健康', '免疫功能', '皮肤健康'],
    imageUrl: '../../../images/foods/carrots.png',
    goodForDiseases: ['夜盲症', '皮肤问题', '呼吸道感染'],
    description: '胡萝卜富含β-胡萝卜素和抗氧化物，有助于眼睛健康和免疫功能，膳食纤维有助于控制血糖。'
  },
  {
    id: '4007',
    name: '芦笋',
    category: '蔬菜',
    nutrients: ['叶酸', '维生素K', '抗氧化物'],
    benefits: ['叶酸', '维生素K', '抗氧化物'],
    imageUrl: '../../../images/foods/asparagus.png',
    goodForDiseases: ['高血压', '高胆固醇', '心血管疾病'],
    description: '芦笋富含叶酸、维生素K和抗氧化物，有助于心血管健康和骨骼健康，利尿特性有助于控制血压。'
  },

  // 坚果
  {
    id: '5001',
    name: '蓝莓',
    category: '水果',
    nutrients: ['花青素', '维生素C', '维生素K', '锰', '纤维'],
    benefits: ['抗氧化', '改善脑功能', '心脏健康'],
    imageUrl: '../../../images/foods/blueberries.png',
    goodForDiseases: ['高血压', '认知功能障碍', '眼部疾病', '细胞氧化损伤'],
    description: '蓝莓富含花青素和抗氧化物，有助于心血管健康和认知功能，血糖指数低，适合糖尿病患者。'
  },
  {
    id: '5002',
    name: '苹果',
    category: '水果',
    nutrients: ['纤维', '维生素C', '抗氧化物', '钾'],
    benefits: ['肠道健康', '心脏健康', '控制血糖'],
    imageUrl: '../../../images/foods/apple.png',
    goodForDiseases: ['便秘', '高胆固醇', '2型糖尿病'],
    description: '苹果富含果胶等可溶性纤维，有助于控制胆固醇和血糖，抗氧化物有助于心血管健康。'
  },
  {
    id: '5003',
    name: '柑橘类水果',
    category: '水果',
    nutrients: ['维生素C', '黄酮类', '膳食纤维'],
    benefits: ['维生素C', '黄酮类', '膳食纤维'],
    imageUrl: '../../../images/foods/orange.png',
    goodForDiseases: ['免疫缺陷', '皮肤问题', '坏血病'],
    description: '柑橘类水果富含维生素C和黄酮类抗氧化物，有助于免疫功能和心血管健康，膳食纤维有助于控制血糖。'
  },
  {
    id: '5004',
    name: '草莓',
    category: '水果',
    nutrients: ['维生素C', '抗氧化物', '低血糖指数'],
    benefits: ['维生素C', '抗氧化物', '低血糖指数'],
    imageUrl: '../../../images/foods/strawberries.png',
    goodForDiseases: ['高血压', '肌肉痉挛', '消化问题'],
    cautionForDiseases: ['2型糖尿病'],
    description: '草莓富含维生素C和抗氧化物，血糖指数低，热量低，适合糖尿病患者和需要控制体重的人。'
  },
  {
    id: '5005',
    name: '梨',
    category: '水果',
    nutrients: ['膳食纤维', '抗氧化物', '低血糖指数'],
    benefits: ['膳食纤维', '抗氧化物', '低血糖指数'],
    imageUrl: '../../../images/foods/pear.png',
    goodForDiseases: ['便秘', '高胆固醇', '2型糖尿病'],
    description: '梨富含膳食纤维和抗氧化物，血糖指数低，有助于消化健康和血糖控制。'
  },

  // 坚果
  {
    id: '6001',
    name: '绿茶',
    category: '饮品',
    nutrients: ['儿茶素', '抗氧化剂', '茶氨酸', '氟'],
    benefits: ['代谢提升', '大脑功能', '抗癌', '口腔健康'],
    imageUrl: '../../../images/foods/green_tea.png',
    goodForDiseases: ['肥胖', '认知功能障碍', '心血管疾病'],
    cautionForDiseases: ['铁缺乏性贫血', '焦虑症'],
    description: '绿茶富含儿茶素等抗氧化物，有助于心血管健康和代谢健康，适合多种慢性病患者。'
  },
  {
    id: '6002',
    name: '姜茶',
    category: '饮品',
    nutrients: ['姜辣素', '抗炎特性', '消化健康'],
    benefits: ['姜辣素', '抗炎特性', '消化健康'],
    imageUrl: '../../../images/foods/ginger_tea.png',
    goodForDiseases: ['关节炎', '消化系统疾病', '心血管疾病'],
    description: '姜茶具有抗炎特性，有助于消化健康和关节健康，温和的血液循环促进作用有益于心血管健康。'
  },
  {
    id: '6003',
    name: '强化豆浆',
    category: '饮品',
    nutrients: ['植物蛋白', '钙质', '低饱和脂肪'],
    benefits: ['植物蛋白', '钙质', '低饱和脂肪'],
    imageUrl: '../../../images/foods/soy_milk.png',
    goodForDiseases: ['骨质疏松', '心血管疾病', '高血压'],
    description: '钙强化豆浆是优质植物蛋白和钙的良好来源，低饱和脂肪，适合骨质疏松和心血管疾病患者。'
  },
  {
    id: '6004',
    name: '低脂牛奶',
    category: '饮品',
    nutrients: ['钙质', '蛋白质', '维生素D'],
    benefits: ['钙质', '蛋白质', '维生素D'],
    imageUrl: '../../../images/foods/low_fat_milk.png',
    goodForDiseases: ['骨质疏松', '心血管疾病', '高血压'],
    description: '低脂牛奶是钙、蛋白质和维生素D的极佳来源，对骨骼健康至关重要，适合骨质疏松患者。'
  },

  // 调味品
  {
    id: '7001',
    name: '姜黄',
    category: '调味品',
    nutrients: ['姜黄素', '抗氧化剂'],
    benefits: ['抗炎', '排毒', '大脑健康', '关节健康'],
    imageUrl: '../../../images/foods/turmeric.png',
    goodForDiseases: ['关节炎', '阿尔茨海默病', '炎症性疾病'],
    cautionForDiseases: ['血液稀释药物使用者', '胆结石'],
    description: '姜黄含有姜黄素，具有强大的抗炎和抗氧化特性，有助于关节健康和心血管健康。'
  },
  {
    id: '7002',
    name: '肉桂',
    category: '调味品',
    nutrients: ['多酚', '抗氧化剂', '锰'],
    benefits: ['血糖调节', '抗菌', '抗炎'],
    imageUrl: '../../../images/foods/cinnamon.png',
    goodForDiseases: ['2型糖尿病', '高胆固醇', '念珠菌感染'],
    cautionForDiseases: ['肝脏问题', '库马林药物使用者'],
    description: '肉桂有助于改善胰岛素敏感性和血糖控制，具有抗氧化和抗炎特性，适合糖尿病患者。'
  },
  {
    id: '7003',
    name: '大蒜',
    category: '调味品',
    nutrients: ['大蒜素', '心血管健康', '免疫功能'],
    benefits: ['大蒜素', '心血管健康', '免疫功能'],
    imageUrl: '../../../images/foods/garlic.png',
    cautionForDiseases: ['血液稀释药物使用者'],
    goodForDiseases: ['高血压', '高胆固醇', '感冒/流感'],
    description: '大蒜含有大蒜素，有助于降低血压和胆固醇，增强免疫功能，适合心血管疾病患者。'
  },
  {
    id: '7004',
    name: '生姜',
    category: '调味品',
    nutrients: ['姜辣素', '抗炎特性', '消化健康'],
    benefits: ['姜辣素', '抗炎特性', '消化健康'],
    imageUrl: '../../../images/foods/ginger.png',
    cautionForDiseases: ['血液稀释药物使用者'],
    goodForDiseases: ['关节炎', '消化系统疾病', '心血管疾病'],
    description: '生姜具有抗炎特性，有助于消化健康和关节健康，适合关节炎和消化系统疾病患者。'
  },
  {
    id: '8001',
    name: '黑巧克力',
    category: '其他',
    nutrients: ['黄烷醇', '抗氧化物', '心血管健康'],
    benefits: ['黄烷醇', '抗氧化物', '心血管健康'],
    imageUrl: '../../../images/foods/dark_chocolate.png',
    goodForDiseases: ['心血管疾病', '高胆固醇', '代谢综合征'],
    description: '70%以上可可含量的黑巧克力富含黄烷醇和抗氧化物，适量食用有助于心血管健康。'
  },
  {
    id: '8002',
    name: '红酒',
    category: '其他',
    nutrients: ['白藜芦醇', '抗氧化物', '心血管健康'],
    benefits: ['白藜芦醇', '抗氧化物', '心血管健康'],
    imageUrl: '../../../images/foods/red_wine.png',
    goodForDiseases: ['心血管疾病', '高胆固醇', '代谢综合征'],
    description: '红酒含有白藜芦醇和抗氧化物，极少量饮用可能有助于心血管健康，但应遵医嘱。'
  }
];

// 根据疾病分类的餐饮推荐
export interface DiseaseSpecificDiet {
  diseaseCategory: string; // 疾病分类
  recommendedFoods: string[]; // 推荐食物ID列表
  restrictedFoods: string[]; // 限制食物ID列表
  dietPrinciples: string[]; // 饮食原则
}

// 根据疾病分类的饮食推荐
export const diseaseDietRecommendations: DiseaseSpecificDiet[] = [
  {
    diseaseCategory: '心血管疾病',
    recommendedFoods: ['1001', '1002', '1005', '2001', '2003', '3002', '3005', '4001', '4003', '4005', '5001', '5002',
      '6001'],
    restrictedFoods: [], // 这里可以添加不推荐的食物ID
    dietPrinciples: [
      '低盐饮食，每日钠摄入控制在2000mg以下',
      '增加不饱和脂肪酸摄入，减少饱和脂肪和反式脂肪',
      '富含钾、镁、钙的食物有助于控制血压',
      '增加膳食纤维摄入，有助于降低胆固醇',
      '控制总热量摄入，维持健康体重'
    ]
  },
  {
    diseaseCategory: '代谢性疾病',
    recommendedFoods: ['1001', '1002', '1003', '1005', '2003', '2005', '3002', '3003', '4002', '4003', '5002', '7002'],
    restrictedFoods: ['4005'], // 香蕉对糖尿病患者需要谨慎
    dietPrinciples: [
      '选择低血糖指数的碳水化合物，避免精制糖和淀粉',
      '增加膳食纤维摄入，改善血糖控制',
      '控制总热量摄入，维持健康体重',
      '少量多餐，保持血糖稳定',
      '增加蛋白质摄入，提高饱腹感'
    ]
  },
  {
    diseaseCategory: '骨骼疾病',
    recommendedFoods: ['2003', '2004', '3001', '5002', '4003'],
    restrictedFoods: [],
    dietPrinciples: [
      '富含钙的食物是骨骼健康的基础',
      '维生素D有助于钙的吸收，可从阳光和食物中获取',
      '维生素K对骨骼形成至关重要',
      '适量蛋白质有助于骨骼健康',
      '控制钠和咖啡因摄入，减少钙流失'
    ]
  },
  {
    diseaseCategory: '呼吸系统疾病',
    recommendedFoods: ['2001', '3002', '3003', '3005', '4002', '4004', '6001'],
    restrictedFoods: [],
    dietPrinciples: [
      '抗炎和抗氧化食物有助于减轻气道炎症',
      '维生素C和E可以保护肺组织免受氧化应激',
      '欧米茄-3脂肪酸具有抗炎特性',
      '保持健康体重减轻呼吸系统负担',
      '充足的水分有助于稀释呼吸道分泌物'
    ]
  },
  {
    diseaseCategory: '消化系统疾病',
    recommendedFoods: ['1002', '1005', '2005', '3003', '4002', '6002'],
    restrictedFoods: ['3002', '3005'], // 可能引起胃部不适
    dietPrinciples: [
      '增加可溶性膳食纤维摄入，改善肠道健康',
      '选择易消化的食物，减轻胃肠负担',
      '少量多餐，避免过度饱胀',
      '避免辛辣、高脂肪食物，减少刺激',
      '充足水分保持消化系统顺畅'
    ]
  },
  {
    diseaseCategory: '神经系统疾病',
    recommendedFoods: ['2001', '2004', '4001', '5001', '6001', '7001'],
    restrictedFoods: [],
    dietPrinciples: [
      '欧米茄-3脂肪酸对神经健康至关重要',
      '抗氧化物质有助于减缓神经退行性变',
      '增加B族维生素摄入，支持神经功能',
      '保持适当水分摄入，维持神经传导',
      '避免酒精和高糖食物，减少神经毒性'
    ]
  },
  {
    diseaseCategory: '皮肤疾病',
    recommendedFoods: ['2001', '3003', '3004', '4003', '4004', '5002'],
    restrictedFoods: [],
    dietPrinciples: [
      '维生素A、C和E对皮肤健康至关重要',
      '欧米茄-3脂肪酸有助于减轻皮肤炎症',
      '锌和硒支持皮肤修复和再生',
      '充足水分是健康皮肤的基础',
      '抗氧化物质有助于减少皮肤氧化损伤'
    ]
  },
  {
    diseaseCategory: '精神疾病',
    recommendedFoods: ['2001', '2004', '4001', '5001', '6001'],
    restrictedFoods: [],
    dietPrinciples: [
      '欧米茄-3脂肪酸与改善情绪相关',
      'B族维生素支持神经递质合成',
      '保持血糖稳定有助于情绪稳定',
      '抗氧化物质减轻大脑氧化应激',
      '镁等矿物质有助于神经放松和睡眠'
    ]
  },
  {
    diseaseCategory: '眼科疾病',
    recommendedFoods: ['2004', '3001', '3003', '4001', '4004'],
    restrictedFoods: [],
    dietPrinciples: [
      '叶黄素和玉米黄质对视网膜健康至关重要',
      '维生素A维持正常视力不可或缺',
      '抗氧化物质保护眼部组织免受氧化损伤',
      '欧米茄-3脂肪酸有助于预防干眼症',
      '控制血糖有助于预防糖尿病视网膜病变'
    ]
  },
  {
    diseaseCategory: '泌尿系统疾病',
    recommendedFoods: ['4002', '6002'],
    restrictedFoods: ['3001'], // 菠菜中的草酸可能增加肾结石风险
    dietPrinciples: [
      '充足水分摄入是泌尿系统健康的基础',
      '蔓越莓等食物有助于预防尿路感染',
      '根据结石类型调整饮食，如低草酸或低嘌呤',
      '控制钠摄入，减少钙流失',
      '维生素C适量摄入，过量可能增加肾结石风险'
    ]
  }
];

// 根据疾病名称获取饮食建议
export function getDietRecommendationForDisease(diseaseName: string): {
  recommended: FoodItem[],
  restricted: FoodItem[],
  principles: string[]
} | undefined {
  // 获取疾病信息
  const disease = getDiseaseByName(diseaseName);
  if (!disease) {
    return undefined;
  }

  // 根据疾病分类找到对应的饮食建议
  const dietRecommendation = diseaseDietRecommendations.find(
    diet => diet.diseaseCategory === disease.category
  );

  if (!dietRecommendation) {
    return undefined;
  }

  // 获取推荐食物
  const recommendedFoods = foodDatabase.filter(
    food => dietRecommendation.recommendedFoods.includes(food.id)
  );

  // 获取限制食物
  const restrictedFoods = foodDatabase.filter(
    food => dietRecommendation.restrictedFoods.includes(food.id)
  );

  return {
    recommended: recommendedFoods,
    restricted: restrictedFoods,
    principles: dietRecommendation.dietPrinciples
  };
}

// 根据多种疾病获取综合饮食建议
export function getComprehensiveDietRecommendation(diseaseNames: string[]): {
  recommended: FoodItem[],
  restricted: FoodItem[],
  principles: string[]
} {
  let allRecommendedFoodIds = new Set<string>();
  let allRestrictedFoodIds = new Set<string>();
  let allPrinciples = new Set<string>();

  // 收集所有疾病的饮食建议
  diseaseNames.forEach(diseaseName => {
    const recommendation = getDietRecommendationForDisease(diseaseName);
    if (recommendation) {
      recommendation.recommended.forEach(food => allRecommendedFoodIds.add(food.id));
      recommendation.restricted.forEach(food => allRestrictedFoodIds.add(food.id));
      recommendation.principles.forEach(principle => allPrinciples.add(principle));
    }
  });

  // 移除同时在推荐和限制列表中的食物
  const finalRecommendedIds = [...allRecommendedFoodIds].filter(id => !allRestrictedFoodIds.has(id));

  // 获取推荐食物列表
  const recommendedFoods = foodDatabase.filter(food => finalRecommendedIds.includes(food.id));

  // 获取限制食物列表
  const restrictedFoods = foodDatabase.filter(food => allRestrictedFoodIds.has(food.id));

  return {
    recommended: recommendedFoods,
    restricted: restrictedFoods,
    principles: [...allPrinciples]
  };
}

// 食物图标接口
export interface FoodIcon {
  name: string;
  icon: string;
}

// 食物图标数据
export const FOOD_ICONS: FoodIcon[] = [
  { name: '燕麦', icon: '../../../images/foods/oatmeal.png' },
  { name: '糙米', icon: '../../../images/foods/brown_rice.png' },
  { name: '藜麦', icon: '../../../images/foods/quinoa.png' },
  { name: '全麦面包', icon: '../../../images/foods/whole_wheat_bread.png' },
  { name: '燕麦麸', icon: '../../../images/foods/oatmeal2.png' },
  { name: '三文鱼', icon: '../../../images/foods/salmon.png' },
  { name: '沙丁鱼', icon: '../../../images/foods/salmon2.png' },
  { name: '豆腐', icon: '../../../images/foods/tofu.png' },
  { name: '鸡胸肉', icon: '../../../images/foods/chicken_breast.png' },
  { name: '鸡蛋', icon: '../../../images/foods/eggs.png' },
  { name: '希腊酸奶', icon: '../../../images/foods/greek_yogurt.png' },
  { name: '扁豆', icon: '../../../images/foods/lentils.png' },
  { name: '鹰嘴豆', icon: '../../../images/foods/lentils2.png' },
  { name: '牛油果', icon: '../../../images/foods/avocado.png' },
  { name: '橄榄油', icon: '../../../images/foods/olive_oil.png' },
  { name: '亚麻籽', icon: '../../../images/foods/flaxseeds.png' },
  { name: '核桃', icon: '../../../images/foods/walnuts.png' },
  { name: '杏仁', icon: '../../../images/foods/almonds.png' },
]; 