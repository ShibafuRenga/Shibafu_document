namespace NetSyncDemo.Core;

/// <summary>一帧/一次逻辑步进的输入。帧同步里这就是「同步的内容」。</summary>
public struct InputCmd
{
	public int Tick;
	public int Dx; // -1 / 0 / 1
	public int Dy;
	public bool Action; // 结果同步用：按空格触发一次「技能位移」

	public static InputCmd FromAxes(int tick, int dx, int dy, bool action = false) =>
		new() { Tick = tick, Dx = dx, Dy = dy, Action = action };

	public static InputCmd Empty(int tick) => new() { Tick = tick };
}
