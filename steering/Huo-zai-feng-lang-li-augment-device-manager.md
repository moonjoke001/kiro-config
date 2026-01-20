---
inclusion: manual
---

# Augment Device Manager 项目分析

## 项目概述
Cursor/VSCode IDE 的 Augment 扩展设备限制解决方案，支持远程分发和自动配置更新。

GitHub: https://github.com/Huo-zai-feng-lang-li/augment-device-manager

## 核心原理

### 设备身份重置
通过修改 IDE 的 `storage.json` 和 `state.vscdb` 中的设备标识符，让扩展认为是新设备：

```javascript
// 关键设备ID字段
const deviceIdentityFields = [
  'telemetry.devDeviceId',      // UUID v4 格式
  'telemetry.machineId',        // SHA256 hex (64 chars)
  'telemetry.macMachineId',     // SHA512 hex (128 chars)
  'telemetry.sqmId',            // {UUID-UPPER} 格式
  'storage.serviceMachineId',   // UUID v4 格式
];
```

### 三种清理模式
1. **智能清理** (`intelligentMode`) - 仅更新设备身份，保留所有配置
2. **标准清理** (`standardMode`) - 深度清理但保留核心配置
3. **完全清理** (`completeMode`) - 彻底重置，仅保护 MCP 配置

## 关键路径

### Windows
```
~/.config/Cursor/User/globalStorage/storage.json
~/.config/Cursor/User/globalStorage/state.vscdb
~/.config/Code/User/globalStorage/storage.json
~/.config/Code/User/globalStorage/state.vscdb
```

### Linux
```
~/.config/Cursor/User/globalStorage/storage.json
~/.config/Cursor/User/globalStorage/state.vscdb
~/.config/Code/User/globalStorage/storage.json
```

### macOS
```
~/Library/Application Support/Cursor/User/globalStorage/storage.json
~/Library/Application Support/Code/User/globalStorage/storage.json
```

## 核心代码模式

### 设备ID生成
```javascript
// 使用统一ID生成器
const IDGenerator = require('shared/utils/id-generator');
const newIdentity = IDGenerator.generateCompleteDeviceIdentity('cursor');
// 返回: { 'telemetry.devDeviceId': '...', 'telemetry.machineId': '...', ... }
```

### MCP配置保护
```javascript
// 清理前保护
const mcpConfigs = await this.protectMCPConfigUniversal(results);
// 执行清理...
// 清理后恢复
await this.restoreMCPConfigUniversal(results, mcpConfigs);
```

### 增强守护进程
```javascript
// 启动独立守护服务（客户端关闭后仍运行）
const serviceResult = await this.standaloneService.startStandaloneService(deviceId, {
  enableBackupMonitoring: true,
  enableDatabaseMonitoring: true,
  enableEnhancedProtection: true,
});
```

## 项目结构
```
augment-device-manager/
├── modules/
│   ├── admin-backend/          # 管理后台 (Express + WebSocket)
│   │   └── src/server-simple.js
│   └── desktop-client/         # Electron 桌面客户端
│       └── src/
│           ├── main.js
│           ├── device-manager.js      # 核心设备管理
│           ├── enhanced-device-guardian.js  # 增强守护
│           └── standalone-guardian-service.js  # 独立守护服务
├── shared/
│   └── utils/
│       ├── id-generator.js     # 统一ID生成
│       └── stable-device-id.js # 稳定设备ID
└── scripts/                    # 构建和部署脚本
```

## 与 Kiro Pro Free 的区别

| 特性 | Augment Device Manager | Kiro Pro Free |
|------|----------------------|---------------|
| 目标 | Augment 扩展 | Kiro IDE |
| 架构 | Electron 桌面应用 | Python 脚本 |
| 守护 | 独立守护服务 | 无 |
| 远程 | 支持远程分发 | 本地运行 |
| Token | 无 bypass | JS patch bypass |

## 可借鉴的技术

1. **增强守护进程** - 实时监控 storage.json 变化并恢复
2. **独立服务模式** - 客户端关闭后守护进程继续运行
3. **MCP配置保护** - 清理时自动保护和恢复 MCP 配置
4. **多IDE支持** - 同时支持 Cursor 和 VSCode 多个变体
5. **workspaceStorage清理** - 智能清理工作区存储

## 注意事项

- 需要关闭 IDE 后再执行清理
- 清理后需要重新登录 Augment 扩展
- 守护进程会持续监控并恢复设备ID
- MCP 配置会被自动保护，无需手动备份
