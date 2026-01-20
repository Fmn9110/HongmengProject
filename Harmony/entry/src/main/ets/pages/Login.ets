import { Prompt, router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import http from '@ohos.net.http';
import { globalState } from '../component/HW_user';
import { ApiConfig, ApiParams } from '../config/ApiConfig';

// 定义响应数据类型
interface ApiResponse {
  JWTtoken: string | null;
  token: string | null;
  userId: number | null;
  refreshToken?: string;
  message: string;
}

// 定义验证码接口响应类型
interface SendCodeResponse {
  code: number;
  verificationCode?: string;
  message: string;
}

// 定义验证码验证接口响应类型
interface VerifyCodeResponse {
  code: number;
  message: string;
}

// 定义重置密码接口响应类型
interface ResetPasswordResponse {
  code: number;
  message: string;
}

// 定义检查手机号是否注册接口响应类型
interface CheckPhoneRegisteredResponse {
  isRegistered: boolean;
}

// 定义Token验证接口响应类型
interface VerifyTokenResponse {
  code: number;
  userId: number | null;
  message: string;
}

// 颜色常量
const DIVIDER_COLOR: ResourceColor = '#E8ECEF';
const PRIMARY_TEXT_COLOR: ResourceColor = '#1A1A1A';
const SECONDARY_TEXT_COLOR: ResourceColor = '#6B7280';
const ACCENT_COLOR: ResourceColor = '#2563EB';
const GAUGE_RED: ResourceColor = '#EF4444';
const LIGHT_BLUE: ResourceColor = '#ffffffff';
const BUTTON_COLOR: ResourceColor = '#10B981';

// 偏好存储初始化
const context = getContext(this) as common.UIAbilityContext;
const options: preferences.Options = { name: 'userInfo' };
const preference = preferences.getPreferencesSync(context, options);

@Entry
@Component
struct AuthPage {
  @State phoneFocused: boolean = false;
  @State codeFocused: boolean = false;
  @State passwordFocused: boolean = false;
  @State confirmPasswordFocused: boolean = false;
  @State newPasswordFocused: boolean = false;
  @State confirmNewPasswordFocused: boolean = false;
  @State selectedTab: string = 'login';
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State verificationCode: string = '';
  @State newPassword: string = '';
  @State confirmNewPassword: string = '';
  @State errorMessage: string = '';
  @State isPasswordVisible: boolean = false;
  @State buttonScale: number = 1;
  @State wechatButtonScale: number = 1;
  @State douyinButtonScale: number = 1;
  @State codeButtonText: string = '获取验证码';
  @State isCodeButtonDisabled: boolean = false;
  @State countdown: number = 60;
  @State notificationMessage: string = '';
  @State notificationOpacity: number = 0;
  @State notificationTranslateY: number = -50;
  @State isFlipped: boolean = false;
  @State dialogVisible: boolean = false;
  @State isLoading: boolean = true;
  @State isAgreementChecked: boolean = false; // 添加勾选框状态

  // 在页面加载前检查登录状态
  aboutToAppear() {
    this.checkAutoLogin();
  }

  // 检查是否已登录并尝试自动登录
  async checkAutoLogin(): Promise<void> {
    try {
      this.isLoading = true;
      const savedToken = preference.getSync('JWTtoken', '') as string;
      const savedUserId = preference.getSync('userId', '') as string;
      const savedPhone = preference.getSync('phone', '') as string;

      console.log('Checking auto login with token:', savedToken);

      if (savedToken && savedUserId) {
        const isValid = await this.verifyToken(savedToken);
        if (isValid) {
          globalState.JWTtoken = savedToken;
          globalState.userId = parseInt(savedUserId);
          globalState.phone = savedPhone;
          router.pushUrl({ url: 'pages/index/Index' });
        } else {
          preference.deleteSync('JWTtoken');
          preference.deleteSync('userId');
          preference.deleteSync('phone');
          preference.deleteSync('refreshToken');
          preference.flushSync();
          this.errorMessage = '登录状态已过期，请重新登录';
          Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        }
      }
    } catch (error) {
      console.error('Auto login failed:', JSON.stringify(error));
      router.pushUrl({ url: 'pages/index/Index', params: { isOffline: true } });
    } finally {
      this.isLoading = false;
    }
  }

  // 验证Token有效性
  async verifyToken(token: string): Promise<boolean> {
    try {
      console.log('Verifying token:', token);
      const httpRequest = http.createHttp();
      const responsePromise: Promise<http.HttpResponse> =
        httpRequest.request(ApiConfig.VERIFY_TOKEN, {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
          extraData: null
        });
      const response = await responsePromise;
      if (!response || typeof response.responseCode !== 'number' || typeof response.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const result: VerifyTokenResponse = JSON.parse(response.result);
      console.log('VerifyToken response:', JSON.stringify(result));
      httpRequest.destroy();
      if (response.responseCode === 200 && result.code === 200) {
        return true;
      } else if (result.message === 'Token expired') {
        const newToken = await this.refreshToken();
        if (newToken) {
          globalState.JWTtoken = newToken;
          return true;
        }
      }
      return false;
    } catch (error) {
      console.error('Token verification failed:', JSON.stringify(error));
      return false;
    }
  }

  // 刷新Token
  async refreshToken(): Promise<string | null> {
    try {
      const savedRefreshToken = preference.getSync('refreshToken', '') as string;
      if (!savedRefreshToken) {
        console.log('No refresh token available');
        return null;
      }

      console.log('Refreshing token with refreshToken:', savedRefreshToken);
      const httpRequest = http.createHttp();
      const responsePromise: Promise<http.HttpResponse> =
        httpRequest.request(ApiConfig.REFRESH_TOKEN, {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({ refreshToken: savedRefreshToken })
        });
      const response = await responsePromise;
      if (!response || typeof response.responseCode !== 'number' || typeof response.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const result: ApiResponse = JSON.parse(response.result);
      console.log('RefreshToken response:', JSON.stringify(result));
      httpRequest.destroy();
      if (response.responseCode === 200 && result.JWTtoken) {
        preference.putSync('JWTtoken', result.JWTtoken);
        preference.putSync('refreshToken', result.refreshToken || savedRefreshToken);
        preference.flushSync();
        return result.JWTtoken;
      }
      return null;
    } catch (error) {
      console.error('Token refresh failed:', JSON.stringify(error));
      return null;
    }
  }

  // 发送验证码并自动填充（用于注册）
  async handleSendCode(): Promise<void> {
    try {
      if (!this.phone) {
        Prompt.showToast({ message: '请输入手机号', duration: 2000 });
        return;
      }
      if (this.phone.length !== 11) {
        this.errorMessage = '手机号必须为11位';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        return;
      }
      const httpRequest = http.createHttp();
      const url = ApiConfig.buildUrlWithParams(ApiConfig.SEND_CODE, { 'phone': this.phone } as Record<string, string>);
      const responsePromise: Promise<http.HttpResponse> =
        httpRequest.request(url, {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        });
      const response = await responsePromise;
      if (!response || typeof response.responseCode !== 'number' || typeof response.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const result: SendCodeResponse = JSON.parse(response.result);
      if (response.responseCode === 200 && result.code === 200) {
        Prompt.showToast({ message: '验证码发送成功', duration: 2000 });
        if (result.verificationCode) {
          this.notificationMessage = `【慢宁康】注册验证码：${result.verificationCode}`;
          animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
            this.notificationOpacity = 1;
            this.notificationTranslateY = 0;
          });
          setTimeout(() => {
            animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
              this.notificationOpacity = 0;
              this.notificationTranslateY = -50;
            });
            setTimeout(() => {
              this.notificationMessage = '';
            }, 300);
          }, 10000);
        }
        this.isCodeButtonDisabled = true;
        this.countdown = 60;
        this.codeButtonText = `${this.countdown}秒后重试`;
        const interval = setInterval(() => {
          this.countdown--;
          this.codeButtonText = `${this.countdown}秒后重试`;
          if (this.countdown <= 0) {
            clearInterval(interval);
            this.isCodeButtonDisabled = false;
            this.codeButtonText = '获取验证码';
          }
        }, 1000);
      } else {
        this.errorMessage = result.message || '验证码发送失败';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
      }
      httpRequest.destroy();
    } catch (error) {
      this.errorMessage = '网络错误，请稍后重试';
      Prompt.showToast({ message: this.errorMessage, duration: 2000 });
    }
  }

  // 发送验证码并自动填充（用于密码重置）
  async handleSendCodeForReset(): Promise<void> {
    try {
      if (!this.phone) {
        Prompt.showToast({ message: '请输入手机号', duration: 2000 });
        return;
      }
      if (this.phone.length !== 11) {
        this.errorMessage = '手机号必须为11位';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        return;
      }
      const httpRequest = http.createHttp();
      const url = ApiConfig.buildUrlWithParams(ApiConfig.SEND_CODE, { 'phone': this.phone, 'type': 'reset' } as Record<string, string>);
      const responsePromise: Promise<http.HttpResponse> =
        httpRequest.request(url, {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        });
      const response = await responsePromise;
      if (!response || typeof response.responseCode !== 'number' || typeof response.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const result: SendCodeResponse = JSON.parse(response.result);
      if (response.responseCode === 200 && result.code === 200) {
        Prompt.showToast({ message: '验证码发送成功', duration: 2000 });
        if (result.verificationCode) {
          this.notificationMessage = `【慢宁康】重置密码验证码：${result.verificationCode}`;
          animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
            this.notificationOpacity = 1;
            this.notificationTranslateY = 0;
          });
          setTimeout(() => {
            animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
              this.notificationOpacity = 0;
              this.notificationTranslateY = -50;
            });
            setTimeout(() => {
              this.notificationMessage = '';
            }, 300);
          }, 10000);
        }
        this.isCodeButtonDisabled = true;
        this.countdown = 60;
        this.codeButtonText = `${this.countdown}秒后重试`;
        const interval = setInterval(() => {
          this.countdown--;
          this.codeButtonText = `${this.countdown}秒后重试`;
          if (this.countdown <= 0) {
            clearInterval(interval);
            this.isCodeButtonDisabled = false;
            this.codeButtonText = '获取验证码';
          }
        }, 1000);
      } else {
        this.errorMessage = result.message || '验证码发送失败';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
      }
      httpRequest.destroy();
    } catch (error) {
      this.errorMessage = '网络错误，请稍后重试';
      Prompt.showToast({ message: this.errorMessage, duration: 2000 });
    }
  }

  // 复制验证码（填充输入框）
  fillVerificationCode(): void {
    if (this.notificationMessage) {
      const code = this.notificationMessage.replace(/【慢宁康】(注册|重置密码)验证码：/, '').trim();
      this.verificationCode = code;
      Prompt.showToast({ message: '验证码已填充，请确认', duration: 2000 });
    }
  }

  // 验证验证码
  async verifyCode(): Promise<boolean> {
    try {
      if (!this.verificationCode) {
        this.errorMessage = '请输入验证码';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        return false;
      }
      const httpRequest = http.createHttp();
      const responsePromise: Promise<http.HttpResponse> = httpRequest.request(ApiConfig.VERIFY_CODE, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ phone: this.phone, code: this.verificationCode })
      });
      const response = await responsePromise;
      if (!response || typeof response.responseCode !== 'number' || typeof response.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const result: VerifyCodeResponse = JSON.parse(response.result);
      if (response.responseCode === 200 && result.code === 200) {
        return true;
      } else {
        this.errorMessage = result.message || '验证码验证失败';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        return false;
      }
    } catch (error) {
      this.errorMessage = '网络错误，请稍后重试';
      Prompt.showToast({ message: this.errorMessage, duration: 2000 });
      return false;
    }
  }

  // 处理登录
  async handleLogin(): Promise<void> {
    try {
      console.log('Login attempt with phone:', this.phone);
      if (!this.phone || !this.password) {
        Prompt.showToast({ message: '手机号或密码不能为空', duration: 2000 });
        return;
      }
      if (this.phone.length !== 11) {
        this.errorMessage = '手机号必须为11位';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        return;
      }
      const httpRequest = http.createHttp();
      const responsePromise: Promise<http.HttpResponse> = httpRequest.request(ApiConfig.LOGIN, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ phone: this.phone, password: this.password })
      });
      const response = await responsePromise;
      if (!response || typeof response.responseCode !== 'number' || typeof response.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const result: ApiResponse = JSON.parse(response.result);
      console.log('Login response:', JSON.stringify(result));
      if (response.responseCode === 200) {
        globalState.userId = result.userId;
        globalState.JWTtoken = result.JWTtoken;
        if (!result.JWTtoken) {
          this.errorMessage = '登录成功，但未获取到有效 Token';
          Prompt.showToast({ message: this.errorMessage, duration: 2000 });
          return;
        }
        preference.putSync('phone', this.phone.toString());
        preference.putSync('JWTtoken', result.JWTtoken);
        preference.putSync('userId', result.userId?.toString() || '');
        preference.putSync('refreshToken', result.refreshToken || '');
        preference.flushSync();
        router.pushUrl({ url: 'pages/index/Index' });
      } else {
        this.errorMessage = result.message || '登录失败';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
      }
      httpRequest.destroy();
    } catch (error) {
      this.errorMessage = '网络错误，请稍后重试';
      Prompt.showToast({ message: this.errorMessage, duration: 2000 });
    }
  }

  // 处理注册
  async handleRegister(): Promise<void> {
    try {
      if (!this.phone || !this.password || !this.confirmPassword || !this.verificationCode) {
        Prompt.showToast({ message: '请填写所有字段', duration: 2000 });
        return;
      }
      if (this.phone.length !== 11) {
        this.errorMessage = '手机号必须为11位';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        return;
      }
      if (this.password !== this.confirmPassword) {
        Prompt.showToast({ message: '两次输入的密码不一致', duration: 2000 });
        return;
      }
      const isCodeValid = await this.verifyCode();
      if (!isCodeValid) {
        return;
      }
      const httpRequest = http.createHttp();
      const responsePromise: Promise<http.HttpResponse> = httpRequest.request(ApiConfig.REGISTER, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({
          phone: this.phone,
          password: this.password,
          verificationCode: this.verificationCode
        })
      });
      const response = await responsePromise;
      if (!response || typeof response.responseCode !== 'number' || typeof response.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const result: ApiResponse = JSON.parse(response.result);
      if (response.responseCode === 200) {
        Prompt.showToast({ message: '注册成功，请登录', duration: 2000 });
        this.selectedTab = 'login';
        const registeredPhone = this.phone;
        this.phone = registeredPhone;
        this.password = '';
        this.confirmPassword = '';
        this.verificationCode = '';
        this.errorMessage = '';
      } else {
        this.errorMessage = result.message || '注册失败';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
      }
      httpRequest.destroy();
    } catch (error) {
      this.errorMessage = '网络错误，请稍后重试';
      Prompt.showToast({ message: this.errorMessage, duration: 2000 });
    }
  }

  // 处理重置密码
  async handleResetPassword(): Promise<void> {
    try {
      if (!this.phone || !this.verificationCode || !this.newPassword || !this.confirmNewPassword) {
        Prompt.showToast({ message: '请填写所有字段', duration: 2000 });
        return;
      }
      if (this.phone.length !== 11) {
        this.errorMessage = '手机号必须为11位';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        return;
      }
      if (this.newPassword !== this.confirmNewPassword) {
        Prompt.showToast({ message: '两次输入的新密码不一致', duration: 2000 });
        return;
      }

      // 检查手机号是否已注册
      const httpRequest = http.createHttp();
      const url = ApiConfig.buildUrlWithParams(ApiConfig.CHECK_PHONE_REGISTERED, { 'phone': this.phone } as Record<string, string>);
      const checkResponsePromise: Promise<http.HttpResponse> =
        httpRequest.request(url, {
          method: http.RequestMethod.GET,
          header: { 'Content-Type': 'application/json' }
        });
      const checkResponse = await checkResponsePromise;
      if (!checkResponse || typeof checkResponse.responseCode !== 'number' ||
        typeof checkResponse.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const checkResult: CheckPhoneRegisteredResponse = JSON.parse(checkResponse.result);
      if (checkResponse.responseCode !== 200 || !checkResult.isRegistered) {
        this.errorMessage = '该账号未注册，请前往注册';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
        return;
      }

      // 验证验证码
      const isCodeValid = await this.verifyCode();
      if (!isCodeValid) {
        return;
      }

      // 重置密码
      const resetResponsePromise: Promise<http.HttpResponse> =
        httpRequest.request(ApiConfig.RESET_PASSWORD, {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify({
            phone: this.phone,
            verificationCode: this.verificationCode,
            newPassword: this.newPassword
          })
        });
      const resetResponse = await resetResponsePromise;
      if (!resetResponse || typeof resetResponse.responseCode !== 'number' ||
        typeof resetResponse.result !== 'string') {
        throw new Error('Invalid HTTP response');
      }
      const resetResult: ResetPasswordResponse = JSON.parse(resetResponse.result);
      if (resetResponse.responseCode === 200 && resetResult.code === 200) {
        Prompt.showToast({ message: '重置成功', duration: 2000 });
        this.flipBackToLogin();
      } else {
        this.errorMessage = resetResult.message || '重置失败';
        Prompt.showToast({ message: this.errorMessage, duration: 2000 });
      }
      httpRequest.destroy();
    } catch (error) {
      this.errorMessage = '网络错误，请稍后重试';
      Prompt.showToast({ message: this.errorMessage, duration: 2000 });
    }
  }

  // 翻转到找回密码页面
  flipToForgotPassword(): void {
    animateTo({ duration: 500, curve: Curve.EaseInOut }, () => {
      this.isFlipped = true;
    });
  }

  // 翻回登录注册页面
  flipBackToLogin(): void {
    animateTo({ duration: 500, curve: Curve.EaseInOut }, () => {
      this.isFlipped = false;
      this.phone = '';
      this.verificationCode = '';
      this.newPassword = '';
      this.confirmNewPassword = '';
      this.errorMessage = '';
      this.selectedTab = 'login';
    });
  }

  // 显示确认对话框
  showConfirmDialog(): void {
    this.dialogVisible = true;
  }

  // 隐藏确认对话框
  hideConfirmDialog(): void {
    this.dialogVisible = false;
  }

  build() {
    Stack() {
      if (this.isLoading) {
        Column() {
          Text('正在验证登录状态...')
            .fontSize(16)
            .fontColor(SECONDARY_TEXT_COLOR)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          Column() {
            // 背景图片及文字层
            Column()
              .width('100%')
              .height('35%')
              .backgroundImage($r('app.media.avatar_background'))// 使用资源引用，替换为实际资源ID
              .backgroundImageSize(ImageSize.Cover)
              .backgroundImagePosition(Alignment.Center)
              .alignItems(HorizontalAlign.Center)// 确保内容居中
              .justifyContent(FlexAlign.Center)// 垂直居中
              .position({ top: 0 })// 固定在顶部
              .overlay() // 创建覆盖层
            Row() {
              Text('  Hello!')
                .fontSize(28)
                .fontColor('#ff3e3d3d')
                .fontWeight(FontWeight.Bold)
                .margin({ top: 130, bottom: 5 }) // 调整与下方内容的间距
            }
            .width('90%')
            .justifyContent(FlexAlign.Start)

            Row() {
              Text('  欢迎使用慢宁康')
                .fontSize(26)
                .fontColor('#ff3e3d3d')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 35 }) // 调整与下方内容的间距
            }
            .width('90%')
            .justifyContent(FlexAlign.Start)


            if (this.isFlipped) {
              Column() {
                Row() {
                  Text('找回密码')
                    .fontSize(20)
                    .fontColor('#007AFF')
                    .fontWeight(FontWeight.Bold)
                }
                .borderRadius(15)
                .width('90%')
                .height(40)
                .backgroundColor(Color.White)
                .justifyContent(FlexAlign.Center)

                Column() {
                  Row() {
                    Text('手机号')
                      .fontSize(14)
                      .fontColor(SECONDARY_TEXT_COLOR)
                      .fontWeight(FontWeight.Medium)
                    TextInput({ placeholder: '请输入您的手机号', text: this.phone })
                      .fontSize(16)
                      .fontColor(PRIMARY_TEXT_COLOR)
                      .backgroundColor(Color.Transparent)
                      .width('80%')// 与按钮等宽
                      .margin({ left: 29 })
                      .padding({ top: 10, bottom: 10 })
                      .border({ width: 1, color: this.phoneFocused ? ACCENT_COLOR : DIVIDER_COLOR, radius: 8 })
                      .onChange((value: string) => {
                        this.phone = value;
                        this.errorMessage = '';
                      })
                      .onFocus(() => {
                        this.phoneFocused = true;
                      })
                      .onBlur(() => {
                        this.phoneFocused = false;
                      })
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })

                  Divider()
                    .strokeWidth(1)
                    .color(DIVIDER_COLOR)

                  Row() {
                    Text('验证码')
                      .fontSize(14)
                      .fontColor(SECONDARY_TEXT_COLOR)
                      .fontWeight(FontWeight.Medium)
                    TextInput({ placeholder: '请输入验证码', text: this.verificationCode })
                      .fontSize(16)
                      .fontColor(PRIMARY_TEXT_COLOR)
                      .backgroundColor(Color.Transparent)
                      .width('45%')// 调整宽度以适应按钮
                      .margin({ left: 29 })
                      .padding({ top: 10, bottom: 10 })
                      .border({ width: 1, color: this.codeFocused ? ACCENT_COLOR : DIVIDER_COLOR, radius: 8 })
                      .onChange((value: string) => {
                        this.verificationCode = value;
                        this.errorMessage = '';
                      })
                      .onFocus(() => {
                        this.codeFocused = true;
                      })
                      .onBlur(() => {
                        this.codeFocused = false;
                      })
                    Button(this.codeButtonText, { type: ButtonType.Normal })
                      .height(36)
                      .width('32%')// 调整按钮宽度
                      .margin({ left: 10 })
                      .backgroundColor(this.isCodeButtonDisabled ? SECONDARY_TEXT_COLOR : ACCENT_COLOR)
                      .borderRadius(8)
                      .fontSize(12)
                      .fontColor(Color.White)
                      .stateEffect(!this.isCodeButtonDisabled)
                      .onClick(() => {
                        if (!this.isCodeButtonDisabled) {
                          this.handleSendCodeForReset();
                        }
                      })
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })

                  Divider()
                    .strokeWidth(1)
                    .color(DIVIDER_COLOR)

                  Row() {
                    Text('新密码')
                      .fontSize(14)
                      .fontColor(SECONDARY_TEXT_COLOR)
                      .fontWeight(FontWeight.Medium)
                    TextInput({ placeholder: '请输入新密码', text: this.newPassword })
                      .fontSize(16)
                      .fontColor(PRIMARY_TEXT_COLOR)
                      .backgroundColor(Color.Transparent)
                      .width('80%')// 与按钮等宽
                      .margin({ left: 29 })
                      .padding({ top: 10, bottom: 10 })
                      .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                      .border({ width: 1, color: this.newPasswordFocused ? ACCENT_COLOR : DIVIDER_COLOR, radius: 8 })
                      .onChange((value: string) => {
                        this.newPassword = value;
                        this.errorMessage = '';
                      })
                      .onFocus(() => {
                        this.newPasswordFocused = true;
                      })
                      .onBlur(() => {
                        this.newPasswordFocused = false;
                      })
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })

                  Divider()
                    .strokeWidth(1)
                    .color(DIVIDER_COLOR)

                  Row() {
                    Text('确认新密码')
                      .fontSize(14)
                      .fontColor(SECONDARY_TEXT_COLOR)
                      .fontWeight(FontWeight.Medium)
                    TextInput({ placeholder: '请再次输入新密码', text: this.confirmNewPassword })
                      .fontSize(16)
                      .fontColor(PRIMARY_TEXT_COLOR)
                      .backgroundColor(Color.Transparent)
                      .width('75%')// 与按钮等宽
                      .margin({ left: 16 })
                      .padding({ top: 10, bottom: 10, left: 10 })
                      .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                      .border({
                        width: 1,
                        color: this.confirmNewPasswordFocused ? ACCENT_COLOR : DIVIDER_COLOR,
                        radius: 8
                      })
                      .onChange((value: string) => {
                        this.confirmNewPassword = value;
                        this.errorMessage = '';
                      })
                      .onFocus(() => {
                        this.confirmNewPasswordFocused = true;
                      })
                      .onBlur(() => {
                        this.confirmNewPasswordFocused = false;
                      })
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })

                  Divider()
                    .strokeWidth(1)
                    .color(DIVIDER_COLOR)

                  Row() {
                    Text('返回登录/注册')
                      .fontSize(14)
                      .fontColor(ACCENT_COLOR)
                      .margin({ top: 12 })
                      .onClick(() => {
                        this.flipBackToLogin();
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)

                  if (this.errorMessage !== '') {
                    Text(this.errorMessage)
                      .fontSize(14)
                      .fontColor(GAUGE_RED)
                      .margin({ top: 12 })
                      .animation({
                        duration: 300,
                        curve: Curve.EaseInOut,
                        playMode: PlayMode.Normal
                      })
                  }

                  Button('确定重置密码', { type: ButtonType.Normal })
                    .height(52)
                    .width('100%')// 与输入框等宽
                    .margin({ top: 12, bottom: 35 })// 增加底部边距，与登录页面一致
                    .backgroundColor('#007AFF')
                    .borderRadius(15)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                    .scale({ x: this.buttonScale, y: this.buttonScale })
                    .onClick(() => {
                      this.handleResetPassword();
                    })
                    .onTouch((event: TouchEvent) => {
                      if (event.type === TouchType.Down) {
                        this.buttonScale = 0.95;
                      } else if (event.type === TouchType.Up) {
                        this.buttonScale = 1;
                      }
                    })
                }
                .width('80%')
                .padding(5)
                .backgroundColor(Color.White)
                .borderRadius(16)
                .shadow({ radius: 12, color: '#00000015' })
                .margin({ top: 10 })
                .animation({
                  duration: 500,
                  curve: Curve.EaseInOut,
                  playMode: PlayMode.Normal
                })
              }

            } else {
              Column() {
                Row() {
                  Column() {
                    Column() {
                      Text('登录')
                        .fontSize(18)
                        .fontColor(this.selectedTab === 'login' ? '#007AFF' : '#666666')
                        .fontWeight(this.selectedTab === 'login' ? FontWeight.Bold : FontWeight.Normal)
                        .animation({ duration: 300, curve: Curve.EaseInOut })
                      Divider()
                        .strokeWidth(2)
                        .color(this.selectedTab === 'login' ? '#007AFF' : Color.Transparent)
                        .width('50%')
                        .margin({ top: 2 })
                    }
                    .width('100%')
                    .height('100%')
                    .alignItems(HorizontalAlign.Center)
                    .padding({ top: 12, bottom: 8 })
                    .backgroundColor(this.selectedTab === 'login' ? Color.White : '#E6F0FF')
                    .borderRadius(16)
                    .shadow({
                      radius: 8,
                      offsetX: 0,
                      offsetY: 4,
                      color: '#00000030'
                    })
                    .zIndex(this.selectedTab === 'login' ? 2 : 1)
                    .onClick(() => {
                      this.selectedTab = 'login';
                      this.errorMessage = '';
                      this.password = '';
                      this.confirmPassword = '';
                      this.verificationCode = '';
                    })
                  }
                  .width('52%')
                  .height('100%')
                  .alignItems(HorizontalAlign.Center)
                  .margin({ right: -8 })

                  Column() {
                    Column() {
                      Text('注册')
                        .fontSize(18)
                        .fontColor(this.selectedTab === 'register' ? '#007AFF' : '#666666')
                        .fontWeight(this.selectedTab === 'register' ? FontWeight.Bold : FontWeight.Normal)
                        .animation({ duration: 300, curve: Curve.EaseInOut })
                      Divider()
                        .strokeWidth(2)
                        .color(this.selectedTab === 'register' ? '#007AFF' : Color.Transparent)
                        .width('50%')
                        .margin({ top: 2 })
                    }
                    .width('100%')
                    .height('100%')
                    .alignItems(HorizontalAlign.Center)
                    .padding({ top: 12, bottom: 8 })
                    .backgroundColor(this.selectedTab === 'register' ? Color.White : '#E6F0FF')
                    .borderRadius(16)
                    .shadow({
                      radius: 8,
                      offsetX: 0,
                      offsetY: 4,
                      color: '#00000030'
                    })
                    .zIndex(this.selectedTab === 'register' ? 2 : 1)
                    .onClick(() => {
                      this.selectedTab = 'register';
                      this.errorMessage = '';
                      this.password = '';
                      this.confirmPassword = '';
                      this.verificationCode = '';
                    })
                  }
                  .width('52%')
                  .height('100%')
                  .alignItems(HorizontalAlign.Center)
                  .margin({ left: -8 })
                }
                .borderRadius(16)
                .width('90%')
                .height(45)
                .backgroundColor(Color.White)
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ top: 10 }) // 调整与背景图片的间距

                Column() {
                  Row() {
                    Text('手机号')
                      .fontSize(14)
                      .fontColor(SECONDARY_TEXT_COLOR)
                      .fontWeight(FontWeight.Medium)
                    TextInput({ placeholder: '请输入您的手机号', text: this.phone })
                      .fontSize(16)
                      .fontColor(PRIMARY_TEXT_COLOR)
                      .backgroundColor(Color.Transparent)
                      .width('80%')// 与按钮等宽
                      .margin({ left: 16 })
                      .padding({ top: 10, bottom: 10 })
                      .border({ width: 1, color: this.phoneFocused ? ACCENT_COLOR : DIVIDER_COLOR, radius: 8 })
                      .onChange((value: string) => {
                        this.phone = value;
                        this.errorMessage = '';
                      })
                      .onFocus(() => {
                        this.phoneFocused = true;
                      })
                      .onBlur(() => {
                        this.phoneFocused = false;
                      })
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })

                  Divider()
                    .strokeWidth(1)
                    .color(DIVIDER_COLOR)

                  if (this.selectedTab === 'register') {
                    Column() {
                      Row() {
                        Text('验证码')
                          .fontSize(14)
                          .fontColor(SECONDARY_TEXT_COLOR)
                          .fontWeight(FontWeight.Medium)
                        TextInput({ placeholder: '请输入验证码', text: this.verificationCode })
                          .fontSize(16)
                          .fontColor(PRIMARY_TEXT_COLOR)
                          .backgroundColor(Color.Transparent)
                          .width('45%')// 调整宽度以适应按钮
                          .margin({ left: 16 })
                          .padding({ top: 10, bottom: 10 })
                          .border({ width: 1, color: this.codeFocused ? ACCENT_COLOR : DIVIDER_COLOR, radius: 8 })
                          .onChange((value: string) => {
                            this.verificationCode = value;
                            this.errorMessage = '';
                          })
                          .onFocus(() => {
                            this.codeFocused = true;
                          })
                          .onBlur(() => {
                            this.codeFocused = false;
                          })
                        Button(this.codeButtonText, { type: ButtonType.Normal })
                          .height(36)
                          .width('32%')// 调整按钮宽度
                          .margin({ left: 10 })
                          .backgroundColor(this.isCodeButtonDisabled ? SECONDARY_TEXT_COLOR : ACCENT_COLOR)
                          .borderRadius(8)
                          .fontSize(12)
                          .fontColor(Color.White)
                          .stateEffect(!this.isCodeButtonDisabled)
                          .onClick(() => {
                            if (!this.isCodeButtonDisabled) {
                              this.handleSendCode();
                            }
                          })
                      }
                      .width('100%')
                      .padding({ top: 8, bottom: 8 })

                      Divider()
                        .strokeWidth(1)
                        .color(DIVIDER_COLOR)
                    }
                  }

                  Column() {
                    Row() {
                      Text('密码')
                        .fontSize(14)
                        .fontColor(SECONDARY_TEXT_COLOR)
                        .fontWeight(FontWeight.Medium)
                      TextInput({ placeholder: '请输入密码', text: this.password })
                        .fontSize(16)
                        .fontColor(PRIMARY_TEXT_COLOR)
                        .backgroundColor(Color.Transparent)
                        .width('80%')// 与按钮等宽
                        .margin({ left: 29 })
                        .padding({ top: 10, bottom: 10 })
                        .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                        .border({ width: 1, color: this.passwordFocused ? ACCENT_COLOR : DIVIDER_COLOR, radius: 8 })
                        .onChange((value: string) => {
                          this.password = value;
                          this.errorMessage = '';
                        })
                        .onFocus(() => {
                          this.passwordFocused = true;
                        })
                        .onBlur(() => {
                          this.passwordFocused = false;
                        })
                        .key('passwordInput-' + this.selectedTab)
                    }
                    .width('100%')
                    .padding({ top: 8, bottom: 8 })

                    Divider()
                      .strokeWidth(1)
                      .color(DIVIDER_COLOR)
                  }

                  if (this.selectedTab === 'register') {
                    Column() {
                      Row() {
                        Text('确认密码')
                          .fontSize(14)
                          .fontColor(SECONDARY_TEXT_COLOR)
                          .fontWeight(FontWeight.Medium)
                        TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
                          .fontSize(16)
                          .fontColor(PRIMARY_TEXT_COLOR)
                          .backgroundColor(Color.Transparent)
                          .width('75%')// 与按钮等宽
                          .margin({ left: 16 })
                          .padding({ top: 10, bottom: 10, left: 10 })
                          .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                          .border({
                            width: 1,
                            color: this.confirmPasswordFocused ? ACCENT_COLOR : DIVIDER_COLOR,
                            radius: 8
                          })
                          .onChange((value: string) => {
                            this.confirmPassword = value;
                            this.errorMessage = '';
                          })
                          .onFocus(() => {
                            this.confirmPasswordFocused = true;
                          })
                          .onBlur(() => {
                            this.confirmPasswordFocused = false;
                          })
                          .key('confirmPasswordInput-' + this.selectedTab)
                      }
                      .width('100%')
                      .padding({ top: 8, bottom: 8 })

                      Divider()
                        .strokeWidth(1)
                        .color(DIVIDER_COLOR)
                    }
                  }

                  if (this.errorMessage !== '') {
                    Text(this.errorMessage)
                      .fontSize(14)
                      .fontColor(GAUGE_RED)
                      .margin({ top: 12 })
                      .animation({
                        duration: 300,
                        curve: Curve.EaseInOut,
                        playMode: PlayMode.Normal
                      })
                  }

                  if (this.selectedTab === 'login') {
                    Row() {
                      Text('找回密码')
                        .fontSize(14)
                        .fontColor('#007AFF')
                        .margin({ top: 12 })
                        .onClick(() => {
                          this.flipToForgotPassword();
                        })
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.End)
                  }

                  // 登录/注册按钮
                  Button(this.selectedTab === 'login' ? '登录' : '注册', { type: ButtonType.Normal })
                    .height(51)
                    .width('100%')// 与输入框等宽
                    .margin({ top: 12 })
                    .backgroundColor('#007AFF')// 设置背景颜色为 #007AFF
                    .borderRadius(15)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                    .scale({ x: this.buttonScale, y: this.buttonScale })
                    .enabled(this.isAgreementChecked)// 只有勾选后启用
                    .onClick(() => {
                      if (this.selectedTab === 'login') {
                        this.handleLogin();
                      } else {
                        this.handleRegister();
                      }
                    })
                    .onTouch((event: TouchEvent) => {
                      if (event.type === TouchType.Down) {
                        this.buttonScale = 0.95;
                      } else if (event.type === TouchType.Up) {
                        this.buttonScale = 1;
                      }
                    })
                }
                .width('90%')
                .padding(24)
                .backgroundColor(Color.White)
                .borderRadius(16)
                .shadow({ radius: 12, color: '#00000015' })
                .margin({ top: 10 })
                .animation({
                  duration: 500,
                  curve: Curve.EaseInOut,
                  playMode: PlayMode.Normal
                })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center)
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)

          // 勾选框仅在登录和注册页面显示
          if (!this.isFlipped) {
            Row() {
              Checkbox()
                .select(this.isAgreementChecked)
                .onChange((isChecked: boolean) => {
                  this.isAgreementChecked = isChecked;
                })
              Text('我已阅读并同意')
                .fontSize(14)
                .fontColor(SECONDARY_TEXT_COLOR)
                .margin({ left: 8 })
              Text('《用户协议》')
                .fontSize(14)
                .fontColor('#007AFF') // 超链接颜色
              Text('和')
                .fontSize(14)
                .fontColor(SECONDARY_TEXT_COLOR)
              Text('《隐私政策》')
                .fontSize(14)
                .fontColor('#007AFF') // 超链接颜色
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 55 })
          }

          if (this.notificationMessage !== '') {
            Row() {
              Text(this.notificationMessage)
                .fontSize(15)
                .fontColor(PRIMARY_TEXT_COLOR)
                .fontWeight(FontWeight.Medium)
                .margin({ left: 16 })
              Blank()
              Button('自动填充')
                .height(24)
                .fontSize(14)
                .backgroundColor(ACCENT_COLOR)
                .fontColor(Color.White)
                .borderRadius(4)
                .padding({ left: 8, right: 8 })
                .margin({ right: 8 })
                .onClick(() => {
                  this.fillVerificationCode();
                })
              Text('✕')
                .fontSize(15)
                .fontColor(SECONDARY_TEXT_COLOR)
                .margin({ right: 16 })
                .onClick(() => {
                  animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
                    this.notificationOpacity = 0;
                    this.notificationTranslateY = -50;
                  });
                  setTimeout(() => {
                    this.notificationMessage = '';
                  }, 300);
                })
            }
            .width('100%')
            .padding({ top: 40, bottom: 12 })
            .backgroundColor('#E6F0FA')
            .borderRadius(8)
            .shadow({ radius: 8, color: '#00000020' })
            .alignItems(VerticalAlign.Center)
            .position({ top: 0 })
            .opacity(this.notificationOpacity)
            .translate({ y: this.notificationTranslateY })
            .zIndex(100)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(LIGHT_BLUE)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')

  }
}