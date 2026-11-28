# Aldeia das Cinzas — expansão do mundo

- Região nova: centro aproximado (275, 175), ligada à Cidade de Pedra por uma estrada.
- Conteúdo: quatro casas abandonadas, capela com entrada aberta, cripta com escadaria, cemitério com 12 lápides, cinco árvores mortas, poço, carroça quebrada, iluminação e ruínas de limite.
- Implementação: geometria procedural leve em Godot 4.3; colisões apenas nas paredes das casas e nas paredes laterais da capela.
- Integração aditiva: não altera mapas, quests, HUD, jogador, NPCs ou sistemas de save existentes.
- Limitação: cenário visual; não cria ainda NPCs, loot, chefe ou missão próprios. Os ZIPs PBR/OBJ enviados foram inspecionados, mas não foram transferidos para o repositório nesta etapa.


## Conteúdo jogável adicional

- Três relíquias colecionáveis: Lágrima Verde, Cinza Violeta e Brasa Antiga.
- O jogador recebe 35 XP e 1 Essência Sombria por relíquia.
- Ao coletar as três, o altar da cripta desperta; interagir com ele concede 150 XP, 5 Fragmentos Rubros, 4 Essências Sombrias e 2 Poções.
- A missão usa o botão de interação existente e salva os três IDs coletados e o estado da recompensa na versão 16 do save.
- Dois modelos GLB já versionados no projeto são usados como decoração: um aldeão na praça e um cavaleiro na capela.
- A aparência do altar é restaurada corretamente quando o jogador carrega um save com as três relíquias coletadas.

## Limite de importação de arquivos enviados

Os ZIPs adicionais enviados no chat foram inspecionados, mas seus binários ainda não estão dentro do repositório. Esta atualização reaproveita os GLBs que já estavam versionados e não declara os novos pacotes OBJ/PBR como importados.
