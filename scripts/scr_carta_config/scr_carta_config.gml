/// scr_carta_config
/// Fonte de verdade UNICA da "pescaria" (sessao de cartas). Reune os DADOS das
/// cartas (nome + propriedade) e as constantes visuais/temporais do overlay. Separa
/// ESTADO/config de RENDER: a logica vive em scr_carta / obj_pescaria / obj_carta_*,
/// e le tudo daqui. Mexa nestes numeros para reequilibrar ou re-skinnar sem tocar na
/// mecanica.
///
/// NOTA DE ACENTO: a fonte padrao do GameMaker so cobre ASCII (32-127), entao os
/// textos DESENHADOS ficam sem acento de proposito (mesmo padrao da Mare/tooltip).
/// Os nomes "de verdade" (com acento) ficam nos comentarios; quando entrar uma fonte
/// de pixel art com acentuacao, basta trocar as strings de exibicao aqui.

// --- Geometria das cartas (pixels de GUI = resolucao base 320x180) --------------
#macro CARD_W 96    // largura base da carta
#macro CARD_H 100   // altura  base da carta
#macro CARD_GAP 18  // vao entre as duas cartas centradas

// --- Fatores de escala (a carta e desenhada PELO CENTRO, escalando em torno dele)-
#macro CARD_HOVER_SCALE 1.10 // hover: cresce sutilmente (10%)
#macro CARD_THUMB_SCALE 0.34 // miniatura no canto ao ser escolhida
#macro CARD_LERP        0.25 // suavizacao do hover (0..1; maior = mais rapido)

// --- Tempos da animacao (por frame; sala roda a 60fps) --------------------------
#macro CARD_FLIP_SPEED 0.06 // virada: ~17 frames para revelar
#macro CARD_MOVE_SPEED 0.06 // deslize ate o canto: ~17 frames
#macro CARD_HOLD_FRAMES 45  // pausa apos revelar, para ler antes de ir pro canto

// --- Camadas de desenho (Draw GUI: MAIOR depth desenha ANTES = mais ao fundo) ----
// Overlay cobre a Mare (depth 0) e o tabuleiro; as cartas ficam por cima do overlay.
// A carta "Propriedades do Mar" fica ACIMA das duas (depth menor) para parar na
// frente delas.
#macro CARD_OVERLAY_DEPTH -50
#macro CARD_DEPTH         -100
#macro CARD_MAR_DEPTH     -110

// --- Overlay (escurecimento de fundo) -------------------------------------------
#macro CARD_OVERLAY_ALPHA 0.72

// --- Carta "Propriedades do Mar" (informativa, nao selecionavel) ----------------
// So aparece ao FINAL (depois de escolher sorte e reves): cresce de dentro do
// quadrante clicado e enfileira como a 3a miniatura no canto, imprimindo os
// atributos daquele quadrante no ciclo atual da Mare.
#macro CARD_MAR_GROW_SPEED  0.05 // ~20 frames para crescer do quadrante ate o canto

// --- Cores das propriedades (fonte de verdade unica; ver carta_prop_color) ------
#macro CARD_COL_GOOD    make_colour_rgb(30, 140, 60)    // bonus (verde)
#macro CARD_COL_BAD     make_colour_rgb(200, 55, 55)    // penalidade (vermelho)
#macro CARD_COL_NEUTRAL make_colour_rgb(150, 155, 170)  // valor zero (neutro)

/// Baralho de uma fase. Cada carta: nome exibido (ASCII), rotulo da propriedade
/// (ASCII), a chave do atributo afetado e o delta. stat/delta ficam prontos para,
/// no futuro, aplicar o efeito na mecanica (esforco/resistencia/visibilidade dos
/// quadrantes); por ora sao apenas armazenados e exibidos.
/// @param {string} _tipo  "sorte" ou "reves"
/// @returns {array} lista de 2 structs { nome, prop_label, stat, delta }
function carta_deck(_tipo) {
    if (_tipo == "sorte") {
        return [
            // "Linha Firme"           -> +2 Resistencia
            { nome: "Linha Firme",           prop_label: "+2 Resistencia",  stat: "resistencia",  delta:  2 },
            // "Reflexo da Superficie" -> +2 Visibilidade
            { nome: "Reflexo da Superficie", prop_label: "+2 Visibilidade", stat: "visibilidade", delta:  2 },
        ];
    }
    // _tipo == "reves"
    return [
        // "Corrente Pesada" -> +2 Esforco
        { nome: "Corrente Pesada", prop_label: "+2 Esforco",      stat: "esforco",      delta:  2 },
        // "Nevoa Fria"      -> -2 Visibilidade
        { nome: "Nevoa Fria",      prop_label: "-2 Visibilidade", stat: "visibilidade", delta: -2 },
    ];
}

/// Posicao-alvo (centro da carta) do slot na hora da escolha: as duas cartas ficam
/// lado a lado, centradas na zona de jogo e logo abaixo do titulo do topo.
/// @param {real} _slot  0 = esquerda, 1 = direita
/// @returns {struct} { x, y } centro em coordenadas de GUI
function carta_home_pos(_slot) {
    var _z    = game_play_zone();
    var _cx   = (_z.x1 + _z.x2) / 2;
    var _cy   = (_z.y1 + 18 + _z.y2) / 2; // desce ~18px para dar lugar ao titulo
    var _step = CARD_W + CARD_GAP;        // distancia centro-a-centro
    var _dx   = (_slot == 0) ? -_step / 2 : _step / 2;
    return { x: _cx + _dx, y: _cy };
}

/// Posicao-alvo (centro) da MINIATURA no canto da tela, por tipo. Canto inferior
/// esquerdo (dentro da faixa reservada da HUD), enfileiradas: sorte, reves e mar.
/// @param {string} _tipo  "sorte" | "reves" | "mar"
/// @returns {struct} { x, y } centro em coordenadas de GUI
function carta_corner_pos(_tipo) {
    var _tw     = CARD_W * CARD_THUMB_SCALE;
    var _th     = CARD_H * CARD_THUMB_SCALE;
    var _margin = 5;
    var _gap    = 4;

    var _slot = 2; // mar = 3o (padrao)
    if      (_tipo == "sorte") _slot = 0;
    else if (_tipo == "reves") _slot = 1;

    var _y      = GAME_HEIGHT - _margin - _th / 2;
    var _x      = _margin + _tw / 2 + _slot * (_tw + _gap);
    return { x: _x, y: _y };
}

/// Diz se o efeito da carta e BOM para o jogador (verde) ou nao (vermelho). Nao
/// basta o sinal do delta: em "esforco" MENOS e melhor (delta negativo = bonus),
/// enquanto em "resistencia"/"visibilidade" MAIS e melhor (delta positivo = bonus).
/// Fonte de verdade unica dessa regra: consumida pelo render (cor da propriedade) e
/// pronta para a aplicacao do efeito na mecanica numa proxima etapa.
/// @param {string} _stat   "esforco" | "resistencia" | "visibilidade"
/// @param {real}   _delta  variacao da propriedade (ex: +2, -2)
/// @returns {bool} true = bonus (verde); false = penalidade (vermelho)
function carta_is_bonus(_stat, _delta) {
    if (_stat == "esforco") return (_delta < 0); // menos esforco = melhor
    return (_delta > 0);                         // mais resistencia/visibilidade = melhor
}

/// Cor de um valor de propriedade: verde se e bonus, vermelho se e penalidade,
/// neutro se e zero. Fonte de verdade unica das cores; usada tanto pela propriedade
/// unica das cartas de escolha quanto pelas 3 linhas da carta "Propriedades do Mar".
/// @param {string} _stat   "esforco" | "resistencia" | "visibilidade"
/// @param {real}   _value  valor/variacao
/// @returns {constant.Colour}
function carta_prop_color(_stat, _value) {
    if (_value == 0) return CARD_COL_NEUTRAL;
    return carta_is_bonus(_stat, _value) ? CARD_COL_GOOD : CARD_COL_BAD;
}

/// Suavizacao (smootherstep) para o deslize ate o canto comecar/terminar macio.
/// @param {real} _t  progresso 0..1
/// @returns {real} 0..1 suavizado
function carta_ease(_t) {
    _t = clamp(_t, 0, 1);
    return _t * _t * _t * (_t * (_t * 6 - 15) + 10);
}
