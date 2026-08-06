/// obj_player - Draw Event
/// Desenha o jogador como um cubo isometrico. A base (footer) usa exatamente os
/// 4 vertices do quadrante ocupado, ficando alinhada as linhas do tabuleiro; o
/// topo e a mesma base levantada em cube_height. Tres faces visiveis: topo,
/// lateral esquerda e lateral direita. O rotulo do quadrante vai na face de topo.

if (board == noone) exit;

// --- CRUZ: os 4 vizinhos (esquerda, direita, cima, baixo) ---
// cada par é [quanto muda na coluna, quanto muda na linha]
var _vizinhos = [[-1, 0], [1, 0], [0, -1], [0, 1]];

for (var _i = 0; _i < 4; _i++) {
    var _col = column_index + _vizinhos[_i][0];
    var _row = row_index    + _vizinhos[_i][1];

    if (_col >= 0 && _col < BOARD_COLUMNS && _row >= 0 && _row < BOARD_ROWS) {
        var _p = grid_to_iso(_col, _row, board.board_origin_x, board.board_origin_y);

        draw_primitive_begin(pr_trianglefan);
            draw_vertex_color(_p.x,                  _p.y,                   c_yellow, 0.3);
            draw_vertex_color(_p.x + TILE_WIDTH / 2, _p.y + TILE_HEIGHT / 2, c_yellow, 0.3);
            draw_vertex_color(_p.x,                  _p.y + TILE_HEIGHT,     c_yellow, 0.3);
            draw_vertex_color(_p.x - TILE_WIDTH / 2, _p.y + TILE_HEIGHT / 2, c_yellow, 0.3);
        draw_primitive_end();
    }
}


var _iso = grid_to_iso(column_index, row_index, board.board_origin_x, board.board_origin_y);
var _h   = cube_height;

// Transparencia do cubo: quando o mouse esta sobre um quadrante que o corpo
// levantado do cubo cobre na tela (os que ficam "atras"/acima dele), o cubo
// fica translucido para deixar ver qual quadrante esta sob o cursor.
// Como o cubo tem 1 tile de altura, ele encobre o quadrante diretamente atras
// (col-1, row-1) e, em parte, os dois diagonais de tras (col-1, row) e (col, row-1).
var _alpha = 1;
var _hc = board.hovered_column;
var _hr = board.hovered_row;
if (_hc >= 0
 && ((_hc == column_index - 1 && _hr == row_index - 1)
  || (_hc == column_index - 1 && _hr == row_index)
  || (_hc == column_index     && _hr == row_index - 1))) {
    _alpha = 0.4;
}
draw_set_alpha(_alpha); // afeta as linhas de contorno (draw_line_color nao tem parametro de alpha)

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
    draw_vertex_color(_bl_x, _bl_y, left_color, _alpha);
    draw_vertex_color(_bb_x, _bb_y, left_color, _alpha);
    draw_vertex_color(_tb_x, _tb_y, left_color, _alpha);
    draw_vertex_color(_tl_x, _tl_y, left_color, _alpha);
draw_primitive_end();

// Face lateral direita (base baixo -> base direita -> topo direita -> topo baixo).
draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_bb_x, _bb_y, right_color, _alpha);
    draw_vertex_color(_br_x, _br_y, right_color, _alpha);
    draw_vertex_color(_tr_x, _tr_y, right_color, _alpha);
    draw_vertex_color(_tb_x, _tb_y, right_color, _alpha);
draw_primitive_end();

// Face de topo (losango levantado).
draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_tt_x, _tt_y, top_color, _alpha);
    draw_vertex_color(_tr_x, _tr_y, top_color, _alpha);
    draw_vertex_color(_tb_x, _tb_y, top_color, _alpha);
    draw_vertex_color(_tl_x, _tl_y, top_color, _alpha);
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
draw_set_alpha(1); // restaura o alpha para nao afetar desenhos seguintes

// --- Janela de acao (Movimentar / Pescar) ---
// Aparece a direita do tabuleiro quando um quadrante amarelo e clicado.
if (menu_open) {
    // Fundo e borda da janela.
    draw_set_color(make_colour_rgb(28, 30, 42));
    draw_rectangle(menu_x, menu_y, menu_x + menu_w, menu_y + menu_h, false);
    draw_set_color(c_white);
    draw_rectangle(menu_x, menu_y, menu_x + menu_w, menu_y + menu_h, true);

    // Titulo: qual quadrante foi clicado (ex: "Quadrante B2").
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    var _target_label = board.quadrantes[menu_target_row][menu_target_col].label;
    draw_text(menu_x + menu_w / 2, menu_y + menu_pad + menu_title_h / 2, _target_label);

    // Dois botoes: 0 = Movimentar, 1 = Pescar. Realca o que esta sob o mouse.
    var _labels = ["Movimentar", "Pescar"];
    for (var _b = 0; _b < 2; _b++) {
        var _r   = menu_button_rect(_b);
        var _hot = point_in_rectangle(mouse_x, mouse_y, _r.x1, _r.y1, _r.x2, _r.y2);

        draw_set_color(_hot ? c_lime : make_colour_rgb(70, 72, 92));
        draw_rectangle(_r.x1, _r.y1, _r.x2, _r.y2, false);
        draw_set_color(c_white);
        draw_rectangle(_r.x1, _r.y1, _r.x2, _r.y2, true);

        draw_set_color(_hot ? c_black : c_white);
        draw_text((_r.x1 + _r.x2) / 2, (_r.y1 + _r.y2) / 2, _labels[_b]);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
