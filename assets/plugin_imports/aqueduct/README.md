# Aqueduct PBR — pedra do Santuário

Coloque aqui os mapas exportados do material Aqueduct:
- `base_color.png`
- `normal.png` (OpenGL)
- `roughness.png`
- `ao.png`

O shader `res://scripts/aqueduct_stone.gdshader` e o carregador `plugin_asset_loader.gd` aplicam o conjunto quando os quatro arquivos estão presentes. O mapa height foi mantido fora do shader móvel para evitar custo de deslocamento em Android.
