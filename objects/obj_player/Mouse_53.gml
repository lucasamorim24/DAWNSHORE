/// obj_player - Global Left Pressed
/// A cada clique com o botao esquerdo, descobre sob qual quadrante o mouse esta
/// e move o jogador para la, guardando a nova posicao no grid.

if (board == noone) exit;

// --- Janela de acao aberta: o clique interage com ela ---
if (menu_open) {
    var _mv = menu_button_rect(0); // Movimentar
    var _pe = menu_button_rect(1); // Pescar

    if (point_in_rectangle(mouse_x, mouse_y, _mv.x1, _mv.y1, _mv.x2, _mv.y2)) {
        // Movimentar: vai para o quadrante alvo e fecha a janela.
        place_on_tile(menu_target_col, menu_target_row);
    } else if (point_in_rectangle(mouse_x, mouse_y, _pe.x1, _pe.y1, _pe.x2, _pe.y2)) {
        // Pescar: acao a implementar numa proxima etapa; por ora so fecha a janela.
    }
    // Qualquer clique (nos botoes ou fora) fecha a janela.
    menu_open = false;
    exit;
}

// --- Janela fechada: descobre o quadrante clicado ---
var _grid = iso_to_grid(mouse_x, mouse_y, board.board_origin_x, board.board_origin_y);
var _col  = _grid.column_index;
var _row  = _grid.row_index;

// Fora dos limites do tabuleiro 4x4: ignora.
if (_col < 0 || _col >= BOARD_COLUMNS || _row < 0 || _row >= BOARD_ROWS) exit;

if (is_yellow_neighbor(_col, _row)) {
    // Quadrante amarelo: abre a janela perguntando Movimentar ou Pescar.
    menu_open       = true;
    menu_target_col = _col;
    menu_target_row = _row;
} else {
    // Qualquer outro quadrante: movimenta direto.
    place_on_tile(_col, _row);
}
