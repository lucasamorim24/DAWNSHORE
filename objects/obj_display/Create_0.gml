/// obj_display - Create Event
/// Controlador UNICO de resolucao/escala (persistente). Pixel art nitido: o jogo
/// roda na resolucao base (scr_display_config) e sobe por ESCALA INTEIRA - cada
/// pixel do jogo vira um quadrado N x N identico em toda a tela. Escala fracionaria
/// deixa uns pixels maiores que outros (o efeito "estourado"), entao travamos no
/// maior inteiro que cabe no monitor. Quando for pra mobile, a adaptacao mora aqui.

// Nada de suavizar textura/superficie ao escalar: mantem os pixels crocantes.
gpu_set_tex_filter(false);

// GUI na MESMA resolucao base -> HUD e menus desenham 1:1 com os pixels do jogo.
display_set_gui_size(GAME_WIDTH, GAME_HEIGHT);

// Maior escala INTEIRA que cabe no monitor, sem passar da preferida (GAME_SCALE_INIT).
var _mon_w = display_get_width();
var _mon_h = display_get_height();
var _fit   = max(1, min(_mon_w div GAME_WIDTH, _mon_h div GAME_HEIGHT));
var _scale = min(GAME_SCALE_INIT, _fit);

// Janela = base * escala inteira, centralizada no monitor.
window_set_size(GAME_WIDTH * _scale, GAME_HEIGHT * _scale);
window_set_position((_mon_w - GAME_WIDTH * _scale) div 2, (_mon_h - GAME_HEIGHT * _scale) div 2);
