class_name SkyrootPlayerCamera
extends Camera2D

@export var horizontal_follow_speed := 7.5
@export var vertical_follow_speed := 2.2
@export var forward_bias := 132.0
@export var grounded_screen_offset := 166.0
@export var airborne_dead_zone := 58.0

@onready var player: SkyrootPlayer = get_parent() as SkyrootPlayer

var _ground_anchor_y := 450.0
var _initialized := false


func _ready() -> void:
	top_level = true
	position_smoothing_enabled = false
	limit_left = 0
	limit_right = 5600
	limit_top = 0
	limit_bottom = 820


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	if not _initialized:
		_ground_anchor_y = player.global_position.y - grounded_screen_offset
		global_position = Vector2(player.global_position.x, _ground_anchor_y)
		_initialized = true

	var target_x := player.global_position.x + player.get_facing_direction() * forward_bias
	global_position.x = lerpf(global_position.x, target_x, 1.0 - exp(-horizontal_follow_speed * delta))

	if player.is_on_floor():
		var grounded_target := player.global_position.y - grounded_screen_offset
		_ground_anchor_y = lerpf(_ground_anchor_y, grounded_target, 1.0 - exp(-3.2 * delta))

	var player_camera_delta := player.global_position.y - grounded_screen_offset - _ground_anchor_y
	var vertical_target := _ground_anchor_y
	if absf(player_camera_delta) > airborne_dead_zone:
		vertical_target += signf(player_camera_delta) * (absf(player_camera_delta) - airborne_dead_zone)
	global_position.y = lerpf(global_position.y, vertical_target, 1.0 - exp(-vertical_follow_speed * delta))
