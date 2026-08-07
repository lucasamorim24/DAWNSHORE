/// obj_player - Draw GUI Event
/// SO RENDER. Janela de acao (Movimentar / Pescar) como overlay CENTRAL na camada
/// GUI, por cima do jogo. Desenhada em coordenadas de tela (GUI), por isso usa o
/// mouse convertido para GUI no realce dos botoes. A logica do clique vive em
/// Mouse_53; aqui so lemos o estado (menu_open / menu_target_*).

if (board == noone) exit;
if (!menu_open) exit;

// Mouse em coordenadas de GUI (mesma referencia em que a janela e desenhada).
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// Fundo e borda da janela.
draw_set_color(make_colour_rgb(28, 30, 42));
draw_rectangle(menu_x, menu_y, menu_x + menu_w, menu_y + menu_h, false);
draw_set_color(c_white);
draw_rectangle(menu_x, menu_y, menu_x + menu_w, menu_y + menu_h, true);

// Titulo: qual quadrante foi clicado (ex: "B2").
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
var _target_label = board.quadrantes[menu_target_row][menu_target_col].label;
draw_text_transformed(menu_x + menu_w / 2, menu_y + menu_pad + menu_title_h / 2, _target_label, UI_TEXT_SCALE, UI_TEXT_SCALE, 0);

// Dois botoes: 0 = Movimentar, 1 = Pescar. Realca o que esta sob o mouse.
var _labels = ["Movimentar", "Pescar"];
for (var _b = 0; _b < 2; _b++) {
    var _r   = menu_button_rect(_b);
    var _hot = point_in_rectangle(_mx, _my, _r.x1, _r.y1, _r.x2, _r.y2);

    draw_set_color(_hot ? c_lime : make_colour_rgb(70, 72, 92));
    draw_rectangle(_r.x1, _r.y1, _r.x2, _r.y2, false);
    draw_set_color(c_white);
    draw_rectangle(_r.x1, _r.y1, _r.x2, _r.y2, true);

    draw_set_color(_hot ? c_black : c_white);
    draw_text_transformed((_r.x1 + _r.x2) / 2, (_r.y1 + _r.y2) / 2, _labels[_b], UI_TEXT_SCALE, UI_TEXT_SCALE, 0);
}

// Restaura os padroes de desenho.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
