namespace NetSyncDemo.Core;

/// <summary>
/// 纯函数式步进：Same(state, input) => Same(next)。
/// 帧同步要求各端都用这份逻辑；状态同步则通常只在服务器跑。
/// </summary>
public static class DeterministicSim
{
	public const float Speed = 120f;
	public const float TickDt = 1f / 30f; // 30Hz 逻辑帧
	public const float ArenaMin = 40f;
	public const float ArenaMax = 360f;
	public const float ActionImpulse = 48f;

	public static SimState CreateInitial() => new()
	{
		Tick = 0,
		X = 200f,
		Y = 200f,
		Score = 0,
		Rng = 1u,
	};

	public static SimState Tick(in SimState state, in InputCmd input)
	{
		var next = state;
		next.Tick = state.Tick + 1;

		next.X = Clamp(state.X + input.Dx * Speed * TickDt, ArenaMin, ArenaMax);
		next.Y = Clamp(state.Y + input.Dy * Speed * TickDt, ArenaMin, ArenaMax);

		if (input.Action)
		{
			// 用确定性 RNG，避免 DateTime/Random 破坏帧同步
			next.Rng = NextLcg(state.Rng);
			var dir = (int)(next.Rng % 4);
			next.X = Clamp(next.X + DirX(dir) * ActionImpulse, ArenaMin, ArenaMax);
			next.Y = Clamp(next.Y + DirY(dir) * ActionImpulse, ArenaMin, ArenaMax);
			next.Score = state.Score + 1;
		}

		return next;
	}

	static float Clamp(float v, float min, float max) =>
		v < min ? min : (v > max ? max : v);

	static uint NextLcg(uint x) => unchecked(x * 1664525u + 1013904223u);

	static float DirX(int d) => d switch { 0 => 1, 1 => -1, _ => 0 };
	static float DirY(int d) => d switch { 2 => 1, 3 => -1, _ => 0 };
}
