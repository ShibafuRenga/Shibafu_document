namespace NetSyncDemo.Core;

/// <summary>
/// 四种教学用同步策略。运行时可在 HUD 切换。
/// </summary>
public enum SyncMode
{
	/// <summary>结果同步：客户端只发动作，服务器回最终状态（类休闲结算）。</summary>
	ResultSync = 0,

	/// <summary>纯状态同步：服务器演算，定期下发快照；客户端不预测，会「橡皮筋」。</summary>
	StateSync = 1,

	/// <summary>状态同步 + 本地预测 + 和解：先本地演，权威快照到了再纠正。</summary>
	StateSyncPredict = 2,

	/// <summary>帧同步 / Lockstep：同步输入，各端确定性同演算。</summary>
	FrameSync = 3,
}
