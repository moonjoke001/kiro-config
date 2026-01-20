---
inclusion: manual
---

# Antigravity-Manager + OpenCode + Oh-My-OpenCode 配置指南

## 项目概述

### Antigravity-Manager
- **仓库**: https://github.com/lbjlaq/Antigravity-Manager
- **功能**: AI 账号管理与协议反代系统，支持 Google/Anthropic OAuth 转 API
- **技术栈**: Tauri + React + Rust

### 核心机制

#### 低配额自动换号
1. **配额保护**: 账号配额低于阈值时，将该模型加入 `protected_models` 列表，不参与调度
2. **429 限流检测**: 请求失败时自动锁定账号并轮换
   - QUOTA_EXHAUSTED: 60s → 5min → 30min → 2h（指数退避）
   - RATE_LIMIT_EXCEEDED: 30s
   - MODEL_CAPACITY_EXHAUSTED: 15s
3. **账号优先级**: ULTRA > PRO > FREE，同等级高配额优先

#### 关键代码路径
| 功能 | 文件 |
|------|------|
| 配额保护 | `src-tauri/src/proxy/token_manager.rs` |
| 限流检测 | `src-tauri/src/proxy/rate_limit.rs` |
| 账号选择 | `token_manager.rs` → `get_token_internal()` |

---

## OpenCode + Oh-My-OpenCode 安装

### 1. 安装 OpenCode
```bash
brew install opencode
```

### 2. 安装 Oh-My-OpenCode
```bash
bunx oh-my-opencode install --no-tui --claude=no --chatgpt=no --gemini=yes
```

### 3. 配置文件

#### ~/.config/opencode/opencode.json
```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "oh-my-opencode",
    "opencode-antigravity-auth@1.2.8",
    "opencode-supermemory"
  ],
  "provider": {
    "google": {
      "models": {
        "antigravity-gemini-3-pro-high": {
          "name": "Gemini 3 Pro High (Antigravity)",
          "thinking": true,
          "attachment": true,
          "limit": { "context": 1048576, "output": 65535 }
        },
        "antigravity-gemini-3-flash": {
          "name": "Gemini 3 Flash (Antigravity)",
          "attachment": true,
          "limit": { "context": 1048576, "output": 65536 }
        },
        "antigravity-claude-opus-4-5-thinking-high": {
          "name": "Claude Opus 4.5 Thinking High (Antigravity)",
          "thinking": true,
          "attachment": true,
          "limit": { "context": 200000, "output": 32000 }
        },
        "antigravity-claude-sonnet-4-5": {
          "name": "Claude Sonnet 4.5 (Antigravity)",
          "attachment": true,
          "limit": { "context": 200000, "output": 16000 }
        }
      }
    }
  }
}
```

#### ~/.config/opencode/oh-my-opencode.json
```json
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json",
  "google_auth": false,
  "agents": {
    "Sisyphus": {
      "model": "google/antigravity-claude-opus-4-5-thinking-high"
    },
    "oracle": {
      "model": "opencode/glm-4.7-free"
    },
    "librarian": {
      "model": "opencode/glm-4.7-free"
    },
    "explore": {
      "model": "opencode/grok-code"
    },
    "frontend-ui-ux-engineer": {
      "model": "google/antigravity-gemini-3-pro-high"
    },
    "document-writer": {
      "model": "google/antigravity-gemini-3-flash"
    },
    "multimodal-looker": {
      "model": "google/antigravity-gemini-3-flash"
    }
  },
  "background_task": {
    "defaultConcurrency": 5,
    "providerConcurrency": {
      "google": 10
    }
  },
  "disabled_hooks": ["anthropic-context-window-limit-recovery"]
}
```

#### ~/.config/opencode/antigravity.json（多账号配置）
```json
{
  "$schema": "https://raw.githubusercontent.com/NoeFabris/opencode-antigravity-auth/main/assets/antigravity.schema.json",
  "quiet_mode": false,
  "debug": false,
  "auto_update": true,
  "session_recovery": true,
  "auto_resume": true,
  "account_selection_strategy": "sticky",
  "quota_fallback": true,
  "switch_on_first_rate_limit": true,
  "max_rate_limit_wait_seconds": 300,
  "proactive_token_refresh": true
}
```

### 4. 认证
```bash
opencode auth login
# 选择 Google → OAuth with Google (Antigravity)
# 可添加多个账号实现负载均衡
```

---

## 多账号策略

| 策略 | 说明 | 适用场景 |
|------|------|---------|
| `sticky` | 粘性，保持同一账号直到限流 | 长对话、省 token（推荐） |
| `round-robin` | 每次请求轮换 | 高并发短任务 |
| `hybrid` | 先轮询再粘性 | 同步配额重置时间 |

---

## 推荐插件

| 插件 | 说明 |
|------|------|
| oh-my-opencode | 全功能增强，多 agent 协作 |
| opencode-antigravity-auth | Antigravity OAuth 认证 |
| opencode-supermemory | 跨会话长期记忆 |
| opencode-dynamic-context-pruning | 智能裁剪上下文 |

---

## 使用技巧

1. **魔法关键词**: prompt 中加 `ultrawork` 或 `ulw` 启用全部高级功能
2. **调用 Agent**: `@oracle`, `@librarian`, `@explore`, `@frontend-ui-ux-engineer`
3. **初始化记忆**: 进入项目后运行 `/supermemory-init`

---

## 相关 Issues

- **#621**: 配额保护改为模型级别（已修复）
- **#631**: 配额保护不生效问题
- **#636**: 编辑器内自动换号需求（未实现）

