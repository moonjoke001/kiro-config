---
inclusion: manual
---

# Kiro 机器码/设备ID 说明

## Kiro IDE 实际使用的设备标识符

Kiro IDE 使用自己生成的设备ID，存储在用户配置目录：

**位置**: `~/.config/Kiro/User/globalStorage/storage.json`

**关键字段**:
- `telemetry.devDeviceId`: 主要设备ID (UUID格式)
- `telemetry.machineId`: 64位十六进制
- `telemetry.macMachineId`: 128位十六进制
- `telemetry.sqmId`: Windows SQM ID格式
- `storage.serviceMachineId`: 服务机器ID (UUID格式)

## 系统 machine-id

**位置**: `/etc/machine-id` (Linux)

这是系统级的机器标识符，**不是** Kiro IDE 使用的设备ID。

## 项目对比

| 项目 | 管理的机器码 | 位置 |
|------|-------------|------|
| kiro-pro-free | Kiro IDE 配置中的 telemetry.devDeviceId 等 | `~/.config/Kiro/User/globalStorage/storage.json` |
| Kiro-account-manager | 系统 machine-id | `/etc/machine-id` |

## 问题发现

**Kiro-account-manager** (`chaogei/Kiro-account-manager`) 的机器码管理功能存在设计问题：

- 它读写的是系统级 `/etc/machine-id`
- 但 Kiro IDE 实际使用的是自己配置文件中的 `telemetry.devDeviceId`
- 因此该工具的机器码管理功能**无法**真正影响 Kiro IDE 的设备识别

## 正确的机器码管理方式

应该直接修改 `~/.config/Kiro/User/globalStorage/storage.json` 中的相关字段，参考 kiro-pro-free 项目的实现。
