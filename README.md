# RVC 实时变声器 (macOS)

一键安装的 macOS 实时变声器，基于 [RVC (Retrieval-based Voice Conversion)](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI)。

## 特性

- 实时变声，延迟低
- 内置 33 个高质量声音模型（女声/男声/卡通/名人）
- 支持 Apple Silicon (M1/M2/M3/M4) 和 Intel Mac
- Dock 栏一键启动
- 中文界面

## 内置声音模型

共 33 个模型，总大小约 6.9 GB。

### 女声（14 个）

| 音色 | 模型 | 索引 | 总大小 |
|------|------|------|--------|
| OI | 54.9 MB | 31.9 MB | 86.8 MB |
| 云儿青春 | 54.9 MB | 438.5 MB | 493.4 MB |
| 佩佩 | 54.9 MB | 31.9 MB | 86.8 MB |
| 北极星 | 54.9 MB | 306.3 MB | 361.1 MB |
| 可可 | 52.6 MB | 189.0 MB | 241.6 MB |
| 合集 | 52.6 MB | 427.0 MB | 479.7 MB |
| 婉心 | 54.9 MB | 187.7 MB | 242.5 MB |
| 学姐 | 52.7 MB | 124.5 MB | 177.2 MB |
| 小秋少羽 | 54.9 MB | 187.7 MB | 242.6 MB |
| 石榴 | 52.7 MB | 31.9 MB | 84.6 MB |
| 苏苏少洛 | 54.9 MB | 69.9 MB | 124.8 MB |
| 草莓 | 54.9 MB | 124.5 MB | 179.5 MB |
| 诗韵 | 54.9 MB | 163.4 MB | 218.3 MB |
| 雅琳御姐 | 54.9 MB | 193.1 MB | 248.0 MB |

### 男声（13 个）

| 音色 | 模型 | 索引 | 总大小 |
|------|------|------|--------|
| 01号 | 52.7 MB | 342.3 MB | 394.9 MB |
| 02号 | 52.7 MB | 87.3 MB | 139.9 MB |
| 03号 | 52.7 MB | 33.9 MB | 86.6 MB |
| 04号 | 52.7 MB | 30.1 MB | 82.8 MB |
| 06号 | 52.5 MB | 50.0 MB | 102.4 MB |
| 07号 | 52.6 MB | 547.8 MB | 600.5 MB |
| 08号 | 52.5 MB | 31.9 MB | 84.3 MB |
| 09号 | 52.4 MB | 38.6 MB | 91.0 MB |
| 10号 | 52.7 MB | 458.5 MB | 511.2 MB |
| 烟嗓 | 52.5 MB | 90.3 MB | 142.7 MB |
| 男神 | 52.4 MB | 61.0 MB | 113.4 MB |
| 青年 | 52.4 MB | 31.4 MB | 83.9 MB |
| 青年瘦弱 | 52.5 MB | 114.3 MB | 166.8 MB |

### 卡通（2 个）

| 音色 | 模型 | 索引 | 总大小 |
|------|------|------|--------|
| 懒羊羊 | 54.9 MB | 130.8 MB | 185.7 MB |
| 曼波 | 52.7 MB | 134.8 MB | 187.5 MB |

### 名人（4 个）

| 音色 | 模型 | 索引 | 总大小 |
|------|------|------|--------|
| 丁真 | 52.5 MB | 30.1 MB | 82.6 MB |
| 卢本伟 | 52.7 MB | 36.0 MB | 88.7 MB |
| 奥巴马 | 54.9 MB | 46.9 MB | 101.8 MB |
| 特朗普 | 54.9 MB | 527.3 MB | 582.2 MB |

## 一键安装

### 方法一：让 Claude Code 帮你安装（推荐）

如果你使用 [Claude Code](https://claude.ai/claude-code)，只需把这个仓库链接发给它：

```
请帮我安装这个 RVC 变声器：https://github.com/chaye7417/RVC-MacOS
```

Claude Code 会读取 `CLAUDE.md` 文件并自动完成安装。

### 方法二：运行安装脚本

```bash
git clone https://github.com/chaye7417/RVC-MacOS.git
cd RVC-MacOS
chmod +x install.sh
./install.sh
```

安装脚本会自动：
1. 安装 Python 依赖
2. 下载声音模型（约 8GB，国内自动使用镜像加速）
3. 创建 Dock 启动图标

## 使用方法

### 启动
- 点击 Dock 栏的「RVC变声器」图标
- 或运行：`cd ~/Documents/RVC-MacOS && source .venv/bin/activate && python gui.py`

### 音频路由（实现通话变声）

1. 安装 [BlackHole](https://existential.audio/blackhole/)（免费虚拟声卡）
2. RVC 设置：
   - 输入设备：你的麦克风
   - 输出设备：BlackHole 2ch
3. 微信/QQ 等应用设置麦克风为 BlackHole 2ch

### 推荐参数

| 参数 | 推荐值 | 说明 |
|------|--------|------|
| 采样长度 | 0.20 ~ 0.26 | 太小会卡顿 |
| 淡入淡出 | 0.08 ~ 0.10 | |
| 音高算法 | fcpe | 快速；rmvpe 更稳定 |

## 声音模型

### 内置模型下载

安装脚本会自动从 [Hugging Face](https://huggingface.co/chaye741/RVC-Voice-Models) 下载 33 个内置模型（约 6.9 GB）。如果下载失败，可以手动下载：

- **模型地址**：https://huggingface.co/chaye741/RVC-Voice-Models
- **国内镜像**：https://hf-mirror.com/chaye741/RVC-Voice-Models

下载后将文件放到对应目录：
- `.pth` 模型文件 → `assets/weights/`
- `.index` 索引文件 → `logs/`

### 添加自定义模型

你可以添加自己训练或从网上下载的 RVC 模型：

1. 将 `.pth` 文件放入 `assets/weights/` 目录
2. 将 `.index` 文件（如有）放入 `logs/` 目录
3. 重启 RVC，在界面中即可选择新模型

> 推荐模型下载站：[voice-models.com](https://voice-models.com)、[Hugging Face](https://huggingface.co/models?search=rvc)

## 卸载

```bash
./uninstall.sh
```

## 致谢

- [RVC-Project](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI) - 原始 RVC 项目
- [RVC-WebUI-MacOS](https://github.com/NevilPatel01/RVC-WebUI-MacOS) - macOS 适配版本

## 许可证

本项目基于 MIT 许可证开源。声音模型版权归原作者所有，仅供个人学习使用。
