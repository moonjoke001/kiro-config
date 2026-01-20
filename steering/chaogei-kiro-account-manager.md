---
inclusion: manual
---

# Kiro Account Manager

GitHub: https://github.com/chaogei/Kiro-account-manager

## 项目概述

Kiro IDE 多账号管理工具，支持多账号切换、Token自动刷新、机器码管理、自动换号等功能。

## 技术栈

- Electron 38 + React 19 + TypeScript
- 构建: electron-vite + Vite 7
- 状态管理: Zustand
- 样式: Tailwind CSS 4
- 图标: Lucide React

## 项目结构

```
Kiro-account-manager/Kiro-account-manager/
├── src/
│   ├── main/
│   │   ├── index.ts        # 主进程入口，IPC处理，API调用，Token刷新
│   │   └── machineId.ts    # 机器码读写
│   ├── preload/
│   │   └── index.ts        # IPC桥接，暴露API给渲染进程
│   └── renderer/src/
│       ├── store/accounts.ts   # Zustand状态管理（核心逻辑）
│       ├── components/pages/   # 页面组件
│       │   ├── HomePage.tsx
│       │   ├── SettingsPage.tsx
│       │   ├── MachineIdPage.tsx
│       │   ├── KiroSettingsPage.tsx
│       │   └── AboutPage.tsx
│       ├── components/ui/      # UI组件库
│       └── types/              # TypeScript类型
```

## 关键API端点

- Kiro API: `https://app.kiro.dev/service/KiroWebPortalService/operation`
- 社交登录刷新: `https://prod.us-east-1.auth.desktop.kiro.dev`
- OIDC Token刷新: `https://oidc.{region}.amazonaws.com/token`

## 核心功能实现

### Token刷新 (main/index.ts)

- `refreshOidcToken()`: Builder ID (IdC) Token刷新
- `refreshSocialToken()`: GitHub/Google社交登录Token刷新

### 状态管理 (store/accounts.ts)

关键状态:
- `accounts`: Map<string, Account> - 账号数据
- `activeAccountId`: 当前激活账号
- `autoRefreshEnabled/Interval`: 自动刷新配置
- `autoSwitchEnabled/Threshold`: 自动换号配置
- `machineIdConfig`: 机器码配置

### 机器码管理 (main/machineId.ts)

读写Kiro的机器码文件，支持备份/恢复/随机生成。

## 构建命令

```bash
npm run dev           # 开发
npm run build:win     # Windows
npm run build:mac     # macOS
npm run build:linux   # Linux
```

## 注意事项

1. 修改机器码需要管理员权限
2. 数据存储使用 electron-store
3. 支持代理设置 (HTTP/HTTPS/SOCKS5)

## AppImage 运行方法

```bash
# 解压
./kiro-account-manager-*.AppImage --appimage-extract
cd squashfs-root

# 普通用户运行
./kiro-account-manager --no-sandbox

# 管理员运行（修改机器码需要）
xhost +local:root
sudo ./kiro-account-manager --no-sandbox
```

