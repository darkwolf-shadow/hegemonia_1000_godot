extends Node


func create_ground_texture(width: int, height: int, base: Color, seed_val: int = 0) -> ImageTexture:
	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(base)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	for y in range(height):
		for x in range(width):
			var n := rng.randf_range(-0.10, 0.10)
			var c := img.get_pixel(x, y)
			c.r = clampf(c.r + n, 0.0, 1.0)
			c.g = clampf(c.g + n, 0.0, 1.0)
			c.b = clampf(c.b + n * 0.7, 0.0, 1.0)
			c.a = 1.0
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


func create_parchment_texture(width: int, height: int, color1: Color = Color(0.88, 0.80, 0.65), color2: Color = Color(0.72, 0.62, 0.48)) -> GradientTexture2D:
	var grad := Gradient.new()
	grad.add_point(0.0, color1)
	grad.add_point(0.5, Color((color1.r + color2.r) * 0.5, (color1.g + color2.g) * 0.5, (color1.b + color2.b) * 0.5))
	grad.add_point(1.0, color2)
	var tex := GradientTexture2D.new()
	tex.width = width
	tex.height = height
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_LINEAR
	tex.fill_from = Vector2(0.0, 0.0)
	tex.fill_to = Vector2(0.0, 1.0)
	return tex


func parchment_stylebox(bg: Color = Color(0.82, 0.72, 0.58, 0.97)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.45, 0.35, 0.22, 0.95)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style


func button_stylebox(base: Color = Color(0.72, 0.60, 0.42)) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = base
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.35, 0.25, 0.15)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	return style


func style_button(btn: Button, base: Color = Color(0.72, 0.60, 0.42)):
	var normal := button_stylebox(base)
	var hover := button_stylebox(base.lightened(0.12))
	var pressed := button_stylebox(base.darkened(0.15))
	var disabled := button_stylebox(base.darkened(0.30))
	disabled.bg_color.a = 0.65
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", Color(0.15, 0.10, 0.06))
	btn.add_theme_color_override("font_hover_color", Color(0.10, 0.07, 0.04))
	btn.add_theme_color_override("font_pressed_color", Color(0.20, 0.14, 0.08))
	btn.add_theme_color_override("font_disabled_color", Color(0.35, 0.30, 0.25))


func apply_parchment_theme(node: Control, font_color: Color = Color(0.18, 0.12, 0.06)):
	if node is Label:
		node.add_theme_color_override("font_color", font_color)
		node.add_theme_color_override("font_shadow_color", Color(1.0, 1.0, 0.9, 0.35))
		node.add_theme_constant_override("shadow_offset_x", 1)
		node.add_theme_constant_override("shadow_offset_y", 1)
	elif node is ItemList:
		node.add_theme_stylebox_override("panel", parchment_stylebox(Color(0.78, 0.68, 0.54, 0.92)))
		node.add_theme_color_override("font_color", font_color)
		node.add_theme_color_override("font_selected_color", Color(0.95, 0.90, 0.80))
		node.add_theme_stylebox_override("selected", button_stylebox(Color(0.55, 0.42, 0.28)))
		node.add_theme_stylebox_override("selected_focus", button_stylebox(Color(0.55, 0.42, 0.28)))
	elif node is OptionButton or node is SpinBox:
		node.add_theme_color_override("font_color", font_color)
		node.add_theme_stylebox_override("normal", parchment_stylebox(Color(0.78, 0.68, 0.54, 0.92)))
	elif node is Button:
		style_button(node)
	for child in node.get_children():
		if child is Control:
			apply_parchment_theme(child, font_color)
