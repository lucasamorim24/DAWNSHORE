#macro BOARD_COLUMNS 4   // colunas A-D
#macro BOARD_ROWS    4   // linhas 1-4

// --- Medidas da FACE DE TOPO do losango (a superficie andavel do quadrante) ---
// Casam 1:1 com o tileset isometrico baixado (D:\GAME DEV\isometric tileset): cada
// tile e um canvas 32x32 cuja face de topo e um losango 2:1 de 32x16, com ~8px de
// "saia"/bloco por baixo (look de diorama). Sao a FONTE DE VERDADE das medidas:
// grid_to_iso, hover, cubo do jogador e cruz derivam daqui. Manter em pixels
// NATIVOS (sem escalar) preserva o pixel-perfect - o jogo inteiro sobe por escala
// inteira via obj_display, nao os sprites individualmente.
#macro TILE_WIDTH    32  // largura da face de topo (losango), em pixels de jogo
#macro TILE_HEIGHT   16  // altura da face de topo (losango), proporcao 2:1 padrao iso

// --- Geometria da arte (para importar os sprites e para elevacao futura) ---
// Cada tile do tileset e 32x32; abaixo da face de topo ha uma "saia"/bloco de ~8px.
// Ao importar cada tile como sprite no GameMaker, use a ORIGEM (16, 8) = vertice de
// topo do losango, para o sprite cair alinhado ao ponto que grid_to_iso devolve.
// TILE_BLOCK_HEIGHT fica reservado para empilhamento/elevacao e ajuste de ordem.
#macro TILE_SPRITE_SIZE  32  // canvas quadrado de cada tile do tileset (px)
#macro TILE_BLOCK_HEIGHT 8   // espessura visivel do bloco sob a face de topo (px)
