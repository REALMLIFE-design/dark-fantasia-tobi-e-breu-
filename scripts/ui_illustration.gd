extends Control
## Ilustração vetorial original, desenhada por código para a interface.
## Não usa imagens geradas, texturas ou recursos externos.

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return
	var scale_factor := minf(w / 520.0, h / 220.0)
	var moon_center := Vector2(w * 0.76, h * 0.28)
	var moon_radius := minf(h * 0.24, w * 0.13)
	draw_circle(moon_center, moon_radius, Color("#6c343c"))
	draw_circle(moon_center + Vector2(-moon_radius * 0.12, -moon_radius * 0.08), moon_radius * 0.82, Color("#8b4a4a"))
	# Silhueta distante de árvores e ruínas.
	var skyline := PackedVector2Array([
		Vector2(0, h * 0.68), Vector2(w * 0.08, h * 0.49),
		Vector2(w * 0.14, h * 0.63), Vector2(w * 0.22, h * 0.40),
		Vector2(w * 0.29, h * 0.65), Vector2(w * 0.39, h * 0.46),
		Vector2(w * 0.48, h * 0.68), Vector2(w * 0.60, h * 0.48),
		Vector2(w * 0.71, h * 0.68), Vector2(w * 0.82, h * 0.48),
		Vector2(w * 0.91, h * 0.65), Vector2(w, h * 0.52),
		Vector2(w, h), Vector2(0, h)
	])
	draw_colored_polygon(skyline, Color("#101b23"))
	# Tobi: capa, ombros, capuz e espada em formas simples.
	var hero_x := w * 0.43
	var ground_y := h * 0.91
	var cloak := PackedVector2Array([
		Vector2(hero_x - 36 * scale_factor, h * 0.52),
		Vector2(hero_x - 60 * scale_factor, h * 0.68),
		Vector2(hero_x - 47 * scale_factor, ground_y),
		Vector2(hero_x + 46 * scale_factor, ground_y),
		Vector2(hero_x + 61 * scale_factor, h * 0.68),
		Vector2(hero_x + 34 * scale_factor, h * 0.52)
	])
	draw_colored_polygon(cloak, Color("#202e36"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(hero_x - 27 * scale_factor, h * 0.55),
		Vector2(hero_x, h * 0.48),
		Vector2(hero_x + 27 * scale_factor, h * 0.55),
		Vector2(hero_x + 18 * scale_factor, h * 0.78),
		Vector2(hero_x - 18 * scale_factor, h * 0.78)
	]), Color("#40534f"))
	draw_circle(Vector2(hero_x, h * 0.39), 22 * scale_factor, Color("#c79c79"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(hero_x - 28 * scale_factor, h * 0.42),
		Vector2(hero_x - 22 * scale_factor, h * 0.29),
		Vector2(hero_x, h * 0.23),
		Vector2(hero_x + 24 * scale_factor, h * 0.30),
		Vector2(hero_x + 28 * scale_factor, h * 0.43),
		Vector2(hero_x + 10 * scale_factor, h * 0.35),
		Vector2(hero_x - 10 * scale_factor, h * 0.35)
	]), Color("#172128"))
	# Lâmina e guarda da espada.
	draw_line(Vector2(hero_x + 39 * scale_factor, h * 0.63), Vector2(hero_x + 88 * scale_factor, h * 0.20), Color("#c5c9c4"), 3.0 * scale_factor, true)
	draw_line(Vector2(hero_x + 29 * scale_factor, h * 0.59), Vector2(hero_x + 49 * scale_factor, h * 0.67), Color("#c5a15c"), 4.0 * scale_factor, true)
	# Breu: corpo felino, orelhas, cauda e olhos luminosos.
	var cat_x := w * 0.69
	draw_circle(Vector2(cat_x, h * 0.79), 25 * scale_factor, Color("#090d13"))
	draw_circle(Vector2(cat_x + 18 * scale_factor, h * 0.70), 16 * scale_factor, Color("#090d13"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(cat_x + 5 * scale_factor, h * 0.60),
		Vector2(cat_x + 6 * scale_factor, h * 0.49),
		Vector2(cat_x + 17 * scale_factor, h * 0.60)
	]), Color("#090d13"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(cat_x + 20 * scale_factor, h * 0.59),
		Vector2(cat_x + 31 * scale_factor, h * 0.49),
		Vector2(cat_x + 32 * scale_factor, h * 0.63)
	]), Color("#090d13"))
	draw_line(Vector2(cat_x - 20 * scale_factor, h * 0.80), Vector2(cat_x - 48 * scale_factor, h * 0.68), Color("#090d13"), 7.0 * scale_factor, true)
	draw_circle(Vector2(cat_x + 24 * scale_factor, h * 0.69), 2.8 * scale_factor, Color("#8e7bd0"))
	draw_circle(Vector2(cat_x + 13 * scale_factor, h * 0.69), 2.8 * scale_factor, Color("#8e7bd0"))
	# Pequenos pontos de energia e um arco de runa discreto.
	for point in [
		Vector2(w * 0.16, h * 0.28),
		Vector2(w * 0.30, h * 0.18),
		Vector2(w * 0.56, h * 0.24),
		Vector2(w * 0.91, h * 0.36)
	]:
		draw_circle(point, 2.0 * scale_factor, Color("#c5a15c"))
	draw_line(Vector2(w * 0.12, h * 0.94), Vector2(w * 0.91, h * 0.94), Color("#80633d"), 1.0, true)
