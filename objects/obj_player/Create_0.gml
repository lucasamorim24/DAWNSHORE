/// obj_player - Create Event
/// Peca do jogador: um cubo isometrico que ocupa exatamente 1 quadrante do
/// tabuleiro por vez, com a base (footer) alinhada ao losango do tile e o rotulo
/// do quadrante marcado na face de topo. Depende de obj_board (origem/config do
/// grid) e dos scripts scr_board_config e scr_grid_to_iso.

// Referencia ao tabuleiro (existe uma unica instancia de obj_board na sala).
board = instance_exists(obj_board) ? obj_board : noone;

// Quadrante ocupado no grid. Comeca ocupando A1 (canto de origem).
column_index = 0;
row_index    = 0;
label        = ""; // rotulo do quadrante ocupado (ex: "A1"), guardado do board

// Altura do cubo, em pixels (aresta vertical das faces laterais).
cube_height = TILE_HEIGHT;

// Cores das tres faces visiveis do cubo (topo mais claro, laterais sombreadas)
// e do contorno.
top_color     = make_colour_rgb(80, 165, 245);
right_color   = make_colour_rgb(55, 125, 200);
left_color    = make_colour_rgb(38,  95, 160);
outline_color = make_colour_rgb(20,  55, 100);

// Depth negativo garante que o jogador seja desenhado por cima dos losangos
// do tabuleiro (depth menor = desenhado na frente).
depth = -100;

/// Move o jogador para o quadrante (_col, _row) e guarda a posicao. O x/y da
/// instancia fica no centro do losango do quadrante ocupado.
place_on_tile = function(_col, _row) {
    column_index = _col;
    row_index    = _row;
    label        = board.quadrantes[_row][_col].label; // reaproveita o rotulo do board

    var _iso = grid_to_iso(_col, _row, board.board_origin_x, board.board_origin_y);
    x = _iso.x;
    y = _iso.y + TILE_HEIGHT / 2; // centro do losango (topo + meia altura)
};

/// Verdadeiro se (_col,_row) e um dos 4 quadrantes vizinhos em cruz (os amarelos),
/// dentro dos limites do tabuleiro. Distancia de Manhattan == 1 = so os adjacentes.
is_yellow_neighbor = function(_col, _row) {
    return (abs(_col - column_index) + abs(_row - row_index)) == 1
        && _col >= 0 && _col < BOARD_COLUMNS
        && _row >= 0 && _row < BOARD_ROWS;
};

// --- Janela de acao (Movimentar / Pescar) ---
// Abre quando o jogador clica num quadrante amarelo; some ao escolher uma opcao
// ou clicar fora dela.
menu_open       = false;
menu_target_col = -1; // quadrante amarelo escolhido, alvo da acao
menu_target_row = -1;

// Geometria da janela (constantes de layout; posicao x/y definida abaixo, ja que
// depende da origem do tabuleiro).
menu_w       = 170;
menu_pad     = 12;
menu_title_h = 26;
menu_btn_h   = 40;
menu_btn_gap = 10;
menu_h = menu_pad + menu_title_h + menu_btn_h + menu_btn_gap + menu_btn_h + menu_pad;
menu_x = 0;
menu_y = 0;

/// Retangulo de um dos dois botoes da janela. 0 = Movimentar, 1 = Pescar.
/// @returns {struct} { x1, y1, x2, y2 }
menu_button_rect = function(_index) {
    var _x1 = menu_x + menu_pad;
    var _x2 = menu_x + menu_w - menu_pad;
    var _y1 = menu_y + menu_pad + menu_title_h + _index * (menu_btn_h + menu_btn_gap);
    var _y2 = _y1 + menu_btn_h;
    return { x1: _x1, y1: _y1, x2: _x2, y2: _y2 };
};

// Posiciona no quadrante inicial e ancora a janela a direita do tabuleiro (para
// fora dele: borda direita do board + margem).
if (board != noone) {
    place_on_tile(column_index, row_index);

    menu_x = board.board_origin_x + BOARD_COLUMNS * (TILE_WIDTH / 2) + 40;
    menu_y = board.board_origin_y + 40;
}
