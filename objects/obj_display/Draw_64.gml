/// obj_display - Draw GUI Event
/// GUIA DE LAYOUT (dev). Pinta por cima do jogo as faixas reservadas da HUD (topo
/// e base, largura total) e o contorno da zona de jogo, so para visualizar a
/// composicao enquanto o conteudo real dessas areas nao existe. Controlado por
/// DEBUG_LAYOUT (scr_display_config); desligar quando entrarem os conteudos.
/// NAO e mecanica, e so andaime visual.

if (!DEBUG_LAYOUT) exit;

var _zone = game_play_zone();

// Faixas reservadas, preenchimento bem sutil so para demarcar as areas.
draw_set_alpha(0.12);

draw_set_color(c_aqua);   // faixa do topo (HUD): esquerda + centro (Mare) + direita
draw_rectangle(0, 0, GAME_WIDTH, HUD_TOP_HEIGHT, false);

draw_set_color(c_orange); // faixa da base: reservada (a definir)
draw_rectangle(0, GAME_HEIGHT - HUD_BOTTOM_HEIGHT, GAME_WIDTH, GAME_HEIGHT, false);

draw_set_color(c_gray);   // margens laterais da area de jogo (iguais dos dois lados)
draw_rectangle(0, HUD_TOP_HEIGHT, HUD_SIDE_MARGIN, GAME_HEIGHT - HUD_BOTTOM_HEIGHT, false);
draw_rectangle(GAME_WIDTH - HUD_SIDE_MARGIN, HUD_TOP_HEIGHT,
               GAME_WIDTH, GAME_HEIGHT - HUD_BOTTOM_HEIGHT, false);

draw_set_alpha(1);

// Divisorias sutis dos tres espacos da faixa do topo (so referencia visual; os
// tamanhos exatos dos cantos definem-se quando o conteudo entrar).
draw_set_color(c_aqua);
draw_line(GAME_WIDTH / 3,     0, GAME_WIDTH / 3,     HUD_TOP_HEIGHT);
draw_line(GAME_WIDTH * 2 / 3, 0, GAME_WIDTH * 2 / 3, HUD_TOP_HEIGHT);

// Contorno da zona de jogo (onde o tabuleiro vive, centralizado).
draw_set_color(c_lime);
draw_rectangle(_zone.x1, _zone.y1, _zone.x2 - 1, _zone.y2 - 1, true);

// Rotulos discretos, encostados nas bordas.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text(2, 2, "HUD ESQ");
draw_text(GAME_WIDTH * 2 / 3 + 2, 2, "HUD DIR");
draw_text(2, GAME_HEIGHT - HUD_BOTTOM_HEIGHT + 2, "BASE");

draw_set_color(c_white);
