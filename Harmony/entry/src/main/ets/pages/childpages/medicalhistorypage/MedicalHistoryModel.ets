import { getDiseaseByName } from './DiseaseData';
import storageUtil from '../../../utils/StorageUtil';

export interface MedicalRecord {
  id: string;
  diseaseName: string;
  diagnosisDate: string;
  severity: string; // 轻度、中度、重度
  hospital: string;
  doctor: string;
  treatment: string;
  notes: string;
  isExpanded?: boolean;
}

export interface HealthSuggestion {
  id: string;
  title: string;
  content: string;
  priority: number;
  isExpanded?: boolean;
}

// 根据疾病记录生成健康建议
export function generateHealthSuggestions(records: MedicalRecord[]): HealthSuggestion[] {
  const suggestions: HealthSuggestion[] = [];
  let suggestionId = 1;

  records.forEach(record => {
    const diseaseTemplate = getDiseaseByName(record.diseaseName);
    if (!diseaseTemplate) {
      return;
    }

    // 获取适合该疾病严重程度的建议
    diseaseTemplate.suggestions.forEach(suggestion => {
      // 检查这个建议是否适用于当前严重程度
      if (!suggestion.forSeverity || suggestion.forSeverity.includes(record.severity)) {
        // 检查是否已经有相同标题的建议
        const existingSuggestion = suggestions.find(s => s.title === suggestion.title);

        if (!existingSuggestion) {
          // 添加新建议
          suggestions.push({
            id: `suggestion-${suggestionId++}`,
            title: suggestion.title,
            content: suggestion.content,
            priority: suggestion.priority,
            isExpanded: false
          });
        }
      }
    });
  });

  // 按优先级排序
  return suggestions.sort((a, b) => a.priority - b.priority);
}

// 模拟医疗记录数据
export const mockMedicalRecords: MedicalRecord[] = [
  {
    id: '1',
    diseaseName: '高血压',
    diagnosisDate: '2023-01-15',
    severity: '中度',
    hospital: '协和医院',
    doctor: '张医生',
    treatment: '口服降压药物，生活方式干预',
    notes: '血压波动较大，需要定期监测',
    isExpanded: false
  },
  {
    id: '2',
    diseaseName: '糖尿病',
    diagnosisDate: '2022-05-20',
    severity: '轻度',
    hospital: '同济医院',
    doctor: '李医生',
    treatment: '饮食控制，口服降糖药',
    notes: '需控制碳水化合物摄入',
    isExpanded: false
  },
  {
    id: '3',
    diseaseName: '骨质疏松',
    diagnosisDate: '2023-08-10',
    severity: '中度',
    hospital: '华山医院',
    doctor: '王医生',
    treatment: '钙剂补充，双膦酸盐类药物',
    notes: '需要增加负重运动',
    isExpanded: false
  }
];

// 添加新的医疗记录
export function addMedicalRecord(record: MedicalRecord, records: MedicalRecord[]): MedicalRecord[] {
  // 生成新ID
  const newId = String(records.length + 1);
  // 创建新记录对象
  const newRecord: MedicalRecord = {
    id: newId,
    diseaseName: record.diseaseName,
    diagnosisDate: record.diagnosisDate,
    severity: record.severity,
    hospital: record.hospital,
    doctor: record.doctor,
    treatment: record.treatment,
    notes: record.notes,
    isExpanded: false
  };
  // 返回包含新记录的数组
  const updatedRecords = [...records, newRecord];
  // 保存到持久化存储
  saveMedicalRecordsToStorage(updatedRecords);
  return updatedRecords;
}

// 根据ID删除医疗记录
export function deleteMedicalRecord(id: string, records: MedicalRecord[]): MedicalRecord[] {
  const updatedRecords = records.filter(record => record.id !== id);
  // 保存到持久化存储
  saveMedicalRecordsToStorage(updatedRecords);
  return updatedRecords;
}

// 更新医疗记录
export function updateMedicalRecord(updatedRecord: MedicalRecord, records: MedicalRecord[]): MedicalRecord[] {
  const updatedRecords = records.map(record => record.id === updatedRecord.id ? updatedRecord : record);
  // 保存到持久化存储
  saveMedicalRecordsToStorage(updatedRecords);
  return updatedRecords;
}

// 从持久化存储加载医疗记录
export async function loadMedicalRecordsFromStorage(): Promise<MedicalRecord[]> {
  try {
    const records = await storageUtil.getMedicalRecords();
    if (records) {
      return records;
    }
    // 如果没有保存的记录，则返回默认记录
    return mockMedicalRecords;
  } catch (error) {
    console.error(`加载医疗记录失败: ${error}`);
    return mockMedicalRecords;
  }
}

// 保存医疗记录到持久化存储
export async function saveMedicalRecordsToStorage(records: MedicalRecord[]): Promise<void> {
  try {
    await storageUtil.saveMedicalRecords(records);
  } catch (error) {
    console.error(`保存医疗记录失败: ${error}`);
  }
}

// 清除持久化存储中的医疗记录
export async function clearMedicalRecordsStorage(): Promise<void> {
  try {
    await storageUtil.clearMedicalRecords();
  } catch (error) {
    console.error(`清除医疗记录失败: ${error}`);
  }
} 