# Aqueduct PBR — pedra do Santuário

Projeto: `0931f547-7cd7-40af-a785-d6ddf642c7ce`

O pacote de exportação foi concluído (job `exp_edaba8b3-ae4e-4011-b627-910bd03d17e3`) com cinco mapas de 1024×1024 e normal OpenGL:

- `base_color.png`
- `normal.png`
- `roughness.png`
- `ao.png`
- `height.png`

O shader `res://scripts/aqueduct_stone.gdshader` aplica base color, normal, roughness e AO. O mapa height é preservado para futura utilização, mas fica fora do shader móvel atual para evitar deslocamento caro/incompatível com GL Compatibility. Os PNGs ainda não foram copiados para o repositório nesta sessão.
