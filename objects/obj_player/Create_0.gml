/// obj_player - Create Event
/// Peca do jogador: um losango isometrico que ocupa exatamente 1 quadrante do
/// tabuleiro por vez. Depende de obj_board (origem/config do grid) e dos scripts
/// scr_board_config e scr_grid_to_iso.

// Referencia ao tabuleiro (existe uma unica instancia de obj_board na sala).
board = instance_exists(obj_board) ? obj_board : noone;

// Quadrante ocupado no grid. Comeca ocupando A1 (canto de origem).
column_index = 0;
row_index    = 0;

// Cores do preenchimento e do contorno do losango do jogador.
fill_color    = make_colour_rgb(60, 140, 220);
outline_color = make_colour_rgb(20,  70, 130);

// Depth negativo garante que o jogador seja desenhado por cima dos losangos
// do tabuleiro (depth menor = desenhado na frente).
depth = -100;

/// Move o jogador para o quadrante (_col, _row) e guarda a posicao. O x/y da
/// instancia fica no centro do losango do quadrante ocupado.
place_on_tile = function(_col, _row) {
    column_index = _col;
    row_index    = _row;

    var _iso = grid_to_iso(_col, _row, board.board_origin_x, board.board_origin_y);
    x = _iso.x;
    y = _iso.y + TILE_HEIGHT / 2; // centro do losango (topo + meia altura)
};

// Posiciona no quadrante inicial.
if (board != noone) {
    place_on_tile(column_index, row_index);
}
