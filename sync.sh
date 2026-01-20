#!/bin/bash
# Kiro 配置同步工具

CONFIG_DIR="$HOME/.kiro/kiro-config"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查目录是否存在
if [ ! -d "$CONFIG_DIR" ]; then
    echo "错误: 配置目录不存在，请先运行初始化脚本"
    exit 1
fi

cd "$CONFIG_DIR" || exit 1

# 显示菜单
echo -e "${GREEN}==> Kiro 配置同步工具${NC}"
echo ""
echo "1) 推送配置到 GitHub (push)"
echo "2) 拉取最新配置 (pull)"
echo "3) 查看状态 (status)"
echo "4) 退出"
echo ""
read -p "请选择操作 [1-4]: " choice

case $choice in
    1)
        echo -e "${YELLOW}==> 推送配置到 GitHub${NC}"
        git add .
        read -p "输入提交信息 (默认: Update config): " msg
        msg=${msg:-"Update config"}
        git commit -m "$msg"
        git push origin main
        echo -e "${GREEN}✓ 推送完成${NC}"
        ;;
    2)
        echo -e "${YELLOW}==> 拉取最新配置${NC}"
        git pull origin main
        echo -e "${GREEN}✓ 拉取完成${NC}"
        ;;
    3)
        echo -e "${YELLOW}==> 配置状态${NC}"
        git status
        ;;
    4)
        echo "退出"
        exit 0
        ;;
    *)
        echo "无效选择"
        exit 1
        ;;
esac

# 询问是否进入目录
echo ""
read -p "是否进入配置目录? [y/N]: " enter_dir
if [[ "$enter_dir" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}进入 $CONFIG_DIR${NC}"
    exec $SHELL
fi
