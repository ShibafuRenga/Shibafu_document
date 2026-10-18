using System.Collections.Generic;
using NetSyncDemo.Core;

namespace NetSyncDemo.Modes;

/// <summary>
/// 单进程内同时模拟 Server + Client，通过 FakeNet 传包。
/// 切换 SyncMode 即可对比不同策略手感。
/// </summary>
public sealed class SyncSession
{
	public SyncMode Mode { get; private set; } = SyncMode.StateSyncPredict;

	public SimState ServerState { get; private set; }
	public SimState ClientView { get; private set; }

	public int ServerTick => ServerState.Tick;
	public int ClientTick => ClientView.Tick;
	public int Corrections { get; private set; }
	public int PacketsC2S { get; private set; }
	public int PacketsS2C { get; private set; }
	public string LastEvent { get; private set; } = "ready";

	readonly FakeNet _net = new();
	readonly List<InputCmd> _clientPredictionBuf = new(); // 预测用：已发未确认的输入
	readonly Dictionary<int, InputCmd> _frameInputs = new(); // 帧同步：按 tick 存输入
	readonly Dictionary<int, SimState> _frameSnapshots = new(); // 简化回滚：保留快照

	float _accum;
	int _localTick;
	int _lastAckTick = -1;
	bool _pendingResultAction;
	InputCmd _heldInput;

	public FakeNet Net => _net;

	public void Reset(SyncMode mode)
	{
		Mode = mode;
		ServerState = DeterministicSim.CreateInitial();
		ClientView = ServerState.Clone();
		_net.Reset();
		_clientPredictionBuf.Clear();
		_frameInputs.Clear();
		_frameSnapshots.Clear();
		_accum = 0f;
		_localTick = 0;
		_lastAckTick = -1;
		_pendingResultAction = false;
		Corrections = 0;
		PacketsC2S = 0;
		PacketsS2C = 0;
		_heldInput = InputCmd.Empty(0);
		LastEvent = $"mode={mode}";
		_frameSnapshots[0] = ServerState;
	}

	public void SetHeldInput(int dx, int dy, bool actionPressed)
	{
		_heldInput.Dx = dx;
		_heldInput.Dy = dy;
		if (actionPressed)
			_pendingResultAction = true;
	}

	public void Update(float dt)
	{
		_net.AdvanceTime(dt);
		_net.ReceiveAll(OnPacket);

		_accum += dt;
		while (_accum >= DeterministicSim.TickDt)
		{
			_accum -= DeterministicSim.TickDt;
			StepLogic();
		}
	}

	void StepLogic()
	{
		switch (Mode)
		{
			case SyncMode.ResultSync:
				StepResultSync();
				break;
			case SyncMode.StateSync:
				StepStateSync(predict: false);
				break;
			case SyncMode.StateSyncPredict:
				StepStateSync(predict: true);
				break;
			case SyncMode.FrameSync:
				StepFrameSync();
				break;
		}
	}

	/// <summary>
	/// 结果同步：平时客户端几乎不本地演移动（这里故意卡住/只显示旧状态），
	/// 按空格发一次 Action，服务器算完回完整快照。
	/// </summary>
	void StepResultSync()
	{
		// 服务器空转保持时间流逝感（倒计时类玩法常见）
		ServerState = DeterministicSim.Tick(ServerState, InputCmd.Empty(ServerState.Tick));

		if (!_pendingResultAction)
			return;

		_pendingResultAction = false;
		var cmd = InputCmd.FromAxes(ServerState.Tick, 0, 0, action: true);
		SendC2S(cmd);
	}

	/// <summary>
	/// 状态同步：输入上服务器演算；定期下发快照。
	/// predict=false：客户端只跟快照（延迟感明显）。
	/// predict=true：客户端先 Tick，收到快照再和解。
	/// </summary>
	void StepStateSync(bool predict)
	{
		_localTick++;
		var cmd = InputCmd.FromAxes(_localTick, _heldInput.Dx, _heldInput.Dy, _pendingResultAction);
		_pendingResultAction = false;

		SendC2S(cmd);

		if (predict)
		{
			ClientView = DeterministicSim.Tick(ClientView, cmd);
			_clientPredictionBuf.Add(cmd);
			// 缓冲过长就裁掉极旧的（防内存涨）
			if (_clientPredictionBuf.Count > 120)
				_clientPredictionBuf.RemoveAt(0);
		}
	}

	/// <summary>
	/// 帧同步：本 Demo 简化为「本机输入延迟到达后，服务器与客户端用同一输入推进」。
	/// 真实多人还要等所有玩家输入齐；这里演示 deterministic + 迟到输入的简化回滚重演。
	/// </summary>
	void StepFrameSync()
	{
		_localTick++;
		var cmd = InputCmd.FromAxes(_localTick, _heldInput.Dx, _heldInput.Dy, _pendingResultAction);
		_pendingResultAction = false;
		SendC2S(cmd);

		// 客户端也可以先用本地输入预测一帧（可选）；正式 lockstep 常「等齐再演」。
		// 这里先不本地演，等输入从假网络回来后两端一起演，突出「同步的是输入」。
	}

	void OnPacket(NetLane lane, object payload)
	{
		if (lane == NetLane.ClientToServer && payload is InputCmd cmd)
		{
			PacketsC2S++;
			OnServerGotInput(cmd);
			return;
		}

		if (lane == NetLane.ServerToClient && payload is SnapshotMsg snap)
		{
			PacketsS2C++;
			OnClientGotSnapshot(snap);
		}
	}

	void OnServerGotInput(InputCmd cmd)
	{
		switch (Mode)
		{
			case SyncMode.ResultSync:
			{
				ServerState = DeterministicSim.Tick(ServerState, cmd);
				SendS2C(new SnapshotMsg { State = ServerState, AckTick = cmd.Tick, Kind = SnapshotKind.Full });
				LastEvent = "result: server resolved action";
				break;
			}
			case SyncMode.StateSync:
			case SyncMode.StateSyncPredict:
			{
				ServerState = DeterministicSim.Tick(ServerState, cmd);
				// 每帧都下发（教学用；真实项目会降频/差分/AOI）
				SendS2C(new SnapshotMsg { State = ServerState, AckTick = cmd.Tick, Kind = SnapshotKind.Full });
				LastEvent = "state: server ticked + snapshot";
				break;
			}
			case SyncMode.FrameSync:
			{
				ApplyFrameSyncInput(cmd);
				break;
			}
		}
	}

	void ApplyFrameSyncInput(InputCmd cmd)
	{
		_frameInputs[cmd.Tick] = cmd;

		// 若输入按序到达：从当前 server tick 往后演
		// 若乱序/迟到：回滚到该 tick 之前快照再重演（简化版 GGPO 思想）
		if (cmd.Tick <= ServerState.Tick)
		{
			RollbackAndReplay(cmd.Tick);
			LastEvent = $"frame: late input tick={cmd.Tick} -> rollback";
			Corrections++;
			return;
		}

		// 正常：缺帧补空输入（真实 lockstep 会等；这里为可玩性补 Empty）
		while (ServerState.Tick + 1 < cmd.Tick)
		{
			var missTick = ServerState.Tick + 1;
			var empty = InputCmd.Empty(missTick);
			AdvanceBothWithInput(empty);
		}

		AdvanceBothWithInput(cmd);
		LastEvent = $"frame: lockstep tick={ServerState.Tick}";
	}

	void RollbackAndReplay(int fromTick)
	{
		if (!_frameSnapshots.TryGetValue(fromTick - 1, out var snap))
		{
			// 找不到就从初始重来（极端情况）
			snap = DeterministicSim.CreateInitial();
			_frameSnapshots.Clear();
			_frameSnapshots[0] = snap;
		}

		ServerState = snap;
		ClientView = snap;

		var end = _localTick;
		for (var t = fromTick; t <= end; t++)
		{
			var input = _frameInputs.TryGetValue(t, out var i) ? i : InputCmd.Empty(t);
			AdvanceBothWithInput(input);
		}
	}

	void AdvanceBothWithInput(InputCmd cmd)
	{
		ServerState = DeterministicSim.Tick(ServerState, cmd);
		ClientView = DeterministicSim.Tick(ClientView, cmd);
		_frameSnapshots[ServerState.Tick] = ServerState;
		// 限制快照数量
		if (_frameSnapshots.Count > 180)
		{
			var minKeep = ServerState.Tick - 120;
			var remove = new List<int>();
			foreach (var k in _frameSnapshots.Keys)
			{
				if (k < minKeep) remove.Add(k);
			}
			foreach (var k in remove)
				_frameSnapshots.Remove(k);
		}

		SendS2C(new SnapshotMsg
		{
			State = ServerState,
			AckTick = cmd.Tick,
			Kind = SnapshotKind.FrameConfirm,
		});
	}

	void OnClientGotSnapshot(SnapshotMsg snap)
	{
		switch (Mode)
		{
			case SyncMode.ResultSync:
			case SyncMode.StateSync:
				ClientView = snap.State;
				_lastAckTick = snap.AckTick;
				break;

			case SyncMode.StateSyncPredict:
				Reconcile(snap);
				break;

			case SyncMode.FrameSync:
				// 帧同步权威已在 ApplyFrameSyncInput 里两端一起演；快照仅作确认显示
				_lastAckTick = snap.AckTick;
				break;
		}
	}

	void Reconcile(SnapshotMsg snap)
	{
		_lastAckTick = snap.AckTick;
		var auth = snap.State;

		// 丢掉已确认输入
		_clientPredictionBuf.RemoveAll(i => i.Tick <= snap.AckTick);

		// 从权威状态重放未确认输入
		var replay = auth;
		foreach (var cmd in _clientPredictionBuf)
			replay = DeterministicSim.Tick(replay, cmd);

		if (!replay.Equals(ClientView))
		{
			Corrections++;
			LastEvent = $"predict: reconcile ack={snap.AckTick} correction#{Corrections}";
		}
		else
		{
			LastEvent = $"predict: ok ack={snap.AckTick}";
		}

		ClientView = replay;
	}

	void SendC2S(InputCmd cmd)
	{
		_net.Send(NetLane.ClientToServer, cmd);
	}

	void SendS2C(SnapshotMsg msg)
	{
		_net.Send(NetLane.ServerToClient, msg);
	}
}

public enum SnapshotKind
{
	Full,
	FrameConfirm,
}

public struct SnapshotMsg
{
	public SimState State;
	public int AckTick;
	public SnapshotKind Kind;
}
