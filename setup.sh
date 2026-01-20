#!/bin/bash
# Kiro CLI 配置同步脚本

set -e

REPO_URL="https://github.com/moonjoke001/kiro-config.git"
CONFIG_DIR="$HOME/.kiro/kiro-config"
KIRO_DIR="$HOME/.kiro"

echo "==> Kiro CLI 配置同步"

# 克隆配置仓库
if [ ! -d "$CONFIG_DIR" ]; then
    echo "克隆配置仓库..."
    git clone "$REPO_URL" "$CONFIG_DIR"
else
    echo "更新配置仓库..."
    cd "$CONFIG_DIR" && git pull
fi

# 创建符号链接
echo "创建符号链接..."

# Settings
if [ -f "$CONFIG_DIR/settings/cli.json" ]; then
    mkdir -p "$KIRO_DIR/settings"
    rm -f "$KIRO_DIR/settings/cli.json"
    ln -sf "$CONFIG_DIR/settings/cli.json" "$KIRO_DIR/settings/cli.json"
    echo "  ✓ settings/cli.json"
fi

# Agents
if [ -d "$CONFIG_DIR/agents" ] && [ "$(ls -A $CONFIG_DIR/agents)" ]; then
    mkdir -p "$KIRO_DIR/agents"
    for agent in "$CONFIG_DIR/agents"/*; do
        [ -f "$agent" ] && ln -sf "$agent" "$KIRO_DIR/agents/$(basename "$agent")"
    done
    echo "  ✓ agents/"
fi

# Steering
if [ -d "$CONFIG_DIR/steering" ]; then
    rm -rf "$KIRO_DIR/steering"
    ln -sf "$CONFIG_DIR/steering" "$KIRO_DIR/steering"
    echo "  ✓ steering/"
fi

echo "==> 完成！配置已同步"