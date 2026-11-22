extends CylinderMesh
# Godot não tem ConeMesh nativo: um cone é um cilindro com o topo de raio zero.
# Esta classe mantém a interface `radius`/`height` usada pelos modelos procedurais.

var radius: float = 0.5:
	set(value):
		radius = value
		bottom_radius = value
		top_radius = 0.0

func _init() -> void:
	top_radius = 0.0
	bottom_radius = radius
