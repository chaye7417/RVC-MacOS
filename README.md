# RVC 实时变声器 (macOS)

一键安装的 macOS 实时变声器，基于 [RVC (Retrieval-based Voice Conversion)](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI)。

## 特性

- 实时变声，延迟低
- 内置 60+ 高质量声音模型（男声/女声/卡通角色）
- 支持 Apple Silicon (M1/M2/M3/M4) 和 Intel Mac
- Dock 栏一键启动
- 中文界面

## 内置声音模型

| 分类 | 数量 | 示例 |
|------|------|------|
| 女声 | 14 | 御姐、少萝、清纯、学姐等 |
| 男声 | 38 | 青年、烟嗓、温柔、男神等 |
| 卡通 | 9 | 海绵宝宝、派大星、懒羊羊等 |

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

## 卸载

```bash
./uninstall.sh
```

## 致谢

- [RVC-Project](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI) - 原始 RVC 项目
- [RVC-WebUI-MacOS](https://github.com/NevilPatel01/RVC-WebUI-MacOS) - macOS 适配版本

## 许可证

本项目基于 MIT 许可证开源。声音模型版权归原作者所有，仅供个人学习使用。
