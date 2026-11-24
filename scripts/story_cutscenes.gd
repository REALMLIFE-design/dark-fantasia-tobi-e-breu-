extends RefCounted
## Cinematic story layer for Tobi e Breu. Uses native Godot UI so it stays lightweight on Android.

const STORY_SETTINGS_PATH := "user://tobi_breu_story.cfg"

static func intro_was_seen() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(STORY_SETTINGS_PATH) != OK:
		return false
	return bool(cfg.get_value("story", "intro_seen", false))

static func _mark_intro_seen() -> void:
	var cfg := ConfigFile.new()
	cfg.load(STORY_SETTINGS_PATH)
	cfg.set_value("story", "intro_seen", true)
	cfg.save(STORY_SETTINGS_PATH)

static func play_intro(world: Node) -> void:
	if intro_was_seen():
		return
	var previous_pause := world.get_tree().paused
	world.get_tree().paused = true
	var layer := CanvasLayer.new()
	layer.name = "OpeningCinematic"
	layer.layer = 120
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	world.add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(root)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.012, 0.018, 0.025, 1.0)
	root.add_child(backdrop)

	var glow := ColorRect.new()
	glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	glow.color = Color(0.16, 0.035, 0.025, 0.12)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(glow)

	var content := VBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_CENTER)
	content.anchor_left = 0.12
	content.anchor_right = 0.88
	content.anchor_top = 0.22
	content.anchor_bottom = 0.80
	content.offset_left = 0
	content.offset_right = 0
	content.offset_top = 0
	content.offset_bottom = 0
	content.add_theme_constant_override("separation", 22)
	root.add_child(content)

	var chapter := Label.new()
	chapter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter.add_theme_font_size_override("font_size", 15)
	chapter.add_theme_color_override("font_color", Color("c7a66b"))
	content.add_child(chapter)

	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("f0e5ce"))
	content.add_child(title)

	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(100, 2)
	divider.color = Color("9d7548")
	divider.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(divider)

	var body := Label.new()
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 20)
	body.add_theme_color_override("font_color", Color("d9d0bf"))
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(body)

	var hint := Label.new()
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("a99a80"))
	content.add_child(hint)

	var next_button := Button.new()
	next_button.custom_minimum_size = Vector2(220, 54)
	next_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	next_button.text = "CONTINUAR"
	next_button.add_theme_font_size_override("font_size", 17)
	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color("3b3025")
	button_style.border_color = Color("b18b55")
	button_style.set_border_width_all(2)
	button_style.set_corner_radius_all(12)
	button_style.content_margin_left = 24
	button_style.content_margin_right = 24
	button_style.content_margin_top = 12
	button_style.content_margin_bottom = 12
	next_button.add_theme_stylebox_override("normal", button_style)
	content.add_child(next_button)

	var pages := [
		{"chapter":"PRÓLOGO  •  QUANDO A LUZ SE CALOU","title":"O Coração Roubado","body":"Durante gerações, o Coração Rubro manteve o equilíbrio entre a vida e a escuridão. Até que, numa noite sem estrelas, alguém o arrancou do Templo do Coração. Uma névoa cinzenta começou a engolir florestas, rios e lembranças.","hint":"Uma antiga lenda voltou a despertar."},
		{"chapter":"DOIS VIAJANTES  •  UMA PROMESSA","title":"Tobi e Breu","body":"Tobi encontrou Breu ainda pequeno, perdido na fronteira da floresta corrompida. Desde então, os dois nunca se separaram. Agora, enquanto o Silêncio Cinzento avança, Breu sente a corrupção antes de qualquer pessoa — e Tobi decide não abandonar seu amigo nem o mundo que os acolheu.","hint":"A amizade deles será testada em cada região."},
		{"chapter":"CAPÍTULO I  •  A PRIMEIRA PISTA","title":"O chamado de Azulan","body":"O Mestre Azulan sabe que o roubo não foi obra de um simples ladrão. As marcas levam para além da clareira, até o Guardião do Silêncio e as terras esquecidas. Para encontrar o Coração Rubro, Tobi precisará reunir aliados, purificar os santuários e descobrir quem está por trás da névoa.","hint":"Sua jornada começa agora."}
	]

	var page_index := 0
	var finished := false
	var tween := world.create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	backdrop.modulate.a = 0.0
	content.modulate.a = 0.0
	tween.tween_property(backdrop, "modulate:a", 1.0, 0.65)
	tween.parallel().tween_property(content, "modulate:a", 1.0, 0.85)
	await tween.finished

	while not finished:
		var page: Dictionary = pages[page_index]
		chapter.text = str(page["chapter"])
		title.text = str(page["title"])
		body.text = str(page["body"])
		hint.text = str(page["hint"])
		next_button.text = "INICIAR A JORNADA" if page_index == pages.size() - 1 else "CONTINUAR"
		var pressed := false
		var callback := func() -> void: pressed = true
		next_button.pressed.connect(callback)
		while not pressed:
			await world.get_tree().process_frame
		next_button.pressed.disconnect(callback)
		if page_index < pages.size() - 1:
			var fade := world.create_tween()
			fade.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			fade.tween_property(content, "modulate:a", 0.0, 0.22)
			await fade.finished
			page_index += 1
			var reveal := world.create_tween()
			reveal.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			reveal.tween_property(content, "modulate:a", 1.0, 0.30)
			await reveal.finished
		else:
			finished = true

	_mark_intro_seen()
	var outro := world.create_tween()
	outro.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	outro.tween_property(root, "modulate:a", 0.0, 0.45)
	await outro.finished
	world.get_tree().paused = previous_pause
	layer.queue_free()
