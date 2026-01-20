import { Toolbar } from "../../../component/Toolbar";
import { router, Prompt } from '@kit.ArkUI';
import { preferences } from "@kit.ArkData";
import { common } from "@kit.AbilityKit";

// 定义颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const BACKGROUND_COLOR: ResourceColor = '#F5F5F5';
const DIVIDER_COLOR: ResourceColor = '#E5E5E5';

// 共享用户接口
interface SharedUser {
  id: string;
  name: string;
  phone: string;
  relationship: string;
  icon: Resource;
  canView: boolean;
  canEdit: boolean;
}

// 设备接口
interface SharedDevice {
  id: string;
  name: string;
  type: string;
  icon: Resource;
  isShared: boolean;
}

@Entry
@Component
export default struct DeviceSharePage {
  @State currentTabIndex: number = 0;
  @State sharedUsers: SharedUser[] = [];
  @State myDevices: SharedDevice[] = [];
  @State overscrollOffset: number = 0;
  @State isLoading: boolean = true;
  @State newUserName: string = '';
  @State newUserPhone: string = '';
  @State newUserRelationship: string = '家人';
  @State showAddUserDialog: boolean = false;
  // 获取本地存储实例
  private context = getContext(this) as common.UIAbilityContext;
  private options: preferences.Options = { name: 'device_share_data' };
  private preference = preferences.getPreferencesSync(this.context, this.options);
  // 关系选项
  private relationshipOptions: string[] = ['家人', '朋友', '医生', '其他'];

  aboutToAppear() {
    // 加载数据
    setTimeout(() => {
      this.loadShareData();
      this.isLoading = false;
    }, 1000);
  }

  // 加载共享数据
  private loadShareData() {
    // 从本地存储加载数据，如果没有则使用默认数据
    const savedUsers = this.preference.getSync('shared_users', JSON.stringify([])) as string;
    const savedDevices = this.preference.getSync('my_devices', JSON.stringify([])) as string;

    try {
      const parsedUsers = JSON.parse(savedUsers) as SharedUser[];
      const parsedDevices = JSON.parse(savedDevices) as SharedDevice[];

      if (parsedUsers.length > 0) {
        this.sharedUsers = parsedUsers;
      } else {
        // 默认共享用户数据
        this.sharedUsers = [
          {
            id: '1',
            name: '张三',
            phone: '138****1234',
            relationship: '家人',
            icon: $r('app.media.adiminIcon'),
            canView: true,
            canEdit: false
          },
          {
            id: '2',
            name: '李医生',
            phone: '159****5678',
            relationship: '医生',
            icon: $r('app.media.adiminIcon'),
            canView: true,
            canEdit: true
          }
        ];
        this.saveSharedUsers();
      }

      if (parsedDevices.length > 0) {
        this.myDevices = parsedDevices;
      } else {
        // 默认设备数据
        this.myDevices = [
          {
            id: '1',
            name: 'Smart Watch Pro',
            type: '智能手表',
            icon: $r('app.media.device'),
            isShared: true
          },
          {
            id: '2',
            name: 'Health Monitor X1',
            type: '健康监测器',
            icon: $r('app.media.device'),
            isShared: false
          },
          {
            id: '3',
            name: 'Blood Pressure Monitor',
            type: '血压监测器',
            icon: $r('app.media.device'),
            isShared: true
          }
        ];
        this.saveMyDevices();
      }
    } catch (error) {
      console.error('加载共享数据失败:', error);
      Prompt.showToast({ message: '加载数据失败', duration: 2000 });
    }
  }

  // 保存共享用户数据
  private saveSharedUsers() {
    try {
      this.preference.putSync('shared_users', JSON.stringify(this.sharedUsers));
      this.preference.flushSync();
    } catch (error) {
      console.error('保存共享用户数据失败:', error);
    }
  }

  // 保存我的设备数据
  private saveMyDevices() {
    try {
      this.preference.putSync('my_devices', JSON.stringify(this.myDevices));
      this.preference.flushSync();
    } catch (error) {
      console.error('保存我的设备数据失败:', error);
    }
  }

  // 添加共享用户
  private addSharedUser() {
    if (!this.newUserName.trim() || !this.newUserPhone.trim()) {
      Prompt.showToast({ message: '请填写完整信息', duration: 2000 });
      return;
    }

    // 生成随机ID
    const newId = Date.now().toString();

    // 创建新用户
    const newUser: SharedUser = {
      id: newId,
      name: this.newUserName,
      phone: this.newUserPhone,
      relationship: this.newUserRelationship,
      icon: $r('app.media.adiminIcon'),
      canView: true,
      canEdit: false
    };

    // 添加到列表并保存
    this.sharedUsers.push(newUser);
    this.saveSharedUsers();

    // 重置表单
    this.newUserName = '';
    this.newUserPhone = '';
    this.newUserRelationship = '家人';
    this.showAddUserDialog = false;

    Prompt.showToast({ message: '添加共享用户成功', duration: 2000 });
  }

  // 删除共享用户
  private deleteSharedUser(userId: string) {
    Prompt.showDialog({
      title: '删除共享用户',
      message: '确定要删除此共享用户吗？',
      buttons: [
        {
          text: '取消',
          color: '#666666',
        },
        {
          text: '确定',
          color: '#007DFF',
        }
      ],
      success: (result) => {
        if (result.index === 1) {
          this.sharedUsers = this.sharedUsers.filter(user => user.id !== userId);
          this.saveSharedUsers();
          Prompt.showToast({ message: '删除成功', duration: 2000 });
        }
      }
    });
  }

  // 更改设备共享状态
  private toggleDeviceShare(deviceId: string) {
    const index = this.myDevices.findIndex(device => device.id === deviceId);
    if (index !== -1) {
      this.myDevices[index].isShared = !this.myDevices[index].isShared;
      this.saveMyDevices();
      Prompt.showToast({
        message: `${this.myDevices[index].name} ${this.myDevices[index].isShared ? '已开启共享' : '已关闭共享'}`,
        duration: 2000
      });
    }
  }

  // 更改权限设置
  private togglePermission(userId: string, permissionType: 'view' | 'edit') {
    const index = this.sharedUsers.findIndex(user => user.id === userId);
    if (index !== -1) {
      if (permissionType === 'view') {
        this.sharedUsers[index].canView = !this.sharedUsers[index].canView;
        // 如果关闭查看权限，编辑权限也要关闭
        if (!this.sharedUsers[index].canView) {
          this.sharedUsers[index].canEdit = false;
        }
      } else if (permissionType === 'edit') {
        this.sharedUsers[index].canEdit = !this.sharedUsers[index].canEdit;
        // 如果开启编辑权限，查看权限也要开启
        if (this.sharedUsers[index].canEdit) {
          this.sharedUsers[index].canView = true;
        }
      }
      this.saveSharedUsers();
    }
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
          Text('设备共享')
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
          Text('正在加载共享数据...')
            .fontSize(16)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        Column() {
          // 顶部选项卡
          Tabs({ barPosition: BarPosition.Start, index: this.currentTabIndex }) {
            TabContent() {
              this.buildSharedUsersTab()
            }
            .tabBar('共享用户')
            
            TabContent() {
              this.buildMyDevicesTab()
            }
            .tabBar('我的设备')
          }
          .onChange((index: number) => {
            this.currentTabIndex = index;
          })
          .width('100%')
          .height('100%')
          .backgroundColor(BACKGROUND_COLOR)
          .barMode(BarMode.Fixed)
          .barHeight(50)
          .animationDuration(300)
          
          if (this.showAddUserDialog) {
            this.buildAddUserDialog()
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildSharedUsersTab() {
    Scroll() {
      Column() {
        // 共享说明
        Column() {
          Text("数据共享")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
            .margin({ bottom: 8 })

          Text("您可以与家人、朋友或医生共享您的健康数据，方便他们随时了解您的健康状况。")
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ bottom: 8 })

          Text("注意：请确保您信任这些人，因为他们将能够查看您的健康数据。")
            .fontSize(14)
            .fontColor('#FF6666')
        }
        .width('95%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 16, bottom: 16 })

        // 共享用户列表
        Column() {
          Row() {
            Text("共享用户")
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor(PRIMARY_TEXT_COLOR)

            Blank()

            Button("+ 添加")
              .fontSize(14)
              .fontColor(ACCENT_COLOR)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.showAddUserDialog = true;
              })
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16,
            top: 16,
            bottom: 8
          })

          Divider().color(DIVIDER_COLOR).margin({ left: 16, right: 16 })

          if (this.sharedUsers.length > 0) {
            ForEach(this.sharedUsers, (user: SharedUser) => {
              Column() {
                Row() {
                  Image(user.icon)
                    .width(50)
                    .height(50)
                    .borderRadius(25)
                    .margin({ right: 16 })

                  Column() {
                    Text(user.name)
                      .fontSize(16)
                      .fontColor(PRIMARY_TEXT_COLOR)
                      .fontWeight(FontWeight.Medium)

                    Text(user.phone)
                      .fontSize(14)
                      .fontColor(SECONDARY_TEXT_COLOR)
                      .margin({ top: 4 })

                    Text(`关系：${user.relationship}`)
                      .fontSize(14)
                      .fontColor(SECONDARY_TEXT_COLOR)
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()

                  Button({ type: ButtonType.Circle, stateEffect: true }) {
                    Image($r('app.media.delete'))
                      .width(24)
                      .height(24)
                  }
                  .width(36)
                  .height(36)
                  .backgroundColor(Color.Transparent)
                  .onClick(() => {
                    this.deleteSharedUser(user.id);
                  })
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 16 })

                // 权限设置
                Column() {
                  Text("权限设置")
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(PRIMARY_TEXT_COLOR)
                    .margin({ bottom: 12 })

                  Row() {
                    Text("查看数据")
                      .fontSize(14)
                      .fontColor(PRIMARY_TEXT_COLOR)

                    Blank()

                    Toggle({ type: ToggleType.Switch, isOn: user.canView })
                      .onChange((isOn: boolean) => {
                        this.togglePermission(user.id, 'view');
                      })
                  }
                  .width('100%')
                  .margin({ bottom: 12 })

                  Row() {
                    Text("编辑数据")
                      .fontSize(14)
                      .fontColor(PRIMARY_TEXT_COLOR)

                    Blank()

                    Toggle({ type: ToggleType.Switch, isOn: user.canEdit })
                      .enabled(user.canView)
                      .onChange((isOn: boolean) => {
                        this.togglePermission(user.id, 'edit');
                      })
                  }
                  .width('100%')
                }
                .width('100%')
                .padding({
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 16
                })

                Divider().color(DIVIDER_COLOR).margin({ left: 16, right: 16 })
              }
            })
          } else {
            Column() {
              Image($r('app.media.device'))
                .width(100)
                .height(100)
                .margin({ top: 50, bottom: 16 })

              Text("暂无共享用户")
                .fontSize(16)
                .fontColor(SECONDARY_TEXT_COLOR)
            }
            .width('100%')
            .padding({ top: 20, bottom: 50 })
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .width('95%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 30 })

        Blank().height(this.overscrollOffset)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(BACKGROUND_COLOR)
    }
    .edgeEffect(EdgeEffect.Spring)
    .onScrollEdge((edge: Edge) => {
      this.handleOverscroll(edge);
    })
    .width('100%')
    .height('100%')
  }

  @Builder
  buildMyDevicesTab() {
    Scroll() {
      Column() {
        // 设备共享说明
        Column() {
          Text("设备共享")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
            .margin({ bottom: 8 })

          Text("您可以选择要与他人共享的设备。启用共享后，共享用户将可以访问该设备收集的健康数据。")
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
        }
        .width('95%')
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 16, bottom: 16 })

        // 设备列表
        Column() {
          Text("我的设备")
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(PRIMARY_TEXT_COLOR)
            .alignSelf(ItemAlign.Start)
            .padding({ left: 16, top: 16, bottom: 8 })

          Divider().color(DIVIDER_COLOR).margin({ left: 16, right: 16 })

          if (this.myDevices.length > 0) {
            ForEach(this.myDevices, (device: SharedDevice) => {
              Row() {
                Image(device.icon)
                  .width(50)
                  .height(50)
                  .margin({ right: 16 })

                Column() {
                  Text(device.name)
                    .fontSize(16)
                    .fontColor(PRIMARY_TEXT_COLOR)
                    .fontWeight(FontWeight.Medium)

                  Text(device.type)
                    .fontSize(14)
                    .fontColor(SECONDARY_TEXT_COLOR)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Toggle({ type: ToggleType.Switch, isOn: device.isShared })
                  .onChange((isOn: boolean) => {
                    this.toggleDeviceShare(device.id);
                  })
              }
              .width('100%')
              .padding(16)
              .border({ width: { bottom: 1 }, color: { bottom: DIVIDER_COLOR } })
            })
          } else {
            Column() {
              Image($r('app.media.device'))
                .width(100)
                .height(100)
                .margin({ top: 50, bottom: 16 })

              Text("暂无可共享设备")
                .fontSize(16)
                .fontColor(SECONDARY_TEXT_COLOR)
            }
            .width('100%')
            .padding({ top: 20, bottom: 50 })
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .width('95%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ bottom: 30 })

        Blank().height(this.overscrollOffset)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(BACKGROUND_COLOR)
    }
    .edgeEffect(EdgeEffect.Spring)
    .onScrollEdge((edge: Edge) => {
      this.handleOverscroll(edge);
    })
    .width('100%')
    .height('100%')
  }

  @Builder
  buildAddUserDialog() {
    Column() {
      Text("添加共享用户")
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(PRIMARY_TEXT_COLOR)
        .margin({ bottom: 24 })

      TextInput({ placeholder: '姓名', text: this.newUserName })
        .width('90%')
        .height(50)
        .backgroundColor('#F5F5F5')
        .placeholderColor(SECONDARY_TEXT_COLOR)
        .fontSize(16)
        .padding({ left: 16, right: 16 })
        .borderRadius(8)
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.newUserName = value;
        })

      TextInput({ placeholder: '手机号码', text: this.newUserPhone })
        .width('90%')
        .height(50)
        .backgroundColor('#F5F5F5')
        .placeholderColor(SECONDARY_TEXT_COLOR)
        .fontSize(16)
        .padding({ left: 16, right: 16 })
        .borderRadius(8)
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.newUserPhone = value;
        })

      Text("关系")
        .fontSize(16)
        .fontColor(PRIMARY_TEXT_COLOR)
        .alignSelf(ItemAlign.Start)
        .margin({ left: '5%', bottom: 8 })

      Row() {
        ForEach(this.relationshipOptions, (option: string) => {
          Text(option)
            .fontSize(14)
            .fontColor(this.newUserRelationship === option ? Color.White : PRIMARY_TEXT_COLOR)
            .backgroundColor(this.newUserRelationship === option ? ACCENT_COLOR : '#F0F0F0')
            .textAlign(TextAlign.Center)
            .borderRadius(16)
            .width('22%')
            .height(36)
            .margin({ right: 8 })
            .onClick(() => {
              this.newUserRelationship = option;
            })
        })
      }
      .width('90%')
      .margin({ bottom: 24 })

      Row() {
        Button("取消")
          .fontSize(16)
          .fontColor(SECONDARY_TEXT_COLOR)
          .backgroundColor('#F0F0F0')
          .width(120)
          .height(45)
          .borderRadius(22)
          .margin({ right: 16 })
          .onClick(() => {
            this.showAddUserDialog = false;
          })

        Button("确定")
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(ACCENT_COLOR)
          .width(120)
          .height(45)
          .borderRadius(22)
          .onClick(() => {
            this.addSharedUser();
          })
      }
    }
    .width('90%')
    .padding({ top: 24, bottom: 24 })
    .backgroundColor(Color.White)
    .borderRadius(16)
    .position({ x: '5%', y: '25%' })
    .zIndex(999)
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
} 