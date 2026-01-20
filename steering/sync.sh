#!/bin/bash
# Kiro Steering 同步脚本

STEERING_DIR="$HOME/.kiro/steering"
SETTINGS_DIR="$HOME/.kiro/settings"

cd "$STEERING_DIR" || exit 1

case "$1" in
  push)
    # 复制 cli.json 到 steering 目录
    cp "$SETTINGS_DIR/cli.json" "$STEERING_DIR/cli.json"
    git add -A
    git commit -m "sync: $(date '+%Y-%m-%d %H:%M')"
    git push
    ;;
  pull)
    git pull
    # 恢复 cli.json 到 settings 目录
    if [ -f "$STEERING_DIR/cli.json" ]; then
      mkdir -p "$SETTINGS_DIR"
      cp "$STEERING_DIR/cli.json" "$SETTINGS_DIR/cli.json"
      echo "✅ cli.json 已恢复到 $SETTINGS_DIR"
    fi
    ;;
  *)
    echo "用法: $0 {push|pull}"
    echo "  push - 推送 steering 和 cli.json 到 GitHub"
    echo "  pull - 从 GitHub 拉取并恢复 cli.json"
    ;;
esac
