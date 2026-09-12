extends Control

const SKY_TOP := Color("061328")
const SKY_MID := Color("0b2940")
const SKY_LOW := Color("174955")
const CYAN := Color("76e7d0")
const MINT := Color("b9f7df")
const CLOUD := Color("dffcf0")
const TEXT_MUTED := Color("9fc7c5")
const TEXT_DIM := Color("65908f")

var _elapsed := 0.0
var _motes: Array[Dictionary] = []
var _accept_input := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rng := RandomNumberGenerator.new()
	rng.seed = 730_021
	for index in range(34):
		_motes.append({
			"x": rng.randf(),
			"y": rng.randf_range(0.08, 0.88),
			"radius": rng.randf_range(0.7, 2.2),
			"speed": rng.randf_range(0.012, 0.034),
			"phase": rng.randf_range(0.0, TAU),
			"alpha": rng.randf_range(0.16, 0.52),
		})
	queue_redraw()
	if "--phase1-playtest" in OS.get_cmdline_user_args():
		_begin_phase1_playtest.call_deferred()


func _begin_phase1_playtest() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/test/player_movement_lab.tscn")


func _process(delta: float) -> void:
	_elapsed += delta
	_accept_input = _elapsed >= 0.65
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if _accept_input and event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/test/player_movement_lab.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var viewport_size := size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	_draw_sky(viewport_size)
	_draw_horizon(viewport_size)
	_draw_motes(viewport_size)
	_draw_frame(viewport_size)
	_draw_identity(viewport_size)


func _draw_sky(viewport_size: Vector2) -> void:
	const BAND_COUNT := 30
	for band in range(BAND_COUNT):
		var t := float(band) / float(BAND_COUNT - 1)
		var color := SKY_TOP.lerp(SKY_MID, minf(t * 1.55, 1.0))
		if t > 0.58:
			color = SKY_MID.lerp(SKY_LOW, (t - 0.58) / 0.42)
		var y := viewport_size.y * t
		draw_rect(Rect2(0.0, y, viewport_size.x, viewport_size.y / BAND_COUNT + 2.0), color)

	var glow_center := Vector2(viewport_size.x * 0.5, viewport_size.y * 0.53)
	for ring in range(12, 0, -1):
		var radius := viewport_size.y * (0.055 + float(ring) * 0.032)
		var alpha := 0.006 + float(12 - ring) * 0.0015
		draw_circle(glow_center, radius, Color(0.35, 0.95, 0.81, alpha))


func _draw_horizon(viewport_size: Vector2) -> void:
	var w := viewport_size.x
	var h := viewport_size.y
	var far_ridge := PackedVector2Array([
		Vector2(0.0, h * 0.74),
		Vector2(w * 0.11, h * 0.64),
		Vector2(w * 0.20, h * 0.70),
		Vector2(w * 0.34, h * 0.54),
		Vector2(w * 0.46, h * 0.68),
		Vector2(w * 0.61, h * 0.51),
		Vector2(w * 0.75, h * 0.66),
		Vector2(w * 0.89, h * 0.56),
		Vector2(w, h * 0.65),
		Vector2(w, h),
		Vector2(0.0, h),
	])
	draw_colored_polygon(far_ridge, Color("102f3b"))

	var near_ridge := PackedVector2Array([
		Vector2(0.0, h * 0.82),
		Vector2(w * 0.16, h * 0.70),
		Vector2(w * 0.29, h * 0.78),
		Vector2(w * 0.44, h * 0.65),
		Vector2(w * 0.57, h * 0.76),
		Vector2(w * 0.71, h * 0.62),
		Vector2(w * 0.84, h * 0.73),
		Vector2(w, h * 0.67),
		Vector2(w, h),
		Vector2(0.0, h),
	])
	draw_colored_polygon(near_ridge, Color("0a202d"))

	draw_rect(Rect2(0.0, h * 0.90, w, h * 0.10), Color("06131d"))
	for layer in range(4):
		var mist_y := h * (0.77 + float(layer) * 0.045)
		var drift := sin(_elapsed * 0.16 + float(layer)) * w * 0.012
		draw_line(
			Vector2(-w * 0.05 + drift, mist_y),
			Vector2(w * 1.05 + drift, mist_y - h * 0.018),
			Color(0.55, 0.92, 0.84, 0.035 - float(layer) * 0.006),
			2.0
		)


func _draw_motes(viewport_size: Vector2) -> void:
	for mote in _motes:
		var x := fposmod((float(mote.x) + _elapsed * float(mote.speed)), 1.08) - 0.04
		var y := float(mote.y) + sin(_elapsed * 0.45 + float(mote.phase)) * 0.014
		var alpha := float(mote.alpha) * (0.72 + 0.28 * sin(_elapsed * 0.8 + float(mote.phase)))
		draw_circle(
			Vector2(x * viewport_size.x, y * viewport_size.y),
			float(mote.radius),
			Color(0.66, 1.0, 0.88, alpha)
		)


func _draw_frame(viewport_size: Vector2) -> void:
	var margin := maxf(24.0, minf(viewport_size.x, viewport_size.y) * 0.045)
	var corner := 26.0
	var line_color := Color(0.55, 0.96, 0.86, 0.16)
	var left := margin
	var right := viewport_size.x - margin
	var top := margin
	var bottom := viewport_size.y - margin

	draw_line(Vector2(left, top), Vector2(left + corner, top), line_color, 1.0)
	draw_line(Vector2(left, top), Vector2(left, top + corner), line_color, 1.0)
	draw_line(Vector2(right, top), Vector2(right - corner, top), line_color, 1.0)
	draw_line(Vector2(right, top), Vector2(right, top + corner), line_color, 1.0)
	draw_line(Vector2(left, bottom), Vector2(left + corner, bottom), line_color, 1.0)
	draw_line(Vector2(left, bottom), Vector2(left, bottom - corner), line_color, 1.0)
	draw_line(Vector2(right, bottom), Vector2(right - corner, bottom), line_color, 1.0)
	draw_line(Vector2(right, bottom), Vector2(right, bottom - corner), line_color, 1.0)


func _draw_identity(viewport_size: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var scale_factor := clampf(minf(viewport_size.x / 1280.0, viewport_size.y / 720.0), 0.72, 1.35)
	var center := Vector2(viewport_size.x * 0.5, viewport_size.y * 0.42)

	_draw_centered_text(font, "PROJECT  SKYROOT", viewport_size.y * 0.104, int(17.0 * scale_factor), TEXT_MUTED)
	var label_width := 96.0 * scale_factor
	draw_line(Vector2(center.x - label_width, viewport_size.y * 0.118), Vector2(center.x + label_width, viewport_size.y * 0.118), Color(0.47, 0.91, 0.81, 0.22), 1.0)

	_draw_crest(center, scale_factor)

	var title_y := viewport_size.y * 0.585
	_draw_centered_text(font, "SKYROOT", title_y, int(68.0 * scale_factor), CLOUD)
	_draw_centered_text(font, "THE SKY REMEMBERS", title_y + 48.0 * scale_factor, int(14.0 * scale_factor), TEXT_MUTED)

	var status_y := viewport_size.y * 0.835
	var pulse := 0.62 + sin(_elapsed * 2.2) * 0.18
	draw_circle(Vector2(center.x - 119.0 * scale_factor, status_y - 5.0 * scale_factor), 3.2 * scale_factor, Color(0.46, 0.95, 0.81, pulse))
	_draw_centered_text(font, "PHASE 0    FOUNDATION ONLINE", status_y, int(13.0 * scale_factor), TEXT_DIM)

	var load_width := minf(viewport_size.x * 0.22, 280.0 * scale_factor)
	var load_x := center.x - load_width * 0.5
	var load_y := status_y + 22.0 * scale_factor
	draw_rect(Rect2(load_x, load_y, load_width, 1.0), Color(0.42, 0.81, 0.74, 0.13))
	var sweep := 0.35 + 0.65 * (0.5 + 0.5 * sin(_elapsed * 0.65))
	draw_rect(Rect2(load_x, load_y, load_width * sweep, 1.0), Color(0.46, 0.95, 0.81, 0.68))
	var prompt_alpha := 0.46 + 0.18 * sin(_elapsed * 2.0)
	_draw_centered_text(font, "ENTER  /  SPACE    BEGIN MOVEMENT LAB", viewport_size.y * 0.925, int(12.0 * scale_factor), Color(0.62, 0.84, 0.82, prompt_alpha))


func _draw_crest(center: Vector2, scale_factor: float) -> void:
	var outer_radius := 74.0 * scale_factor
	var pulse := 1.0 + sin(_elapsed * 1.4) * 0.018
	var crest_center := center - Vector2(0.0, 35.0 * scale_factor)

	draw_arc(crest_center, outer_radius * pulse, -2.65, -0.49, 72, Color(0.50, 0.95, 0.84, 0.24), 1.5 * scale_factor, true)
	draw_arc(crest_center, outer_radius * 0.78, 0.49, 2.65, 72, Color(0.50, 0.95, 0.84, 0.16), 1.0 * scale_factor, true)
	draw_circle(crest_center, 46.0 * scale_factor, Color(0.15, 0.58, 0.50, 0.08))
	draw_arc(crest_center, 46.0 * scale_factor, 0.0, TAU, 72, Color(0.55, 0.98, 0.86, 0.24), 1.0 * scale_factor, true)

	var stem_base := crest_center + Vector2(0.0, 24.0 * scale_factor)
	var stem_top := crest_center - Vector2(0.0, 19.0 * scale_factor)
	draw_line(stem_base, stem_top, CYAN, 3.0 * scale_factor, true)
	draw_line(stem_base, stem_base + Vector2(-11.0, 12.0) * scale_factor, Color(0.52, 0.95, 0.77, 0.88), 2.0 * scale_factor, true)
	draw_line(stem_base, stem_base + Vector2(11.0, 12.0) * scale_factor, Color(0.52, 0.95, 0.77, 0.88), 2.0 * scale_factor, true)

	var left_leaf := PackedVector2Array([
		stem_top + Vector2(-1.0, 5.0) * scale_factor,
		stem_top + Vector2(-27.0, -12.0) * scale_factor,
		stem_top + Vector2(-18.0, 15.0) * scale_factor,
	])
	var right_leaf := PackedVector2Array([
		stem_top + Vector2(1.0, 4.0) * scale_factor,
		stem_top + Vector2(27.0, -15.0) * scale_factor,
		stem_top + Vector2(18.0, 14.0) * scale_factor,
	])
	draw_colored_polygon(left_leaf, MINT)
	draw_colored_polygon(right_leaf, CYAN)
	draw_circle(stem_base + Vector2(0.0, 13.0 * scale_factor), 3.5 * scale_factor, Color(0.50, 0.94, 0.75, 0.90))


func _draw_centered_text(font: Font, text: String, baseline_y: float, font_size: int, color: Color) -> void:
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	draw_string(font, Vector2((size.x - text_size.x) * 0.5, baseline_y), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
