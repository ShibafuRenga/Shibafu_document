# NetSyncDemo（Godot 4 C#）

用**进程内假延迟**对比四种网络同步策略，方便对照 Unity Mirror / UE Replication / 帧同步概念。

> 推荐 **Godot 4.7 .NET 版**（带 Mono/.NET 字样）。不要用纯 GDScript 版，否则 C# 脚本挂不上。

---

## 怎么跑

1. 用 **Godot 4.7 .NET** → **Import** → 选本目录的 `project.godot`（或直接拖进编辑器）
2. 若提示升级项目设置，选允许升级即可
3. 确认已装 **.NET 8 SDK**；首次打开会还原 `Godot.NET.Sdk`
4. 若编译报找不到 Sdk `4.7.0`：把 `NetSyncDemo.csproj` 里的 `Godot.NET.Sdk/4.7.0` 改成编辑器帮助里写的版本（或与 Godot 小版本一致，如 `4.7.1`）
5. 按 F5 运行

操作：

| 按键 | 作用 |
|------|------|
| WASD | 移动 |
| Space / Enter | Action（结果同步必用；其它模式会触发冲刺+加分） |
| 顶部 Mode | 切换策略 |
| Latency / Jitter / 丢包 | 调假网络 |

左蓝球 = **Server 权威**；右橙球 = **Client 表现**。

---

## 四种模式（建议按顺序试）

### 1. ResultSync 结果同步

- 客户端**几乎不本地模拟移动**
- Space 发一次动作 → 服务器算完 → 回**完整快照** → 客户端跳变
- 像：休闲结算、老虎机结果、强服务器权威的回合结果

### 2. StateSync 纯状态同步

- 输入上服务器，服务器 `Tick`，每帧回快照
- 客户端**不预测**，只显示最新快照 → 延迟高时粘滞/橡皮筋
- 像：Mirror `SyncVar`、UE `Replicated`（无预测）

### 3. StateSync+Predict 预测 + 和解

- 客户端先本地 `Tick`（跟手）
- 权威快照到了：丢掉已确认输入，从权威状态**重放未确认输入**
- `Corrections` 增加 = 发生过纠正
- 像：常见射击/移动预测；UE/Mirror 上都是这套思路

### 4. FrameSync 帧同步 / Lockstep

- **同步的是输入**，两端跑同一份 `DeterministicSim`
- 迟到输入会触发**简化回滚 + 重演**（看 Event / Corrections）
- 像：部分 RTS/格斗；真正多人还要「等齐所有玩家输入」

---

## 代码地图

```
scripts/Core/
  SyncMode.cs          模式枚举
  InputCmd.cs          一帧输入（帧同步的同步物）
  SimState.cs          世界快照（状态同步的同步物）
  DeterministicSim.cs  确定性步进（同输入同结果）
  FakeNet.cs           延迟/抖动/丢包队列
scripts/Modes/
  SyncSession.cs       四种策略核心逻辑
scripts/UI/
  DemoRoot.cs          输入、HUD、左右绘制
scenes/Main.tscn       主场景
```

和真实引擎的对应：

| Demo | Mirror | UE |
|------|--------|-----|
| 快照 / SimState | SyncVar | Replicated + OnRep |
| 输入上服务器 | Command | Server RPC |
| 预测和解 | 自写 | 角色移动等内置更复杂 |
| 帧同步 | 一般不用 Mirror 默认模型 | 也不是默认 Replication |

---

## 和简历说法的边界

- 本 Demo 能帮你**讲清方案与手感差异**
- 简历仍写：了解状态同步/帧同步；**实际用过 UE Actor Replication**
- 不要写成「生产级帧同步 / GGPO 专家」——这里的回滚是教学简化版

---

## 建议观察实验

1. Latency=200ms，对比 StateSync vs StateSync+Predict 跟手程度  
2. Predict 下猛打方向键，看 Corrections 何时涨  
3. FrameSync + 提高 Jitter，看是否出现 `late input -> rollback`  
4. 勾选丢包，看结果同步/状态同步谁更「跳」
