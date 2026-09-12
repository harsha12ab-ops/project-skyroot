extends Control

var player: SkyrootPlayer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	player = get_tree().current_scene.get_node("Player") as SkyrootPlayer
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(player):
		return
	var font := ThemeDB.fallback_font
	var panel := Rect2(34.0, 30.0, 360.0, 78.0)
	draw_style_box(_panel_style(), panel)
	draw_string(font, Vector2(54.0, 58.0), "PROJECT SKYROOT    MOVEMENT LAB", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 17, Color("ecfff4"))
	draw_string(font, Vector2(54.0, 82.0), "A / D  MOVE     SPACE  JUMP     V  SWITCH HERO", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("b9d9d1"))
	var variant_name := "FEMALE" if player.is_female else "MALE"
	var readout := "%s    %s    SPEED %03d" % [variant_name, String(player.current_motion).to_upper(), int(absf(player.velocity.x))]
	draw_string(font, Vector2(54.0, 101.0), readout, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color("78e6c4"))

	var objective := "Reach the waygate    F9  FULL PLAYTEST"
	var objective_size := font.get_string_size(objective, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13)
	draw_style_box(_panel_style(0.68), Rect2(size.x - objective_size.x - 76.0, 30.0, objective_size.x + 42.0, 43.0))
	draw_string(font, Vector2(size.x - objective_size.x - 55.0, 57.0), objective, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("d8f5e8"))


func _panel_style(alpha := 0.82) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.12, 0.16, alpha)
	style.border_color = Color(0.46, 0.90, 0.76, 0.28)
	style.set_border_width_all(1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style
