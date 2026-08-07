/// obj_board - Draw GUI Event
/// SO RENDER. Tooltip de DEPURACAO que segue o mouse: quando o cursor esta sobre um
/// quadrante, mostra label + esforco/resistencia/visibilidade daquela casa. Serve
/// para conferir a re-randomizacao da Mare (scr_mare_randomize) a cada virada.
///
/// Le o estado da fonte de verdade (hovered_column/row, atualizados no Step) e a
/// instancia da casa na matriz quadrantes[][]. Desenhado em coordenadas de GUI
/// (resolucao base), a mesma referencia do mouse convertido - por isso acompanha o
/// cursor com precisao independentemente da escala inteira da janela (obj_display).

// Sem casa sob o cursor: nada a mostrar.
if (hovered_column < 0 || hovered_row < 0) exit;

var _q = quadrantes[hovered_row][hovered_column];
if (_q == noone) exit;

// Linhas do tooltip. Labels em ASCII de proposito: a fonte padrao do GameMaker so
// cobre 32-127, entao evitamos acentos (troca por fonte de pixel art no futuro).
var _lines = [
    _q.label,
    "Esforco: "      + string(_q.esforco),
    "Resistencia: "  + string(_q.resistencia),
    "Visibilidade: " + string(_q.visibilidade),
];

// Mouse em coordenadas de GUI (mesma referencia em que o tooltip e desenhado).
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// --- Dimensiona a caixa pelo conteudo (fonte de verdade: o texto) ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _pad       = 4;   // respiro interno
var _line_h    = string_height("Ag") * UI_TEXT_SCALE;   // altura de linha ja escalada
var _text_w    = 0;
for (var _i = 0; _i < array_length(_lines); _i++) {
    _text_w = max(_text_w, string_width(_lines[_i]) * UI_TEXT_SCALE);
}
var _box_w = _text_w + _pad * 2;
var _box_h = _line_h * array_length(_lines) + _pad * 2;

// --- Posiciona junto ao cursor, sem sair da tela ---
// Offset diagonal para nao ficar embaixo do ponteiro; se estourar a borda direita/
// inferior da GUI, joga para o outro lado do cursor. Clamp final garante que nunca
// vaze, mesmo em quadrantes de canto.
var _gui_w  = display_get_gui_width();
var _gui_h  = display_get_gui_height();
var _offset = 12;

var _box_x = _mx + _offset;
var _box_y = _my + _offset;
if (_box_x + _box_w > _gui_w) _box_x = _mx - _offset - _box_w;
if (_box_y + _box_h > _gui_h) _box_y = _my - _offset - _box_h;
_box_x = clamp(_box_x, 0, _gui_w - _box_w);
_box_y = clamp(_box_y, 0, _gui_h - _box_h);

// --- Fundo + borda ---
draw_set_alpha(0.9);
draw_set_color(make_colour_rgb(28, 30, 42));
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);

// --- Texto (titulo em destaque, propriedades em branco) ---
for (var _i = 0; _i < array_length(_lines); _i++) {
    draw_set_color(_i == 0 ? c_yellow : c_white);
    draw_text_transformed(_box_x + _pad, _box_y + _pad + _line_h * _i, _lines[_i], UI_TEXT_SCALE, UI_TEXT_SCALE, 0);
}

// Restaura os padroes de desenho para nao vazar estado para outros objetos.
draw_set_color(c_white);
