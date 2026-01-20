---
inclusion: manual
---

# UI UX Pro Max Skill

GitHub: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill

## 项目概述

AI 编码助手的设计智能技能，提供可搜索的 UI 样式、配色方案、字体配对、图表类型、UX 指南数据库。

## 核心架构

```
.shared/ui-ux-pro-max/
├── scripts/
│   ├── search.py    # CLI 入口
│   └── core.py      # BM25 搜索引擎
└── data/
    ├── styles.csv       # 57 种 UI 样式
    ├── colors.csv       # 95 种配色方案
    ├── typography.csv   # 56 种字体配对
    ├── charts.csv       # 24 种图表类型
    ├── ux-guidelines.csv # 98 条 UX 指南
    ├── products.csv     # 产品类型推荐
    ├── landing.csv      # 落地页结构
    ├── prompts.csv      # AI 提示词
    └── stacks/          # 9 种技术栈指南
```

## 搜索命令

```bash
# 领域搜索
python3 .shared/ui-ux-pro-max/scripts/search.py "<query>" --domain <domain>

# 技术栈搜索
python3 .shared/ui-ux-pro-max/scripts/search.py "<query>" --stack <stack>
```

领域: `style`, `color`, `typography`, `chart`, `ux`, `product`, `landing`, `prompt`
技术栈: `html-tailwind`, `react`, `nextjs`, `vue`, `nuxt-ui`, `svelte`, `swiftui`, `react-native`, `flutter`

## 搜索引擎原理

- 使用 BM25 算法进行文本相关性排序
- 支持自动领域检测（根据关键词匹配）
- 纯 Python 实现，无外部依赖

## CLI 工具

```bash
npm install -g uipro-cli
uipro init --ai <claude|cursor|windsurf|kiro|copilot|all>
uipro update
uipro versions
```

## 多平台同步规则

修改文件时需同步到所有平台：
- `.claude/skills/ui-ux-pro-max/`
- `.cursor/commands/`
- `.windsurf/workflows/`
- `.agent/workflows/`
- `.github/prompts/`
- `.kiro/steering/`
- `.shared/ui-ux-pro-max/`
- `cli/assets/` (所有上述目录的副本)

## Git 工作流

禁止直接推送 main，必须通过 PR：
```bash
git checkout -b feat/xxx
git push -u origin feat/xxx
gh pr create
```
