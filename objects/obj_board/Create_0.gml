/// obj_board - Create Event
/// Cole este conteudo no evento Create de um objeto chamado "obj_board".
/// Requer os scripts scr_board_config e scr_grid_to_iso no projeto.

// Origem do tabuleiro na tela: vertice superior do quadrante A1.
// O tabuleiro e um "diorama" compacto CENTRALIZADO na zona de jogo (o retangulo
// central que sobra depois das faixas reservadas da HUD - ver game_play_zone em
// scr_display_config). Assim ele nunca invade o topo (Mare/personagem), o painel
// direito nem a base reservada, e se recentraliza sozinho se as faixas mudarem.
var _zone = game_play_zone();

// Horizontal: centro da zona de jogo. Como o grid e simetrico (4x4), o centro do
// tabuleiro cai exatamente no meio da zona.
board_origin_x = (_zone.x1 + _zone.x2) / 2;

// Vertical: centraliza o CONTEUDO (losangos + a altura do cubo do jogador, que
// sobe 1 tile acima do quadrante do fundo) dentro da zona. Alturas derivadas da
// config do grid (fonte de verdade), entao mudam sozinhas com o tile/o board.
var _cube_overhang = TILE_HEIGHT;
var _board_span    = ((BOARD_COLUMNS - 1) + (BOARD_ROWS - 1)) * (TILE_HEIGHT / 2) + TILE_HEIGHT;
var _content_h     = _cube_overhang + _board_span;
board_origin_y = _zone.y1 + ((_zone.y2 - _zone.y1) - _content_h) / 2 + _cube_overhang;

// Quadrante atualmente sob o cursor do mouse (-1 = nenhum / fora do tabuleiro).
// Recalculado a cada Draw e lido tambem pelo obj_player para saber quando ficar
// translucido.
hovered_column = -1;
hovered_row    = -1;

// Letras das colunas, secao 2: "colunas = letras, linhas = numeros" (estilo batalha naval)
column_letters = ["A", "B", "C", "D"];

// Matriz [row_index][column_index] com os dados de cada um dos 16 quadrantes
quadrantes = array_create(BOARD_ROWS);

for (var _row_index = 0; _row_index < BOARD_ROWS; _row_index++) {
    quadrantes[_row_index] = array_create(BOARD_COLUMNS);

    for (var _column_index = 0; _column_index < BOARD_COLUMNS; _column_index++) {
        var _iso_position = grid_to_iso(_column_index, _row_index, board_origin_x, board_origin_y);

        var _quadrante = {
            column_index: _column_index,
            row_index:    _row_index,
            label:        column_letters[_column_index] + string(_row_index + 1), // ex: "A1", "D4"
            iso_x:        _iso_position.x,
            iso_y:        _iso_position.y,

            // Propriedades do quadrante (secao 2 e 6). Ficam zeradas por enquanto -
            // a re-randomizacao via Mare (secao 6) e quem vai popular esses valores
            // dentro dos intervalos pre-estabelecidos. Isso entra numa proxima etapa.
            esforco:      0,
            resistencia:  0,
            visibilidade: 0
        };

        quadrantes[_row_index][_column_index] = _quadrante;
    }
}
