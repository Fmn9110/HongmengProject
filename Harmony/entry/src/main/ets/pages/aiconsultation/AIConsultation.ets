import { Toolbar } from '../../component/Toolbar';
import http from '@ohos.net.http';
import { Prompt } from '@kit.ArkUI';
import { lvMarkdownIn, lvTitle, lvText } from '@luvi/lv-markdown-in';

// 颜色常量
const PRIMARY_TEXT_COLOR: ResourceColor = Color.Black;
const SECONDARY_TEXT_COLOR: ResourceColor = '#666666';
const ACCENT_COLOR: ResourceColor = '#007DFF';
const LIGHT_BLUE: ResourceColor = '#fff6f8ff';
const USER_MESSAGE_COLOR: ResourceColor = '#ff0099ff';

lvText.setTextColor("black")
lvTitle.setLevelTitleColor("black")
// API消息接口
interface APIMessage {
  role: 'user' | 'assistant';
  content: string;
}

// HTTP头部接口
interface HttpHeaders {
  Authorization: string;
  'Content-Type': string;
}

// API返回内容结构
interface ChoiceMessage {
  content: string;
}

interface Choice {
  message: ChoiceMessage;
}

interface APIResponse {
  choices: Choice[];
}


// 聊天消息类
class ChatMessage {
  sender: 'user' | 'ai';
  text: string; // 纯文本内容
  rawText: string; // 原始 Markdown 文本
  timestamp: string;
  id: number;

  constructor(sender: 'user' | 'ai', text: string, rawText: string, timestamp: string) {
    this.sender = sender;
    this.text = text;
    this.rawText = rawText;
    this.timestamp = timestamp;
    this.id = Date.now() + Math.random();
  }
}

@Entry
@Preview
@Component
export default struct AIConsultation {
  @State messages: ChatMessage[] = [
    new ChatMessage(
      'ai',
      '',
      '',
      new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    )
  ];
  @State userInput: string = '';
  @State isAITyping: boolean = false;
  private scroller: Scroller = new Scroller();

  // 发送消息
  private sendMessage(): void {
    if (this.userInput.trim() === '') {
      return;
    }
    const userMessage: ChatMessage = new ChatMessage(
      'user',
      this.userInput,
      this.userInput,
      new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    );
    this.messages = [...this.messages, userMessage];
    this.userInput = '';
    this.scrollToBottom();
    this.isAITyping = true;
    this.callAPI(this.messages);
  }

  // 调用AI接口
  private async callAPI(currentMessages: ChatMessage[]): Promise<void> {
    const apiMessages: APIMessage[] = currentMessages.map((msg: ChatMessage): APIMessage => ({
      role: msg.sender === 'user' ? 'user' : 'assistant',
      content: msg.text
    }));

    const httpRequest = http.createHttp();
    const url: string = 'https://openrouter.ai/api/v1/chat/completions';
    const headers: HttpHeaders = {
      Authorization: 'Bearer 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',
      'Content-Type': 'application/json'
    };
    const body: string = JSON.stringify({
      model: 'deepseek/deepseek-chat-v3-0324:free',
      messages: apiMessages
    });

    let aiMessageBeingStreamed: ChatMessage | null = null;

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: body,
        connectTimeout: 10000,
        readTimeout: 60000
      });

      if (response.responseCode === 200 && response.result) {
        const result: string = response.result.toString();
        const jsonResponse: APIResponse = JSON.parse(result) as APIResponse;

        if (jsonResponse.choices && jsonResponse.choices.length > 0 && jsonResponse.choices[0].message &&
        jsonResponse.choices[0].message.content) {
          const content: string = jsonResponse.choices[0].message.content;
          aiMessageBeingStreamed = new ChatMessage(
            'ai',
            content,
            content,
            new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
          );
          this.messages = [...this.messages, aiMessageBeingStreamed];
          this.scrollToBottom();
        } else {
          throw new Error('API response content is missing');
        }
      } else {
        const errorBody = response.result ? response.result.toString() : 'Unknown error';
        throw new Error(`API request failed with status ${response.responseCode}: ${errorBody}`);
      }
    } catch (error) {
      const errorMessage: ChatMessage = new ChatMessage(
        'ai',
        '抱歉，获取回复时发生了错误，请稍后再试。',
        '抱歉，获取回复时发生了错误，请稍后再试。',
        new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      );
      this.messages = [...this.messages, errorMessage];
      Prompt.showToast({ message: 'API请求失败', duration: 2000 });
    } finally {
      this.isAITyping = false;
      httpRequest.destroy();
      this.scrollToBottom();
    }
  }

  // 滚动到底部
  private scrollToBottom(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 200);
  }

  build() {
    Column() {
      Toolbar({ title: 'AI问诊' }) {
        Column() {
          // 添加顶部样式框
          Stack() {
            Row() {
              Row() {
                Column() {
                  Text('您好！👋')
                    .fontSize(23)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#666666')
                    .maxLines(2)
                    .margin({ left: -150 })
                  Text('我是您的AI健康助手。请问有什么我可以帮您的？')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#666666')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 5 })
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .padding({ left: 85, right: 10 })
            }
            .width('99%')
            .height(100)
            .borderRadius(16)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['#ffc3f4fc', 0.1], ['#fff4fcfc', 0.8]]
            })
            .margin(10)
            .shadow({
              radius: 5,
              color: 'rgba(196, 196, 196, 0.50)',
              offsetX: 2,
              offsetY: 2
            })
            .padding(10)
            .margin({ top: 30, bottom: 15 })

            // 叠加的图片，带自定义位置
            Image($r('app.media.character_image'))
              .width('20%')
              .height(120)
              .borderRadius(12)
              .zIndex(1)// 确保图片位于顶部
              .align(Alignment.TopStart)// 锚定到左上角
              .offset({ x: -130, y: -18 }) // 微调位置
          }
          .width('99%')
          .height(150)


          Scroll(this.scroller) {
            Column() {
              ForEach(this.messages, (message: ChatMessage) => {
                Column() {
                  if (message.sender === 'ai' && message.text !== '') {
                    Column() {
                      lvMarkdownIn({ text: message.rawText, loadMode: 'text' })
                        .width('100%')
                        .height('auto')
                        .backgroundColor(Color.White)
                        .borderRadius(12)
                        .shadow({ radius: 4, color: '#00000020' })

                      Text(message.timestamp)
                        .fontSize(12)
                        .fontColor(SECONDARY_TEXT_COLOR)
                        .margin({ top: 5 })
                        .textAlign(TextAlign.Start)
                    }
                    .width('80%')
                    .alignItems(HorizontalAlign.Start)
                    .margin({ top: 10, bottom: 5 })
                  } else if (message.sender === 'user') {
                    Column() {
                      Text(message.text)
                        .fontSize(16)
                        .fontColor(Color.White)
                        .padding(12)
                        .backgroundColor(USER_MESSAGE_COLOR)
                        .borderRadius(12)
                        .textAlign(TextAlign.Start)
                        .shadow({ radius: 4, color: '#00000020' })
                        .maxLines(undefined)
                      Text(message.timestamp)
                        .fontSize(12)
                        .fontColor(SECONDARY_TEXT_COLOR)
                        .margin({ top: 5 })
                        .textAlign(TextAlign.End)
                    }
                    .width('80%')
                    .alignItems(HorizontalAlign.End)
                    .margin({ top: 10, bottom: 5 })
                  }
                }
                .width('100%')
                .alignItems(message.sender === 'ai' ? HorizontalAlign.Start : HorizontalAlign.End)
              },
                (message: ChatMessage, index: number) => `${message.timestamp}-${message.sender}-${index}`
              )

              if (this.isAITyping) {
                Column() {
                  Text('AI 正在思考，请稍后...')
                    .fontSize(14)
                    .fontColor(SECONDARY_TEXT_COLOR)
                    .fontStyle(FontStyle.Italic)
                    .padding({
                      left: 12,
                      right: 12,
                      top: 8,
                      bottom: 8
                    })
                    .backgroundColor(Color.White)
                    .borderRadius(12)
                    .shadow({ radius: 4, color: '#00000020' })
                }
                .width('auto')
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 10, top: 10, bottom: 20 })
              }
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              bottom: 16,
              top: 10
            })
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)

          Row() {
            TextInput({ text: this.userInput, placeholder: '请输入您的问题...' })
              .fontSize(16)
              .fontColor(PRIMARY_TEXT_COLOR)
              .placeholderColor(SECONDARY_TEXT_COLOR)
              .backgroundColor(Color.White)
              .caretColor(ACCENT_COLOR)
              .borderRadius(20)
              .padding({
                left: 15,
                right: 15,
                top: 10,
                bottom: 10
              })
              .layoutWeight(1)
              .margin({ left: 16, right: 8 })
              .onChange((value: string) => {
                this.userInput = value;
              })
              .onSubmit(() => {
                this.sendMessage();
              })

            Button('发送', { type: ButtonType.Normal })
              .height(40)
              .width(70)
              .backgroundColor(this.userInput.trim() === '' ? '#ffb3b2b2' : '#0BACCE')
              .borderRadius(20)
              .fontColor(Color.White)
              .fontSize(16)
              .margin({ right: 16 })
              .shadow({ radius: 4, color: '#00000020' })
              .enabled(this.userInput.trim() !== '')
              .onClick(() => {
                this.sendMessage();
              })
          }
          .width('100%')
          .padding({ top: 10, bottom: 5 })
          .backgroundColor(LIGHT_BLUE)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .height('96%')
        .backgroundColor(LIGHT_BLUE)
      }
    }
  }
}