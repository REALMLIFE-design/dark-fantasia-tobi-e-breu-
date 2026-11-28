# Pacotes enviados para o Dark World

Este registro acompanha os quatro pacotes enviados pelo usuário. A integração deve ser aditiva: não substituir mapas, personagens, missões, saves, HUD ou sistemas existentes.

| Pacote | Conteúdo confirmado | Tratamento |
|---|---|---|
| MedievalPackSTY.rar | Chest1.blend, previews e texturas PBR de madeira, pedra, metal, couro e tecido | Exportar o baú para GLB; otimizar texturas para mobile |
| Hohenzollern_Castle+(usdz).zip | Hohenzollern_Castle.usdz dentro do ZIP | Importar USDZ e exportar GLB; revisar escala e colisões |
| EU43_FORESTPACK.zip | 9 cenas .max, 116 entradas no total, texturas TIFF e materiais Mental Ray/V-Ray | Otimizar texturas; cenas .max exigem exportação no Autodesk 3ds Max para FBX/GLB |
| Gledista_Triacanthos_BLEND.zip | Gledista_Triacanthos.blend, cópia .blend1 e mapas de casca, folhas, flores e sementes | Exportar árvore para GLB, limitar geometria e texturas para Android |

## Pipeline de conversão

O workflow .github/workflows/import-submitted-assets.yml aceita links HTTPS diretos dos quatro arquivos, extrai os pacotes, usa Blender em modo headless para converter arquivos Blender/USDZ em GLB, otimiza mapas de textura e registra os resultados.

## Limites e segurança

- Nenhum arquivo binário é declarado integrado apenas por constar no inventário.
- O pipeline não tenta abrir arquivos Autodesk .max com Blender. As texturas do Forestpack podem ser preparadas, mas a geometria precisa ser exportada pelo 3ds Max.
- Os GLBs convertidos ainda precisam ser inspecionados no Godot 4.3 quanto a escala, orientação, materiais, colisões, desempenho e posicionamento no mundo.
- O workflow não remove nem substitui conteúdo existente.
- São necessários links HTTPS diretos e acessíveis pelo GitHub Actions. Links de visualização do Drive que exigem login não funcionam como URL de download direto.
