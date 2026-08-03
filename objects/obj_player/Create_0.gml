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

// Posiciona no quadrante inicial.
if (board != noone) {
    place_on_tile(column_index, row_index);
}
