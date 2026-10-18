using Godot;
using NetSyncDemo.Core;
using NetSyncDemo.Modes;

namespace NetSyncDemo.UI;

/// <summary>
/// 主场景根节点：读输入、跑 SyncSession、左右画 Server/Client。
/// </summary>
public partial class DemoRoot : Node2D
{
	readonly SyncSession _session = new();

	Label _hud = null!;
	OptionButton _modePicker = null!;
	HSlider _latency = null!;
	HSlider _jitter = null!;
	CheckButton _loss = null!;
	bool _actionQueued;

	public override void _Ready()
	{
		_hud = GetNode<Label>("Canvas/Hud");
		_modePicker = GetNode<OptionButton>("Canvas/Panel/ModePicker");
		_latency = GetNode<HSlider>("Canvas/Panel/Latency");
		_jitter = GetNode<HSlider>("Canvas/Panel/Jitter");
		_loss = GetNode<CheckButton>("Canvas/Panel/Loss");

		_modePicker.Clear();
		_modePicker.AddItem("ResultSync 结果同步", (int)SyncMode.ResultSync);
		_modePicker.AddItem("StateSync 纯状态同步", (int)SyncMode.StateSync);
		_modePicker.AddItem("StateSync+Predict 预测和解", (int)SyncMode.StateSyncPredict);
		_modePicker.AddItem("FrameSync 帧同步/Lockstep", (int)SyncMode.FrameSync);
		_modePicker.Selected = (int)SyncMode.StateSyncPredict;
		_modePicker.ItemSelected += OnModeSelected;

		_latency.MinValue = 0;
		_latency.MaxValue = 400;
		_latency.Value = 120;
		_latency.ValueChanged += _ => ApplyNetParams();

		_jitter.MinValue = 0;
		_jitter.MaxValue = 100;
		_jitter.Value = 30;
		_jitter.ValueChanged += _ => ApplyNetParams();

		_loss.Toggled += _ => ApplyNetParams();

		_session.Reset(SyncMode.StateSyncPredict);
		ApplyNetParams();
	}

	void OnModeSelected(long index)
	{
		_session.Reset((SyncMode)index);
		ApplyNetParams();
	}

	void ApplyNetParams()
	{
		_session.Net.LatencySec = (float)_latency.Value / 1000f;
		_session.Net.JitterSec = (float)_jitter.Value / 1000f;
		_session.Net.LossChance = _loss.ButtonPressed ? 0.08f : 0f;
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventKey key && key.Pressed && !key.Echo && key.PhysicalKeycode == Key.Space)
		{
			_actionQueued = true;
			GetViewport().SetInputAsHandled();
		}
	}

	public override void _Process(double delta)
	{
		var dx = 0;
		var dy = 0;
		if (Input.IsActionPressed("move_left")) dx -= 1;
		if (Input.IsActionPressed("move_right")) dx += 1;
		if (Input.IsActionPressed("move_up")) dy -= 1;
		if (Input.IsActionPressed("move_down")) dy += 1;

		var action = _actionQueued || Input.IsActionJustPressed("ui_accept");
		_actionQueued = false;

		_session.SetHeldInput(dx, dy, action);
		_session.Update((float)delta);
		UpdateHud();
		QueueRedraw();
	}

	void UpdateHud()
	{
		_hud.Text =
			$"Mode: {_session.Mode}\n" +
			$"WASD 移动 | Space 触发 Action（结果同步必用）\n" +
			$"Latency={_session.Net.LatencySec * 1000:0}ms  Jitter={_session.Net.JitterSec * 1000:0}ms  Loss={_session.Net.LossChance:P0}\n" +
			$"Server {_session.ServerState}\n" +
			$"Client {_session.ClientView}\n" +
			$"C2S={_session.PacketsC2S}  S2C={_session.PacketsS2C}  Corrections={_session.Corrections}\n" +
			$"Event: {_session.LastEvent}\n" +
			ModeHint(_session.Mode);
	}

	static string ModeHint(SyncMode mode) => mode switch
	{
		SyncMode.ResultSync =>
			"【结果同步】本地几乎不跟手移动；Space 发动作，等服务器回最终快照再跳变。类似结算型玩法。",
		SyncMode.StateSync =>
			"【纯状态同步】输入上服务器演算后回快照；客户端不预测，延迟高时明显「粘滞/橡皮筋」。类似 Mirror SyncVar。",
		SyncMode.StateSyncPredict =>
			"【预测+和解】客户端先本地 Tick；权威快照到达后重放未确认输入。Corrections 增加=发生过纠正。",
		SyncMode.FrameSync =>
			"【帧同步】同步的是输入；两端同逻辑演算。迟到输入会触发简化回滚重演（看 Event / Corrections）。",
		_ => "",
	};

	public override void _Draw()
	{
		DrawArena(new Vector2(40, 120), "SERVER (权威)", _session.ServerState, new Color(0.25f, 0.55f, 1f));
		DrawArena(new Vector2(480, 120), "CLIENT (表现)", _session.ClientView, new Color(0.95f, 0.65f, 0.15f));

		// 误差线：两端位置差
		var a = new Vector2(40, 120) + new Vector2(_session.ServerState.X, _session.ServerState.Y);
		var b = new Vector2(480, 120) + new Vector2(_session.ClientView.X, _session.ClientView.Y);
		DrawLine(a, b + new Vector2(-440, 0), new Color(1, 0.3f, 0.3f, 0.35f), 1.5f);
	}

	void DrawArena(Vector2 origin, string title, SimState state, Color color)
	{
		var size = DeterministicSim.ArenaMax - DeterministicSim.ArenaMin + 40f;
		DrawRect(new Rect2(origin, new Vector2(size, size)), new Color(0.12f, 0.14f, 0.18f));
		DrawRect(new Rect2(origin, new Vector2(size, size)), new Color(0.35f, 0.4f, 0.5f), false, 2);
		DrawString(ThemeDB.FallbackFont, origin + new Vector2(8, -8), title, HorizontalAlignment.Left, -1, 16, Colors.White);

		var pos = origin + new Vector2(state.X - DeterministicSim.ArenaMin + 20f, state.Y - DeterministicSim.ArenaMin + 20f);
		DrawCircle(pos, 14, color);
		DrawString(ThemeDB.FallbackFont, pos + new Vector2(18, 4), $"t{state.Tick}", HorizontalAlignment.Left, -1, 14, color);
	}
}
