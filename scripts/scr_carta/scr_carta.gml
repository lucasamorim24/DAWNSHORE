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
///   Cartas de ESCOLHA (tipo "sorte"/"reves"):
///     "idle"      verso para cima, selecionavel, cresce no hover
///     "flip"      virando (revela a frente ao passar da metade)
///     "revealed"  frente revelada, aguardando o controlador manda-la ao canto
///     "to_corner" deslizando/encolhendo ate a miniatura no canto
///     "thumb"     miniatura estatica no canto (persiste apos a pescaria)
///   Carta "Propriedades do Mar" (tipo "mar", informativa e NAO selecionavel):
///     "grow"      cresce de dentro do quadrante clicado ate o canto (3a miniatura)
///     "thumb"     miniatura estatica no canto (persiste apos a pescaria)

/// Defaults da carta. Chamado no Create; espera `tipo` ja definido
/// ("sorte" | "reves" | "mar").
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

    // --- Carta "Propriedades do Mar" (tipo "mar") ---
    grow_t          = 0;    // progresso do crescimento 0..1
    start_x = 0; start_y = 0; // origem da animacao (centro do quadrante clicado)
    mar_esforco      = 0;   // snapshot dos atributos do quadrante no ciclo da Mare
    mar_resistencia  = 0;
    mar_visibilidade = 0;

    depth = (tipo == "mar") ? CARD_MAR_DEPTH : CARD_DEPTH; // mar por cima das 2 cartas

    // Paleta por tipo: verso escuro tematico, frente clara para o texto.
    if (tipo == "sorte") {
        back_fill = make_colour_rgb(28,  70, 110); // azul-mar profundo
        accent    = make_colour_rgb(120, 200, 235);
    } else if (tipo == "reves") {
        back_fill = make_colour_rgb(86,  42,  80);  // roxo-bruma
        accent    = make_colour_rgb(210, 150, 200);
    } else { // "mar"
        back_fill = make_colour_rgb(20,  90,  95);  // verde-agua (nao usado: mar so mostra a frente)
        accent    = make_colour_rgb(140, 210, 210);
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

        // --- Carta "Propriedades do Mar": cresce do quadrante ate o canto ---
        case "grow":
            grow_t = min(1, grow_t + CARD_MAR_GROW_SPEED);
            var _g = carta_ease(grow_t);
            cx = lerp(start_x, corner_x, _g);
            cy = lerp(start_y, corner_y, _g);
            render_scale = lerp(0.05, CARD_THUMB_SCALE, _g); // brota pequena e assenta no canto
            if (grow_t >= 1) state = "thumb"; // vira a 3a miniatura (reusa o estado thumb)
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

    // A carta "mar" e sempre frente (informativa, sem verso/virada).
    var _show_front = (tipo == "mar"
                    || state == "revealed" || state == "to_corner" || state == "thumb"
                    || (state == "flip" && flip_t >= 0.5));

    // --- Corpo da carta ---
    draw_set_color(_show_front ? front_fill : back_fill);
    draw_rectangle(_x1, _y1, _x2, _y2, false);

    // Borda (destaca em branco no hover do verso selecionavel).
    draw_set_color((hover && state == "idle") ? c_white : border_col);
    draw_rectangle(_x1, _y1, _x2, _y2, true);

    // Conteudo textual so aparece quando a carta esta "aberta" o bastante (evita
    // texto esmagado no meio da virada) e grande o bastante (evita "sujeira" nos
    // primeiros frames do crescimento da carta do mar).
    if (_ff > 0.55 && render_scale > 0.12) {
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

            if (tipo == "mar") {
                // Tres linhas com os atributos do quadrante (ciclo atual da Mare).
                // Cada linha e colorida pela mesma regra (carta_prop_color): +res,
                // +vis e -esforco em verde; o resto em vermelho; zero em neutro.
                // Escala um pouco menor e SEM quebra para cada linha caber inteira.
                var _keys = ["esforco",      "resistencia",  "visibilidade"];
                var _lbls = ["Esforco",      "Resistencia",  "Visibilidade"];
                var _vals = [mar_esforco,    mar_resistencia, mar_visibilidade];
                var _tsm  = _ts * 0.8;
                var _lh   = _h * 0.16;
                var _base = cy + _h * 0.06;

                draw_set_valign(fa_top);
                for (var _i = 0; _i < 3; _i++) {
                    var _v   = _vals[_i];
                    var _txt = _lbls[_i] + ": " + ((_v > 0) ? "+" : "") + string(_v);
                    draw_set_color(carta_prop_color(_keys[_i], _v));
                    draw_text_transformed(cx, _base + _lh * _i, _txt, _tsm, _tsm, 0);
                }
            } else {
                // Propriedade unica: verde para bonus, vermelho para penalidade
                // (carta_prop_color): +resistencia, +visibilidade e -esforco em verde.
                draw_set_valign(fa_middle);
                draw_set_color(carta_prop_color(stat, delta));
                draw_text_ext_transformed(cx, cy + _h * 0.22, prop_label, -1, _wrapw, _ts, _ts, 0);
            }
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

/// Cria a carta "Propriedades do Mar": nasce no centro do quadrante clicado para
/// pescar e cresce ate o canto, enfileirando como 3a miniatura, imprimindo os
/// atributos daquele quadrante (snapshot do ciclo atual da Mare). Roda no escopo do
/// CONTROLADOR (obj_pescaria), que ja tem target_col/target_row.
/// @returns {id.Instance} a carta criada, ou noone se nao foi possivel.
function carta_spawn_mar() {
    if (!instance_exists(obj_board)) return noone;
    if (target_col < 0 || target_row < 0) return noone;

    var _mar = instance_create_depth(0, 0, CARD_MAR_DEPTH, obj_carta_mar);
    _mar.pescaria = id;
    _mar.nome     = "Propriedades do Mar";

    // Snapshot dos atributos do quadrante alvo (fonte de verdade: a instancia da casa).
    var _q = obj_board.quadrantes[target_row][target_col];
    if (_q != noone) {
        _mar.mar_esforco      = _q.esforco;
        _mar.mar_resistencia  = _q.resistencia;
        _mar.mar_visibilidade = _q.visibilidade;
    }

    // Origem da animacao = centro do losango do quadrante clicado. Mundo e GUI estao
    // 1:1 (display_set_gui_size na resolucao base), entao a coord serve direto.
    var _iso = grid_to_iso(target_col, target_row, obj_board.board_origin_x, obj_board.board_origin_y);
    _mar.start_x = _iso.x;
    _mar.start_y = _iso.y + TILE_HEIGHT / 2;
    _mar.cx      = _mar.start_x;
    _mar.cy      = _mar.start_y;

    // Destino = 3a miniatura no canto (depois de sorte e reves).
    var _corner = carta_corner_pos("mar");
    _mar.corner_x = _corner.x;
    _mar.corner_y = _corner.y;

    _mar.render_scale = 0.05; // brota pequena
    _mar.state        = "grow";
    return _mar;
}

/// Destroi as cartas NAO escolhidas da fase (mesmo tipo do vencedor, menos ele e
/// menos qualquer miniatura ja fixada). Roda no escopo do controlador.
/// @param {id.Instance} _winner  a carta escolhida
function carta_destroy_losers(_winner) {
    with (_winner.object_index) {
        if (id != _winner && state != "thumb") instance_destroy();
    }
}
