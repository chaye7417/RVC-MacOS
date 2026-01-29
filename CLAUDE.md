# RVC 变声器安装指南（Claude Code 专用）

本文档供 Claude Code 阅读，用于自动化安装 RVC 实时变声器。

## 项目概述

- **功能**：实时语音变声器，支持 60+ 声音模型
- **平台**：macOS (Apple Silicon / Intel)
- **模型来源**：Hugging Face (`chaye741/RVC-Voice-Models`)

## 安装步骤

### 步骤 1：检查系统要求

```bash
# 检查 macOS 版本（需要 10.15+）
sw_vers

# 检查是否安装 Homebrew
which brew || echo "需要安装 Homebrew"

# 检查 Python 版本（需要 3.10+）
python3 --version
```

如果没有 Homebrew，安装它：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 步骤 2：克隆仓库

```bash
cd ~/Documents
git clone https://github.com/chaye7417/RVC-MacOS.git RVC-WebUI-MacOS
cd RVC-WebUI-MacOS
```

### 步骤 3：创建虚拟环境并安装依赖

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements/requirements-macos.txt
```

### 步骤 4：下载预训练模型

```bash
# 安装 huggingface_hub
pip install huggingface_hub "httpx[socks]"

# 下载基础模型
python -c "
from huggingface_hub import snapshot_download
import os

# 下载 hubert 模型
snapshot_download(
    repo_id='lj1995/VoiceConversionWebUI',
    allow_patterns=['hubert_base.pt', 'rmvpe.pt'],
    local_dir='assets',
    local_dir_use_symlinks=False
)
print('基础模型下载完成')
"
```

### 步骤 5：下载声音模型（约 8GB）

**国内用户**（自动检测，使用镜像加速）：
```bash
python -c "
import os
import subprocess

# 检测网络，决定使用镜像还是原站
def check_hf_access():
    try:
        import httpx
        r = httpx.get('https://huggingface.co', timeout=5)
        return r.status_code == 200
    except:
        return False

if check_hf_access():
    os.environ['HF_ENDPOINT'] = 'https://huggingface.co'
    print('使用 Hugging Face 原站')
else:
    os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
    print('使用镜像站 hf-mirror.com')

from huggingface_hub import snapshot_download

# 下载声音模型
snapshot_download(
    repo_id='chaye741/RVC-Voice-Models',
    local_dir='models_download',
    local_dir_use_symlinks=False
)

# 移动文件到正确位置
import shutil
if os.path.exists('models_download/weights'):
    for f in os.listdir('models_download/weights'):
        shutil.move(f'models_download/weights/{f}', f'assets/weights/{f}')
if os.path.exists('models_download/indices'):
    for f in os.listdir('models_download/indices'):
        shutil.move(f'models_download/indices/{f}', f'logs/{f}')

shutil.rmtree('models_download', ignore_errors=True)
print('声音模型下载完成')
"
```

### 步骤 6：创建 Dock 启动图标

```bash
# 创建 AppleScript 应用
mkdir -p "/Applications/RVC变声器.app/Contents/MacOS"
mkdir -p "/Applications/RVC变声器.app/Contents/Resources/Scripts"

# 创建 Info.plist
cat > "/Applications/RVC变声器.app/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>applet</string>
    <key>CFBundleName</key>
    <string>RVC变声器</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
PLIST

# 创建启动脚本
cat > /tmp/rvc_launch.applescript << 'APPLESCRIPT'
do shell script "/bin/bash -c 'export LANG=zh_CN.UTF-8 && cd ~/Documents/RVC-WebUI-MacOS && source .venv/bin/activate && python gui.py' &> /dev/null &"
APPLESCRIPT

osacompile -o "/Applications/RVC变声器.app/Contents/Resources/Scripts/main.scpt" /tmp/rvc_launch.applescript

# 复制 applet 可执行文件（从系统模板）
cp /System/Library/CoreServices/Script\ Menu.app/Contents/MacOS/applet "/Applications/RVC变声器.app/Contents/MacOS/" 2>/dev/null || \
cp /System/Library/CoreServices/Automator\ Runner.app/Contents/MacOS/Automator\ Runner "/Applications/RVC变声器.app/Contents/MacOS/applet" 2>/dev/null

echo "Dock 图标创建完成"
```

### 步骤 7：验证安装

```bash
source .venv/bin/activate
python -c "import torch; print(f'PyTorch: {torch.__version__}')"
python -c "import fairseq; print('fairseq OK')"
ls assets/weights/*.pth | wc -l | xargs echo "声音模型数量:"
```

## 启动方法

```bash
# 方法1：Dock 图标
# 点击「RVC变声器」图标

# 方法2：命令行
cd ~/Documents/RVC-WebUI-MacOS && source .venv/bin/activate && python gui.py
```

## 音频路由配置（通话变声）

1. 安装 BlackHole 虚拟声卡：
```bash
brew install blackhole-2ch
```

2. RVC 中设置：
   - 输入设备：用户的麦克风（如 Duet USB）
   - 输出设备：BlackHole 2ch

3. 通话软件（微信等）设置麦克风为 BlackHole 2ch

## 常见问题

### Q: 提示找不到模型文件
A: 运行步骤 5 下载声音模型

### Q: 界面是英文
A: 确保启动时设置了 `LANG=zh_CN.UTF-8`

### Q: 声音卡顿
A: 增大「采样长度」参数到 0.25 以上

## 文件结构

```
RVC-WebUI-MacOS/
├── gui.py              # 主程序
├── assets/
│   ├── weights/        # .pth 模型文件
│   ├── hubert/         # hubert 基础模型
│   └── rmvpe/          # rmvpe 音高模型
├── logs/               # .index 索引文件
└── configs/            # 配置文件
```
