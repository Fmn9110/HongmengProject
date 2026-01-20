import HealthMonitorPage from '../healthpage/HealthMonitorPage';
import AIConsultation from '../aiconsultation/AIConsultation';
import DevicePage from '../devicepage/DevicePage';
import mine from '../mine/Mine';
import router from '@ohos.router';

// 定义路由参数接口
interface RouteParams {
  initialTab?: number;
}

@Entry
@Component
export struct Index {
  @State private currentIndex: number = 0; // 当前选中的Tab索引
  private readonly TAB_BAR_HEIGHT: number = 50; // 底部Tab栏高度
  tabController: TabsController = new TabsController(); // Tab控制器
  tabTitles: string[] = ["健康", "问诊", "设备", "我的"]; // Tab栏标题
  tabTextColors: string[] = ["#ffb1adad", "#0BACCE"]; // Tab文字颜色（未选中/选中）

  aboutToAppear() {
    // 获取路由参数，如果有initialTab参数，则切换到对应的选项卡
    const params = router.getParams() as RouteParams;
    if (params && params.initialTab !== undefined) {
      const tabIndex = params.initialTab;
      // 确保索引在有效范围内
      if (tabIndex >= 0 && tabIndex < this.tabTitles.length) {
        this.currentIndex = tabIndex;
        // 使用nextTick确保UI渲染后再切换Tab
        setTimeout(() => {
          this.tabController.changeIndex(tabIndex);
        }, 10);
      }
    }
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
        // 健康Tab页面
        TabContent() {
          Column() {
            HealthMonitorPage()
              .width('100%')
              .height('100%')
          }
          .width('100%')
          .height('92%')
          .padding({ bottom: 10 }) // 为健康页面底部添加间距
        }.tabBar(this.createTabMenu(0))

        // 问诊Tab页面
        TabContent() {
          Column() {
            AIConsultation()
              .width('100%')
              .height('100%')
          }
          .width('100%')
          .height('92%')
        }.tabBar(this.createTabMenu(1))

        // 设备Tab页面
        TabContent() {
          Column() {
            DevicePage()
              .width('100%')
              .height('100%')
          }
          .width('100%')
          .height('92%')
        }.tabBar(this.createTabMenu(2))

        // 我的Tab页面
        TabContent() {
          Column() {
            mine()
              .width('100%')
              .height('100%')
          }
          .width('100%')
          .height('92%')
        }.tabBar(this.createTabMenu(3))
      }
      .margin({ bottom: 15 })
      .barHeight(this.TAB_BAR_HEIGHT) // 设置Tab栏高度
      .backgroundColor(Color.White) // 设置Tab栏背景色
      .onChange((index: number) => {
        this.currentIndex = index; // Tab切换时更新当前选中索引
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White) // 整体背景色为白色
  }

  // 创建底部Tab菜单项（包含图标和文字）
  @Builder
  createTabMenu(index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        // 显示Tab图标，按选中状态切换图片
        Image(
          this.currentIndex === index
            ? `/images/main_page_index${index}_pre.png`
            : `/images/main_page_index${index}_nor.png`
        )
          .width(30)
          .height(30)

        // 显示Tab文字，按选中状态切换颜色
        Text(this.tabTitles[index])
          .fontColor(this.tabTextColors[this.currentIndex === index ? 1 : 0])
          .fontSize('12')
      }
    }
  }
}
