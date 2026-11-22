extends RefCounted
# Estilo visual compartilhado do HUD: paleta dark fantasy (ouro envelhecido sobre
# pedra escura), painéis translúcidos, barras com moldura e botões redondos de
# toque. Tudo é feito com StyleBoxFlat para manter o pacote leve no Android.

const GOLD := Color("c9a96a")
const GOLD_BRIGHT := Color("f1d5a5")
const CREAM := Color("f1e6cc")
const STONE := Color(0.045, 0.06, 0.07, 0.84)
const STONE_SOLID := Color(0.06, 0.075, 0.085, 0.96)
const HEALTH := Color("c0392b")
const HEALTH_BACK := Color(0.16, 0.04, 0.04, 0.92)
const STAMINA := Color("8fbf6a")
const XP := Color("8b6fd6")
const BOSS := Color("8e1f2a")
const TEAL := Color("9acfc2")

static func panel_box(alpha := 0.84, radius := 10, border := 1) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(STONE.r, STONE.g, STONE.b, alpha)
	sb.border_color = Color(GOLD.r, GOLD.g, GOLD.b, 0.75)
	sb.set_border_width_all(border)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 4
	return sb

static func bar_back(radius := 6) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = HEALTH_BACK
	sb.border_color = Color(0.0, 0.0, 0.0, 0.85)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(radius)
	return sb

static func bar_fill(color: Color, radius := 6) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = color.lightened(0.35)
	sb.border_width_top = 1
	sb.set_corner_radius_all(radius)
	return sb

static func style_bar(bar: ProgressBar, color: Color, height: float, width: float, radius := 6) -> void:
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(width, height)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var back := bar_back(radius)
	back.bg_color = Color(color.r * 0.18, color.g * 0.18, color.b * 0.18, 0.92)
	bar.add_theme_stylebox_override("background", back)
	bar.add_theme_stylebox_override("fill", bar_fill(color, radius))

static func round_button_box(fill: Color, border: Color, radius := 999) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = fill
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(radius)
	# Botões circulares ficam sem sombra: a sombra de cantos totalmente arredondados
	# deixava uma costura vertical visível no meio do botão.
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 0 if radius >= 30 else 4
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	return sb

# Aplica o visual de botão de ação. `accent` diferencia ataque, defesa e utilidade.
static func style_button(b: Button, accent: Color, radius := 999, font_size := 15) -> void:
	b.add_theme_stylebox_override("normal", round_button_box(Color(0.07, 0.085, 0.095, 0.78), accent, radius))
	b.add_theme_stylebox_override("hover", round_button_box(Color(0.10, 0.12, 0.13, 0.85), accent.lightened(0.2), radius))
	b.add_theme_stylebox_override("pressed", round_button_box(Color(accent.r * 0.55, accent.g * 0.55, accent.b * 0.55, 0.95), GOLD_BRIGHT, radius))
	b.add_theme_stylebox_override("disabled", round_button_box(Color(0.05, 0.06, 0.065, 0.55), Color(0.4, 0.4, 0.4, 0.5), radius))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color(0.6, 0.6, 0.6, 0.8))
	b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	b.add_theme_constant_override("outline_size", 3)
	b.focus_mode = Control.FOCUS_NONE

# Texto legível sobre o cenário 3D: contorno escuro em volta das letras.
static func style_label(l: Label, size: int, color := CREAM) -> void:
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.92))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE

static func place_corner(c: Control, anchor: Vector2, center_offset: Vector2, size: Vector2) -> void:
	# Posiciona o controle pelo CENTRO, a partir de um canto ancorado (0/1, 0/1).
	c.anchor_left = anchor.x
	c.anchor_right = anchor.x
	c.anchor_top = anchor.y
	c.anchor_bottom = anchor.y
	c.offset_left = center_offset.x - size.x * 0.5
	c.offset_right = center_offset.x + size.x * 0.5
	c.offset_top = center_offset.y - size.y * 0.5
	c.offset_bottom = center_offset.y + size.y * 0.5
