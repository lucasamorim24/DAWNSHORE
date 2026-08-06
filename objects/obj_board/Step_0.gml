/// obj_board - Step Event
/// Logica de leitura de estado do tabuleiro (nao desenha nada). Aqui fica o que
/// precisa ser recalculado por frame independentemente da renderizacao - hoje so
/// o quadrante sob o cursor, mas e o lugar natural para futuras regras de turno,
/// re-randomizacao das propriedades (Mare), etc.

// Descobre qual quadrante esta sob o mouse neste frame. Fica -1/-1 quando o
// cursor esta fora do tabuleiro 4x4. E lido pelo obj_board (Draw, para o
// destaque verde) e pelo obj_player (Draw, para a transparencia do cubo).
var _mouse_grid = iso_to_grid(mouse_x, mouse_y, board_origin_x, board_origin_y);
if (_mouse_grid.column_index >= 0 && _mouse_grid.column_index < BOARD_COLUMNS
 && _mouse_grid.row_index    >= 0 && _mouse_grid.row_index    < BOARD_ROWS) {
    hovered_column = _mouse_grid.column_index;
    hovered_row    = _mouse_grid.row_index;
} else {
    hovered_column = -1;
    hovered_row    = -1;
}
