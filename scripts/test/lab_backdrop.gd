extends Control

const SKY_TOP := Color("6ab8ef")
const SKY_BOTTOM := Color("e7f7f1")
const CLOUD := Color("f8fff9")
const CLOUD_SHADE := Color("cce8ea")

var _elapsed := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()


func _draw() -> void:
	var viewport_size := size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	for band in range(24):
		var t := float(band) / 23.0
		var color := SKY_TOP.lerp(SKY_BOTTOM, t)
		draw_rect(Rect2(0.0, viewport_size.y * t, viewport_size.x, viewport_size.y / 23.0 + 2.0), color)

	_draw_cloud(Vector2(viewport_size.x * 0.14 + sin(_elapsed * 0.08) * 9.0, viewport_size.y * 0.25), 1.05)
	_draw_cloud(Vector2(viewport_size.x * 0.73 + sin(_elapsed * 0.06 + 2.0) * 12.0, viewport_size.y * 0.18), 0.82)
	_draw_cloud(Vector2(viewport_size.x * 0.48 + sin(_elapsed * 0.05 + 4.0) * 8.0, viewport_size.y * 0.43), 0.58)

	_draw_floating_island(Vector2(viewport_size.x * 0.22, viewport_size.y * 0.49), 0.58)
	_draw_floating_island(Vector2(viewport_size.x * 0.82, viewport_size.y * 0.40), 0.72)
	_draw_floating_island(Vector2(viewport_size.x * 0.56, viewport_size.y * 0.22), 0.36)

	for index in range(14):
		var x := fposmod(float(index) * 137.0 + _elapsed * (2.0 + float(index % 3)), viewport_size.x + 80.0) - 40.0
		var y := 105.0 + float((index * 47) % 310)
		draw_circle(Vector2(x, y), 1.4 + float(index % 2), Color(0.91, 1.0, 0.82, 0.42))


func _draw_cloud(center: Vector2, cloud_scale: float) -> void:
	draw_set_transform(center + Vector2(0.0, 8.0 * cloud_scale), 0.0, Vector2(cloud_scale, cloud_scale * 0.62))
	draw_circle(Vector2.ZERO, 52.0, Color(CLOUD_SHADE, 0.34))
	draw_set_transform(center, 0.0, Vector2(cloud_scale, cloud_scale * 0.62))
	draw_circle(Vector2(-38.0, 5.0), 34.0, Color(CLOUD, 0.83))
	draw_circle(Vector2(0.0, -7.0), 48.0, Color(CLOUD, 0.88))
	draw_circle(Vector2(43.0, 7.0), 31.0, Color(CLOUD, 0.80))
	draw_rect(Rect2(-42.0, 0.0, 86.0, 28.0), Color(CLOUD, 0.82))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_floating_island(center: Vector2, island_scale: float) -> void:
	draw_set_transform(center, 0.0, Vector2(island_scale, island_scale))
	var rock := PackedVector2Array([
		Vector2(-74.0, 0.0), Vector2(72.0, 0.0), Vector2(46.0, 48.0),
		Vector2(15.0, 92.0), Vector2(-12.0, 73.0), Vector2(-45.0, 49.0),
	])
	draw_colored_polygon(rock, Color("7c9aa2"))
	draw_colored_polygon(PackedVector2Array([Vector2(-74.0, 0.0), Vector2(72.0, 0.0), Vector2(58.0, 14.0), Vector2(-63.0, 14.0)]), Color("80b84d"))
	draw_polyline(PackedVector2Array([Vector2(-74.0, 0.0), Vector2(72.0, 0.0)]), Color("d7ef72"), 7.0, true)
	draw_line(Vector2(-27.0, 19.0), Vector2(-8.0, 68.0), Color(0.34, 0.49, 0.52, 0.45), 3.0)
	draw_line(Vector2(32.0, 16.0), Vector2(14.0, 64.0), Color(0.34, 0.49, 0.52, 0.38), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
