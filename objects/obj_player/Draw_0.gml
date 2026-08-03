/// obj_player - Draw Event
/// Desenha o jogador como um cubo isometrico. A base (footer) usa exatamente os
/// 4 vertices do quadrante ocupado, ficando alinhada as linhas do tabuleiro; o
/// topo e a mesma base levantada em cube_height. Tres faces visiveis: topo,
/// lateral esquerda e lateral direita. O rotulo do quadrante vai na face de topo.

if (board == noone) exit;

var _iso = grid_to_iso(column_index, row_index, board.board_origin_x, board.board_origin_y);
var _h   = cube_height;

// Base do cubo (footer) = losango do tile: topo, direita, baixo, esquerda.
var _bt_x = _iso.x;                    var _bt_y = _iso.y;
var _br_x = _iso.x + TILE_WIDTH / 2;   var _br_y = _iso.y + TILE_HEIGHT / 2;
var _bb_x = _iso.x;                    var _bb_y = _iso.y + TILE_HEIGHT;
var _bl_x = _iso.x - TILE_WIDTH / 2;   var _bl_y = _iso.y + TILE_HEIGHT / 2;

// Topo do cubo = base levantada em _h (mesmo losango, deslocado para cima).
var _tt_x = _bt_x; var _tt_y = _bt_y - _h;
var _tr_x = _br_x; var _tr_y = _br_y - _h;
var _tb_x = _bb_x; var _tb_y = _bb_y - _h;
var _tl_x = _bl_x; var _tl_y = _bl_y - _h;

// Face lateral esquerda (base esquerda -> base baixo -> topo baixo -> topo esquerda).
draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_bl_x, _bl_y, left_color, 1);
    draw_vertex_color(_bb_x, _bb_y, left_color, 1);
    draw_vertex_color(_tb_x, _tb_y, left_color, 1);
    draw_vertex_color(_tl_x, _tl_y, left_color, 1);
draw_primitive_end();

// Face lateral direita (base baixo -> base direita -> topo direita -> topo baixo).
draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_bb_x, _bb_y, right_color, 1);
    draw_vertex_color(_br_x, _br_y, right_color, 1);
    draw_vertex_color(_tr_x, _tr_y, right_color, 1);
    draw_vertex_color(_tb_x, _tb_y, right_color, 1);
draw_primitive_end();

// Face de topo (losango levantado).
draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_tt_x, _tt_y, top_color, 1);
    draw_vertex_color(_tr_x, _tr_y, top_color, 1);
    draw_vertex_color(_tb_x, _tb_y, top_color, 1);
    draw_vertex_color(_tl_x, _tl_y, top_color, 1);
draw_primitive_end();

// Contorno: arestas do topo, arestas verticais visiveis e base frontal.
draw_line_color(_tt_x, _tt_y, _tr_x, _tr_y, outline_color, outline_color);
draw_line_color(_tr_x, _tr_y, _tb_x, _tb_y, outline_color, outline_color);
draw_line_color(_tb_x, _tb_y, _tl_x, _tl_y, outline_color, outline_color);
draw_line_color(_tl_x, _tl_y, _tt_x, _tt_y, outline_color, outline_color);
draw_line_color(_tl_x, _tl_y, _bl_x, _bl_y, outline_color, outline_color); // vertical esquerda
draw_line_color(_tb_x, _tb_y, _bb_x, _bb_y, outline_color, outline_color); // vertical central
draw_line_color(_tr_x, _tr_y, _br_x, _br_y, outline_color, outline_color); // vertical direita
draw_line_color(_bl_x, _bl_y, _bb_x, _bb_y, outline_color, outline_color); // base frontal esquerda
draw_line_color(_bb_x, _bb_y, _br_x, _br_y, outline_color, outline_color); // base frontal direita

// Rotulo do quadrante ocupado, centrado na face de topo.
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(_iso.x, _iso.y + TILE_HEIGHT / 2 - _h, label);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
