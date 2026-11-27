extends RefCounted
## Cinematic story layer for Dark World: A Lenda de Tobi e Breu.
## Native Godot UI keeps the story presentation lightweight on Android.

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
	content.anchor_left = 0.06
	content.anchor_right = 0.94
	content.anchor_top = 0.06
	content.anchor_bottom = 0.94
	content.offset_left = 0
	content.offset_right = 0
	content.offset_top = 0
	content.offset_bottom = 0
	content.add_theme_constant_override("separation", 10)
	root.add_child(content)

	var chapter := Label.new()
	chapter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter.add_theme_font_size_override("font_size", 12)
	chapter.add_theme_color_override("font_color", Color("c7a66b"))
	content.add_child(chapter)

	var title := Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 28)
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
	body.add_theme_font_size_override("font_size", 16)
	body.add_theme_color_override("font_color", Color("d9d0bf"))
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(body)

	var hint := Label.new()
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("a99a80"))
	content.add_child(hint)

	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color("3b3025")
	button_style.border_color = Color("b18b55")
	button_style.set_border_width_all(2)
	button_style.set_corner_radius_all(8)
	button_style.content_margin_left = 24
	button_style.content_margin_right = 24
	button_style.content_margin_top = 12
	button_style.content_margin_bottom = 12

	var next_button := Button.new()
	next_button.custom_minimum_size = Vector2(220, 48)
	next_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	next_button.text = "CONTINUAR"
	next_button.add_theme_font_size_override("font_size", 17)
	next_button.add_theme_stylebox_override("normal", button_style)
	content.add_child(next_button)

	var skip_button := Button.new()
	skip_button.custom_minimum_size = Vector2(190, 46)
	skip_button.anchor_left = 1.0
	skip_button.anchor_right = 1.0
	skip_button.anchor_top = 0.0
	skip_button.anchor_bottom = 0.0
	skip_button.offset_left = -206.0
	skip_button.offset_right = -16.0
	skip_button.offset_top = 16.0
	skip_button.offset_bottom = 62.0
	skip_button.z_index = 10
	skip_button.text = "PULAR INTRODUÇÃO"
	skip_button.add_theme_font_size_override("font_size", 13)
	var skip_style := StyleBoxFlat.new()
	skip_style.bg_color = Color(0.08, 0.11, 0.14, 0.72)
	skip_style.border_color = Color(0.48, 0.55, 0.55, 0.65)
	skip_style.set_border_width_all(1)
	skip_style.set_corner_radius_all(6)
	skip_button.add_theme_stylebox_override("normal", skip_style)
	root.add_child(skip_button)

	var pages := [
		{"chapter":"PRÓLOGO  •  UMA HISTÓRIA ANTIGA","title":"Era uma vez…","body":"Era uma vez um mundo costurado por rios brilhantes, florestas antigas e pequenas luzes que dançavam no céu. No coração desse lugar pulsava o Coração Rubro, uma joia mágica que mantinha o equilíbrio entre todas as coisas. Dizem que, enquanto sua luz brilhasse, até a noite teria sonhos tranquilos.","hint":"Mas toda história guarda um dia que muda tudo…"},
		{"chapter":"PRÓLOGO  •  A NOITE SEM ESTRELAS","title":"Quando a luz se calou","body":"Numa noite em que nenhuma estrela apareceu, uma sombra levou o Coração Rubro do templo. Uma névoa cinzenta despertou e começou a cobrir caminhos, rios e lembranças. Alguns moradores esqueceram canções antigas; outros já não reconheciam o próprio lar. E o mundo, pouco a pouco, deixou de contar suas histórias.","hint":"Foi então que dois pequenos destinos se encontraram."},
		{"chapter":"PRÓLOGO  •  DOIS AMIGOS","title":"Tobi e Breu","body":"Muito antes daquela noite, Tobi encontrou Breu ainda pequeno, perdido perto da floresta. Ninguém sabia de onde ele tinha vindo, mas Tobi percebeu que aquele companheiro precisava de um amigo. Desde então, os dois dividiram trilhas, sustos, risadas e promessas. Agora, Breu sente a névoa antes de todos — e Tobi não vai deixá-lo enfrentar esse medo sozinho.","hint":"Porque até a maior aventura começa com uma amizade."},
		{"chapter":"CAPÍTULO I  •  O CHAMADO","title":"O conselho de Azulan","body":"Ao ver a névoa se aproximar de sua casa, Tobi procurou o velho Mestre Azulan. O sábio observou uma marca rubra deixada pela sombra e ficou em silêncio por um longo instante. Então revelou que a pista apontava para terras esquecidas, onde um Guardião vigiava um segredo antigo. Tobi apertou a mão do amigo. A jornada pelo Coração Rubro estava prestes a começar.","hint":"Abra o caminho, ajude quem encontrar e descubra o primeiro segredo."}
	]

	var page_index := 0
	var finished := false
	var advance_requested := false
	next_button.pressed.connect(func() -> void:
		advance_requested = true
	)
	skip_button.pressed.connect(func() -> void:
		finished = true
	)
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
		next_button.text = "COMEÇAR A AVENTURA" if page_index == pages.size() - 1 else "CONTINUAR"
		advance_requested = false
		while not advance_requested and not finished:
			await world.get_tree().process_frame
		if finished:
			break
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
