# RVC 变声器安装指南（Claude Code 专用）

本文档供 Claude Code 阅读，执行自动化安装。
**用户只需说「帮我部署」，Claude Code 按以下步骤逐一执行即可。**

---

## 项目概述

- **功能**：实时语音变声器，支持 60+ 声音模型
- **平台**：macOS（Apple Silicon M1/M2/M3/M4 或 Intel）
- **仓库**：https://github.com/chaye7417/RVC-MacOS
- **声音模型**：Hugging Face `chaye741/RVC-Voice-Models`（约 8GB）
- **基础模型**：Hugging Face `lj1995/VoiceConversionWebUI`

---

## 安装步骤

### 步骤 1：检查系统要求

```bash
# 检查 macOS 版本（需要 10.15+）
sw_vers

# 检查 Python 版本（需要 3.10+）
python3 --version

# 检查 Homebrew
which brew || echo "需要先安装 Homebrew"
```

如果没有 Homebrew：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

如果 Python 版本低于 3.10：
```bash
brew install python@3.10
```

---

### 步骤 2：克隆仓库

```bash
cd ~/Documents
git clone https://github.com/chaye7417/RVC-MacOS.git RVC-WebUI-MacOS
cd RVC-WebUI-MacOS
```

---

### 步骤 3：创建虚拟环境

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
```

---

### 步骤 4：安装 PyTorch（macOS 专用）

```bash
# Apple Silicon (M1/M2/M3/M4) 使用 MPS 加速
pip install torch torchvision torchaudio

# 验证安装
python -c "import torch; print('PyTorch:', torch.__version__); print('MPS 可用:', torch.backends.mps.is_available())"
```

---

### 步骤 5：安装项目依赖

```bash
pip install -r requirements/main.txt
```

> 如果 `fairseq` 安装报错，尝试：
> ```bash
> pip install fairseq --no-build-isolation
> ```

---

### 步骤 6：下载基础模型

```bash
pip install huggingface_hub "httpx[socks]"

python3 -c "
from huggingface_hub import snapshot_download
import os

os.makedirs('assets/hubert', exist_ok=True)
os.makedirs('assets/rmvpe', exist_ok=True)

snapshot_download(
    repo_id='lj1995/VoiceConversionWebUI',
    allow_patterns=['hubert_base.pt', 'rmvpe.pt'],
    local_dir='assets',
    local_dir_use_symlinks=False
)
print('基础模型下载完成')
"
```

---

### 步骤 7：下载声音模型（约 8GB）

> 国内网络自动使用镜像加速

```bash
python3 -c "
import os, shutil

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

os.makedirs('assets/weights', exist_ok=True)
os.makedirs('logs', exist_ok=True)

snapshot_download(
    repo_id='chaye741/RVC-Voice-Models',
    local_dir='models_download',
    local_dir_use_symlinks=False
)

# 移动文件到正确位置
if os.path.exists('models_download/weights'):
    for f in os.listdir('models_download/weights'):
        shutil.move(f'models_download/weights/{f}', f'assets/weights/{f}')
        print(f'  移动模型: {f}')

if os.path.exists('models_download/indices'):
    for f in os.listdir('models_download/indices'):
        shutil.move(f'models_download/indices/{f}', f'logs/{f}')
        print(f'  移动索引: {f}')

shutil.rmtree('models_download', ignore_errors=True)
print('声音模型下载完成')
"
```

---

### 步骤 8：创建 Dock 启动图标（可选）

```bash
mkdir -p "/Applications/RVC变声器.app/Contents/MacOS"
mkdir -p "/Applications/RVC变声器.app/Contents/Resources/Scripts"

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

cat > /tmp/rvc_launch.applescript << 'APPLESCRIPT'
do shell script "/bin/bash -c 'export LANG=zh_CN.UTF-8 && cd ~/Documents/RVC-WebUI-MacOS && source .venv/bin/activate && python gui.py' &> /dev/null &"
APPLESCRIPT

osacompile -o "/Applications/RVC变声器.app/Contents/Resources/Scripts/main.scpt" /tmp/rvc_launch.applescript

cp /System/Library/CoreServices/Script\ Menu.app/Contents/MacOS/applet \
   "/Applications/RVC变声器.app/Contents/MacOS/" 2>/dev/null || true

echo "Dock 图标创建完成，在 /Applications 中找到「RVC变声器」并拖到 Dock"
```

---

### 步骤 9：验证安装

```bash
source .venv/bin/activate
python -c "import torch; print('PyTorch:', torch.__version__)"
python -c "import fairseq; print('fairseq: OK')"
python -c "import FreeSimpleGUI; print('GUI 库: OK')"
ls assets/weights/*.pth 2>/dev/null | wc -l | xargs echo "声音模型数量:"
ls assets/hubert/hubert_base.pt && echo "hubert 基础模型: OK"
ls assets/rmvpe/rmvpe.pt && echo "rmvpe 音高模型: OK"
```

---

## 启动方法

```bash
# 命令行启动
cd ~/Documents/RVC-WebUI-MacOS
source .venv/bin/activate
python gui.py
```

或点击 Dock 中的「RVC变声器」图标。

---

## 音频路由配置（通话变声）

安装 BlackHole 虚拟声卡（免费）：
```bash
brew install blackhole-2ch
```

配置步骤：
1. RVC 界面 → 输入设备：选自己的麦克风
2. RVC 界面 → 输出设备：选 **BlackHole 2ch**
3. 微信/飞书等软件 → 麦克风 → 选 **BlackHole 2ch**
4. 点击「开始音频转换」

---

## 推荐参数

| 参数 | 推荐值 | 说明 |
|------|--------|------|
| 采样长度 | 0.20 ~ 0.26 | 太小会卡顿 |
| 淡入淡出 | 0.08 ~ 0.10 | 减少切换噪音 |
| 音高算法 | fcpe | 速度快 |
| 音高算法 | rmvpe | 质量稳定 |

---

## 常见问题

### Q: `fairseq` 安装失败
```bash
pip install fairseq --no-build-isolation
# 或
pip install fairseq --pre
```

### Q: 界面显示英文
启动时加 `LANG=zh_CN.UTF-8`：
```bash
LANG=zh_CN.UTF-8 python gui.py
```

### Q: 声音卡顿/延迟大
增大「采样长度」到 0.25 以上

### Q: 找不到模型文件
重新运行步骤 7

### Q: MPS 不可用（Intel Mac）
Intel Mac 没有 MPS，会自动降级使用 CPU，速度较慢属正常。
