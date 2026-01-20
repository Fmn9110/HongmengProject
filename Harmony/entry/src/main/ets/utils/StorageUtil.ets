import preferences from '@ohos.data.preferences';
import { MedicalRecord } from '../pages/childpages/medicalhistorypage/MedicalHistoryModel';

// 存储键名常量
const PREFERENCES_NAME = 'health_data';
const MEDICAL_RECORDS_KEY = 'medical_records';

/**
 * 存储工具类，用于实现数据的持久化存储
 */
export class StorageUtil {
  private static instance: StorageUtil;
  private preferences: preferences.Preferences | null = null;

  /**
   * 获取单例实例
   */
  public static getInstance(): StorageUtil {
    if (!StorageUtil.instance) {
      StorageUtil.instance = new StorageUtil();
    }
    return StorageUtil.instance;
  }

  /**
   * 初始化存储
   */
  public async init(): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(getContext(), PREFERENCES_NAME);
      console.info('StorageUtil: 初始化存储成功');
    } catch (error) {
      console.error(`StorageUtil: 初始化存储失败: ${error}`);
    }
  }

  /**
   * 保存医疗记录
   * @param records 医疗记录数组
   */
  public async saveMedicalRecords(records: MedicalRecord[]): Promise<boolean> {
    if (!this.preferences) {
      await this.init();
    }
    
    try {
      const jsonString = JSON.stringify(records);
      await this.preferences?.put(MEDICAL_RECORDS_KEY, jsonString);
      await this.preferences?.flush();
      console.info('StorageUtil: 保存医疗记录成功');
      return true;
    } catch (error) {
      console.error(`StorageUtil: 保存医疗记录失败: ${error}`);
      return false;
    }
  }

  /**
   * 获取医疗记录
   * @returns 医疗记录数组，如果没有记录则返回null
   */
  public async getMedicalRecords(): Promise<MedicalRecord[] | null> {
    if (!this.preferences) {
      await this.init();
    }
    
    try {
      const jsonString = await this.preferences?.get(MEDICAL_RECORDS_KEY, '');
      if (jsonString && typeof jsonString === 'string' && jsonString !== '') {
        const records = JSON.parse(jsonString) as MedicalRecord[];
        console.info('StorageUtil: 获取医疗记录成功');
        return records;
      }
      return null;
    } catch (error) {
      console.error(`StorageUtil: 获取医疗记录失败: ${error}`);
      return null;
    }
  }

  /**
   * 清除所有医疗记录
   */
  public async clearMedicalRecords(): Promise<boolean> {
    if (!this.preferences) {
      await this.init();
    }
    
    try {
      await this.preferences?.delete(MEDICAL_RECORDS_KEY);
      await this.preferences?.flush();
      console.info('StorageUtil: 清除医疗记录成功');
      return true;
    } catch (error) {
      console.error(`StorageUtil: 清除医疗记录失败: ${error}`);
      return false;
    }
  }
}

export default StorageUtil.getInstance(); 