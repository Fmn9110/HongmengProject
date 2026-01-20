import { router, Prompt } from '@kit.ArkUI';
import { preferences } from "@kit.ArkData";
import { common } from "@kit.AbilityKit";
import bundleManager from '@ohos.bundle.bundleManager';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';

// 定义颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const BACKGROUND_COLOR: ResourceColor = '#F5F5F5';
const DIVIDER_COLOR: ResourceColor = '#E5E5E5';

// 权限项接口
interface PermissionItem {
  name: string;
  description: string;
  icon: Resource;
  permissionName: string;
  granted: boolean;
}

@Entry
@Component
export default struct SysPermissionPage {
  @State permissions: PermissionItem[] = [];
  @State overscrollOffset: number = 0;
  @State isLoading: boolean = true;
  // 存储权限设置的preferences实例
  private context = getContext(this) as common.UIAbilityContext;
  private options: preferences.Options = { name: 'permission_data' };
  private preference = preferences.getPreferencesSync(this.context, this.options);

  aboutToAppear() {
    // 初始化权限数据
    this.initPermissionData();
    // 获取实际权限状态
    this.checkPermissionStatus();
  }

  // 初始化权限数据
  private initPermissionData() {
    // 从本地存储加载权限数据，如果没有则使用默认数据
    const savedPermissions = this.preference.getSync('permissions', JSON.stringify([])) as string;

    try {
      const parsedPermissions = JSON.parse(savedPermissions) as PermissionItem[];

      if (parsedPermissions.length > 0) {
        this.permissions = parsedPermissions;
      } else {
        // 默认权限数据
        this.permissions = [
          {
            name: '位置信息',
            description: '允许应用获取您的位置信息',
            icon: $r('app.media.device'),
            permissionName: 'ohos.permission.LOCATION',
            granted: false
          },
          {
            name: '相机',
            description: '允许应用使用相机拍照',
            icon: $r('app.media.device'),
            permissionName: 'ohos.permission.CAMERA',
            granted: false
          },
          {
            name: '存储',
            description: '允许应用读写设备存储',
            icon: $r('app.media.device'),
            permissionName: 'ohos.permission.READ_MEDIA',
            granted: false
          },
          {
            name: '麦克风',
            description: '允许应用使用麦克风录音',
            icon: $r('app.media.device'),
            permissionName: 'ohos.permission.MICROPHONE',
            granted: false
          },
          {
            name: '通讯录',
            description: '允许应用访问通讯录',
            icon: $r('app.media.device'),
            permissionName: 'ohos.permission.READ_CONTACTS',
            granted: false
          },
          {
            name: '日历',
            description: '允许应用读写日历',
            icon: $r('app.media.device'),
            permissionName: 'ohos.permission.READ_CALENDAR',
            granted: false
          },
          {
            name: '健康数据',
            description: '允许应用访问健康数据',
            icon: $r('app.media.device'),
            permissionName: 'ohos.permission.ACTIVITY_MOTION',
            granted: false
          }
        ];
      }
    } catch (error) {
      console.error('加载权限数据失败:', error);
      // 默认权限数据
      this.permissions = [
        {
          name: '位置信息',
          description: '允许应用获取您的位置信息',
          icon: $r('app.media.device'),
          permissionName: 'ohos.permission.LOCATION',
          granted: false
        },
        {
          name: '相机',
          description: '允许应用使用相机拍照',
          icon: $r('app.media.device'),
          permissionName: 'ohos.permission.CAMERA',
          granted: false
        },
        {
          name: '存储',
          description: '允许应用读写设备存储',
          icon: $r('app.media.device'),
          permissionName: 'ohos.permission.READ_MEDIA',
          granted: false
        },
        {
          name: '麦克风',
          description: '允许应用使用麦克风录音',
          icon: $r('app.media.device'),
          permissionName: 'ohos.permission.MICROPHONE',
          granted: false
        },
        {
          name: '通讯录',
          description: '允许应用访问通讯录',
          icon: $r('app.media.device'),
          permissionName: 'ohos.permission.READ_CONTACTS',
          granted: false
        },
        {
          name: '日历',
          description: '允许应用读写日历',
          icon: $r('app.media.device'),
          permissionName: 'ohos.permission.READ_CALENDAR',
          granted: false
        },
        {
          name: '健康数据',
          description: '允许应用访问健康数据',
          icon: $r('app.media.device'),
          permissionName: 'ohos.permission.ACTIVITY_MOTION',
          granted: false
        }
      ];
    }
  }

  // 保存权限数据
  private savePermissionsData() {
    try {
      this.preference.putSync('permissions', JSON.stringify(this.permissions));
      this.preference.flushSync();
    } catch (error) {
      console.error('保存权限数据失败:', error);
    }
  }

  // 检查权限状态
  private async checkPermissionStatus() {
    try {
      const bundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const appInfo = bundleInfo.appInfo;
      const tokenId = appInfo.accessTokenId;

      const atManager = abilityAccessCtrl.createAtManager();

      // 检查每个权限的状态
      for (let i = 0; i < this.permissions.length; i++) {
        try {
          // 实际应用中应该使用实际的权限检查
          // 这里使用模拟数据
          const permission = this.permissions[i];

          // 模拟权限检查结果
          const grantStatus = Math.random() > 0.5;
          this.permissions[i].granted = grantStatus;

          /*
          // 真实权限检查代码（部分权限可能不支持检查）
          const grantStatus = await atManager.checkAccessToken(tokenId, permission.permissionName);
          this.permissions[i].granted = grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
          */
        } catch (error) {
          console.error(`检查权限 ${this.permissions[i].permissionName} 状态失败:`, error);
        }
      }

      // 保存更新后的权限状态
      this.savePermissionsData();

    } catch (error) {
      console.error('获取应用信息失败:', error);
    } finally {
      this.isLoading = false;
    }
  }

  // 请求权限
  private requestPermission(permission: PermissionItem) {
    // 在实际应用中，这里应该有实际请求权限的逻辑
    Prompt.showDialog({
      title: '权限请求',
      message: `是否允许应用${permission.description.toLowerCase()}？`,
      buttons: [
        {
          text: '拒绝',
          color: '#666666',
        },
        {
          text: '允许',
          color: '#007DFF',
        }
      ],
      success: (result) => {
        const index = this.permissions.findIndex(p => p.permissionName === permission.permissionName);
        if (index !== -1) {
          this.permissions[index].granted = result.index === 1;
          this.savePermissionsData();
        }
      }
    });
  }

  build() {
    Column() {
      // 自定义顶部栏
      Column() {
        Row() {
          Image($r("app.media.ic_back_black"))
            .width(22)
            .height(22)
            .margin({ left: 5 })
            .onClick(() => {
              router.back()
            })
          Blank()
          Text('系统权限')
            .fontSize(22)
            .textAlign(TextAlign.Center)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
          Blank()
          Row() {
            // 可以根据需要添加右侧按钮
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .height(56)
        .padding({ left: 12, right: 12 })
        .backgroundColor(Color.White)
        .zIndex(100)

        // 底部分割线
        Divider().color(DIVIDER_COLOR).height(1).width('100%')
      }
      .width('100%')
      .margin({ top: 35 }) // 预留状态栏高度
      .backgroundColor(Color.White)
      .shadow({ radius: 2, color: 'rgba(0, 0, 0, 0.05)', offsetY: 2 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(ACCENT_COLOR)
          Text('正在加载权限信息...')
            .fontSize(16)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 权限说明
            Column() {
              Text('权限管理')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(PRIMARY_TEXT_COLOR)
                .margin({ bottom: 8 })

              Text('您可以在此管理应用所需的各项系统权限，开启或关闭权限后可能需要重启应用')
                .fontSize(14)
                .fontColor(SECONDARY_TEXT_COLOR)
                .margin({ bottom: 16 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .margin({ bottom: 16 })

            // 权限列表
            Column() {
              ForEach(this.permissions, (permission: PermissionItem) => {
                this.buildPermissionItem(permission)
              })
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(12)

            Blank().height(this.overscrollOffset)
          }
          .width('100%')
          .padding(15)
          .backgroundColor(BACKGROUND_COLOR)
        }
        .edgeEffect(EdgeEffect.Spring)
        .onScrollEdge((edge: Edge) => {
          this.handleOverscroll(edge);
        })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }

  private handleOverscroll(edge: Edge) {
    if (edge === Edge.Bottom || edge === Edge.Top) {
      this.overscrollOffset = edge === Edge.Bottom ? -50 : 50;
      animateTo({
        duration: 600,
        curve: Curve.Friction,
        onFinish: () => {
          this.overscrollOffset = 0;
        }
      }, () => {
        this.overscrollOffset = 0;
      });
    }
  }

  @Builder
  buildPermissionItem(permission: PermissionItem) {
    Row() {
      Image(permission.icon)
        .width(36)
        .height(36)
        .margin({ right: 16 })

      Column() {
        Text(permission.name)
          .fontSize(16)
          .fontColor(PRIMARY_TEXT_COLOR)
          .fontWeight(FontWeight.Medium)

        Text(permission.description)
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Toggle({ type: ToggleType.Switch, isOn: permission.granted })
        .onChange((isOn: boolean) => {
          if (isOn && !permission.granted) {
            this.requestPermission(permission);
          } else {
            permission.granted = isOn;
            this.savePermissionsData();
          }
        })
    }
    .width('100%')
    .padding(16)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 1 }, color: { bottom: DIVIDER_COLOR } })
  }
} 