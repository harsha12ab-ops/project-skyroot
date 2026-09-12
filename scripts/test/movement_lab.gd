extends Node2D

const SPAWN_POSITION := Vector2(220.0, 620.0)

@onready var player: SkyrootPlayer = $Player

var _elapsed := 0.0
var replay_running := false
var replay_finished := false
var _jump_index := 0
var _jump_hold_remaining := 0.0
var _direction_test_started := false
var _direction_test_remaining := 0.0

const JUMP_TARGETS := [520.0, 865.0, 1420.0, 1920.0, 2650.0, 4100.0]


func _ready() -> void:
	player.global_position = SPAWN_POSITION
	queue_redraw()
	if "--phase1-playtest" in OS.get_cmdline_user_args():
		_begin_command_line_replay.call_deferred()


func _begin_command_line_replay() -> void:
	await get_tree().create_timer(0.75).timeout
	if "--female" in OS.get_cmdline_user_args():
		player.set_female_variant(true)
	_start_replay()


func _process(delta: float) -> void:
	_elapsed += delta
	if player.global_position.y > 980.0:
		_respawn_player()
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not replay_running:
		return

	var axis := 1.0
	var jump_pressed := false
	var jump_released := false

	if _jump_hold_remaining > 0.0:
		_jump_hold_remaining -= delta
		if _jump_hold_remaining <= 0.0:
			jump_released = true

	if _jump_index < JUMP_TARGETS.size():
		var target_x: float = JUMP_TARGETS[_jump_index]
		if player.global_position.x >= target_x and player.is_on_floor():
			jump_pressed = true
			_jump_hold_remaining = 0.10 if _jump_index == 0 else 0.30
			_jump_index += 1

	if player.global_position.x >= 3320.0 and not _direction_test_started and player.is_on_floor():
		_direction_test_started = true
		_direction_test_remaining = 0.62
	if _direction_test_remaining > 0.0:
		_direction_test_remaining -= delta
		axis = -1.0

	player.set_movement_replay(true, axis, jump_pressed, jump_released)
	if player.global_position.x >= 5200.0:
		replay_running = false
		replay_finished = true
		player.set_movement_replay(false)
		print("MOVEMENT_LAB_PLAYTEST_PASS variant=%s max_x=%.1f" % ["female" if player.is_female else "male", player.global_position.x])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		var pressed_key := key_event.keycode if key_event.keycode != 0 else key_event.physical_keycode
		if pressed_key == KEY_F9:
			_start_replay()
		elif pressed_key == KEY_R:
			_respawn_player()


func _start_replay() -> void:
	_respawn_player()
	_jump_index = 0
	_jump_hold_remaining = 0.0
	_direction_test_started = false
	_direction_test_remaining = 0.0
	replay_finished = false
	replay_running = true
	print("MOVEMENT_LAB_PLAYTEST_START variant=%s" % ["female" if player.is_female else "male"])


func _respawn_player() -> void:
	player.global_position = SPAWN_POSITION
	player.velocity = Vector2.ZERO


func _draw() -> void:
	_draw_wind_lines()
	_draw_platform(Rect2(-400.0, 620.0, 1900.0, 240.0), 0)
	_draw_platform(Rect2(1640.0, 620.0, 1060.0, 240.0), 1)
	_draw_platform(Rect2(2890.0, 655.0, 1310.0, 240.0), 2)
	_draw_platform(Rect2(4200.0, 620.0, 1400.0, 240.0), 3)
	_draw_platform(Rect2(620.0, 580.0, 160.0, 40.0), 4)
	_draw_platform(Rect2(980.0, 530.0, 160.0, 90.0), 5)
	_draw_platform(Rect2(2040.0, 500.0, 380.0, 38.0), 6)
	_draw_waystone(Vector2(375.0, 620.0), "START")
	_draw_waystone(Vector2(700.0, 580.0), "SMALL STEP")
	_draw_waystone(Vector2(1060.0, 530.0), "MEDIUM STEP")
	_draw_waystone(Vector2(1568.0, 620.0), "SMALL GAP")
	_draw_waystone(Vector2(2795.0, 648.0), "MEDIUM GAP")
	_draw_waystone(Vector2(2230.0, 500.0), "RAISED")
	_draw_waystone(Vector2(3260.0, 655.0), "LOWER")
	_draw_finish_gate(Vector2(5150.0, 620.0))


func _draw_wind_lines() -> void:
	for index in range(18):
		var base_x := fposmod(float(index) * 347.0 + _elapsed * (18.0 + float(index % 4) * 3.0), 6000.0) - 250.0
		var y := 155.0 + float((index * 83) % 330)
		var length := 34.0 + float(index % 5) * 13.0
		draw_line(Vector2(base_x, y), Vector2(base_x + length, y - 3.0), Color(0.80, 1.0, 0.95, 0.24), 2.0, true)


func _draw_platform(rect: Rect2, style_index: int) -> void:
	var body_color := Color("788b79") if style_index % 2 == 0 else Color("6d8277")
	draw_rect(rect, Color("304c49"))
	draw_rect(Rect2(rect.position + Vector2(0.0, 6.0), rect.size - Vector2(0.0, 6.0)), body_color)
	var block_width := 86.0
	var column_count := int(ceil(rect.size.x / block_width))
	for column in range(column_count):
		var x := rect.position.x + float(column) * block_width
		var visible_width := minf(block_width - 3.0, rect.end.x - x)
		if visible_width <= 0.0:
			continue
		var shade := body_color.lightened(0.05) if column % 2 == 0 else body_color.darkened(0.04)
		draw_rect(Rect2(x + 2.0, rect.position.y + 18.0, visible_width, minf(58.0, rect.size.y - 20.0)), shade)
		draw_line(Vector2(x + 3.0, rect.position.y + 75.0), Vector2(x + visible_width, rect.position.y + 75.0), Color(0.20, 0.31, 0.30, 0.42), 2.0)
		draw_line(Vector2(x + visible_width + 1.0, rect.position.y + 19.0), Vector2(x + visible_width + 1.0, rect.position.y + 76.0), Color(0.20, 0.31, 0.30, 0.32), 2.0)

	draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(12.0, rect.size.y))), Color("4d762f"))
	draw_line(rect.position + Vector2(0.0, 1.0), Vector2(rect.end.x, rect.position.y + 1.0), Color("d6ed64"), 7.0, true)
	for tuft in range(int(rect.size.x / 38.0)):
		var x := rect.position.x + 14.0 + float(tuft) * 38.0
		var sway := sin(_elapsed * 1.6 + float(tuft + style_index)) * 2.0
		draw_line(Vector2(x, rect.position.y), Vector2(x + sway, rect.position.y - 9.0 - float(tuft % 3) * 2.0), Color("6ea73d"), 3.0, true)
		if tuft % 5 == 0:
			draw_circle(Vector2(x + 7.0, rect.position.y - 4.0), 2.3, Color("fff4bd"))


func _draw_waystone(position: Vector2, label: String) -> void:
	var stone := PackedVector2Array([
		position + Vector2(-12.0, 0.0),
		position + Vector2(-10.0, -34.0),
		position + Vector2(0.0, -43.0),
		position + Vector2(10.0, -34.0),
		position + Vector2(12.0, 0.0),
	])
	draw_colored_polygon(stone, Color("657b76"))
	draw_polyline(PackedVector2Array([stone[0], stone[1], stone[2], stone[3], stone[4]]), Color("314a49"), 3.0, true)
	draw_colored_polygon(PackedVector2Array([
		position + Vector2(-5.0, -25.0), position + Vector2(0.0, -32.0),
		position + Vector2(5.0, -25.0), position + Vector2(0.0, -18.0),
	]), Color("a9e5c1"))
	var font := ThemeDB.fallback_font
	var text_width := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11).x
	draw_string(font, position + Vector2(-text_width * 0.5, 19.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, Color("355b58"))


func _draw_finish_gate(position: Vector2) -> void:
	draw_rect(Rect2(position + Vector2(-70.0, -150.0), Vector2(28.0, 150.0)), Color("526d66"))
	draw_rect(Rect2(position + Vector2(42.0, -150.0), Vector2(28.0, 150.0)), Color("526d66"))
	draw_rect(Rect2(position + Vector2(-70.0, -166.0), Vector2(140.0, 28.0)), Color("667f72"))
	draw_arc(position + Vector2(0.0, -78.0), 46.0, 0.0, TAU, 48, Color(0.53, 0.96, 0.79, 0.30), 4.0, true)
	draw_arc(position + Vector2(0.0, -78.0), 37.0, 0.0, TAU, 48, Color(0.80, 1.0, 0.90, 0.24), 2.0, true)
