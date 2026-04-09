#!/bin/bash
# RVC 变声器一键安装脚本
# 适用于 macOS (Apple Silicon / Intel)

set -e

echo "======================================"
echo "   RVC 实时变声器 - 一键安装脚本"
echo "======================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否在正确的目录
if [ ! -f "gui.py" ]; then
    echo -e "${RED}错误：请在 RVC-WebUI-MacOS 目录下运行此脚本${NC}"
    exit 1
fi

PROJECT_DIR=$(pwd)

# 步骤 1：检查系统要求
echo -e "${YELLOW}[1/6] 检查系统要求...${NC}"

# 检查 macOS 版本
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${RED}错误：此脚本仅支持 macOS${NC}"
    exit 1
fi

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}错误：未找到 Python3，请先安装 Python 3.10+${NC}"
    echo "推荐使用 Homebrew 安装：brew install python@3.10"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "Python 版本：$PYTHON_VERSION"

# 步骤 2：创建虚拟环境
echo ""
echo -e "${YELLOW}[2/6] 创建 Python 虚拟环境...${NC}"

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "虚拟环境创建完成"
else
    echo "虚拟环境已存在，跳过"
fi

source .venv/bin/activate

# 步骤 3：安装依赖
echo ""
echo -e "${YELLOW}[3/6] 安装 Python 依赖...${NC}"

pip3 cache purge -q
pip3 install --upgrade "pip<24.1" -q
pip install -r requirements/main.txt -q
pip install huggingface_hub "httpx[socks]" -q
echo "依赖安装完成"

# 步骤 4：下载声音模型
echo ""
echo -e "${YELLOW}[4/6] 下载声音模型（约 8GB，请耐心等待）...${NC}"

python3 << 'PYTHON_SCRIPT'
import os
import sys

# 检测网络，决定使用镜像还是原站
def check_hf_access():
    try:
        import httpx
        r = httpx.get('https://huggingface.co', timeout=5)
        return r.status_code == 200
    except:
        return False

if check_hf_access():
    print('使用 Hugging Face 原站下载...')
else:
    os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
    print('检测到国内网络，使用镜像站加速...')

from huggingface_hub import snapshot_download
import shutil

# 检查是否已有模型
weights_dir = 'assets/weights'
existing_models = len([f for f in os.listdir(weights_dir) if f.endswith('.pth')]) if os.path.exists(weights_dir) else 0

if existing_models > 10:
    print(f'检测到已有 {existing_models} 个声音模型，跳过下载')
    sys.exit(0)

print('开始下载声音模型...')
try:
    snapshot_download(
        repo_id='chaye741/RVC-Voice-Models',
        local_dir='models_download',
        local_dir_use_symlinks=False
    )

    # 移动文件到正确位置
    os.makedirs('assets/weights', exist_ok=True)
    os.makedirs('logs', exist_ok=True)

    if os.path.exists('models_download/weights'):
        for f in os.listdir('models_download/weights'):
            src = f'models_download/weights/{f}'
            dst = f'assets/weights/{f}'
            if not os.path.exists(dst):
                shutil.move(src, dst)

    if os.path.exists('models_download/indices'):
        for f in os.listdir('models_download/indices'):
            src = f'models_download/indices/{f}'
            dst = f'logs/{f}'
            if not os.path.exists(dst):
                shutil.move(src, dst)

    shutil.rmtree('models_download', ignore_errors=True)
    print('声音模型下载完成！')
except Exception as e:
    print(f'下载失败：{e}')
    print('你可以稍后手动下载模型')
PYTHON_SCRIPT

# 步骤 5：创建 Dock 启动图标
echo ""
echo -e "${YELLOW}[5/6] 创建 Dock 启动图标...${NC}"

APP_PATH="/Applications/RVC变声器.app"

# 删除旧的（如果存在）
rm -rf "$APP_PATH"

# 创建应用结构
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources/Scripts"

# 创建 Info.plist
cat > "$APP_PATH/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>applet</string>
    <key>CFBundleIconFile</key>
    <string>applet</string>
    <key>CFBundleName</key>
    <string>RVC变声器</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>RVC 变声器需要使用麦克风进行实时变声</string>
</dict>
</plist>
PLIST

# 创建启动脚本
cat > /tmp/rvc_launch.applescript << APPLESCRIPT
do shell script "/bin/bash -c 'export LANG=zh_CN.UTF-8 && cd $PROJECT_DIR && source .venv/bin/activate && python gui.py' &> /dev/null &"
APPLESCRIPT

osacompile -o "$APP_PATH/Contents/Resources/Scripts/main.scpt" /tmp/rvc_launch.applescript

# 复制 applet
if [ -f "/System/Library/CoreServices/Script Menu.app/Contents/MacOS/applet" ]; then
    cp "/System/Library/CoreServices/Script Menu.app/Contents/MacOS/applet" "$APP_PATH/Contents/MacOS/"
fi

echo "Dock 图标创建完成"

# 步骤 6：验证安装
echo ""
echo -e "${YELLOW}[6/6] 验证安装...${NC}"

MODEL_COUNT=$(ls assets/weights/*.pth 2>/dev/null | wc -l | tr -d ' ')
INDEX_COUNT=$(ls logs/*.index 2>/dev/null | wc -l | tr -d ' ')

echo "声音模型：$MODEL_COUNT 个"
echo "索引文件：$INDEX_COUNT 个"

echo ""
echo -e "${GREEN}======================================"
echo "   安装完成！"
echo "======================================${NC}"
echo ""
echo "启动方式："
echo "  1. 点击 Dock 栏的「RVC变声器」图标"
echo "  2. 或运行命令：cd $PROJECT_DIR && source .venv/bin/activate && python gui.py"
echo ""
echo "如需通话变声，请安装 BlackHole 虚拟声卡："
echo "  brew install blackhole-2ch"
echo ""
