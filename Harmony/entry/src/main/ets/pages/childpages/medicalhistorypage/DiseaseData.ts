// 疾病类型定义
export interface DiseaseTemplate {
  name: string;
  category: string; // 分类：心血管疾病、代谢性疾病、骨骼疾病等
  suggestions: DiseaseSuggestion[];
}

// 健康建议模板
export interface DiseaseSuggestion {
  title: string;
  content: string;
  priority: number; // 1-高优先级，2-中优先级，3-低优先级
  forSeverity?: string[]; // 适用于哪些严重程度，如果为空则对所有严重程度有效
}

// 模拟疾病数据库
export const diseaseTemplates: DiseaseTemplate[] = [
  // 心血管疾病
  {
    name: '高血压',
    category: '心血管疾病',
    suggestions: [
      {
        title: '严格控制血压',
        content: '建议每日监测血压，严格按医嘱服药，控制盐分摄入，避免情绪波动。',
        priority: 1,
        forSeverity: ['重度']
      },
      {
        title: '低盐饮食',
        content: '建议每日食盐摄入量控制在5g以下，避免高盐食品如腌制品、加工肉类等。',
        priority: 2
      },
      {
        title: '规律运动',
        content: '建议每周进行3-5次中等强度有氧运动，如快走、游泳等，每次30-60分钟。',
        priority: 2
      },
      {
        title: '定期复查',
        content: '建议每3个月进行一次血压检查，评估治疗效果并及时调整治疗方案。',
        priority: 2
      },
      {
        title: '戒烟限酒',
        content: '烟草和酒精会升高血压，建议完全戒烟，限制饮酒。',
        priority: 2
      }
    ]
  },
  {
    name: '冠心病',
    category: '心血管疾病',
    suggestions: [
      {
        title: '遵医嘱服药',
        content: '严格按医嘱服用抗血小板、调脂和抗心绞痛等药物，不可擅自停药或调整剂量。',
        priority: 1
      },
      {
        title: '心脏保护',
        content: '避免剧烈运动和情绪波动，出现胸痛及时含服硝酸甘油，不缓解立即就医。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '合理运动',
        content: '在医生指导下进行适量有氧运动，如散步、太极等，避免过度劳累。',
        priority: 2
      },
      {
        title: '健康饮食',
        content: '低盐低脂饮食，增加蔬果摄入，控制总热量，保持健康体重。',
        priority: 2
      }
    ]
  },
  {
    name: '心律失常',
    category: '心血管疾病',
    suggestions: [
      {
        title: '规律服药',
        content: '按医嘱服用抗心律失常药物，不可自行调整剂量或停药。',
        priority: 1
      },
      {
        title: '避免诱因',
        content: '避免咖啡因、酒精和过度疲劳等可能诱发心律失常的因素。',
        priority: 2
      },
      {
        title: '监测心率',
        content: '定期监测心率和心律，记录异常感觉，及时就医。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  
  // 代谢性疾病
  {
    name: '糖尿病',
    category: '代谢性疾病',
    suggestions: [
      {
        title: '血糖监测',
        content: '建议每日监测血糖水平，记录并分析波动情况，严格按医嘱服药或注射胰岛素。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '饮食控制',
        content: '建议采用低糖、低脂、高纤维饮食，控制总热量摄入，避免精制碳水化合物。',
        priority: 2
      },
      {
        title: '规律运动',
        content: '每周进行至少150分钟中等强度有氧运动，并适当进行抗阻训练，有助于控制血糖。',
        priority: 2
      },
      {
        title: '足部护理',
        content: '每日检查足部，保持清洁干燥，避免赤脚行走，预防糖尿病足并发症。',
        priority: 3
      },
      {
        title: '定期检查',
        content: '每3-6个月进行一次糖化血红蛋白检查，每年进行眼底、肾功能和神经系统检查。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '高脂血症',
    category: '代谢性疾病',
    suggestions: [
      {
        title: '控制饮食',
        content: '减少饱和脂肪和胆固醇摄入，增加不饱和脂肪酸，如橄榄油、坚果和鱼类。',
        priority: 2
      },
      {
        title: '规律服药',
        content: '按医嘱服用他汀类或其他调脂药物，定期检查肝功能。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '增加运动',
        content: '每周进行至少150分钟中等强度有氧运动，帮助降低血脂水平。',
        priority: 2
      }
    ]
  },
  
  // 骨骼疾病
  {
    name: '骨折',
    category: '骨骼疾病',
    suggestions: [
      {
        title: '适当活动',
        content: '遵医嘱进行适当的康复训练，避免过度负重，促进骨折愈合和功能恢复。',
        priority: 2
      },
      {
        title: '钙质补充',
        content: '建议适当增加钙质摄入，如牛奶、豆制品等，必要时可在医生指导下服用钙剂。',
        priority: 3
      },
      {
        title: '防止再次受伤',
        content: '老年人应保持居家环境安全，避免跌倒风险，必要时使用辅助行走工具。',
        priority: 2,
        forSeverity: ['重度']
      }
    ]
  },
  {
    name: '骨质疏松',
    category: '骨骼疾病',
    suggestions: [
      {
        title: '钙质与维生素D',
        content: '每日补充1000-1200mg钙和800-1000IU维生素D，促进钙吸收和骨密度维持。',
        priority: 2
      },
      {
        title: '负重运动',
        content: '进行适当的负重运动，如快走、爬楼梯、轻度力量训练等，增强骨密度。',
        priority: 2
      },
      {
        title: '防跌倒措施',
        content: '改善家居环境，去除地毯绊脚物，增加照明，安装扶手，预防跌倒。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '药物治疗',
        content: '严格按医嘱服用双膦酸盐类等抗骨质疏松药物，不可自行停药。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '关节炎',
    category: '骨骼疾病',
    suggestions: [
      {
        title: '关节保护',
        content: '避免关节过度使用和负重，使用合适的辅助工具如拐杖、助行器等。',
        priority: 2
      },
      {
        title: '温热敷',
        content: '晨僵时可使用热敷，活动后关节肿痛可使用冷敷缓解不适。',
        priority: 3
      },
      {
        title: '合理运动',
        content: '选择低冲击性运动如游泳、骑自行车等，增强关节周围肌肉力量。',
        priority: 2
      },
      {
        title: '控制体重',
        content: '减轻体重可降低关节负担，每减少5kg体重可减少25%的关节疼痛。',
        priority: 2
      }
    ]
  },
  
  // 呼吸系统疾病
  {
    name: '哮喘',
    category: '呼吸系统疾病',
    suggestions: [
      {
        title: '避免诱因',
        content: '识别并避免个人哮喘诱发因素，如花粉、尘螨、宠物皮屑、烟草等。',
        priority: 1
      },
      {
        title: '坚持用药',
        content: '即使无症状时也应按医嘱使用控制药物，急性发作时正确使用缓解药物。',
        priority: 1
      },
      {
        title: '制定行动计划',
        content: '与医生一起制定哮喘行动计划，学会根据症状调整用药并识别紧急情况。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '肺功能监测',
        content: '使用峰流速仪定期监测肺功能，及时发现哮喘控制状况变化。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '慢性阻塞性肺疾病',
    category: '呼吸系统疾病',
    suggestions: [
      {
        title: '戒烟',
        content: '立即戒烟是最重要的干预措施，可延缓肺功能下降，减少急性发作。',
        priority: 1
      },
      {
        title: '肺康复',
        content: '参加肺康复计划，包括运动训练、营养支持和呼吸技巧训练。',
        priority: 2
      },
      {
        title: '接种疫苗',
        content: '每年接种流感疫苗，按医嘱接种肺炎球菌疫苗，减少感染风险。',
        priority: 2
      },
      {
        title: '氧疗',
        content: '重度患者可能需要家庭氧疗，严格按医嘱使用并定期评估。',
        priority: 1,
        forSeverity: ['重度']
      }
    ]
  },
  
  // 消化系统疾病
  {
    name: '胃食管反流病',
    category: '消化系统疾病',
    suggestions: [
      {
        title: '饮食调整',
        content: '少量多餐，避免高脂、辛辣、酸性食物，睡前3小时不进食。',
        priority: 2
      },
      {
        title: '生活方式改变',
        content: '抬高床头15-20cm，减轻体重，避免紧身衣物，戒烟限酒。',
        priority: 2
      },
      {
        title: '规律服药',
        content: '按医嘱服用质子泵抑制剂或H2受体拮抗剂，不可突然停药。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '消化性溃疡',
    category: '消化系统疾病',
    suggestions: [
      {
        title: '根除幽门螺杆菌',
        content: '如检测出幽门螺杆菌感染，应完成根除治疗，提高溃疡愈合率。',
        priority: 1
      },
      {
        title: '避免刺激物',
        content: '避免咖啡因、酒精、辛辣食物和非甾体抗炎药，减少胃黏膜刺激。',
        priority: 2
      },
      {
        title: '规律生活',
        content: '保持规律饮食，避免长时间空腹，减轻精神压力，充分休息。',
        priority: 2
      }
    ]
  },
  
  // 神经系统疾病
  {
    name: '帕金森病',
    category: '神经系统疾病',
    suggestions: [
      {
        title: '药物管理',
        content: '严格按医嘱服用左旋多巴等药物，按时服药维持血药浓度稳定。',
        priority: 1
      },
      {
        title: '物理治疗',
        content: '定期进行物理治疗，包括平衡训练、步态训练和伸展运动。',
        priority: 2
      },
      {
        title: '跌倒预防',
        content: '改善家居环境，使用助行器具，穿防滑鞋，预防跌倒。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '语言训练',
        content: '定期进行语言训练，大声朗读，练习面部表情，改善言语困难。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '阿尔茨海默病',
    category: '神经系统疾病',
    suggestions: [
      {
        title: '认知刺激',
        content: '进行拼图、阅读、棋牌等认知活动，延缓认知功能下降。',
        priority: 2
      },
      {
        title: '规律生活',
        content: '保持规律的作息时间，建立日常活动例程，减少混淆和焦虑。',
        priority: 2
      },
      {
        title: '安全环境',
        content: '简化家居环境，标记重要物品和区域，移除危险物品，防止走失。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '药物治疗',
        content: '按医嘱服用胆碱酯酶抑制剂或美金刚等药物，缓解症状。',
        priority: 1,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  
  // 皮肤疾病
  {
    name: '银屑病',
    category: '皮肤疾病',
    suggestions: [
      {
        title: '皮肤保湿',
        content: '使用温和的保湿剂，避免热水洗澡，保持皮肤湿润。',
        priority: 2
      },
      {
        title: '避免诱因',
        content: '识别并避免个人诱发因素，如压力、感染、某些药物等。',
        priority: 2
      },
      {
        title: '光疗和药物',
        content: '按医嘱接受紫外线光疗或使用外用药物，不可擅自停药。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  
  // 精神疾病
  {
    name: '抑郁症',
    category: '精神疾病',
    suggestions: [
      {
        title: '规律服药',
        content: '抗抑郁药需要连续服用4-6周才能发挥完全效果，不可自行停药。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '心理治疗',
        content: '定期接受认知行为治疗或其他心理治疗，学习应对技巧。',
        priority: 2
      },
      {
        title: '生活规律',
        content: '保持规律作息，适当运动，建立社交支持网络，避免孤立。',
        priority: 2
      },
      {
        title: '危机应对',
        content: '制定情绪危机应对计划，记录紧急联系人和求助热线。',
        priority: 1,
        forSeverity: ['重度']
      }
    ]
  },
  {
    name: '焦虑症',
    category: '精神疾病',
    suggestions: [
      {
        title: '放松技巧',
        content: '学习并练习深呼吸、渐进性肌肉放松和冥想等放松技巧。',
        priority: 2
      },
      {
        title: '认知重构',
        content: '识别并挑战消极思维模式，学习更加平衡的思考方式。',
        priority: 2
      },
      {
        title: '适当运动',
        content: '每周进行至少150分钟中等强度有氧运动，有助于缓解焦虑。',
        priority: 2
      },
      {
        title: '药物治疗',
        content: '按医嘱服用抗焦虑药物，注意可能的依赖性，不可自行调整剂量。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  
  // 眼科疾病
  {
    name: '白内障',
    category: '眼科疾病',
    suggestions: [
      {
        title: '手术评估',
        content: '当视力下降影响日常生活时，请咨询眼科医生进行手术评估，现代白内障手术安全有效。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '光线调节',
        content: '增加室内照明亮度，避免眩光，使用抗紫外线太阳镜减少户外强光刺激。',
        priority: 2
      },
      {
        title: '视力保护',
        content: '定期更新眼镜处方，减少眼睛疲劳，避免长时间近距离用眼。',
        priority: 2
      },
      {
        title: '定期检查',
        content: '每6-12个月进行一次眼科检查，监测白内障进展情况。',
        priority: 2
      }
    ]
  },
  {
    name: '青光眼',
    category: '眼科疾病',
    suggestions: [
      {
        title: '眼压控制',
        content: '严格按医嘱使用降眼压药物，不可擅自停药或调整剂量，定期监测眼压。',
        priority: 1
      },
      {
        title: '避免诱因',
        content: '避免长时间低头、过度用眼、情绪激动等可能升高眼压的活动。',
        priority: 2
      },
      {
        title: '规律复查',
        content: '按医嘱定期进行眼底检查、视野检查和眼压测量，评估病情进展。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '家族筛查',
        content: '青光眼有家族聚集性，建议直系亲属定期进行青光眼筛查。',
        priority: 3
      }
    ]
  },
  {
    name: '近视',
    category: '眼科疾病',
    suggestions: [
      {
        title: '正确用眼',
        content: '保持正确坐姿，阅读距离保持30-40厘米，每用眼40-50分钟休息10分钟。',
        priority: 2
      },
      {
        title: '户外活动',
        content: '每天至少2小时户外活动，自然光照可减缓近视进展。',
        priority: 2,
        forSeverity: ['轻度']
      },
      {
        title: '定期验光',
        content: '每6-12个月更换眼镜，不宜频繁更换，避免过度矫正。',
        priority: 2
      },
      {
        title: '防控措施',
        content: '高度近视者应定期检查眼底，警惕视网膜病变等并发症。',
        priority: 1,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '干眼症',
    category: '眼科疾病',
    suggestions: [
      {
        title: '人工泪液',
        content: '规律使用不含防腐剂的人工泪液，缓解眼干、眼涩等不适症状。',
        priority: 2
      },
      {
        title: '环境调整',
        content: '保持室内湿度，使用加湿器，避免直接对着空调或风扇。',
        priority: 2
      },
      {
        title: '热敷按摩',
        content: '每天进行眼睑热敷和睑板腺按摩，促进油脂分泌，稳定泪膜。',
        priority: 2
      },
      {
        title: '减少屏幕时间',
        content: '使用电子设备时遵循20-20-20原则：每20分钟向20英尺外看20秒。',
        priority: 2
      }
    ]
  },
  
  // 泌尿系统疾病
  {
    name: '肾结石',
    category: '泌尿系统疾病',
    suggestions: [
      {
        title: '大量饮水',
        content: '每天饮水2000-3000ml，保持尿液稀释，促进结石排出，预防新结石形成。',
        priority: 1
      },
      {
        title: '饮食调整',
        content: '根据结石成分控制相应饮食，如草酸钙结石应限制高草酸食物，尿酸结石应限制嘌呤摄入。',
        priority: 2
      },
      {
        title: '监测尿液',
        content: '定期检查尿液pH值和结石相关成分，及时调整治疗方案。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '药物治疗',
        content: '按医嘱服用排石药物或碱化尿液药物，配合适量运动促进结石排出。',
        priority: 2
      }
    ]
  },
  {
    name: '尿路感染',
    category: '泌尿系统疾病',
    suggestions: [
      {
        title: '抗生素治疗',
        content: '完成全程抗生素治疗，即使症状缓解也不可擅自停药，以防感染复发。',
        priority: 1
      },
      {
        title: '充分饮水',
        content: '增加饮水量，每天至少2000ml，促进排尿，冲刷尿路细菌。',
        priority: 2
      },
      {
        title: '个人卫生',
        content: '保持会阴部清洁干燥，女性应前后分开擦拭，避免交叉感染。',
        priority: 2
      },
      {
        title: '定期复查',
        content: '治疗后进行尿常规复查，确认感染已完全清除。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '前列腺增生',
    category: '泌尿系统疾病',
    suggestions: [
      {
        title: '规律服药',
        content: '按医嘱服用5α-还原酶抑制剂或α受体阻滞剂，缓解排尿困难症状。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '排尿管理',
        content: '避免长时间憋尿，夜间减少饮水，避免酒精和咖啡因。',
        priority: 2
      },
      {
        title: '温水坐浴',
        content: '每天温水坐浴15-20分钟，缓解盆腔充血，改善排尿症状。',
        priority: 3
      },
      {
        title: '监测尿流',
        content: '定期进行国际前列腺症状评分和尿流率检查，评估治疗效果。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  
  // 生殖系统疾病
  {
    name: '子宫内膜异位症',
    category: '生殖系统疾病',
    suggestions: [
      {
        title: '药物治疗',
        content: '按医嘱使用激素药物或避孕药，控制疼痛和异位内膜生长。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '疼痛管理',
        content: '经期前适当使用非甾体抗炎药，配合热敷缓解疼痛。',
        priority: 2
      },
      {
        title: '生育规划',
        content: '有生育需求者应及早规划，疾病可能影响生育能力。',
        priority: 2
      },
      {
        title: '规律随访',
        content: '每6-12个月进行一次盆腔超声检查，评估病情变化。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '多囊卵巢综合征',
    category: '生殖系统疾病',
    suggestions: [
      {
        title: '体重管理',
        content: '超重者减重5-10%可显著改善内分泌紊乱和排卵功能。',
        priority: 2
      },
      {
        title: '规律生活',
        content: '保持规律作息，适量运动，减少糖分和精制碳水化合物摄入。',
        priority: 2
      },
      {
        title: '药物治疗',
        content: '按医嘱使用二甲双胍或口服避孕药，改善胰岛素抵抗和月经紊乱。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '定期筛查',
        content: '定期检查血糖、血脂和血压，预防代谢综合征。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '良性前列腺增生',
    category: '生殖系统疾病',
    suggestions: [
      {
        title: '药物治疗',
        content: '按医嘱服用α受体阻滞剂或5α-还原酶抑制剂，改善排尿症状。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '生活习惯调整',
        content: '避免憋尿，减少夜间饮水，限制酒精和咖啡因摄入。',
        priority: 2
      },
      {
        title: '规律检查',
        content: '每年进行前列腺特异性抗原(PSA)检查，排除前列腺癌可能。',
        priority: 2
      },
      {
        title: '手术评估',
        content: '症状严重或出现并发症时，咨询医生评估手术治疗的必要性。',
        priority: 1,
        forSeverity: ['重度']
      }
    ]
  },
  
  // 内分泌系统疾病
  {
    name: '甲状腺功能亢进',
    category: '内分泌系统疾病',
    suggestions: [
      {
        title: '规律服药',
        content: '按医嘱服用抗甲状腺药物，不可擅自停药或调整剂量。',
        priority: 1
      },
      {
        title: '避免碘摄入',
        content: '限制高碘食物如海带、紫菜等，避免使用含碘消毒剂。',
        priority: 2
      },
      {
        title: '定期检查',
        content: '每1-3个月检查甲状腺功能，评估治疗效果并调整用药。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '情绪管理',
        content: '保持情绪稳定，学习放松技巧，避免过度紧张和焦虑。',
        priority: 2
      }
    ]
  },
  {
    name: '甲状腺功能减退',
    category: '内分泌系统疾病',
    suggestions: [
      {
        title: '终身替代治疗',
        content: '每日早晨空腹服用左旋甲状腺素，终身替代治疗，不可自行停药。',
        priority: 1
      },
      {
        title: '药物相互作用',
        content: '甲状腺素与某些药物、食物有相互作用，服药时间应与其他药物间隔4小时以上。',
        priority: 2
      },
      {
        title: '监测甲功',
        content: '初始治疗每4-6周，稳定后每6-12个月检查甲状腺功能。',
        priority: 2
      },
      {
        title: '妊娠管理',
        content: '计划妊娠前和妊娠期需调整剂量，密切监测甲状腺功能。',
        priority: 1,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '肾上腺功能减退',
    category: '内分泌系统疾病',
    suggestions: [
      {
        title: '激素替代',
        content: '按医嘱服用糖皮质激素和盐皮质激素，模拟正常分泌节律，早晨剂量大，晚上剂量小。',
        priority: 1
      },
      {
        title: '应激调整',
        content: '发热、手术等应激状态时需增加激素剂量，避免肾上腺危象。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '携带急救卡',
        content: '随身携带肾上腺危象急救卡，方便紧急情况下及时救治。',
        priority: 1
      },
      {
        title: '电解质监测',
        content: '定期检查血钠、血钾水平，及时调整治疗方案。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  
  // 血液系统疾病
  {
    name: '贫血',
    category: '血液系统疾病',
    suggestions: [
      {
        title: '铁剂补充',
        content: '缺铁性贫血应口服或静脉补充铁剂，最好空腹服用，可与维生素C同服以增加吸收。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '饮食调整',
        content: '增加富含铁、叶酸、维生素B12的食物，如红肉、动物肝脏、绿叶蔬菜等。',
        priority: 2
      },
      {
        title: '病因治疗',
        content: '积极治疗原发病，如胃肠道出血、慢性肾病等。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '定期复查',
        content: '定期监测血红蛋白、血清铁蛋白等指标，评估治疗效果。',
        priority: 2
      }
    ]
  },
  {
    name: '血小板减少症',
    category: '血液系统疾病',
    suggestions: [
      {
        title: '避免外伤',
        content: '避免剧烈运动和有外伤风险的活动，预防出血。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '药物注意',
        content: '避免使用影响血小板功能的药物，如阿司匹林、非甾体抗炎药等。',
        priority: 1
      },
      {
        title: '激素治疗',
        content: '按医嘱使用糖皮质激素或免疫抑制剂，不可自行调整剂量。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '出血监测',
        content: '密切观察皮肤瘀斑、黏膜出血等症状，出现严重出血立即就医。',
        priority: 1,
        forSeverity: ['重度']
      }
    ]
  },
  {
    name: '血友病',
    category: '血液系统疾病',
    suggestions: [
      {
        title: '凝血因子替代',
        content: '严格按医嘱定期或按需输注凝血因子，预防或治疗出血。',
        priority: 1
      },
      {
        title: '居家安全',
        content: '改善家居环境，去除尖锐物品和绊倒风险，预防外伤。',
        priority: 2
      },
      {
        title: '关节保护',
        content: '进行适当的关节保护性运动，如游泳、步行，避免高冲击活动。',
        priority: 2
      },
      {
        title: '携带急救卡',
        content: '随身携带血友病紧急治疗信息卡，注明病型和凝血因子水平。',
        priority: 1,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  
  // 耳鼻喉科疾病
  {
    name: '慢性鼻炎',
    category: '耳鼻喉科疾病',
    suggestions: [
      {
        title: '鼻腔冲洗',
        content: '每日使用生理盐水进行鼻腔冲洗，清除过敏原和分泌物。',
        priority: 2
      },
      {
        title: '药物治疗',
        content: '按医嘱使用鼻用糖皮质激素喷雾，减轻鼻腔炎症。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '避免刺激',
        content: '避免接触烟草、刺激性气味和过敏原，保持室内空气清新。',
        priority: 2
      },
      {
        title: '湿度控制',
        content: '保持适当室内湿度（40-50%），使用加湿器或除湿机。',
        priority: 3
      }
    ]
  },
  {
    name: '中耳炎',
    category: '耳鼻喉科疾病',
    suggestions: [
      {
        title: '抗生素治疗',
        content: '完成全程抗生素治疗，即使症状改善也不可提前停药。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '保持耳道干燥',
        content: '游泳或洗澡后彻底擦干耳道，避免水分进入。',
        priority: 2
      },
      {
        title: '止痛处理',
        content: '疼痛明显时可在医生指导下使用适当止痛药物。',
        priority: 2
      },
      {
        title: '听力监测',
        content: '定期进行听力检查，特别是反复中耳炎患者。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '耳鸣',
    category: '耳鼻喉科疾病',
    suggestions: [
      {
        title: '避免噪音',
        content: '避免接触强烈噪音环境，必要时使用耳塞保护听力。',
        priority: 2
      },
      {
        title: '放松训练',
        content: '学习放松技巧和冥想，缓解压力和焦虑情绪。',
        priority: 2
      },
      {
        title: '声音疗法',
        content: '使用白噪音或其他背景声音掩盖耳鸣，帮助入睡和集中注意力。',
        priority: 2
      },
      {
        title: '多学科治疗',
        content: '严重影响生活质量时，考虑听力学、耳鼻喉科和心理科多学科综合治疗。',
        priority: 1,
        forSeverity: ['重度']
      }
    ]
  },
  
  // 免疫系统疾病
  {
    name: '系统性红斑狼疮',
    category: '免疫系统疾病',
    suggestions: [
      {
        title: '避免阳光',
        content: '避免阳光直接照射，外出使用防晒霜（SPF50+），穿着防晒衣物。',
        priority: 1
      },
      {
        title: '规律服药',
        content: '按医嘱服用抗疟药、糖皮质激素或免疫抑制剂，不可自行停药。',
        priority: 1
      },
      {
        title: '感染预防',
        content: '避免接触感染源，保持良好个人卫生，出现发热等症状及时就医。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '定期监测',
        content: '定期进行血常规、肾功能、自身抗体等检查，评估疾病活动度。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '类风湿关节炎',
    category: '免疫系统疾病',
    suggestions: [
      {
        title: '早期干预',
        content: '早期使用改变病情抗风湿药(DMARDs)，控制疾病进展，预防关节破坏。',
        priority: 1
      },
      {
        title: '关节保护',
        content: '学习关节保护技巧，使用辅助工具，避免关节过度使用。',
        priority: 2
      },
      {
        title: '定期运动',
        content: '进行适当的关节活动度练习和肌肉强化训练，维持关节功能。',
        priority: 2
      },
      {
        title: '监测副作用',
        content: '定期检查肝肾功能和血常规，监测药物可能的副作用。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '过敏性鼻炎',
    category: '免疫系统疾病',
    suggestions: [
      {
        title: '避免过敏原',
        content: '识别并避免个人过敏原，如花粉、尘螨、宠物皮屑等。',
        priority: 1
      },
      {
        title: '药物治疗',
        content: '按医嘱使用抗组胺药物和鼻用糖皮质激素，控制症状。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '鼻腔冲洗',
        content: '每日使用生理盐水进行鼻腔冲洗，清除过敏原和分泌物。',
        priority: 2
      },
      {
        title: '考虑脱敏治疗',
        content: '症状严重且明确过敏原者，可咨询医生评估是否适合脱敏治疗。',
        priority: 2,
        forSeverity: ['重度']
      }
    ]
  },
  {
    name: '特应性皮炎',
    category: '免疫系统疾病',
    suggestions: [
      {
        title: '皮肤保湿',
        content: '每日至少两次使用无香料保湿剂，沐浴后立即涂抹以锁住水分。',
        priority: 1
      },
      {
        title: '避免刺激',
        content: '穿着柔软棉质衣物，避免羊毛和合成纤维，使用温和无香料清洁产品。',
        priority: 2
      },
      {
        title: '药物治疗',
        content: '按医嘱使用外用糖皮质激素或钙调神经磷酸酶抑制剂，控制炎症。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '预防感染',
        content: '避免抓挠，保持指甲短而平滑，皮肤感染时及时就医。',
        priority: 2
      }
    ]
  },
  
  // 儿科疾病
  {
    name: '注意力缺陷多动障碍',
    category: '儿科疾病',
    suggestions: [
      {
        title: '行为干预',
        content: '建立结构化日常活动，设定明确的规则和期望，提供及时的正面反馈。',
        priority: 1
      },
      {
        title: '学习环境调整',
        content: '减少学习环境中的干扰，提供安静的学习空间，分解任务为小步骤。',
        priority: 2
      },
      {
        title: '药物管理',
        content: '按医嘱服用中枢神经兴奋剂或非兴奋剂类药物，定期评估剂量和副作用。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '家校合作',
        content: '与学校教师紧密合作，制定个性化教育计划，保持沟通一致性。',
        priority: 2
      }
    ]
  },
  {
    name: '自闭症谱系障碍',
    category: '儿科疾病',
    suggestions: [
      {
        title: '早期干预',
        content: '尽早开始行为、语言和社交干预，提高社交沟通能力和适应性行为。',
        priority: 1
      },
      {
        title: '结构化教育',
        content: '提供高度结构化的学习和生活环境，使用视觉提示和明确的日程安排。',
        priority: 2
      },
      {
        title: '感觉整合',
        content: '针对感觉过敏或感觉寻求行为，提供适当的感觉整合训练。',
        priority: 2
      },
      {
        title: '家庭支持',
        content: '家长参与培训，学习如何在日常生活中促进孩子的发展和管理行为问题。',
        priority: 1,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '小儿哮喘',
    category: '儿科疾病',
    suggestions: [
      {
        title: '避免触发因素',
        content: '识别并避免个体哮喘触发因素，如尘螨、宠物皮屑、冷空气或运动等。',
        priority: 1
      },
      {
        title: '用药指导',
        content: '教导儿童和家长正确使用吸入器，区分控制药物和缓解药物的使用时机。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '制定行动计划',
        content: '与医生共同制定哮喘行动计划，明确症状加重时的应对措施。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '定期随访',
        content: '每3-6个月进行一次哮喘控制评估，根据需要调整治疗方案。',
        priority: 2
      }
    ]
  },
  
  // 传染病
  {
    name: '新型冠状病毒肺炎',
    category: '传染病',
    suggestions: [
      {
        title: '居家隔离',
        content: '确诊或疑似患者应严格居家隔离，单独房间、单独卫生间，减少与家人接触。',
        priority: 1
      },
      {
        title: '症状监测',
        content: '定期监测体温和氧饱和度，出现呼吸困难、持续胸痛等症状立即就医。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '充分休息',
        content: '增加休息时间，保持充分睡眠，适当补充维生素和蛋白质。',
        priority: 2
      },
      {
        title: '后遗症管理',
        content: '康复后可能出现疲劳、气短等长期症状，应进行针对性康复训练。',
        priority: 2,
        forSeverity: ['中度', '重度']
      }
    ]
  },
  {
    name: '流行性感冒',
    category: '传染病',
    suggestions: [
      {
        title: '充分休息',
        content: '感染期间应卧床休息，避免过度劳累，增加睡眠时间。',
        priority: 1
      },
      {
        title: '适当用药',
        content: '按医嘱使用抗病毒药物和对症治疗药物，不可滥用抗生素。',
        priority: 2
      },
      {
        title: '预防传播',
        content: '戴口罩，勤洗手，咳嗽或打喷嚏时用纸巾或肘部遮挡，避免接触他人。',
        priority: 1
      },
      {
        title: '疫苗接种',
        content: '康复后考虑在下一流感季节前接种流感疫苗，预防再次感染。',
        priority: 2
      }
    ]
  },
  {
    name: '病毒性肝炎',
    category: '传染病',
    suggestions: [
      {
        title: '休息与营养',
        content: '急性期应卧床休息，避免剧烈活动，保证优质蛋白质和碳水化合物摄入。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '避免肝损伤',
        content: '禁酒，避免服用对肝脏有损害的药物，如对乙酰氨基酚大剂量使用。',
        priority: 1
      },
      {
        title: '定期随访',
        content: '按医嘱定期检查肝功能和病毒标志物，评估疾病进展。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '预防传播',
        content: '不共用个人物品，如牙刷、剃须刀等，避免无保护性性行为。',
        priority: 1
      }
    ]
  },
  {
    name: '结核病',
    category: '传染病',
    suggestions: [
      {
        title: '规范抗结核治疗',
        content: '严格按医嘱服用抗结核药物，疗程通常需要6-9个月，不可擅自停药或减量。',
        priority: 1
      },
      {
        title: '隔离措施',
        content: '痰涂片阳性患者需进行有效隔离，直至痰涂片转阴，避免传染他人。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '定期随访',
        content: '按医嘱定期进行痰检、胸片和肝功能检查，评估治疗效果和副作用。',
        priority: 2
      },
      {
        title: '营养支持',
        content: '保证充足的蛋白质和热量摄入，维持良好营养状态，提高免疫力。',
        priority: 2
      }
    ]
  },
  
  // 肿瘤
  {
    name: '乳腺癌',
    category: '肿瘤',
    suggestions: [
      {
        title: '规范治疗',
        content: '按医嘱完成手术、化疗、放疗、内分泌治疗等综合治疗方案，不可擅自中断。',
        priority: 1
      },
      {
        title: '定期随访',
        content: '按医嘱进行定期随访，包括影像学检查、肿瘤标志物和相关症状评估。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '上肢功能锻炼',
        content: '乳腺手术后进行循序渐进的上肢功能锻炼，预防淋巴水肿和关节挛缩。',
        priority: 2
      },
      {
        title: '心理支持',
        content: '加入乳腺癌患者互助组织，获取专业心理支持，保持积极乐观心态。',
        priority: 2
      }
    ]
  },
  {
    name: '肺癌',
    category: '肿瘤',
    suggestions: [
      {
        title: '呼吸功能训练',
        content: '进行深呼吸、缩唇呼吸等呼吸功能训练，改善氧合和排痰。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '营养支持',
        content: '保证高蛋白、高热量饮食，必要时使用营养补充剂，维持体重和体能。',
        priority: 2
      },
      {
        title: '规律治疗',
        content: '按医嘱完成手术、化疗、放疗、靶向治疗和免疫治疗等，定期评估疗效。',
        priority: 1
      },
      {
        title: '生活质量管理',
        content: '积极控制疼痛、呼吸困难等症状，改善生活质量，必要时寻求姑息治疗团队帮助。',
        priority: 1,
        forSeverity: ['重度']
      }
    ]
  },
  {
    name: '结直肠癌',
    category: '肿瘤',
    suggestions: [
      {
        title: '定期随访',
        content: '按医嘱进行定期肠镜、CT和肿瘤标志物检查，早期发现复发和转移。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '饮食调整',
        content: '手术后逐渐调整饮食，避免产气食物，少量多餐，预防肠梗阻。',
        priority: 2
      },
      {
        title: '造口护理',
        content: '结肠造口患者学习正确的造口护理技术，预防皮肤刺激和感染。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '生活方式改变',
        content: '增加体力活动，维持健康体重，避免烟酒，降低复发风险。',
        priority: 2
      }
    ]
  },
  
  // 康复医学
  {
    name: '脊髓损伤',
    category: '康复医学',
    suggestions: [
      {
        title: '压疮预防',
        content: '每2小时更换体位，使用减压垫和气垫床，保持皮肤清洁干燥。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '排便管理',
        content: '建立规律排便习惯，必要时使用辅助排便方法，预防便秘和意外排便。',
        priority: 1
      },
      {
        title: '神经源性膀胱管理',
        content: '按时间或感觉提示排尿，必要时学习清洁间歇导尿技术。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '功能训练',
        content: '根据损伤平面进行适当的功能训练，使用辅助器具提高日常生活活动能力。',
        priority: 2
      }
    ]
  },
  {
    name: '脑卒中',
    category: '康复医学',
    suggestions: [
      {
        title: '早期康复',
        content: '病情稳定后尽早开始康复训练，包括翻身、坐起、站立和行走等功能训练。',
        priority: 1
      },
      {
        title: '吞咽训练',
        content: '吞咽障碍患者进行吞咽功能训练，选择适当食物质地，预防误吸。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '语言训练',
        content: '失语症患者进行系统语言功能训练，使用替代沟通方式促进交流。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '二级预防',
        content: '严格控制高血压、糖尿病、高脂血症等危险因素，预防复发。',
        priority: 1
      }
    ]
  },
  {
    name: '创伤性脑损伤',
    category: '康复医学',
    suggestions: [
      {
        title: '认知训练',
        content: '针对记忆、注意力、执行功能等认知障碍进行系统训练，使用代偿策略。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '行为管理',
        content: '针对冲动、易怒等行为问题制定行为干预计划，保持环境结构化和一致性。',
        priority: 1,
        forSeverity: ['中度', '重度']
      },
      {
        title: '运动功能训练',
        content: '根据功能障碍进行针对性训练，包括平衡、协调性和精细运动训练。',
        priority: 2
      },
      {
        title: '家庭支持',
        content: '教育家庭成员了解脑损伤后遗症，参与康复过程，提供合理的家庭环境。',
        priority: 2
      }
    ]
  },
  {
    name: '截肢',
    category: '康复医学',
    suggestions: [
      {
        title: '残肢护理',
        content: '保持残肢清洁干燥，进行适当包扎和塑形，预防残肢水肿和畸形。',
        priority: 1
      },
      {
        title: '假肢适配',
        content: '在专业团队指导下选择合适的假肢，定期检查和调整，避免皮肤问题。',
        priority: 2,
        forSeverity: ['中度', '重度']
      },
      {
        title: '平衡训练',
        content: '进行站立平衡和行走训练，学习上下楼梯、不平整地面行走等技能。',
        priority: 2
      },
      {
        title: '幻肢痛管理',
        content: '出现幻肢痛时使用药物、物理疗法或心理疗法进行综合管理。',
        priority: 1,
        forSeverity: ['中度', '重度']
      }
    ]
  }
];

// 获取所有疾病名称列表
export function getAllDiseaseNames(): string[] {
  return diseaseTemplates.map(disease => disease.name);
}

// 获取所有疾病分类
export function getAllCategories(): string[] {
  const categories = new Set<string>();
  diseaseTemplates.forEach(disease => {
    categories.add(disease.category);
  });
  return Array.from(categories);
}

// 根据疾病名称获取疾病模板
export function getDiseaseByName(name: string): DiseaseTemplate | undefined {
  return diseaseTemplates.find(disease => disease.name === name);
}

// 根据分类获取疾病列表
export function getDiseasesByCategory(category: string): DiseaseTemplate[] {
  return diseaseTemplates.filter(disease => disease.category === category);
} 