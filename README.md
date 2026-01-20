# Kiro CLI 配置同步

跨设备同步 Kiro CLI 配置的 Git 仓库。

## 快速开始

新电脑运行：
```bash
curl -fsSL https://raw.githubusercontent.com/moonjoke001/kiro-config/main/setup.sh | bash
```

## 目录结构

```
kiro-config/
├── setup.sh           # 初始化脚本
├── settings/
│   └── cli.json       # CLI 设置
├── agents/            # Agent 配置
└── steering/          # Steering 文件
    ├── rules.md
    ├── roles.md
    └── knowledge-base.md
```

## 日常使用

**推送配置更新**：
```bash
cd ~/.kiro/kiro-config
git add .
git commit -m "Update: 配置说明"
git push
```

**拉取最新配置**：
```bash
cd ~/.kiro/kiro-config && git pull
```

## 工作原理

使用符号链接将配置链接到 `~/.kiro/`，修改会自动反映到仓库。