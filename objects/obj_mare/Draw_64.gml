/// obj_mare - Draw GUI Event
/// SO RENDER. Le o estado (mare_time_left) e pinta o marcador no topo-centro da
/// tela, em coordenadas de GUI (resolucao base). Barra compacta de UMA linha, com
/// o TOPO do bloco a mare_margin_top da borda superior. A logica vive no Create/Step.

var _center_x = display_get_gui_width() / 2;
var _top      = mare_margin_top; // topo do bloco

// Estado -> texto. Fonte de verdade: mare_time_left (segundos). ceil() faz o
// relogio mostrar "5:00" no inicio e so trocar quando o segundo realmente termina.
var _t       = max(0, ceil(mare_time_left));
var _minutes = _t div 60;
var _seconds = _t mod 60;
var _time_text = string(_minutes) + ":" + (_seconds < 10 ? "0" + string(_seconds) : string(_seconds));

// Nome ASCII de proposito: a fonte padrao do GameMaker so cobre ASCII (32-127),
// entao "MARE" garante legibilidade. Trocar por uma fonte de pixel art (com
// acento) e o proximo passo natural quando entrarem os assets de fonte.
var _text = "MARE  " + _time_text;

draw_set_halign(fa_center);
draw_set_valign(fa_top);

// Bloco: fundo semitransparente comecando exatamente em _top (nunca acima), so
// para garantir contraste sobre o tabuleiro. Dimensionado pelo texto.
var _pad_x  = 5;
var _pad_y  = 2;
var _text_w = string_width(_text);
var _text_h = string_height(_text);

draw_set_alpha(0.45);
draw_set_color(c_black);
draw_rectangle(_center_x - _text_w / 2 - _pad_x, _top,
               _center_x + _text_w / 2 + _pad_x, _top + _text_h + _pad_y * 2, false);
draw_set_alpha(1);

// Texto do marcador (nome + cronometro na mesma linha), centralizado no bloco.
draw_set_color(c_white);
draw_text(_center_x, _top + _pad_y, _text);

// Restaura os padroes de desenho para nao vazar estado para outros objetos.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
