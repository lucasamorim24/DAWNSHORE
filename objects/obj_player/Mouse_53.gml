/// obj_player - Global Left Pressed
/// A cada clique com o botao esquerdo, descobre sob qual quadrante o mouse esta
/// e move o jogador para la, guardando a nova posicao no grid.

if (board == noone) exit;

var _grid = iso_to_grid(mouse_x, mouse_y, board.board_origin_x, board.board_origin_y);

// So ocupa se o clique caiu dentro dos limites do tabuleiro 4x4.
if (_grid.column_index >= 0 && _grid.column_index < BOARD_COLUMNS
 && _grid.row_index    >= 0 && _grid.row_index    < BOARD_ROWS) {
    place_on_tile(_grid.column_index, _grid.row_index);
}
