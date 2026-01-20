// 定义运动推荐接口
export interface ExerciseRecommendation {
  exerciseName: string;
  description: string;
  benefits: string;
  duration: string;
  frequency: string;
  intensity: string;
  precautions: string;
  suitableDiseases: string[]; // 适合的疾病列表
  unsuitable: string[]; // 不适合的疾病列表
  imageUrl?: string; // 运动图片资源路径
}

// 运动计划接口
export interface ExercisePlan {
  planName: string;
  description: string;
  targetDiseases: string[];
  exercises: ExerciseRecommendation[];
  difficulty: 'easy' | 'moderate' | 'challenging';
  totalDuration: string;
  imageUrl?: string; // 图片资源路径
}

// 定义模拟运动数据
export const exerciseRecommendations: ExerciseRecommendation[] = [
  {
    exerciseName: '散步',
    description: '轻度有氧运动，适合大多数人，尤其是初学者或行动不便的人',
    benefits: '改善心肺功能，促进血液循环，降低血压和血糖，减轻压力',
    duration: '30-45分钟',
    frequency: '每日或每周4-5次',
    intensity: '低强度',
    precautions: '穿着舒适鞋子，注意路面状况，热身和冷却',
    suitableDiseases: ['高血压', '糖尿病', '心脏病', '关节炎', '肥胖', '抑郁症'],
    unsuitable: ['急性心肌梗塞', '严重骨折', '严重骨质疏松']
  },
  {
    exerciseName: '太极',
    description: '中国传统的柔和运动，结合缓慢动作、呼吸和冥想',
    benefits: '改善平衡感和柔韧性，降低血压，减轻关节疼痛，增强身体控制力',
    duration: '20-30分钟',
    frequency: '每日或每周3-4次',
    intensity: '低强度',
    precautions: '保持正确姿势，循序渐进，不要勉强',
    suitableDiseases: ['高血压', '骨质疏松', '关节炎', '帕金森病', '抑郁症', '失眠'],
    unsuitable: ['急性腰椎间盘突出', '急性关节炎发作期']
  },
  {
    exerciseName: '水中有氧运动',
    description: '在水中进行的有氧运动，减少关节压力',
    benefits: '增强心肺功能，减轻关节负担，增强肌肉力量，提升柔韧性',
    duration: '30-45分钟',
    frequency: '每周3-5次',
    intensity: '中等强度',
    precautions: '确保有救生员在场，了解自己的游泳能力，不要过度疲劳',
    suitableDiseases: ['骨关节炎', '纤维肌痛症', '骨质疏松', '肥胖', '脊椎问题'],
    unsuitable: ['严重心脏病', '开放性伤口', '皮肤感染']
  },
  {
    exerciseName: '轻度力量训练',
    description: '使用轻量哑铃、弹力带或自身体重进行的肌肉强化训练',
    benefits: '增强肌肉力量，提高代谢率，改善骨密度，预防跌倒',
    duration: '20-30分钟',
    frequency: '每周2-3次，非连续日',
    intensity: '低至中等强度',
    precautions: '开始时使用轻量，注意正确姿势，避免屏气，缓慢进行',
    suitableDiseases: ['骨质疏松', '糖尿病', '肥胖', '肌肉萎缩'],
    unsuitable: ['未控制的高血压', '严重心脏病', '急性关节炎']
  },
  {
    exerciseName: '伸展运动',
    description: '温和的拉伸活动，改善柔韧性和活动范围',
    benefits: '增加关节活动度，减轻肌肉紧张，改善姿势，预防受伤',
    duration: '15-20分钟',
    frequency: '每日或运动前后',
    intensity: '低强度',
    precautions: '缓慢拉伸至轻微紧张感，不要弹跳，避免疼痛',
    suitableDiseases: ['关节炎', '纤维肌痛症', '帕金森病', '肌肉紧张', '慢性背痛'],
    unsuitable: ['急性骨折', '急性肌肉拉伤']
  },
  {
    exerciseName: '椅子运动',
    description: '坐在椅子上进行的各种运动，适合行动不便或平衡感差的人',
    benefits: '增强上肢和核心肌群力量，改善血液循环，维持活动能力',
    duration: '15-30分钟',
    frequency: '每日或每周3-5次',
    intensity: '低强度',
    precautions: '使用稳固的椅子，注意姿势，避免过度疲劳',
    suitableDiseases: ['行动障碍', '中风后恢复', '严重骨关节炎', '平衡障碍', '严重骨质疏松'],
    unsuitable: ['严重腰椎问题']
  },
  {
    exerciseName: '呼吸练习',
    description: '专注于深呼吸和横膈膜呼吸的练习',
    benefits: '减轻压力，改善肺功能，降低血压，增强冥想能力',
    duration: '10-15分钟',
    frequency: '每日1-3次',
    intensity: '低强度',
    precautions: '在安静环境中进行，避免过度换气',
    suitableDiseases: ['焦虑症', '轻度哮喘', '高血压', '慢阻肺', '失眠', '压力相关疾病'],
    unsuitable: ['严重呼吸系统疾病']
  },
  {
    exerciseName: '有氧步行',
    description: '比普通散步速度稍快的步行，提高心率',
    benefits: '增强心肺功能，燃烧卡路里，降低血压和胆固醇，改善心情',
    duration: '30-60分钟',
    frequency: '每周4-5次',
    intensity: '中等强度',
    precautions: '穿着合适的鞋子，注意心率变化，避免过度疲劳',
    suitableDiseases: ['糖尿病', '高血压', '心脏病', '抑郁症', '肥胖', '骨质疏松'],
    unsuitable: ['严重心脏病', '急性关节炎', '严重骨质疏松']
  },
  {
    exerciseName: '平衡训练',
    description: '专注于改善平衡能力和预防跌倒的练习',
    benefits: '增强平衡能力，预防跌倒，增强核心稳定性，提高身体意识',
    duration: '15-20分钟',
    frequency: '每周3-5次',
    intensity: '低强度',
    precautions: '开始时有支撑物在旁，适应后再尝试更具挑战性的动作',
    suitableDiseases: ['骨质疏松', '帕金森病', '老年人', '平衡障碍', '中风后恢复'],
    unsuitable: ['严重平衡障碍', '未受监督的头晕患者']
  },
  {
    exerciseName: '瑜伽',
    description: '结合姿势、呼吸和冥想的练习，提高柔韧性和力量',
    benefits: '增强柔韧性和力量，改善平衡感，减轻压力和焦虑，促进心理平静',
    duration: '30-60分钟',
    frequency: '每周2-3次',
    intensity: '低至中等强度',
    precautions: '尊重身体限制，遵循指导，使用道具辅助',
    suitableDiseases: ['焦虑症', '抑郁症', '轻度高血压', '慢性背痛', '失眠', '关节炎'],
    unsuitable: ['急性背痛', '严重骨质疏松', '急性关节炎']
  },
  {
    exerciseName: '自行车（固定或户外）',
    description: '骑固定自行车或户外自行车的有氧运动',
    benefits: '增强心肺功能，强化下肢肌肉，减轻关节压力，燃烧卡路里',
    duration: '20-45分钟',
    frequency: '每周3-5次',
    intensity: '中等强度',
    precautions: '调整座位高度，保持适当阻力，户外骑行注意安全',
    suitableDiseases: ['骨关节炎', '糖尿病', '肥胖', '心脏康复患者', '高血压'],
    unsuitable: ['严重平衡障碍', '严重骨质疏松', '急性背痛']
  },
  {
    exerciseName: '普拉提',
    description: '注重核心力量和稳定性的运动系统',
    benefits: '增强核心力量，改善姿势，增加柔韧性，减轻背痛，提高身体控制力',
    duration: '30-45分钟',
    frequency: '每周2-3次',
    intensity: '低至中等强度',
    precautions: '遵循专业指导，注意正确呼吸技巧，避免不适',
    suitableDiseases: ['慢性背痛', '骨盆功能障碍', '姿势不良', '关节炎', '尿失禁'],
    unsuitable: ['急性背痛', '骨折恢复初期']
  },
  {
    exerciseName: '轻度游泳',
    description: '在水中进行的全身性运动，减轻关节压力',
    benefits: '全身肌肉锻炼，无关节冲击，增强心肺功能，改善血液循环',
    duration: '20-30分钟',
    frequency: '每周2-4次',
    intensity: '低至中等强度',
    precautions: '在有救生员的泳池进行，避免疲劳，保持水分',
    suitableDiseases: ['关节炎', '纤维肌痛症', '骨质疏松', '慢性背痛', '肥胖'],
    unsuitable: ['皮肤开放性伤口', '严重心脏病', '水恐惧症']
  },
  {
    exerciseName: '舞蹈',
    description: '各种形式的舞蹈，如民族舞、交谊舞或健康舞',
    benefits: '增强心肺功能，改善协调性和平衡感，增加社交互动，提升心情',
    duration: '30-45分钟',
    frequency: '每周2-4次',
    intensity: '低至中等强度',
    precautions: '根据自身能力选择适当舞种，避免过度转动和跳跃',
    suitableDiseases: ['轻度抑郁症', '轻度焦虑症', '轻度认知障碍', '早期帕金森', '社交孤立'],
    unsuitable: ['严重骨质疏松', '严重平衡障碍', '急性关节炎']
  },
  {
    exerciseName: '低强度健身操',
    description: '专为老年人或体弱者设计的低冲击力健身操',
    benefits: '增强心肺功能，增加肌肉力量，改善协调性，增强身体意识',
    duration: '20-30分钟',
    frequency: '每周3-4次',
    intensity: '低强度',
    precautions: '循序渐进，注意体力限制，保持水分',
    suitableDiseases: ['高血压', '糖尿病', '轻度骨质疏松', '肥胖', '心脏康复初期'],
    unsuitable: ['未控制的心脏病', '急性关节炎', '严重平衡障碍']
  },
  {
    exerciseName: '冥想',
    description: '静坐冥想练习，集中注意力和保持当下',
    benefits: '减轻压力，降低血压，改善情绪，增强专注力，促进放松',
    duration: '10-20分钟',
    frequency: '每日1-2次',
    intensity: '低强度',
    precautions: '在安静环境中进行，保持舒适姿势，不要强求效果',
    suitableDiseases: ['焦虑症', '抑郁症', '高血压', '失眠', '压力相关疾病', '慢性疼痛'],
    unsuitable: ['严重精神疾病（无专业指导时）']
  }
];

// 根据疾病生成运动推荐
export function generateExerciseRecommendations(diseases: string[], severities: Map<string, string>): ExerciseRecommendation[] {
  if (!diseases || diseases.length === 0) {
    // 无疾病记录时，推荐通用安全运动
    return exerciseRecommendations.filter(ex => 
      ex.exerciseName === '散步' || 
      ex.exerciseName === '轻度伸展' ||
      ex.exerciseName === '呼吸练习'
    );
  }

  // 不适合的运动列表（需要排除的运动）
  const unsuitableExercises: string[] = [];

  // 遍历所有疾病，收集不适合的运动
  diseases.forEach(disease => {
    // 检查疾病的严重程度
    const severity = severities.get(disease) || '轻度';
    
    // 对于重度疾病，可能需要额外排除某些运动
    if (severity === '重度') {
      if (disease === '骨质疏松') {
        unsuitableExercises.push('跑步', '跳跃运动', '重力训练');
      } else if (disease === '高血压') {
        unsuitableExercises.push('高强度间歇训练', '举重');
      } else if (disease === '糖尿病') {
        // 针对糖尿病的特殊限制
      }
    }
  });

  // 筛选适合的运动建议
  const suitableExercises = exerciseRecommendations.filter(exercise => {
    // 检查是否有任何不适合的疾病
    for (const disease of diseases) {
      if (exercise.unsuitable.includes(disease)) {
        return false; // 如果有不适合的疾病，则排除该运动
      }
    }
    
    // 检查是否在不适合的运动列表中
    if (unsuitableExercises.includes(exercise.exerciseName)) {
      return false;
    }
    
    // 检查是否适合至少一种疾病
    let isSuitable = false;
    for (const disease of diseases) {
      if (exercise.suitableDiseases.includes(disease)) {
        isSuitable = true;
        break;
      }
    }
    
    return isSuitable;
  });

  // 如果没有找到任何适合的运动，返回一些通用安全的建议
  if (suitableExercises.length === 0) {
    return exerciseRecommendations.filter(ex => 
      ex.exerciseName === '散步' || 
      ex.exerciseName === '呼吸练习' ||
      ex.exerciseName === '椅子运动'
    );
  }

  return suitableExercises;
}

// 预定义运动计划
export const exercisePlans: ExercisePlan[] = [
  {
    planName: '心血管健康计划',
    description: '专为心血管疾病患者设计的温和运动计划，帮助改善心血管健康',
    targetDiseases: ['高血压', '冠心病', '心律失常', '高脂血症'],
    exercises: exerciseRecommendations.filter(ex => 
      ex.exerciseName === '散步' || 
      ex.exerciseName === '呼吸练习' ||
      ex.exerciseName === '轻度游泳' ||
      ex.exerciseName === '太极'
    ),
    difficulty: 'easy',
    totalDuration: '每日30-45分钟'
  },
  {
    planName: '糖尿病健康计划',
    description: '帮助控制血糖和体重的综合运动计划',
    targetDiseases: ['糖尿病', '肥胖'],
    exercises: exerciseRecommendations.filter(ex => 
      ex.exerciseName === '有氧步行' || 
      ex.exerciseName === '轻度力量训练' ||
      ex.exerciseName === '自行车（固定或户外）'
    ),
    difficulty: 'moderate',
    totalDuration: '每日45-60分钟'
  },
  {
    planName: '骨骼健康计划',
    description: '增强骨密度和预防跌倒的平衡与力量训练组合',
    targetDiseases: ['骨质疏松', '骨折', '关节炎'],
    exercises: exerciseRecommendations.filter(ex => 
      ex.exerciseName === '轻度力量训练' || 
      ex.exerciseName === '平衡训练' ||
      ex.exerciseName === '太极'
    ),
    difficulty: 'moderate',
    totalDuration: '每周5次，每次30分钟'
  },
  {
    planName: '关节友好计划',
    description: '减轻关节压力的低冲击运动组合',
    targetDiseases: ['骨关节炎', '纤维肌痛症', '风湿性关节炎'],
    exercises: exerciseRecommendations.filter(ex => 
      ex.exerciseName === '水中有氧运动' || 
      ex.exerciseName === '伸展运动' ||
      ex.exerciseName === '轻度游泳'
    ),
    difficulty: 'easy',
    totalDuration: '每周4次，每次30分钟'
  },
  {
    planName: '心理健康计划',
    description: '缓解焦虑和抑郁的身心练习组合',
    targetDiseases: ['焦虑症', '抑郁症', '失眠'],
    exercises: exerciseRecommendations.filter(ex => 
      ex.exerciseName === '瑜伽' || 
      ex.exerciseName === '冥想' ||
      ex.exerciseName === '太极' ||
      ex.exerciseName === '舞蹈'
    ),
    difficulty: 'easy',
    totalDuration: '每日30-45分钟'
  },
  {
    planName: '老年综合健康计划',
    description: '专为老年人设计的安全全面的活动组合',
    targetDiseases: ['高血压', '关节炎', '骨质疏松', '平衡障碍'],
    exercises: exerciseRecommendations.filter(ex => 
      ex.exerciseName === '椅子运动' || 
      ex.exerciseName === '太极' ||
      ex.exerciseName === '伸展运动' ||
      ex.exerciseName === '平衡训练'
    ),
    difficulty: 'easy',
    totalDuration: '每日20-30分钟'
  }
];

// 根据疾病生成运动计划推荐
export function getRecommendedPlansForDiseases(diseases: string[]): ExercisePlan[] {
  if (!diseases || diseases.length === 0) {
    return [exercisePlans[5]]; // 返回老年综合健康计划作为默认选项
  }
  
  // 计算计划匹配度，根据匹配疾病数量排序
  const plansWithScore = exercisePlans.map(plan => {
    let matchCount = 0;
    diseases.forEach(disease => {
      if (plan.targetDiseases.includes(disease)) {
        matchCount++;
      }
    });
    return { plan, matchCount };
  });
  
  // 按匹配度排序
  plansWithScore.sort((a, b) => b.matchCount - a.matchCount);
  
  // 返回前3个最匹配的计划，或者所有有匹配的计划
  return plansWithScore
    .filter(item => item.matchCount > 0)
    .slice(0, 3)
    .map(item => item.plan);
} 