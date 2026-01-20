// 华为IAM用户认证对象
export default class HW_User {
  auth: Auth;

  constructor(name: string, password: string, domain: string) {
    // 构造IAM认证请求体
    this.auth = {
      identity: {
        methods: ["password"],
        password: {
          user: {
            name: name,
            password: password,
            domain: {
              name: domain
            }
          }
        }
      },
      scope: {
        domain: {
          name: domain
        }
      }
    };
  }
}

// 认证相关接口类型
interface Auth {
  identity: Identity;
  scope: Scope;
}

interface Identity {
  methods: string[];
  password: Password;
}

interface User {
  name: string;
  password: string;
  domain: Domain;
}

interface Password {
  user: User;
}

interface Domain {
  name: string;
}

interface Scope {
  domain: Domain;
}

interface DeviceProperties {
  HeartRate: string;
  Temperature: string;
  BloodOxygen: string;
  RespiratoryRate: string;
  State: string;
}

// 全局状态管理（单例模式）
export class GlobalState {
  onIsVipChange(arg0: (isVip: any) => void): () => void {
    throw new Error('Method not implemented.');
  }

  private static instance: GlobalState;
  private _deviceProperties: DeviceProperties;
  private _userId: number | null;
  private _JWTtoken: string | null;
  token: string;
  phone: string;
  isVip: boolean;

  private constructor() {
    this._deviceProperties = {
      HeartRate: '',
      Temperature: '',
      BloodOxygen: '',
      RespiratoryRate: '',
      State: ''
    };
    this._userId = null;
    this._JWTtoken = null;
    this.token = '';
    this.phone = '';
    console.log('GlobalState constructor called:', new Date().toISOString());
  }

  public static getInstance(): GlobalState {
    if (!GlobalState.instance) {
      GlobalState.instance = new GlobalState();
      console.log('GlobalState initialized:', GlobalState.instance);
    }
    return GlobalState.instance;
  }

  get deviceProperties(): DeviceProperties {
    return this._deviceProperties;
  }

  set deviceProperties(value: DeviceProperties) {
    this._deviceProperties = value;
  }

  get userId(): number | null {
    return this._userId;
  }

  set userId(value: number | null) {
    this._userId = value;
  }

  get JWTtoken(): string | null {
    return this._JWTtoken;
  }

  set JWTtoken(value: string | null) {
    this._JWTtoken = value;
  }

  // 清除用户数据
  public clearUserData(): void {
    // 重置用户状态
    this._userId = null;
    this._JWTtoken = null;
    this.token = '';
    this.phone = '';
    
    console.log('用户状态已重置');
  }
}

// 导出全局状态单例
export const globalState = GlobalState.getInstance();
