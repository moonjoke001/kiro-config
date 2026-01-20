---
inclusion: always
---

# 上下文管理规则

## 当上下文过长时
1. 自动总结当前任务状态和关键决策
2. 保留重要的文件路径和代码片段
3. 清理冗余的对话历史

## 任务状态记录
每次完成重要步骤后，更新以下信息：
- 当前正在进行的任务
- 已完成的关键决策
- 待解决的问题

## 代码风格
- 使用最简洁的代码实现需求
- 避免冗余实现
- 优先使用已有的工具和库

## 常用项目路径
- MCP 工作目录: /home/sjchu/mcp
- DeepSeek-OCR-DEMO: /home/sjchu/mcp/DeepSeek-OCR-DEMO
- Kiro 配置: /home/sjchu/.kiro/settings/

## Docker Compose 命令
- 使用 `docker compose` (不是 `docker-compose`)
- 启动: `docker compose -f case/docker-compose.yml up -d`
- 停止: `docker compose -f case/docker-compose.yml down`
- 重启: `docker compose -f case/docker-compose.yml restart`
- 查看状态: `docker compose -f case/docker-compose.yml ps`
- 查看日志: `docker compose -f case/docker-compose.yml logs -f`

## Chrome DevTools MCP 交互式启动方法（推荐）

由于 Chrome DevTools MCP 连接不稳定，推荐使用以下交互式方法：

### 步骤 1: Agent 执行
```bash
pkill -9 chrome 2>/dev/null; sleep 2; echo "Chrome killed"
```

### 步骤 2: Agent 启动 Chrome
```bash
nohup /usr/bin/google-chrome-stable --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-debug-mcp http://localhost:8002 > /tmp/chrome.log 2>&1 &
echo "Chrome started, waiting..."
sleep 5
curl -s http://127.0.0.1:9222/json/version | head -3
```

### 步骤 3: 用户手动操作
- 在 Kiro 侧边栏找到 "MCP Servers" 面板
- 找到 "Chrome DevTools" 服务器
- 点击重启按钮（刷新图标）
- 等待状态变为 "Connected"

### 步骤 4: Agent 验证连接
```bash
curl -s http://127.0.0.1:9222/json/version
```

### 注意事项
- 必须使用独立的 `--user-data-dir` 避免复用已有会话
- 每次使用前建议先 `pkill -9 chrome` 确保干净启动
- 如果 MCP 仍显示 "Not connected"，尝试更换 user-data-dir 路径

## Steering 文件管理
当分析完一个 GitHub 项目后：
1. 创建 steering 文件，命名格式：`{作者名}-{项目名}.md`
2. 设置 `inclusion: manual`（按需加载）
3. 记录项目核心原理、关键路径、代码模式、注意事项
4. 使用 GitHub MCP 推送到 https://github.com/moonjoke001/kiro-steering

## Kiro CLI 配置
新电脑同步 steering 后，设置 `~/.kiro/settings/cli.json`:
```json
{
  "chat.defaultModel": "claude-opus-4.5",
  "chat.enableCheckpoint": true,
  "mcp.loadedBefore": true,
  "chat.trustAllTools": true
}
```

## Kiro Manager WB 安装后配置
安装 vsix 扩展后，运行补丁前需要先配置 Python 环境：
```bash
cd ~/.kiro-manager-wb && \
python3 -m venv venv && \
./venv/bin/pip install -r requirements.txt && \
sed -i '1s|.*|#!'$(pwd)'/venv/bin/python3|' cli.py
```

打补丁需要 sudo 权限（因为 Kiro 安装在 /usr/share/kiro）：
```bash
# 先关闭 Kiro IDE，然后运行：
sudo ~/.kiro-manager-wb/venv/bin/python3 ~/.kiro-manager-wb/cli.py patch apply
```
