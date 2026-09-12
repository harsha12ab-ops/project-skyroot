class_name HeroRig
extends Node2D

## Shared lightweight cutout rig for both playable hero variants.
## Future motion names are reserved here so later abilities can extend the same rig.
const MOTION_IDLE := &"Idle"
const MOTION_RUN := &"Run"
const MOTION_JUMP_START := &"Jump Start"
const MOTION_RISING := &"Rising"
const MOTION_FALL := &"Fall"
const MOTION_LAND := &"Land"
const MOTION_ATTACK := &"Attack"
const MOTION_HIT := &"Hit"
const MOTION_DEATH := &"Death"
const MOTION_GALE_DASH := &"Gale Dash"
const MOTION_INTERACT := &"Interact"

const OUTLINE := Color("172535")
const HAIR_DARK := Color("3a251f")
const HAIR_LIGHT := Color("6b3c28")
const SKIN := Color("f2b487")
const SKIN_LIGHT := Color("ffd1a6")
const TUNIC := Color("2f79a8")
const TUNIC_LIGHT := Color("55a7c4")
const TUNIC_DARK := Color("1d4969")
const LEATHER := Color("6f452d")
const LEATHER_LIGHT := Color("a36b3d")
const TROUSERS := Color("253c4a")
const BOOT := Color("563726")
const SCARF := Color("c83f35")
const SCARF_LIGHT := Color("ef6351")
const METAL := Color("e8d18b")

var female_variant := false
var motion_state: StringName = MOTION_IDLE
var planar_speed := 0.0
var vertical_speed := 0.0
var _elapsed := 0.0
var _state_age := 0.0


func set_variant(is_female: bool) -> void:
	if female_variant == is_female:
		return
	female_variant = is_female
	queue_redraw()


func set_motion(next_motion: StringName, velocity: Vector2) -> void:
	if motion_state != next_motion:
		motion_state = next_motion
		_state_age = 0.0
	planar_speed = absf(velocity.x)
	vertical_speed = velocity.y
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	_state_age += delta
	queue_redraw()


func _draw() -> void:
	var pose := _build_pose()
	_draw_ground_shadow(pose)
	_draw_scarf(pose)
	_draw_hair_back(pose)
	_draw_leg(pose.hip + Vector2(-4.0, 0.0), pose.rear_knee, pose.rear_ankle, false)
	_draw_arm(pose.shoulder + Vector2(-3.0, 0.0), pose.rear_elbow, pose.rear_hand, false)
	_draw_torso(pose)
	_draw_leg(pose.hip + Vector2(4.0, 0.0), pose.front_knee, pose.front_ankle, true)
	_draw_head(pose)
	_draw_arm(pose.shoulder + Vector2(4.0, 0.0), pose.front_elbow, pose.front_hand, true)
	_draw_costume_details(pose)


func _build_pose() -> Dictionary:
	var phase := _elapsed * (10.5 + planar_speed / 95.0)
	var body_y := 0.0
	var lean := 0.0
	var front_leg := 0.04
	var rear_leg := -0.04
	var front_arm := -0.08
	var rear_arm := 0.08

	match motion_state:
		MOTION_IDLE:
			body_y = sin(_elapsed * 2.15) * 1.25
			front_arm = -0.05 + sin(_elapsed * 2.15) * 0.025
			rear_arm = 0.08 - sin(_elapsed * 2.15) * 0.02
		MOTION_RUN:
			body_y = -absf(sin(phase)) * 3.0
			lean = 0.10
			front_leg = sin(phase) * 0.78
			rear_leg = sin(phase + PI) * 0.78
			front_arm = sin(phase + PI) * 0.62
			rear_arm = sin(phase) * 0.62
		MOTION_JUMP_START:
			var crouch := clampf(_state_age / 0.10, 0.0, 1.0)
			body_y = lerpf(5.0, -2.0, crouch)
			front_leg = 0.34
			rear_leg = -0.28
			front_arm = -0.55
			rear_arm = 0.40
		MOTION_RISING:
			body_y = -1.0
			lean = 0.06
			front_leg = 0.42
			rear_leg = -0.50
			front_arm = -0.72
			rear_arm = 0.30
		MOTION_FALL:
			body_y = 0.5
			front_leg = -0.16
			rear_leg = 0.24
			front_arm = -0.28
			rear_arm = 0.36
		MOTION_LAND:
			var settle := clampf(_state_age / 0.13, 0.0, 1.0)
			body_y = lerpf(6.0, 0.0, settle)
			front_leg = lerpf(0.30, 0.04, settle)
			rear_leg = lerpf(-0.24, -0.04, settle)
			front_arm = lerpf(-0.34, -0.08, settle)
			rear_arm = lerpf(0.30, 0.08, settle)

	var hip := Vector2(0.0, -43.0 + body_y)
	var shoulder := Vector2(lean * 20.0, -62.0 + body_y)
	var head := Vector2(4.0 + lean * 16.0, -84.0 + body_y)
	var front_knee := hip + _down_vector(front_leg) * 23.0
	var rear_knee := hip + _down_vector(rear_leg) * 23.0
	var front_ankle := front_knee + _down_vector(-front_leg * 0.55) * 24.0
	var rear_ankle := rear_knee + _down_vector(-rear_leg * 0.55) * 24.0
	var front_elbow := shoulder + _down_vector(front_arm) * 19.0
	var rear_elbow := shoulder + _down_vector(rear_arm) * 19.0
	var front_hand := front_elbow + _down_vector(-front_arm * 0.45) * 17.0
	var rear_hand := rear_elbow + _down_vector(-rear_arm * 0.45) * 17.0

	return {
		"body_y": body_y,
		"lean": lean,
		"hip": hip,
		"shoulder": shoulder,
		"head": head,
		"front_knee": front_knee,
		"rear_knee": rear_knee,
		"front_ankle": front_ankle,
		"rear_ankle": rear_ankle,
		"front_elbow": front_elbow,
		"rear_elbow": rear_elbow,
		"front_hand": front_hand,
		"rear_hand": rear_hand,
	}


func _down_vector(angle: float) -> Vector2:
	return Vector2(sin(angle), cos(angle))


func _draw_ground_shadow(pose: Dictionary) -> void:
	if motion_state == MOTION_RISING or motion_state == MOTION_FALL or motion_state == MOTION_JUMP_START:
		return
	var compression := 1.0 - minf(planar_speed / 800.0, 0.22)
	draw_set_transform(Vector2(0.0, 1.5), 0.0, Vector2(1.0, 0.34))
	draw_circle(Vector2.ZERO, 27.0 * compression, Color(0.03, 0.12, 0.17, 0.24))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_scarf(pose: Dictionary) -> void:
	var neck: Vector2 = pose.shoulder + Vector2(-6.0, -5.0)
	var airflow := clampf(planar_speed / 320.0, 0.0, 1.0)
	if motion_state == MOTION_RISING or motion_state == MOTION_FALL:
		airflow = maxf(airflow, 0.72)
	var flutter := sin(_elapsed * (5.0 + airflow * 7.0))
	var lift := clampf(-vertical_speed / 900.0, -0.55, 0.65)
	var points := PackedVector2Array([
		neck,
		neck + Vector2(-20.0, -1.0 - airflow * 2.0),
		neck + Vector2(-43.0 - airflow * 8.0, 2.0 + flutter * 3.8 + lift * 8.0),
		neck + Vector2(-67.0 - airflow * 12.0, 7.0 - flutter * 5.2 + lift * 12.0),
	])
	draw_polyline(points, OUTLINE, 13.0, true)
	draw_polyline(points, SCARF, 8.5, true)
	draw_polyline(PackedVector2Array([points[0], points[1]]), SCARF_LIGHT, 2.0, true)
	var tip: Vector2 = points[3]
	var tail := PackedVector2Array([
		tip + Vector2(0.0, -5.0),
		tip + Vector2(-14.0, 2.0 + flutter * 2.0),
		tip + Vector2(1.0, 7.0),
	])
	draw_colored_polygon(tail, SCARF)
	draw_polyline(PackedVector2Array([tail[0], tail[1], tail[2], tail[0]]), OUTLINE, 2.5, true)


func _draw_hair_back(pose: Dictionary) -> void:
	if not female_variant:
		return
	var head: Vector2 = pose.head
	var sway := sin(_elapsed * 3.1) * 1.8
	var back_hair := PackedVector2Array([
		head + Vector2(-8.0, -12.0),
		head + Vector2(-17.0, -3.0),
		head + Vector2(-18.0 + sway, 24.0),
		head + Vector2(-8.0 + sway, 31.0),
		head + Vector2(-2.0, 13.0),
	])
	draw_colored_polygon(back_hair, HAIR_DARK)
	draw_polyline(PackedVector2Array([back_hair[0], back_hair[1], back_hair[2], back_hair[3], back_hair[4]]), OUTLINE, 3.0, true)


func _draw_leg(hip: Vector2, knee: Vector2, ankle: Vector2, front: bool) -> void:
	var pants := TROUSERS.lightened(0.07) if front else TROUSERS.darkened(0.13)
	_draw_cutout_limb(hip, knee, 11.5, pants)
	_draw_cutout_limb(knee, ankle, 10.0, pants.darkened(0.04))
	var boot_color := BOOT.lightened(0.08) if front else BOOT.darkened(0.10)
	draw_line(ankle + Vector2(0.0, -10.0), ankle + Vector2(0.0, 1.0), OUTLINE, 14.0, true)
	draw_line(ankle + Vector2(0.0, -10.0), ankle + Vector2(0.0, 1.0), boot_color, 9.5, true)
	var toe := ankle + Vector2(9.0, 1.0)
	draw_line(ankle, toe, OUTLINE, 11.5, true)
	draw_line(ankle, toe, boot_color, 7.0, true)
	draw_line(ankle + Vector2(-4.0, -8.0), ankle + Vector2(4.0, -8.0), LEATHER_LIGHT.darkened(0.12), 2.0, true)


func _draw_arm(shoulder: Vector2, elbow: Vector2, hand: Vector2, front: bool) -> void:
	var sleeve := TUNIC_LIGHT if front else TUNIC_DARK
	_draw_cutout_limb(shoulder, elbow, 10.5, sleeve)
	_draw_cutout_limb(elbow, hand, 8.5, LEATHER)
	draw_circle(hand, 6.0, OUTLINE)
	draw_circle(hand, 3.8, SKIN if front else SKIN.darkened(0.05))


func _draw_cutout_limb(from: Vector2, to: Vector2, width: float, fill: Color) -> void:
	draw_line(from, to, OUTLINE, width + 4.0, true)
	draw_circle(from, (width + 4.0) * 0.5, OUTLINE)
	draw_circle(to, (width + 4.0) * 0.5, OUTLINE)
	draw_line(from, to, fill, width, true)
	draw_circle(from, width * 0.5, fill)
	draw_circle(to, width * 0.5, fill)


func _draw_torso(pose: Dictionary) -> void:
	var shoulder: Vector2 = pose.shoulder
	var hip: Vector2 = pose.hip
	var waist_width := 14.0 if female_variant else 16.0
	var tunic := PackedVector2Array([
		shoulder + Vector2(-14.0, -4.0),
		shoulder + Vector2(14.0, -3.0),
		hip + Vector2(waist_width + 4.0, 7.0),
		hip + Vector2(-waist_width - 4.0, 7.0),
		hip + Vector2(-waist_width, -4.0),
	])
	draw_colored_polygon(tunic, OUTLINE)
	var inner := PackedVector2Array([
		shoulder + Vector2(-11.5, -1.5),
		shoulder + Vector2(11.5, -0.8),
		hip + Vector2(waist_width + 0.5, 4.0),
		hip + Vector2(-waist_width - 0.5, 4.0),
		hip + Vector2(-waist_width + 2.0, -3.0),
	])
	draw_colored_polygon(inner, TUNIC)
	draw_colored_polygon(PackedVector2Array([
		inner[0],
		inner[1],
		shoulder + Vector2(7.0, 8.0),
		shoulder + Vector2(-5.0, 8.0),
	]), TUNIC_LIGHT)


func _draw_head(pose: Dictionary) -> void:
	var head: Vector2 = pose.head
	draw_circle(head, 16.2, OUTLINE)
	draw_circle(head + Vector2(1.0, 0.5), 13.6, SKIN)
	draw_circle(head + Vector2(5.5, -3.5), 4.4, SKIN_LIGHT)
	var hair_points: PackedVector2Array
	if female_variant:
		hair_points = PackedVector2Array([
			head + Vector2(-15.0, -2.0),
			head + Vector2(-12.0, -14.0),
			head + Vector2(-4.0, -20.0),
			head + Vector2(2.0, -16.0),
			head + Vector2(9.0, -20.0),
			head + Vector2(16.0, -10.0),
			head + Vector2(10.0, -4.0),
			head + Vector2(5.0, -10.0),
			head + Vector2(-2.0, -5.0),
			head + Vector2(-8.0, -8.0),
		])
	else:
		hair_points = PackedVector2Array([
			head + Vector2(-16.0, -1.0),
			head + Vector2(-14.0, -13.0),
			head + Vector2(-7.0, -12.0),
			head + Vector2(-4.0, -23.0),
			head + Vector2(2.0, -16.0),
			head + Vector2(9.0, -22.0),
			head + Vector2(10.0, -13.0),
			head + Vector2(18.0, -16.0),
			head + Vector2(14.0, -5.0),
			head + Vector2(7.0, -9.0),
			head + Vector2(1.0, -5.0),
			head + Vector2(-7.0, -8.0),
		])
	draw_colored_polygon(hair_points, HAIR_DARK)
	draw_polyline(PackedVector2Array(Array(hair_points) + [hair_points[0]]), OUTLINE, 2.4, true)
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(-10.0, -12.0),
		head + Vector2(-4.0, -18.0),
		head + Vector2(3.0, -14.0),
		head + Vector2(-3.0, -9.0),
	]), HAIR_LIGHT)
	draw_circle(head + Vector2(10.3, 0.0), 2.1, OUTLINE)
	draw_circle(head + Vector2(10.9, -0.5), 0.8, Color.WHITE)
	draw_line(head + Vector2(13.0, 7.0), head + Vector2(9.0, 7.8), Color("9e503d"), 1.2, true)


func _draw_costume_details(pose: Dictionary) -> void:
	var shoulder: Vector2 = pose.shoulder
	var hip: Vector2 = pose.hip
	# Scarf knot and collar.
	draw_circle(shoulder + Vector2(-9.0, -5.0), 7.0, OUTLINE)
	draw_circle(shoulder + Vector2(-8.5, -5.0), 4.7, SCARF_LIGHT)
	draw_line(shoulder + Vector2(-8.0, -1.0), shoulder + Vector2(11.0, 7.0), SCARF, 7.0, true)
	# Leather belt and brass clasp.
	draw_line(hip + Vector2(-15.0, -1.0), hip + Vector2(16.0, -1.0), OUTLINE, 8.5, true)
	draw_line(hip + Vector2(-14.0, -1.0), hip + Vector2(15.0, -1.0), LEATHER, 5.0, true)
	draw_rect(Rect2(hip + Vector2(1.0, -5.0), Vector2(7.0, 8.0)), OUTLINE)
	draw_rect(Rect2(hip + Vector2(2.5, -3.5), Vector2(4.0, 5.0)), METAL)
	# Cross-body travel strap and small side pouch.
	draw_line(shoulder + Vector2(8.0, 0.0), hip + Vector2(-10.0, 0.0), LEATHER_LIGHT, 3.5, true)
	draw_rect(Rect2(hip + Vector2(-21.0, -1.0), Vector2(10.0, 12.0)), OUTLINE)
	draw_rect(Rect2(hip + Vector2(-19.0, 1.0), Vector2(7.0, 8.0)), LEATHER_LIGHT)
