/// obj_player - Draw Event
/// Desenha o jogador como um losango isometrico preenchido, usando exatamente os
/// mesmos 4 vertices do quadrante ocupado. Assim o footer da peca fica
/// perfeitamente alinhado com as linhas do tabuleiro.

if (board == noone) exit;

var _iso = grid_to_iso(column_index, row_index, board.board_origin_x, board.board_origin_y);

// Vertice de topo do losango do quadrante ocupado.
var _top_x    = _iso.x;
var _top_y    = _iso.y;
var _right_x  = _top_x + TILE_WIDTH / 2;
var _right_y  = _top_y + TILE_HEIGHT / 2;
var _bottom_x = _top_x;
var _bottom_y = _top_y + TILE_HEIGHT;
var _left_x   = _top_x - TILE_WIDTH / 2;
var _left_y   = _top_y + TILE_HEIGHT / 2;

// Preenchimento.
draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_top_x,    _top_y,    fill_color, 1);
    draw_vertex_color(_right_x,  _right_y,  fill_color, 1);
    draw_vertex_color(_bottom_x, _bottom_y, fill_color, 1);
    draw_vertex_color(_left_x,   _left_y,   fill_color, 1);
draw_primitive_end();

// Contorno, reforcando o alinhamento com as linhas do grid.
draw_line_color(_top_x,    _top_y,    _right_x,  _right_y,  outline_color, outline_color);
draw_line_color(_right_x,  _right_y,  _bottom_x, _bottom_y, outline_color, outline_color);
draw_line_color(_bottom_x, _bottom_y, _left_x,   _left_y,   outline_color, outline_color);
draw_line_color(_left_x,   _left_y,   _top_x,    _top_y,    outline_color, outline_color);
