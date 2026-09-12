class_name SkyrootPlayer
extends CharacterBody2D

signal variant_changed(is_female: bool)
signal motion_changed(motion_name: StringName)

@export_category("Horizontal Movement")
@export var run_speed := 320.0
@export var ground_acceleration := 2500.0
@export var ground_deceleration := 3000.0
@export var air_acceleration := 1450.0
@export var air_deceleration := 850.0

@export_category("Vertical Movement")
@export var jump_velocity := -690.0
@export var gravity := 1900.0
@export var terminal_velocity := 1120.0
@export_range(0.2, 0.8, 0.01) var short_hop_multiplier := 0.46
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

@onready var hero_rig: HeroRig = $HeroRig

var is_female := false
var current_motion: StringName = HeroRig.MOTION_IDLE
var _facing := 1.0
var _coyote_remaining := 0.0
var _jump_buffer_remaining := 0.0
var _landing_remaining := 0.0
var _jump_age := 999.0
var _was_on_floor := false
var _replay_active := false
var _replay_axis := 0.0
var _replay_jump_pressed := false
var _replay_jump_released := false


func _ready() -> void:
	floor_snap_length = 7.0
	floor_stop_on_slope = true
	floor_max_angle = deg_to_rad(46.0)
	motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
	hero_rig.set_variant(is_female)


func _physics_process(delta: float) -> void:
	_was_on_floor = is_on_floor()
	_update_input_windows(delta)
	_update_variant_input()
	_apply_horizontal_movement(delta)
	_apply_vertical_movement(delta)
	move_and_slide()
	_detect_landing()
	_update_motion_state(delta)
	_replay_jump_pressed = false
	_replay_jump_released = false


func _update_input_windows(delta: float) -> void:
	if is_on_floor():
		_coyote_remaining = coyote_time
	else:
		_coyote_remaining = maxf(_coyote_remaining - delta, 0.0)

	if Input.is_action_just_pressed("jump") or _replay_jump_pressed:
		_jump_buffer_remaining = jump_buffer_time
	else:
		_jump_buffer_remaining = maxf(_jump_buffer_remaining - delta, 0.0)


func _update_variant_input() -> void:
	if Input.is_action_just_pressed("toggle_variant"):
		set_female_variant(not is_female)


func _apply_horizontal_movement(delta: float) -> void:
	var input_axis := _replay_axis if _replay_active else Input.get_axis("move_left", "move_right")
	if not is_zero_approx(input_axis):
		_facing = signf(input_axis)
		hero_rig.scale.x = _facing
		var acceleration := ground_acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, input_axis * run_speed, acceleration * delta)
	else:
		var deceleration := ground_deceleration if is_on_floor() else air_deceleration
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)


func _apply_vertical_movement(delta: float) -> void:
	if _jump_buffer_remaining > 0.0 and _coyote_remaining > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_remaining = 0.0
		_coyote_remaining = 0.0
		_jump_age = 0.0

	if (Input.is_action_just_released("jump") or _replay_jump_released) and velocity.y < 0.0:
		velocity.y *= short_hop_multiplier

	if not is_on_floor() or velocity.y < 0.0:
		velocity.y = minf(velocity.y + gravity * delta, terminal_velocity)


func _detect_landing() -> void:
	if not _was_on_floor and is_on_floor():
		_landing_remaining = 0.13
		_jump_age = 999.0


func _update_motion_state(delta: float) -> void:
	_landing_remaining = maxf(_landing_remaining - delta, 0.0)
	_jump_age += delta

	var next_motion: StringName
	if _landing_remaining > 0.0:
		next_motion = HeroRig.MOTION_LAND
	elif not is_on_floor():
		if velocity.y < -120.0:
			next_motion = HeroRig.MOTION_JUMP_START if _jump_age < 0.10 else HeroRig.MOTION_RISING
		else:
			next_motion = HeroRig.MOTION_FALL
	elif absf(velocity.x) > 24.0:
		next_motion = HeroRig.MOTION_RUN
	else:
		next_motion = HeroRig.MOTION_IDLE

	if current_motion != next_motion:
		current_motion = next_motion
		motion_changed.emit(current_motion)
	hero_rig.set_motion(current_motion, velocity)


func get_facing_direction() -> float:
	return _facing


func set_female_variant(value: bool) -> void:
	if is_female == value:
		return
	is_female = value
	hero_rig.set_variant(is_female)
	variant_changed.emit(is_female)


func set_movement_replay(active: bool, axis := 0.0, jump_pressed := false, jump_released := false) -> void:
	_replay_active = active
	_replay_axis = clampf(axis, -1.0, 1.0)
	_replay_jump_pressed = jump_pressed
	_replay_jump_released = jump_released
