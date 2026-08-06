/// obj_board - Draw Event
/// Cole este conteudo no evento Draw do objeto "obj_board".
/// Desenha o tabuleiro 4x4 (secao 2) em losangos isometricos, sem sprites -
/// so para validar a orientacao e a leitura visual da grade A1-D4.

// O quadrante sob o mouse (hovered_column/row) e calculado no evento Step; aqui
// so lemos para pintar o destaque.
for (var _row_index = 0; _row_index < BOARD_ROWS; _row_index++) {
    for (var _column_index = 0; _column_index < BOARD_COLUMNS; _column_index++) {
        var _quadrante = quadrantes[_row_index][_column_index];

        var _center_x = _quadrante.iso_x; // vertice de topo do losango
        var _center_y = _quadrante.iso_y;

        // Os 4 vertices do losango: topo, direita, baixo, esquerda
        var _top_x    = _center_x;
        var _top_y    = _center_y;
        var _right_x  = _center_x + TILE_WIDTH / 2;
        var _right_y  = _center_y + TILE_HEIGHT / 2;
        var _bottom_x = _center_x;
        var _bottom_y = _center_y + TILE_HEIGHT;
        var _left_x   = _center_x - TILE_WIDTH / 2;
        var _left_y   = _center_y + TILE_HEIGHT / 2;

        // Cor alternada tipo tabuleiro de xadrez, so para facilitar a leitura dos quadrantes
        var _tile_color = ((_column_index + _row_index) % 2 == 0) ? c_ltgray : c_gray;

        // Se este quadrante esta sob o mouse, pinta de verde para dar o feedback
        // de "flutuando aqui" (bem mais facil de distinguir que o cinza clareado).
        var _is_hovered = (_column_index == hovered_column && _row_index == hovered_row);
        if (_is_hovered) {
            _tile_color = c_lime;
        }

        draw_primitive_begin(pr_trianglefan);
            draw_vertex_color(_top_x,    _top_y,    _tile_color, 1);
            draw_vertex_color(_right_x,  _right_y,  _tile_color, 1);
            draw_vertex_color(_bottom_x, _bottom_y, _tile_color, 1);
            draw_vertex_color(_left_x,   _left_y,   _tile_color, 1);
        draw_primitive_end();

        // Contorno do quadrante
        draw_line_color(_top_x,    _top_y,    _right_x,  _right_y,  c_black, c_black);
        draw_line_color(_right_x,  _right_y,  _bottom_x, _bottom_y, c_black, c_black);
        draw_line_color(_bottom_x, _bottom_y, _left_x,   _left_y,   c_black, c_black);
        draw_line_color(_left_x,   _left_y,   _top_x,    _top_y,    c_black, c_black);

        // Rotulo do quadrante (ex: "A1", "D4") no centro do losango
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_black);
        draw_text(_center_x, _center_y + TILE_HEIGHT / 2, _quadrante.label);
    }
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
