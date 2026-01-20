---
inclusion: always
---

# 知识库

## 工具配置

### opencode 更新 (2026-01-19)
- **问题**：Homebrew 安装想更新到最新版
- **解决方案**：切换到 npm 安装
- **关键步骤**：
  ```bash
  brew uninstall opencode
  npm config set prefix '~/.npm-global'
  echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
  npm i -g opencode-ai@latest
  ```
- **注意**：配置文件在 `~/.opencode` 不会被删除
- **当前版本**：1.1.26

---

---

## API 统一入口模型列表 (2026-01-19)

### 可用模型
调用 `https://api.lalayunssl.xyz/v1/models` 返回的模型：

| 模型名称 | 说明 |
|----------|------|
| gemini-2.5-flash-preview | Gemini 2.5 Flash 预览版 |
| gemini-3-flash-preview | Gemini 3 Flash 预览版 |
| gemini-3-pro-preview | Gemini 3 Pro 预览版 |
| gemini-3-pro-image-preview | Gemini 3 Pro 图像版 |
| gemini-2.5-computer-use-preview-10-2025 | Computer Use 预览版 |
| gemini-claude-sonnet-4-5 | Claude Sonnet 4.5（通过 Antigravity） |
| gemini-claude-sonnet-4-5-thinking | Claude Sonnet 4.5 思维链版 |
| gemini-claude-opus-4-5-thinking | Claude Opus 4.5 思维链版 |

### 使用方式
```bash
curl -X POST "https://api.lalayunssl.xyz/v1/chat/completions" \
  -H "Authorization: Bearer 123456" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-3-pro-preview",
    "messages": [{"role": "user", "content": "你好"}]
  }'
```

### 注意事项
- 默认提供商：`gemini-antigravity`
- 切换提供商：Web UI 中修改或使用具体路径（如 `/claude-kiro-oauth/v1/chat/completions`）

---

## 模板：新知识条目

### [标题] (日期)
- **问题/场景**：
- **解决方案**：
- **关键步骤**：
- **注意事项**：
- **相关链接**：
