// 定义从存储加载的医疗记录接口
interface MedicalRecord {
  id: string;
  diseaseName: string;
  diagnosisDate: string;
  severity: string;
  hospital: string;
  doctor: string;
  treatment: string;
  notes: string;
  status?: string; // 添加可选状态字段
}

import { generateExerciseRecommendations, getRecommendedPlansForDiseases, ExerciseRecommendation, ExercisePlan } from '../pages/childpages/exercisepage/ExerciseData';

/**
 * 运动推荐服务
 * 负责根据用户病史记录生成运动建议
 */
class ExerciseRecommendationService {
  private userDiseases: string[] = [];
  private diseaseSeverities: Map<string, string> = new Map();
  
  /**
   * 设置用户疾病列表
   * @param diseases 疾病名称数组
   */
  setUserDiseases(diseases: string[]) {
    this.userDiseases = diseases;
    console.log('运动推荐服务: 用户疾病已更新 -', JSON.stringify(diseases));
  }
  
  /**
   * 设置疾病严重程度
   * @param diseaseName 疾病名称
   * @param severity 严重程度
   */
  setDiseaseSeverity(diseaseName: string, severity: string) {
    this.diseaseSeverities.set(diseaseName, severity);
  }
  
  /**
   * 设置多个疾病严重程度
   * @param severities 疾病严重程度映射
   */
  setSeverities(severities: Map<string, string>) {
    this.diseaseSeverities = new Map(severities);
  }
  
  /**
   * 获取用户疾病列表
   */
  getUserDiseases(): string[] {
    return this.userDiseases;
  }
  
  /**
   * 获取用户疾病严重程度
   */
  getDiseaseSeverities(): Map<string, string> {
    return this.diseaseSeverities;
  }
  
  /**
   * 获取运动推荐
   */
  getExerciseRecommendations(): ExerciseRecommendation[] {
    return generateExerciseRecommendations(this.userDiseases, this.diseaseSeverities);
  }
  
  /**
   * 获取运动计划推荐
   */
  getRecommendedPlans(): ExercisePlan[] {
    return getRecommendedPlansForDiseases(this.userDiseases);
  }
  
  /**
   * 从存储中加载用户疾病数据
   */
  async loadUserDiseasesFromStorage(): Promise<void> {
    try {
      // 直接从MedicalHistoryPage获取数据
      const diseases: string[] = [];
      const severities = new Map<string, string>();
      
      // 由于无法直接访问存储，我们将依赖MedicalHistoryPage来设置疾病数据
      // 这里只保留设置方法，不直接从存储加载
      
      console.log('运动推荐服务: 等待疾病数据设置');
    } catch (error) {
      console.error('运动推荐服务: 加载用户疾病失败 -', error);
    }
  }
}

// 创建单例
const exerciseRecommendationService = new ExerciseRecommendationService();

export default exerciseRecommendationService; 