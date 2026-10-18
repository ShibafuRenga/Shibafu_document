using System;
using System.Collections.Generic;

namespace NetSyncDemo.Core;

/// <summary>进程内假网络：只做延迟队列，方便观察延迟对策略的影响。</summary>
public sealed class FakeNet
{
	readonly List<Pending> _queue = new();
	float _now;
	readonly Random _jitterRng = new(7);

	public float LatencySec { get; set; } = 0.12f;
	public float JitterSec { get; set; } = 0.03f;
	public float LossChance { get; set; } = 0f; // 0~1，教学时可调

	public void Reset()
	{
		_queue.Clear();
		_now = 0f;
	}

	public void AdvanceTime(float dt) => _now += dt;

	public void Send<T>(NetLane lane, T payload)
	{
		if (LossChance > 0f && _jitterRng.NextDouble() < LossChance)
			return;

		var delay = LatencySec;
		if (JitterSec > 0f)
			delay += (float)((_jitterRng.NextDouble() * 2.0 - 1.0) * JitterSec);
		if (delay < 0f) delay = 0f;

		_queue.Add(new Pending
		{
			DeliverAt = _now + delay,
			Lane = lane,
			Payload = payload!,
		});
	}

	public void ReceiveAll(Action<NetLane, object> onPacket)
	{
		for (var i = _queue.Count - 1; i >= 0; i--)
		{
			if (_queue[i].DeliverAt > _now)
				continue;
			var p = _queue[i];
			_queue.RemoveAt(i);
			onPacket(p.Lane, p.Payload);
		}
	}

	struct Pending
	{
		public float DeliverAt;
		public NetLane Lane;
		public object Payload;
	}
}

public enum NetLane
{
	ClientToServer,
	ServerToClient,
}
