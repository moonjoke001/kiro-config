---
inclusion: manual
---

# Kiro Pro Free 开发参考

- GitHub: https://github.com/iamaanahmad/kiro-pro-free
- 作者: iamaanahmad

基于 Cursor Free VIP 项目改编，用于重置 Kiro IDE 设备 ID。

## 项目位置
- 本地: `/home/sjchu/mcp/kiro/kiro-pro-free/`
- 参考: Cursor Machine ID `/home/sjchu/mcp/kiro/cursor_machine_id/`

---

## 一、核心原理

### 1. 设备 ID 重置
IDE 通过多个 ID 识别设备，重置这些 ID 可绕过试用限制：

| 字段 | 格式 | 说明 |
|-----|------|------|
| `telemetry.devDeviceId` | UUID v4 | 设备唯一标识 |
| `telemetry.machineId` | SHA256 hex (64字符) | 机器 ID |
| `telemetry.macMachineId` | SHA512 hex (128字符) | MAC 机器 ID |
| `telemetry.sqmId` | `{UUID-UPPER}` | 软件质量指标 ID |
| `storage.serviceMachineId` | UUID v4 | 服务机器 ID |

**生成代码：**
```python
import uuid, hashlib, os

dev_device_id = str(uuid.uuid4())
machine_id = hashlib.sha256(os.urandom(32)).hexdigest()
mac_machine_id = hashlib.sha512(os.urandom(64)).hexdigest()
sqm_id = "{" + str(uuid.uuid4()).upper() + "}"
```

### 2. Token 限制绕过
修改 `workbench.desktop.main.js`，替换 token 限制函数：
```javascript
// 原始
async getEffectiveTokenLimit(e){const n=e.modelName;if(!n)return 2e5;
// 修改后
async getEffectiveTokenLimit(e){return 9000000;const n=e.modelName;if(!n)return 9e5;
```

### 3. 禁用自动更新
- 删除 updater 目录
- 清空 `app-update.yml`
- 移除 `product.json` 中的 updateUrl
- 创建只读阻止文件

---

## 二、文件路径

### Linux (Kiro)
```
配置目录:     ~/.config/Kiro/                    # 注意大写 K
storage.json: ~/.config/Kiro/User/globalStorage/storage.json
SQLite:       ~/.config/Kiro/User/globalStorage/state.vscdb
Machine ID:   ~/.config/Kiro/machineid
安装目录:     /usr/share/kiro/resources/app/
main.js:      /usr/share/kiro/resources/app/out/main.js
workbench.js: /usr/share/kiro/resources/app/out/vs/workbench/workbench.desktop.main.js
```

### Linux (Cursor)
```
配置目录:     ~/.config/Cursor/
storage.json: ~/.config/Cursor/User/globalStorage/storage.json
SQLite:       ~/.config/Cursor/User/globalStorage/state.vscdb
Machine ID:   ~/.config/Cursor/machineid
安装目录:     /opt/Cursor/resources/app/ 或 /usr/share/cursor/resources/app/
```

### macOS
```
配置目录:     ~/Library/Application Support/{IDE}/
安装目录:     /Applications/{IDE}.app/Contents/Resources/app/
```

### Windows
```
配置目录:     %APPDATA%\{IDE}\
安装目录:     %LOCALAPPDATA%\Programs\{IDE}\resources\app\
```

---

## 三、关键代码模式

### sudo 运行时获取真实用户目录
```python
import os, pwd

def get_real_user_home():
    sudo_user = os.environ.get('SUDO_USER')
    if sudo_user:
        return pwd.getpwnam(sudo_user).pw_dir
    return os.path.expanduser("~")
```

### 文件备份
```python
import shutil
from datetime import datetime

def backup_file(file_path):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = f"{file_path}.backup.{timestamp}"
    shutil.copy2(file_path, backup_path)
    return backup_path
```

### 更新 storage.json
```python
import json

def update_storage_json(path, new_ids):
    with open(path, 'r') as f:
        data = json.load(f)
    data.update(new_ids)
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)
```

### 更新 SQLite 数据库
```python
import sqlite3

def update_sqlite(path, new_ids):
    conn = sqlite3.connect(path)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ItemTable (
            key TEXT PRIMARY KEY, value TEXT
        )
    """)
    for key, value in new_ids.items():
        cursor.execute(
            "INSERT OR REPLACE INTO ItemTable (key, value) VALUES (?, ?)",
            (key, value)
        )
    conn.commit()
    conn.close()
```

### 字符串替换 patch
```python
def patch_file(path, patterns):
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    for old, new in patterns.items():
        content = content.replace(old, new)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
```

---

## 四、项目结构

```
project/
├── setup.sh              # 安装脚本 (创建 venv)
├── requirements.txt      # 依赖 (colorama)
├── {ide}_config.py       # 路径配置
├── {ide}_reset_machine.py    # 设备 ID 重置
├── {ide}_bypass_token_limit.py  # Token 限制绕过
├── {ide}_disable_auto_update.py # 禁用自动更新
└── {ide}_main.py         # 主菜单
```

---

## 五、注意事项

1. **大小写敏感**: Kiro 用 `~/.config/Kiro/`，Cursor 用 `~/.config/Cursor/`
2. **sudo 权限**: 修改 `/usr/share/` 下文件需要 root
3. **venv**: 使用虚拟环境避免 PEP 668 限制
4. **备份**: 修改前自动备份，后缀 `.backup.时间戳`
5. **关闭 IDE**: 运行前必须关闭目标 IDE
6. **代码差异**: 不同 IDE 版本的 JS 代码结构可能不同，patch 模式需要适配

---

## 六、守护进程功能

### 功能说明
Kiro IDE 会在启动时恢复设备 ID，守护进程监控 `storage.json` 文件变化，自动恢复为目标 ID。

### 实现原理
```python
import hashlib, time, json

def run_polling_mode(storage_path, target_ids, interval=2):
    """轮询模式监控文件变化"""
    def get_file_hash():
        with open(storage_path, 'rb') as f:
            return hashlib.md5(f.read()).hexdigest()
    
    last_hash = get_file_hash()
    
    while True:
        time.sleep(interval)
        current_hash = get_file_hash()
        
        if current_hash != last_hash:
            last_hash = current_hash
            restore_device_ids(storage_path, target_ids)
            last_hash = get_file_hash()
```

### 守护进程菜单
```
🛡️ Guardian - 设备ID守护

状态: 运行中 (PID: 12345)

1. 启动守护 (前台) - 显示实时日志
2. 启动守护 (后台) - 后台运行，日志写入 guardian.log
3. 停止守护
4. 查看日志
0. 返回主菜单
```

### 日志输出格式
```
[23:21:30] 🛡️ 守护进程启动
[23:21:30] 🔒 保护的设备ID:
  telemetry.devDeviceId: 2c428b26-d7f7-438b-9ecf-84a7c89ba994
  telemetry.machineId: bf842a109b143f814413845f01f91880...
  ...
[23:21:30] 📡 轮询监控模式 (间隔 2s)

[23:29:44] ⚠️  检测到企图修改为:
  telemetry.devDeviceId: bf1d9820-8fab-4b58-a745-3dc232b34b31
  ...
[23:29:44] ✅ 已恢复为:
  telemetry.devDeviceId: 2c428b26-d7f7-438b-9ecf-84a7c89ba994
  ...
```

### 后台运行
```python
import subprocess

# 启动后台守护
proc = subprocess.Popen(
    [sys.executable, 'kiro_guardian.py', '--polling', '--interval', '2'],
    stdout=open('guardian.log', 'w'),
    stderr=subprocess.STDOUT,
    start_new_session=True
)
# 保存 PID
with open('.guardian.pid', 'w') as f:
    f.write(str(proc.pid))
```

---

## 七、运行方式

```bash
# 安装
cd ~/mcp/kiro/kiro-pro-free
bash setup.sh

# 运行 (需要 sudo 修改系统文件)
sudo venv/bin/python kiro_main.py
```

---

## 七、参考项目
- Cursor Free VIP: https://github.com/yeongpin/cursor-free-vip
- Kiro Pro Free: https://github.com/iamaanahmad/kiro-pro-free
