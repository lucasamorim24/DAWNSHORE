/// obj_pescaria - Draw GUI Event
/// SO RENDER. Escurece a tela inteira (overlay) e escreve o titulo da fase no topo.
/// As cartas se desenham por conta propria (Draw GUI), com depth menor, POR CIMA
/// deste overlay. Coordenadas de GUI (resolucao base), como o resto da HUD.

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Escurecimento de fundo.
draw_set_alpha(CARD_OVERLAY_ALPHA);
draw_set_color(make_colour_rgb(10, 12, 20));
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// Titulo no topo (ASCII de proposito - ver nota em scr_carta_config). "REVES" = revés.
var _title = (fase == "sorte") ? "TIRE UMA CARTA DE SORTE" : "TIRE UMA CARTA DE REVES";

var _zone = game_play_zone();
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_transformed((_zone.x1 + _zone.x2) / 2, _zone.y1 + 4, _title, UI_TEXT_SCALE, UI_TEXT_SCALE, 0);

// Restaura padroes de desenho.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
