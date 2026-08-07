/// scr_carta
/// Comportamento COMPARTILHADO das cartas da pescaria. obj_carta_sorte e
/// obj_carta_reves sao objetos finos: seus eventos so definem o `tipo` e chamam
/// estas funcoes. Assim os dois compartilham 100% da logica (virar, hover, deslizar
/// pro canto) e diferem so nos DADOS/cores por tipo - escalavel, nao duplicado.
///
/// Estas funcoes rodam no escopo de quem chama (mesmo padrao de scr_mare_randomize):
/// carta_init/step/draw no escopo da CARTA; carta_spawn_deck/destroy_losers no
/// escopo do CONTROLADOR (obj_pescaria).
///
/// Maquina de estados da carta:
///   "idle"      verso para cima, selecionavel, cresce no hover
///   "flip"      virando (revela a frente ao passar da metade)
///   "revealed"  frente revelada, aguardando o controlador manda-la ao canto
///   "to_corner" deslizando/encolhendo ate a miniatura no canto
///   "thumb"     miniatura estatica no canto (persiste apos a pescaria)

/// Defaults da carta. Chamado no Create; espera `tipo` ja definido ("sorte"/"reves").
function carta_init() {
    pescaria     = noone;   // controlador (obj_pescaria); definido pelo spawn
    slot         = 0;       // 0 = esquerda, 1 = direita
    nome         = "";
    prop_label   = "";
    stat         = "";      // "esforco" | "resistencia" | "visibilidade"
    delta        = 0;

    state        = "idle";
    render_scale = 1;       // escala atual (hover/thumb suavizados)
    hover        = false;
    flip_t       = 0;       // progresso da virada 0..1
    move_t       = 0;       // progresso do deslize ao canto 0..1
    click_lock   = 2;       // trava o clique nos 1os frames (evita herdar o clique
                            // do botao "Pescar" que abriu a sessao)

    home_x = 0; home_y = 0; // posicao de escolha (centro), definida pelo spawn
    cx     = 0; cy     = 0; // centro atual desenhado
    corner_x = 0; corner_y = 0; // alvo da miniatura (resolvido ao ir pro canto)

    depth = CARD_DEPTH;     // por cima do overlay

    // Paleta por tipo: verso escuro tematico, frente clara para o texto.
    if (tipo == "sorte") {
        back_fill = make_colour_rgb(28,  70, 110); // azul-mar profundo
        accent    = make_colour_rgb(120, 200, 235);
    } else {
        back_fill = make_colour_rgb(86,  42,  80);  // roxo-bruma
        accent    = make_colour_rgb(210, 150, 200);
    }
    front_fill  = make_colour_rgb(232, 238, 244);   // frente clara (comum)
    border_col  = make_colour_rgb(18,  22,  34);
}

/// Passo por frame da carta: hover/escala, virada, deslize ao canto. SO ESTADO.
function carta_step() {
    if (click_lock > 0) click_lock--;

    // Sem controlador vivo: so miniaturas persistem; qualquer outra sobra some.
    if (pescaria == noone || !instance_exists(pescaria)) {
        if (state != "thumb") instance_destroy();
        exit;
    }

    switch (state) {
        case "idle":
            // So a carta pode ser escolhida enquanto ninguem foi escolhido na fase.
            var _interactive = (pescaria.picked == noone);

            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);
            var _hw = CARD_W * render_scale / 2;
            var _hh = CARD_H * render_scale / 2;
            hover = _interactive && point_in_rectangle(_mx, _my, cx - _hw, cy - _hh, cx + _hw, cy + _hh);

            var _target = hover ? CARD_HOVER_SCALE : 1;
            render_scale = lerp(render_scale, _target, CARD_LERP);

            if (hover && click_lock <= 0 && mouse_check_button_pressed(mb_left)) {
                pescaria.picked = id; // handshake: vira a carta escolhida da fase
                state = "flip";
            }
            break;

        case "flip":
            flip_t += CARD_FLIP_SPEED;
            render_scale = lerp(render_scale, 1, CARD_LERP);
            if (flip_t >= 1) { flip_t = 1; state = "revealed"; }
            break;

        case "revealed":
            render_scale = lerp(render_scale, 1, CARD_LERP);
            break;

        case "to_corner":
            // Resolve o alvo do canto no 1o frame do deslize.
            if (move_t == 0) {
                var _c = carta_corner_pos(tipo);
                corner_x = _c.x; corner_y = _c.y;
            }
            move_t = min(1, move_t + CARD_MOVE_SPEED);
            var _e = carta_ease(move_t);
            cx = lerp(home_x, corner_x, _e);
            cy = lerp(home_y, corner_y, _e);
            render_scale = lerp(1, CARD_THUMB_SCALE, _e);
            if (move_t >= 1) state = "thumb";
            break;

        case "thumb":
            cx = corner_x; cy = corner_y;
            render_scale = CARD_THUMB_SCALE;
            break;
    }
}

/// Render da carta (Draw GUI). Desenha PELO CENTRO (cx,cy) com a escala atual. A
/// virada e um "esmagamento" horizontal: a largura vai 1 -> 0 -> 1 e, ao passar da
/// metade, troca verso pela frente. SO RENDER.
function carta_draw() {
    var _w  = CARD_W * render_scale;
    var _h  = CARD_H * render_scale;

    // Fator de virada (largura). idle=1 (verso), meio=0, revelado=1 (frente).
    var _ff = 1;
    if (state == "flip") _ff = abs(cos(flip_t * pi));

    var _dw = _w * _ff;
    var _x1 = cx - _dw / 2, _x2 = cx + _dw / 2;
    var _y1 = cy - _h  / 2, _y2 = cy + _h  / 2;

    var _show_front = (state == "revealed" || state == "to_corner" || state == "thumb"
                    || (state == "flip" && flip_t >= 0.5));

    // --- Corpo da carta ---
    draw_set_color(_show_front ? front_fill : back_fill);
    draw_rectangle(_x1, _y1, _x2, _y2, false);

    // Borda (destaca em branco no hover do verso selecionavel).
    draw_set_color((hover && state == "idle") ? c_white : border_col);
    draw_rectangle(_x1, _y1, _x2, _y2, true);

    // Conteudo textual so aparece quando a carta esta "aberta" o bastante (evita
    // texto esmagado no meio da virada).
    if (_ff > 0.55) {
        var _ts    = UI_TEXT_SCALE * render_scale;               // escala do texto
        var _wrapw = (CARD_W - 8) / UI_TEXT_SCALE;               // largura de quebra (nao-escalada)

        draw_set_halign(fa_center);

        if (_show_front) {
            // Nome no topo.
            draw_set_valign(fa_top);
            draw_set_color(make_colour_rgb(30, 34, 48));
            draw_text_ext_transformed(cx, _y1 + 5 * render_scale, nome, -1, _wrapw, _ts, _ts, 0);

            // Linha divisoria.
            draw_set_color(make_colour_rgb(180, 188, 200));
            draw_line(_x1 + 5, cy, _x2 - 5, cy);

            // Propriedade (verde para bonus, vermelho para penalidade).
            draw_set_valign(fa_middle);
            draw_set_color(delta >= 0 ? make_colour_rgb(30, 140, 60) : make_colour_rgb(200, 55, 55));
            draw_text_ext_transformed(cx, cy + _h * 0.22, prop_label, -1, _wrapw, _ts, _ts, 0);
        } else {
            // Verso: ornamento "?" e a etiqueta do baralho.
            draw_set_valign(fa_middle);
            draw_set_color(accent);
            draw_text_transformed(cx, cy - _h * 0.06, "?", _ts * 1.8, _ts * 1.8, 0);

            draw_set_valign(fa_bottom);
            draw_set_color(accent);
            draw_text_transformed(cx, _y2 - 4 * render_scale, (tipo == "sorte") ? "SORTE" : "REVES", _ts, _ts, 0);
        }
    }

    // Restaura padroes de desenho para nao vazar estado.
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

/// Cria o baralho (2 cartas) da fase. Roda no escopo do CONTROLADOR (obj_pescaria):
/// `id` aqui e o controlador. Posiciona cada carta no seu slot e injeta os dados.
/// @param {string} _tipo  "sorte" ou "reves"
function carta_spawn_deck(_tipo) {
    var _obj  = (_tipo == "sorte") ? obj_carta_sorte : obj_carta_reves;
    var _deck = carta_deck(_tipo);

    for (var _i = 0; _i < array_length(_deck); _i++) {
        var _c = instance_create_depth(0, 0, CARD_DEPTH, _obj);
        _c.pescaria   = id; // controlador
        _c.slot       = _i;
        _c.nome       = _deck[_i].nome;
        _c.prop_label = _deck[_i].prop_label;
        _c.stat       = _deck[_i].stat;
        _c.delta      = _deck[_i].delta;

        var _h = carta_home_pos(_i);
        _c.home_x = _h.x; _c.home_y = _h.y;
        _c.cx     = _h.x; _c.cy     = _h.y;
    }
}

/// Destroi as cartas NAO escolhidas da fase (mesmo tipo do vencedor, menos ele e
/// menos qualquer miniatura ja fixada). Roda no escopo do controlador.
/// @param {id.Instance} _winner  a carta escolhida
function carta_destroy_losers(_winner) {
    with (_winner.object_index) {
        if (id != _winner && state != "thumb") instance_destroy();
    }
}
