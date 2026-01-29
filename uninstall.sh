#!/bin/bash
# RVC 变声器卸载脚本

echo "======================================"
echo "   RVC 变声器 - 卸载脚本"
echo "======================================"
echo ""

read -p "确定要卸载 RVC 变声器吗？(y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消卸载"
    exit 0
fi

echo "正在卸载..."

# 删除 Dock 应用
if [ -d "/Applications/RVC变声器.app" ]; then
    rm -rf "/Applications/RVC变声器.app"
    echo "✓ 已删除 Dock 应用"
fi

# 询问是否删除项目文件
read -p "是否删除项目文件和模型？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    PROJECT_DIR="$HOME/Documents/RVC-WebUI-MacOS"
    if [ -d "$PROJECT_DIR" ]; then
        rm -rf "$PROJECT_DIR"
        echo "✓ 已删除项目文件"
    fi
fi

echo ""
echo "卸载完成！"
