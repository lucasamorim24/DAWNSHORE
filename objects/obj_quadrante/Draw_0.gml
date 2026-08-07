/// obj_quadrante - Draw Event
/// Cada casa desenha a si mesma. Se tiver sprite atribuido (tileset isometrico
/// 32x32), desenha o TILE; senao, cai no losango-primitiva (placeholder). O hover
/// verde vai por cima em ambos os casos. Os rotulos A1..D4 so aparecem com
/// DEBUG_LAYOUT ligado, para nao poluir o tabuleiro depois que a arte entra.

if (sprite_index != -1) {
    // --- Render por sprite (tile isometrico) ---
    // Ancora: onde o vertice de topo do losango cai dentro do canvas 32x32 do tile.
    // Centro-x do canvas (16) e meia-altura do losango acima do centro-y (16-8=8).
    // Desenhamos por draw_sprite com este offset, entao o encaixe independe da
    // origem configurada no proprio sprite - qualquer tile 32x32 do set alinha.
    var _anchor_x = TILE_SPRITE_SIZE / 2;                   // 16
    var _anchor_y = TILE_SPRITE_SIZE / 2 - TILE_HEIGHT / 2; // 8
    draw_sprite(sprite_index, image_index, x - _anchor_x, y - _anchor_y);

    // Hover: losango verde translucido sobre a face de topo.
    if (hovered) {
        draw_primitive_begin(pr_trianglefan);
            draw_vertex_color(x,                  y,                   c_lime, 0.4);
            draw_vertex_color(x + TILE_WIDTH / 2, y + TILE_HEIGHT / 2, c_lime, 0.4);
            draw_vertex_color(x,                  y + TILE_HEIGHT,     c_lime, 0.4);
            draw_vertex_color(x - TILE_WIDTH / 2, y + TILE_HEIGHT / 2, c_lime, 0.4);
        draw_primitive_end();
    }
} else {
    // --- Placeholder por primitiva (sem sprite) ---
    var _top_x    = x;                    var _top_y    = y;
    var _right_x  = x + TILE_WIDTH / 2;   var _right_y  = y + TILE_HEIGHT / 2;
    var _bottom_x = x;                    var _bottom_y = y + TILE_HEIGHT;
    var _left_x   = x - TILE_WIDTH / 2;   var _left_y   = y + TILE_HEIGHT / 2;

    var _tile_color = ((column_index + row_index) % 2 == 0) ? c_ltgray : c_gray;
    if (hovered) {
        _tile_color = c_lime;
    }

    draw_primitive_begin(pr_trianglefan);
        draw_vertex_color(_top_x,    _top_y,    _tile_color, 1);
        draw_vertex_color(_right_x,  _right_y,  _tile_color, 1);
        draw_vertex_color(_bottom_x, _bottom_y, _tile_color, 1);
        draw_vertex_color(_left_x,   _left_y,   _tile_color, 1);
    draw_primitive_end();

    draw_line_color(_top_x,    _top_y,    _right_x,  _right_y,  c_black, c_black);
    draw_line_color(_right_x,  _right_y,  _bottom_x, _bottom_y, c_black, c_black);
    draw_line_color(_bottom_x, _bottom_y, _left_x,   _left_y,   c_black, c_black);
    draw_line_color(_left_x,   _left_y,   _top_x,    _top_y,    c_black, c_black);
}

// Rotulo do quadrante (ex: "A1"). No modo losango (sem sprite) sempre aparece -
// e a leitura da grade. Com sprite, so em DEBUG_LAYOUT (pra nao poluir a arte).
if (sprite_index == -1 || DEBUG_LAYOUT) {
    // Tamanho unico da tipografia da interface (scr_display_config). Toda a UI usa
    // este mesmo fator, entao a leitura da grade e o resto do texto batem.
    var _label_scale = UI_TEXT_SCALE;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_text_transformed(x, y + TILE_HEIGHT / 2, label, _label_scale, _label_scale, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
