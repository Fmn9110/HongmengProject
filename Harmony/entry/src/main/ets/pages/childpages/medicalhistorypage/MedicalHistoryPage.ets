import { router, Prompt } from '@kit.ArkUI'
import {
  loadMedicalRecordsFromStorage,
  clearMedicalRecordsStorage,
  MedicalRecord as StorageMedicalRecord
} from './MedicalHistoryModel';
import { DiseaseTemplate, getAllDiseaseNames, getDiseaseByName } from './DiseaseData';
import dietRecommendationService from '../../../services/DietRecommendationService';
import exerciseRecommendationService from '../../../services/ExerciseRecommendationService';

// 定义颜色常量 - 更新配色方案
const PRIMARY_TEXT_COLOR: string = '#1A1D1E'
const SECONDARY_TEXT_COLOR: string = '#4B5563'
const ACCENT_COLOR: string = '#0072F5'
const CARD_BG_GRADIENT: string = 'linear-gradient(135deg, #EFF6FF 0%, #DBEAFE 100%)'
const BACKGROUND_COLOR: string = '#F9FAFB'
const CARD_BACKGROUND: string = '#FFFFFF'
const SHADOW_COLOR: string = 'rgba(0, 0, 0, 0.08)'

// 定义SelectOption接口
interface SelectOption {
  value: string;
  text: string;
}

// 定义病史类型
interface MedicalRecord {
  id: number;
  diseaseName: string;
  diagnosisDate: string;
  details: string;
  status: string; // 例如：治愈、慢性病、持续治疗中
  severity: string; // 轻度、中度、重度
}

// 定义健康建议类型
interface HealthSuggestion {
  id: number;
  title: string;
  content: string;
  relatedDisease: string;
  priority: number; // 建议优先级：1-高，2-中，3-低
  isExpanded?: boolean; // 是否展开详情
}

// 添加DiseaseRecordDTO接口用于传递给饮食推荐页面
interface DiseaseRecordDTO {
  name: string;
  diagnosisDate: string;
  severity: string;
  description: string;
  status: string;
}

interface GeneratedObjectLiteralInterface_1 {
  id: string;
  diseaseName: string;
  diagnosisDate: string;
  severity: string;
  hospital: string;
  doctor: string;
  treatment: string;
  notes: string;
  isExpanded: boolean;
}

@Entry
@Component
struct MedicalHistoryPage {
  @State medicalRecords: MedicalRecord[] = [
    {
      id: 1,
      diseaseName: '高血压',
      diagnosisDate: '2020-05-15',
      details: '轻度高血压，药物控制良好',
      status: '慢性病',
      severity: '轻度'
    },
    {
      id: 2,
      diseaseName: '糖尿病',
      diagnosisDate: '2019-03-20',
      details: '2型糖尿病，饮食控制，定期服用降糖药',
      status: '慢性病',
      severity: '中度'
    },
    {
      id: 3,
      diseaseName: '骨折',
      diagnosisDate: '2018-07-10',
      details: '右手腕骨折，已完全康复',
      status: '已治愈',
      severity: '中度'
    }
  ]
  @State healthSuggestions: HealthSuggestion[] = []
  @State isAddDialogOpen: boolean = false
  @State isEditDialogOpen: boolean = false
  @State currentEditId: number = -1
  @State newDiseaseName: string = ''
  @State newDiagnosisDate: string = ''
  @State newDetails: string = ''
  @State newStatus: string = '慢性病'
  @State newSeverity: string = '轻度'
  @State statusOptions: string[] = ['已治愈', '慢性病', '持续治疗中']
  @State severityOptions: string[] = ['轻度', '中度', '重度']
  @State isSuggestionsExpanded: boolean = true
  @State isLogoutDialogOpen: boolean = false
  @State userDiseases: string[] = ['高血压', '糖尿病']; // 示例数据，实际应从存储中获取
  @State allDiseases: string[] = getAllDiseaseNames();
  @State showAddDialog: boolean = false;
  @State selectedDisease: string = '';
  @State selectedSeverity: string = '中度';
  // 添加SelectOption类型定义
  @State diseaseSelectOptions: SelectOption[] = [];
  @State severitySelectOptions: SelectOption[] = [];
  @State isMenuOpen: boolean = false // 添加菜单状态变量

  // 获取严重程度对应的颜色
  getSeverityColor(severity: string): string {
    switch (severity) {
      case '轻度':
        return '#22C55E'
      case '中度':
        return '#F59E0B'
      case '重度':
        return '#EF4444'
      default:
        return '#22C55E'
    }
  }

  // 获取状态对应的文本颜色
  getStatusColor(status: string): string {
    switch (status) {
      case '已治愈':
        return '#22C55E'
      case '慢性病':
        return '#F59E0B'
      case '持续治疗中':
        return '#3B82F6'
      default:
        return '#3B82F6'
    }
  }

  // 获取状态对应的背景颜色
  getStatusBgColor(status: string): string {
    switch (status) {
      case '已治愈':
        return 'rgba(34, 197, 94, 0.1)'
      case '慢性病':
        return 'rgba(245, 158, 11, 0.1)'
      case '持续治疗中':
        return 'rgba(59, 130, 246, 0.1)'
      default:
        return 'rgba(59, 130, 246, 0.1)'
    }
  }

  // 删除记录方法
  deleteRecord(id: number) {
    const index = this.medicalRecords.findIndex(record => record.id === id)
    if (index !== -1) {
      this.medicalRecords.splice(index, 1)

      // 更新健康建议
      this.generateHealthSuggestions()

      // 保存到持久化存储
      this.saveMedicalRecordsToStorage()

      // 更新用户疾病列表
      this.updateUserDiseases()

      Prompt.showToast({ message: '删除成功', duration: 2000 })
    }
  }

  aboutToAppear() {
    // 初始化时加载存储的数据
    this.loadMedicalRecords();
    // 设置用户疾病到餐饮推荐服务中
    dietRecommendationService.setUserDiseases(this.userDiseases);
    // 设置用户疾病到运动推荐服务中
    exerciseRecommendationService.setUserDiseases(this.userDiseases);

    // 初始化Select选项
    this.initSelectOptions();
  }

  // 初始化Select选项
  private initSelectOptions() {
    // 初始化疾病选项
    this.diseaseSelectOptions = [];
    for (let i = 0; i < this.allDiseases.length; i++) {
      const option: SelectOption = {
        value: this.allDiseases[i],
        text: this.allDiseases[i]
      };
      this.diseaseSelectOptions.push(option);
    }

    // 初始化严重程度选项
    this.severitySelectOptions = [];
    for (let i = 0; i < this.severityOptions.length; i++) {
      const option: SelectOption = {
        value: this.severityOptions[i],
        text: this.severityOptions[i]
      };
      this.severitySelectOptions.push(option);
    }
  }

  // 加载医疗记录
  async loadMedicalRecords() {
    try {
      const records = await loadMedicalRecordsFromStorage();
      if (records && records.length > 0) {
        // 将持久化存储的记录转换为页面需要的格式
        const convertedRecords: MedicalRecord[] = [];
        for (let i = 0; i < records.length; i++) {
          const record = records[i];
          const newRecord: MedicalRecord = {
            id: parseInt(record.id),
            diseaseName: record.diseaseName,
            diagnosisDate: record.diagnosisDate,
            details: record.notes,
            status: record.treatment.includes('已治愈') ? '已治愈' :
              record.treatment.includes('慢性') ? '慢性病' : '持续治疗中',
            severity: record.severity
          };
          convertedRecords.push(newRecord);
        }
        this.medicalRecords = convertedRecords;
      }
      // 生成健康建议
      this.generateHealthSuggestions();

      // 更新用户疾病列表
      this.updateUserDiseases();
    } catch (error) {
      console.error(`加载医疗记录失败: ${error}`);
      // 生成健康建议
      this.generateHealthSuggestions();
    }
  }

  // 重置为默认数据
  async resetToDefault() {
    try {
      await clearMedicalRecordsStorage();
      Prompt.showToast({ message: '已恢复默认数据，重新进入页面生效', duration: 2000 });
      // 关闭对话框
      this.isLogoutDialogOpen = false;
      // 返回上一页
      router.back();
    } catch (error) {
      console.error(`重置数据失败: ${error}`);
      Prompt.showToast({ message: '重置数据失败', duration: 2000 });
    }
  }

  build() {
    Stack() {
      Column() {
        // 添加顶部状态栏空间
        Column()
          .width('100%')
          .height(48)// 为系统状态栏预留空间
          .backgroundColor(CARD_BACKGROUND)

        this.buildCustomAppBar() // 顶部栏

        Scroll() {
          Column() {
            this.buildIntroCard()

            // 健康建议卡片
            if (this.healthSuggestions.length > 0) {
              this.buildHealthSuggestionsCard()
            }

            this.buildRecordsList()

            // 底部按钮区域
            Column({ space: 16 }) {
              // 添加新记录按钮
              Button('添加病史记录')
                .width('90%')
                .height(50)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Color.White)
                .backgroundColor(ACCENT_COLOR)
                .borderRadius(25)
                .shadow({ radius: 8, color: 'rgba(0, 114, 245, 0.2)', offsetY: 2 })
                .onClick(() => {
                  this.isAddDialogOpen = true
                })

              // 餐饮推荐关联卡片
              this.buildDietRecommendationCard()
            }
            .width('100%')
            .margin({ bottom: 30 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(BACKGROUND_COLOR)

      // 菜单弹出层 - 使用Stack作为最外层容器，确保菜单显示在最上层
      if (this.isMenuOpen) {
        this.buildMenuOverlay()
      }

      // 添加病史记录对话框
      if (this.isAddDialogOpen) {
        this.buildAddRecordDialog()
      }

      // 编辑病史记录对话框
      if (this.isEditDialogOpen) {
        this.buildEditRecordDialog()
      }

      // 重置数据确认对话框
      if (this.isLogoutDialogOpen) {
        this.buildLogoutDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  // 顶部自定义AppBar
  @Builder
  buildCustomAppBar() {
    Row() {
      Image($r("app.media.ic_back_black"))
        .width(24)
        .height(24)
        .margin({ left: 16 })
        .onClick(() => {
          router.back()
        })

      Text('既往病史')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(PRIMARY_TEXT_COLOR)
        .margin({ left: 16 })

      Blank()

      // 更多按钮，点击显示菜单
      Image($r("app.media.ic_mores"))
        .width(24)
        .height(24)
        .margin({ right: 16 })
        .onClick(() => {
          this.isMenuOpen = !this.isMenuOpen
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 4, right: 4 })
    .backgroundColor(CARD_BACKGROUND)
    .shadow({ radius: 15, color: SHADOW_COLOR, offsetY: 2 })
  }

  // 菜单覆盖层
  @Builder
  buildMenuOverlay() {
    Stack() {
      // 半透明背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.1)')
        .onClick(() => {
          this.isMenuOpen = false
        })

      // 菜单内容
      Column() {
        Button('重置数据')
          .width('100%')
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(SECONDARY_TEXT_COLOR)
          .backgroundColor(CARD_BACKGROUND)
          .borderRadius(8)
          .onClick(() => {
            this.isMenuOpen = false
            this.isLogoutDialogOpen = true
          })
      }
      .width(140)
      .padding(8)
      .backgroundColor(CARD_BACKGROUND)
      .borderRadius(8)
      .shadow({ radius: 12, color: SHADOW_COLOR, offsetY: 4 })
      .position({ x: '100%', y: 104 }) // 48(状态栏) + 56(导航栏)
      .translate({ x: -148 }) // 140宽度 + 8右边距
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .zIndex(9999) // 使用非常高的层级
  }

  // 介绍卡片
  @Builder
  buildIntroCard() {
    Column() {
      Row() {
        Image($r("app.media.medical"))
          .width(60)
          .height(60)
          .margin({ right: 16 })
          .objectFit(ImageFit.Contain)

        Column() {
          Text('既往病史管理')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)

          Text('记录您的健康状况')
            .fontSize(14)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 6 })
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(20)
      .borderRadius(16)
      .backgroundColor(CARD_BG_GRADIENT)
      .shadow({ radius: 12, color: SHADOW_COLOR, offsetY: 2 })
      .margin({ top: 16, bottom: 24 })
    }
  }

  // 健康建议卡片
  @Builder
  buildHealthSuggestionsCard() {
    Column() {
      // 标题和展开/隐藏按钮
      Row() {
        Text('个性化健康建议')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(PRIMARY_TEXT_COLOR)

        Blank()

        Text('基于您的病史')
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ right: 8 })

        Row() {
          Image(this.isSuggestionsExpanded ? $r('app.media.up_arrow') : $r('app.media.down_arrow'))
            .width(16)
            .height(16)
            .margin({ left: 4 })
        }
        .onClick(() => {
          this.isSuggestionsExpanded = !this.isSuggestionsExpanded
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 建议列表 - 带展开/隐藏动画
      if (this.isSuggestionsExpanded) {
        Column() {
          ForEach(this.healthSuggestions, (suggestion: HealthSuggestion) => {
            this.buildSuggestionItem(suggestion)
          })
        }
        .width('100%')
        .animation({
          duration: 300,
          curve: Curve.EaseOut,
          iterations: 1,
          playMode: PlayMode.Normal
        })
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(16)
    .margin({ bottom: 24 })
    .shadow({ radius: 12, color: SHADOW_COLOR, offsetY: 2 })
  }

  // 单个健康建议项
  @Builder
  buildSuggestionItem(suggestion: HealthSuggestion) {
    Column() {
      // 标题行
      Row() {
        // 优先级标识
        Row() {
          Text(this.getPriorityText(suggestion.priority))
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
        }
        .width(44)
        .height(22)
        .backgroundColor(this.getPriorityColor(suggestion.priority))
        .borderRadius(11)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 10 })

        Text(suggestion.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(PRIMARY_TEXT_COLOR)

        Blank()

        Row() {
          Text(`与${suggestion.relatedDisease}相关`)
            .fontSize(12)
            .fontColor(SECONDARY_TEXT_COLOR)

          Image(suggestion.isExpanded ? $r('app.media.up_arrow') : $r('app.media.down_arrow'))
            .width(14)
            .height(14)
            .margin({ left: 4 })
        }
        .onClick(() => {
          suggestion.isExpanded = !suggestion.isExpanded
          // 需要触发UI刷新
          this.healthSuggestions = [...this.healthSuggestions]
        })
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 内容部分 - 可展开/隐藏
      if (suggestion.isExpanded !== false) {
        Text(suggestion.content)
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)
          .width('100%')
          .margin({ left: 54 })// 与标题对齐
          .animation({
            duration: 200,
            curve: Curve.EaseOut,
            iterations: 1,
            playMode: PlayMode.Normal
          })
      }
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .margin({ bottom: this.healthSuggestions.indexOf(suggestion) < this.healthSuggestions.length - 1 ? 12 : 0 })
    .border({
      width: { bottom: this.healthSuggestions.indexOf(suggestion) < this.healthSuggestions.length - 1 ? 1 : 0 },
      color: '#E5E7EB'
    })
  }

  // 病史记录列表
  @Builder
  buildRecordsList() {
    Column() {
      Text('病史记录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(PRIMARY_TEXT_COLOR)
        .width('100%')
        .margin({ bottom: 16 })

      ForEach(this.medicalRecords, (record: MedicalRecord) => {
        this.buildRecordItem(record)
      })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 单个病史记录项
  @Builder
  buildRecordItem(record: MedicalRecord) {
    Column() {
      Row() {
        Text(record.diseaseName)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(PRIMARY_TEXT_COLOR)

        Blank()

        Text(record.status)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getStatusColor(record.status))
          .backgroundColor(this.getStatusBgColor(record.status))
          .borderRadius(12)
          .padding({
            left: 10,
            right: 10,
            top: 4,
            bottom: 4
          })
      }
      .width('100%')
      .margin({ bottom: 8 })

      Row() {
        Text(`诊断日期: ${record.diagnosisDate}`)
          .fontSize(14)
          .fontColor(SECONDARY_TEXT_COLOR)

        Blank()

        Text(record.severity)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getSeverityColor(record.severity))
      }
      .width('100%')
      .margin({ bottom: 10 })

      Text(record.details)
        .fontSize(15)
        .fontColor(SECONDARY_TEXT_COLOR)
        .width('100%')
        .margin({ top: 6, bottom: 10 })

      Row() {
        Blank()
        Button('编辑')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ACCENT_COLOR)
          .backgroundColor('transparent')
          .margin({ right: 16 })
          .onClick(() => {
            this.editRecord(record.id)
          })

        Button('删除')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#EF4444')
          .backgroundColor('transparent')
          .onClick(() => {
            this.deleteRecord(record.id)
          })
      }
      .width('100%')
      .margin({ top: 6 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(16)
    .margin({ bottom: 16 })
    .shadow({ radius: 12, color: SHADOW_COLOR, offsetY: 2 })
  }

  // 餐饮推荐关联卡片
  @Builder
  buildDietRecommendationCard() {
    Column() {
      Row() {
        Image($r('app.media.yinshi'))
          .width(28)
          .height(28)
          .margin({ right: 12 })

        Text('病史餐饮推荐')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ACCENT_COLOR)
      }
      .width('100%')
      .margin({ bottom: 16 })

      Text('基于您的病史记录，我们可以为您提供个性化的餐饮推荐，帮助您更好地管理健康。')
        .fontSize(14)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ bottom: 20 })
        .lineHeight(22)

      Button('查看餐饮推荐', { type: ButtonType.Normal })
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor(ACCENT_COLOR)
        .borderRadius(22)
        .shadow({ radius: 8, color: 'rgba(0, 114, 245, 0.2)', offsetY: 2 })
        .onClick(() => {
          console.info('点击了餐饮推荐按钮')
          // 更新餐饮推荐服务中的疾病数据
          dietRecommendationService.setUserDiseases(this.userDiseases);

          // 将疾病记录转换为AiDietRecommendationPage需要的格式
          const diseaseRecords: DiseaseRecordDTO[] = this.medicalRecords.map(record => {
            return {
              name: record.diseaseName,
              diagnosisDate: record.diagnosisDate,
              severity: record.severity,
              description: record.details,
              status: record.status
            } as DiseaseRecordDTO;
          });

          // 跳转到餐饮推荐页面，传递疾病记录
          router.pushUrl({
            url: 'pages/childpages/dietpage/AiDietRecommendationPage',
            params: {
              diseaseRecords: diseaseRecords
            }
          }).catch((err: Error) => {
            console.error(`路由跳转失败: ${JSON.stringify(err)}`);
            Prompt.showToast({ message: '页面跳转失败，请稍后再试', duration: 2000 });
          });
        })
    }
    .width('90%')
    .padding(20)
    .borderRadius(16)
    .backgroundColor('#EFF6FF')
    .shadow({ radius: 12, color: SHADOW_COLOR, offsetY: 2 })
    .margin({ top: 8, bottom: 20 })
  }

  // 添加病史记录对话框
  @Builder
  buildAddRecordDialog() {
    Stack() {
      // 添加半透明遮罩背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.4)
        .onClick(() => {
          // 点击背景关闭对话框
          this.isAddDialogOpen = false
        })

      // 对话框内容
      Column() {
        // 对话框标题和关闭按钮
        Row() {
          Text('添加病史记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Blank()

          Image($r('app.media.ic_add'))
            .width(20)
            .height(20)
            .rotate({ angle: 45 })
            .onClick(() => {
              this.isAddDialogOpen = false
            })
        }
        .width('100%')
        .padding({
          left: 20,
          right: 20,
          top: 15,
          bottom: 10
        })

        // 分割线
        Divider()
          .color('#EEEEEE')
          .width('100%')

        // 表单项
        Column({ space: 10 }) {
          // 疾病名称输入框
          Column() {
            Text('疾病名称')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 16, bottom: 4 })
              .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: '请输入疾病名称' })
              .placeholderColor('#BBBBBB')
              .width('100%')
              .height(40)
              .backgroundColor('#F8F8F8')
              .borderRadius(4)
              .fontSize(14)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.newDiseaseName = value
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 诊断日期输入框
          Column() {
            Text('诊断日期')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12, bottom: 4 })
              .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: 'YYYY-MM-DD' })
              .placeholderColor('#BBBBBB')
              .width('100%')
              .height(40)
              .backgroundColor('#F8F8F8')
              .borderRadius(4)
              .fontSize(14)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.newDiagnosisDate = value
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 详细说明输入框
          Column() {
            Text('详细说明')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12, bottom: 4 })
              .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: '请输入详细说明' })
              .placeholderColor('#BBBBBB')
              .width('100%')
              .height(60)
              .backgroundColor('#F8F8F8')
              .borderRadius(4)
              .fontSize(14)
              .padding(12)
              .onChange((value: string) => {
                this.newDetails = value
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 状态选择
          Column() {
            Text('状态')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12, bottom: 8 })
              .alignSelf(ItemAlign.Start)

            Row() {
              ForEach(this.statusOptions, (option: string) => {
                Row() {
                  Radio({ value: option, group: 'status' })
                    .checked(this.newStatus === option)
                    .width(16)
                    .height(16)
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.newStatus = option
                      }
                    })

                  Text(option)
                    .fontSize(14)
                    .fontColor('#333333')
                    .margin({ left: 4 })
                }
                .margin({ right: 20 })
                .alignItems(VerticalAlign.Center)
              })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 严重程度选择
          Column() {
            Text('严重程度')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12, bottom: 8 })
              .alignSelf(ItemAlign.Start)

            Row() {
              ForEach(this.severityOptions, (option: string, index: number) => {
                Button(option)
                  .backgroundColor(this.newSeverity === option ? this.getSeverityColor(option) : '#F0F0F0')
                  .fontColor(this.newSeverity === option ? Color.White : '#666666')
                  .borderRadius(20)
                  .height(32)
                  .fontSize(14)
                  .padding({ left: 16, right: 16 })
                  .margin({ right: 10 })
                  .onClick(() => {
                    this.newSeverity = option
                  })
              })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        // 底部按钮区域
        Row() {
          Button('取消')
            .width('47%')
            .height(40)
            .backgroundColor('#F0F0F0')
            .fontColor('#666666')
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => {
              this.isAddDialogOpen = false
            })

          Button('保存')
            .width('47%')
            .height(40)
            .backgroundColor('#007AFF')
            .fontColor(Color.White)
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => {
              this.addNewRecord()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 20,
          right: 20,
          top: 16,
          bottom: 16
        })
      }
      .width('80%')
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({
        radius: 8,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 2
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .alignContent(Alignment.Center)
    .zIndex(999)
  }

  // 添加新记录
  addNewRecord() {
    if (!this.newDiseaseName || !this.newDiagnosisDate) {
      Prompt.showToast({ message: '请填写必要信息', duration: 2000 })
      return
    }

    const newRecord: MedicalRecord = {
      id: this.medicalRecords.length + 1,
      diseaseName: this.newDiseaseName,
      diagnosisDate: this.newDiagnosisDate,
      details: this.newDetails,
      status: this.newStatus,
      severity: this.newSeverity
    }

    this.medicalRecords.push(newRecord)
    this.isAddDialogOpen = false

    // 重置表单
    this.newDiseaseName = ''
    this.newDiagnosisDate = ''
    this.newDetails = ''
    this.newStatus = '慢性病'
    this.newSeverity = '轻度'

    // 更新健康建议
    this.generateHealthSuggestions()

    // 保存到持久化存储
    this.saveMedicalRecordsToStorage()

    // 更新用户疾病列表
    this.updateUserDiseases()

    Prompt.showToast({ message: '添加成功', duration: 2000 })
  }

  // 更新用户疾病列表
  updateUserDiseases() {
    // 从医疗记录中提取疾病名称
    const diseaseNames: string[] = [];
    const diseaseSeverities = new Map<string, string>();
    for (let i = 0; i < this.medicalRecords.length; i++) {
      const record = this.medicalRecords[i];
      // 只添加持续治疗中和慢性病的记录，已治愈的不添加
      if (record.status !== '已治愈' && !diseaseNames.includes(record.diseaseName)) {
        diseaseNames.push(record.diseaseName);
        diseaseSeverities.set(record.diseaseName, record.severity);
      }
    }
    this.userDiseases = diseaseNames;
    console.info('用户疾病列表已更新:', JSON.stringify(this.userDiseases));

    // 更新餐饮推荐服务中的疾病数据
    dietRecommendationService.setUserDiseases(this.userDiseases);

    // 更新运动推荐服务中的疾病数据
    exerciseRecommendationService.setUserDiseases(this.userDiseases);
    exerciseRecommendationService.setSeverities(diseaseSeverities);
  }

  // 重置数据确认对话框
  @Builder
  buildLogoutDialog() {
    Stack() {
      // 半透明背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.4)
        .onClick(() => {
          this.isLogoutDialogOpen = false
        })

      // 对话框内容
      Column() {
        Text('确认恢复默认数据')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 20, bottom: 20 })

        Text('恢复默认数据将清除所有添加的病史记录，确定要继续吗？')
          .fontSize(16)
          .textAlign(TextAlign.Center)
          .margin({ bottom: 30 })
          .padding({ left: 20, right: 20 })

        Row() {
          Button('取消')
            .width('45%')
            .height(40)
            .backgroundColor('#F0F0F0')
            .fontColor('#666666')
            .borderRadius(20)
            .onClick(() => {
              this.isLogoutDialogOpen = false
            })

          Button('确认')
            .width('45%')
            .height(40)
            .backgroundColor('#FF4D4F')
            .fontColor(Color.White)
            .borderRadius(20)
            .onClick(() => {
              this.resetToDefault()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: 20 })
      }
      .width('80%')
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({
        radius: 8,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 2
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .alignContent(Alignment.Center)
    .zIndex(999)
  }

  // 编辑记录对话框
  @Builder
  buildEditRecordDialog() {
    Stack() {
      // 添加半透明遮罩背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.4)
        .onClick(() => {
          // 点击背景关闭对话框
          this.isEditDialogOpen = false
        })

      // 对话框内容
      Column() {
        // 对话框标题和关闭按钮
        Row() {
          Text('编辑病史记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Blank()

          Image($r('app.media.ic_add'))
            .width(20)
            .height(20)
            .rotate({ angle: 45 })
            .onClick(() => {
              this.isEditDialogOpen = false
            })
        }
        .width('100%')
        .padding({
          left: 20,
          right: 20,
          top: 15,
          bottom: 10
        })

        // 分割线
        Divider()
          .color('#EEEEEE')
          .width('100%')

        // 表单项
        Column({ space: 10 }) {
          // 疾病名称输入框
          Column() {
            Text('疾病名称')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 16, bottom: 4 })
              .alignSelf(ItemAlign.Start)

            TextInput({ text: this.newDiseaseName, placeholder: '请输入疾病名称' })
              .placeholderColor('#BBBBBB')
              .width('100%')
              .height(40)
              .backgroundColor('#F8F8F8')
              .borderRadius(4)
              .fontSize(14)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.newDiseaseName = value
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 诊断日期输入框
          Column() {
            Text('诊断日期')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12, bottom: 4 })
              .alignSelf(ItemAlign.Start)

            TextInput({ text: this.newDiagnosisDate, placeholder: 'YYYY-MM-DD' })
              .placeholderColor('#BBBBBB')
              .width('100%')
              .height(40)
              .backgroundColor('#F8F8F8')
              .borderRadius(4)
              .fontSize(14)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.newDiagnosisDate = value
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 详细说明输入框
          Column() {
            Text('详细说明')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12, bottom: 4 })
              .alignSelf(ItemAlign.Start)

            TextInput({ text: this.newDetails, placeholder: '请输入详细说明' })
              .placeholderColor('#BBBBBB')
              .width('100%')
              .height(60)
              .backgroundColor('#F8F8F8')
              .borderRadius(4)
              .fontSize(14)
              .padding(12)
              .onChange((value: string) => {
                this.newDetails = value
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 状态选择
          Column() {
            Text('状态')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12, bottom: 8 })
              .alignSelf(ItemAlign.Start)

            Row() {
              ForEach(this.statusOptions, (option: string) => {
                Row() {
                  Radio({ value: option, group: 'status' })
                    .checked(this.newStatus === option)
                    .width(16)
                    .height(16)
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.newStatus = option
                      }
                    })

                  Text(option)
                    .fontSize(14)
                    .fontColor('#333333')
                    .margin({ left: 4 })
                }
                .margin({ right: 20 })
                .alignItems(VerticalAlign.Center)
              })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 严重程度选择
          Column() {
            Text('严重程度')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 12, bottom: 8 })
              .alignSelf(ItemAlign.Start)

            Row() {
              ForEach(this.severityOptions, (option: string, index: number) => {
                Button(option)
                  .backgroundColor(this.newSeverity === option ? this.getSeverityColor(option) : '#F0F0F0')
                  .fontColor(this.newSeverity === option ? Color.White : '#666666')
                  .borderRadius(20)
                  .height(32)
                  .fontSize(14)
                  .padding({ left: 16, right: 16 })
                  .margin({ right: 10 })
                  .onClick(() => {
                    this.newSeverity = option
                  })
              })
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 20, right: 20 })

        // 底部按钮区域
        Row() {
          Button('取消')
            .width('47%')
            .height(40)
            .backgroundColor('#F0F0F0')
            .fontColor('#666666')
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => {
              this.isEditDialogOpen = false
            })

          Button('保存')
            .width('47%')
            .height(40)
            .backgroundColor('#007AFF')
            .fontColor(Color.White)
            .fontSize(16)
            .borderRadius(20)
            .onClick(() => {
              this.updateRecord()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: 20,
          right: 20,
          top: 16,
          bottom: 16
        })
      }
      .width('80%')
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({
        radius: 8,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 2
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    .alignContent(Alignment.Center)
    .zIndex(999)
  }

  // 编辑记录
  editRecord(id: number) {
    const record = this.medicalRecords.find(item => item.id === id)
    if (record) {
      this.currentEditId = id
      this.newDiseaseName = record.diseaseName
      this.newDiagnosisDate = record.diagnosisDate
      this.newDetails = record.details
      this.newStatus = record.status
      this.newSeverity = record.severity
      this.isEditDialogOpen = true
    }
  }

  // 更新记录
  updateRecord() {
    if (!this.newDiseaseName || !this.newDiagnosisDate) {
      Prompt.showToast({ message: '请填写必要信息', duration: 2000 })
      return
    }

    const index = this.medicalRecords.findIndex(record => record.id === this.currentEditId)
    if (index !== -1) {
      this.medicalRecords[index] = {
        id: this.currentEditId,
        diseaseName: this.newDiseaseName,
        diagnosisDate: this.newDiagnosisDate,
        details: this.newDetails,
        status: this.newStatus,
        severity: this.newSeverity
      }

      this.isEditDialogOpen = false
      this.currentEditId = -1

      // 更新健康建议
      this.generateHealthSuggestions()

      // 保存到持久化存储
      this.saveMedicalRecordsToStorage()

      Prompt.showToast({ message: '更新成功', duration: 2000 })
    }
  }

  // 保存医疗记录到持久化存储
  async saveMedicalRecordsToStorage() {
    try {
      // 将页面的记录格式转换为存储格式
      const storageRecords: StorageMedicalRecord[] = [];
      for (let i = 0; i < this.medicalRecords.length; i++) {
        const record = this.medicalRecords[i];
        const storageRecord: StorageMedicalRecord = {
          id: String(record.id),
          diseaseName: record.diseaseName,
          diagnosisDate: record.diagnosisDate,
          severity: record.severity,
          hospital: '本地医院', // 默认值
          doctor: '本地医生', // 默认值
          treatment: record.status === '已治愈' ? '已治愈' :
            record.status === '慢性病' ? '慢性病治疗' : '持续治疗中',
          notes: record.details,
          isExpanded: false
        };
        storageRecords.push(storageRecord);
      }

      // 导入MedicalHistoryModel中的函数并调用
      const moduleExports = await import('./MedicalHistoryModel');
      const saveFunction = moduleExports.saveMedicalRecordsToStorage;
      await saveFunction(storageRecords);
    } catch (error) {
      console.error(`保存医疗记录失败: ${error}`);
    }
  }

  // 生成健康建议
  generateHealthSuggestions() {
    // 清空现有建议
    this.healthSuggestions = []

    // 遍历病史记录，为每种疾病生成相应的健康建议
    this.medicalRecords.forEach(record => {
      // 只为慢性病和持续治疗中的疾病生成建议
      if (record.status === '已治愈') {
        return
      }

      // 根据疾病类型生成建议
      switch (record.diseaseName) {
        case '高血压':
          this.addHighBloodPressureSuggestions(record)
          break
        case '糖尿病':
          this.addDiabetesSuggestions(record)
          break
        case '骨折':
          if (record.status !== '已治愈') {
            this.addFractureSuggestions(record)
          }
          break
        default:
        // 添加通用健康建议
          this.addGeneralHealthSuggestions(record)
      }
    })

    // 按优先级排序
    this.healthSuggestions.sort((a, b) => a.priority - b.priority)

    // 默认设置所有建议为展开状态
    this.healthSuggestions.forEach(suggestion => {
      suggestion.isExpanded = true
    })
  }

  // 高血压健康建议
  addHighBloodPressureSuggestions(record: MedicalRecord) {
    // 根据严重程度添加不同的建议
    if (record.severity === '重度') {
      this.healthSuggestions.push({
        id: this.healthSuggestions.length + 1,
        title: '严格控制血压',
        content: '建议每日监测血压，严格按医嘱服药，控制盐分摄入，避免情绪波动。',
        relatedDisease: '高血压',
        priority: 1
      })
    } else {
      this.healthSuggestions.push({
        id: this.healthSuggestions.length + 1,
        title: '低盐饮食',
        content: '建议每日食盐摄入量控制在5g以下，避免高盐食品如腌制品、加工肉类等。',
        relatedDisease: '高血压',
        priority: 2
      })
    }

    this.healthSuggestions.push({
      id: this.healthSuggestions.length + 1,
      title: '规律运动',
      content: '建议每周进行3-5次中等强度有氧运动，如快走、游泳等，每次30-60分钟。',
      relatedDisease: '高血压',
      priority: 2
    })

    this.healthSuggestions.push({
      id: this.healthSuggestions.length + 1,
      title: '定期复查',
      content: '建议每3个月进行一次血压检查，评估治疗效果并及时调整治疗方案。',
      relatedDisease: '高血压',
      priority: 2
    })
  }

  // 糖尿病健康建议
  addDiabetesSuggestions(record: MedicalRecord) {
    // 根据严重程度添加不同的建议
    if (record.severity === '重度' || record.severity === '中度') {
      this.healthSuggestions.push({
        id: this.healthSuggestions.length + 1,
        title: '血糖监测',
        content: '建议每日监测血糖水平，记录并分析波动情况，严格按医嘱服药或注射胰岛素。',
        relatedDisease: '糖尿病',
        priority: 1
      })
    }

    this.healthSuggestions.push({
      id: this.healthSuggestions.length + 1,
      title: '饮食控制',
      content: '建议采用低糖、低脂、高纤维饮食，控制总热量摄入，避免精制碳水化合物。',
      relatedDisease: '糖尿病',
      priority: 2
    })

    this.healthSuggestions.push({
      id: this.healthSuggestions.length + 1,
      title: '足部护理',
      content: '每日检查足部，保持清洁干燥，避免赤脚行走，预防糖尿病足并发症。',
      relatedDisease: '糖尿病',
      priority: 3
    })
  }

  // 骨折健康建议
  addFractureSuggestions(record: MedicalRecord) {
    this.healthSuggestions.push({
      id: this.healthSuggestions.length + 1,
      title: '适当活动',
      content: '遵医嘱进行适当的康复训练，避免过度负重，促进骨折愈合和功能恢复。',
      relatedDisease: '骨折',
      priority: 2
    })

    this.healthSuggestions.push({
      id: this.healthSuggestions.length + 1,
      title: '钙质补充',
      content: '建议适当增加钙质摄入，如牛奶、豆制品等，必要时可在医生指导下服用钙剂。',
      relatedDisease: '骨折',
      priority: 3
    })
  }

  // 通用健康建议
  addGeneralHealthSuggestions(record: MedicalRecord) {
    this.healthSuggestions.push({
      id: this.healthSuggestions.length + 1,
      title: '健康生活方式',
      content: '建议保持规律作息，均衡饮食，适当运动，避免烟酒，有助于疾病恢复和预防复发。',
      relatedDisease: record.diseaseName,
      priority: 3
    })

    this.healthSuggestions.push({
      id: this.healthSuggestions.length + 1,
      title: '定期复诊',
      content: '建议定期复诊，遵医嘱治疗，及时调整治疗方案，有效控制病情。',
      relatedDisease: record.diseaseName,
      priority: 3
    })
  }

  // 获取优先级文本
  getPriorityText(priority: number): string {
    switch (priority) {
      case 1:
        return '重要'
      case 2:
        return '建议'
      case 3:
        return '参考'
      default:
        return '建议'
    }
  }

  // 获取优先级对应的颜色
  getPriorityColor(priority: number): string {
    switch (priority) {
      case 1:
        return '#FF4D4F'
      case 2:
        return '#1890FF'
      case 3:
        return '#52C41A'
      default:
        return '#1890FF'
    }
  }

  private getDiseaseCategory(diseaseName: string): string {
    const disease = getDiseaseByName(diseaseName);
    return disease ? disease.category : '未分类';
  }

  private addDisease(diseaseName: string): void {
    if (!this.userDiseases.includes(diseaseName)) {
      this.userDiseases = [...this.userDiseases, diseaseName];
      // 更新餐饮推荐服务中的疾病数据
      dietRecommendationService.setUserDiseases(this.userDiseases);
    }
  }
} 