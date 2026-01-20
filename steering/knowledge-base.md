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

## 模板：新知识条目

### [标题] (日期)
- **问题/场景**：
- **解决方案**：
- **关键步骤**：
- **注意事项**：
- **相关链接**：
