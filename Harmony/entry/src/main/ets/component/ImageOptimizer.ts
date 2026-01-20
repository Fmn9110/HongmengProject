class ImageOptimizer {
  private cache: Map<string, any> = new Map(); // 缓存图片资源
  private maxCacheSize: number = 100; // 增加最大缓存数量，设置为100
  private loadingQueue: string[] = []; // 加载队列
  private maxLoading: number = 20; // 同时加载的最大图片数
  private isLoading: boolean = false;

  // 获取图片资源，懒加载
  async getOptimizedImage(imagePath: string, isVisible: boolean): Promise<any> {
    if (!isVisible) {
      return $r('app.media.placeholder');
    }

    if (this.cache.has(imagePath)) {
      return this.cache.get(imagePath);
    }

    if (!this.loadingQueue.includes(imagePath)) {
      this.loadingQueue.push(imagePath);
    }

    if (!this.isLoading) {
      this.isLoading = true;
      await this.processQueue();
    }

    return new Promise((resolve) => {
      const checkResource = () => {
        if (this.cache.has(imagePath)) {
          resolve(this.cache.get(imagePath));
        } else {
          requestAnimationFrame(checkResource);
        }
      };
      checkResource();
    });
  }

  // 处理加载队列
  private async processQueue() {
    while (this.loadingQueue.length > 0) { // 移除缓存大小限制条件
      const currentLoad = this.loadingQueue.splice(0, this.maxLoading);

      await Promise.all(
        currentLoad.map(async (imagePath) => {
          try {
            // 模拟加载低分辨率图片（替换为实际加载逻辑）
            const resource = await this.loadImage(imagePath);
            this.cache.set(imagePath, resource);
            this.manageCache(); // 管理缓存大小
          } catch (error) {
            console.error(`Failed to load image ${imagePath}:`, error);
          }
        })
      );

      if (this.loadingQueue.length > 0) {
        await new Promise((resolve) => setTimeout(resolve, 50)); // 控制加载速度
      }
    }
    this.isLoading = false;
  }

  // 模拟加载图片（替换为实际资源加载逻辑）
  private async loadImage(imagePath: string): Promise<any> {
    return new Promise((resolve) => {
      const resource = $r(imagePath);
      setTimeout(() => resolve(resource), 100); // 模拟网络延迟
    });
  }

  // 管理缓存，移除最旧的缓存
  private manageCache() {
    if (this.cache.size > this.maxCacheSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
  }
}

// 单例实例
const imageOptimizer = new ImageOptimizer();

export default imageOptimizer;

function $r(arg0: string): any {
  throw new Error("Function not implemented.");
}

function requestAnimationFrame(checkResource: () => void) {
  throw new Error("Function not implemented.");
}