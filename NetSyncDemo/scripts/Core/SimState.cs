using System;

namespace NetSyncDemo.Core;

/// <summary>确定性模拟世界快照。状态同步里「同步的内容」主要就是这个。</summary>
public struct SimState : IEquatable<SimState>
{
	public int Tick;
	public float X;
	public float Y;
	public int Score;
	/// <summary>固定点随机种子，保证同输入同结果（帧同步关键）。</summary>
	public uint Rng;

	public SimState Clone() => this;

	public bool Equals(SimState other) =>
		Tick == other.Tick
		&& Nearly(X, other.X)
		&& Nearly(Y, other.Y)
		&& Score == other.Score
		&& Rng == other.Rng;

	public override bool Equals(object? obj) => obj is SimState s && Equals(s);
	public override int GetHashCode() => HashCode.Combine(Tick, X, Y, Score, Rng);

	static bool Nearly(float a, float b) => MathF.Abs(a - b) < 0.001f;

	public override string ToString() =>
		$"tick={Tick} pos=({X:0.0},{Y:0.0}) score={Score} rng={Rng}";
}
