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
#macro CARD_OVERLAY_DEPTH -50
#macro CARD_DEPTH         -100

// --- Overlay (escurecimento de fundo) -------------------------------------------
#macro CARD_OVERLAY_ALPHA 0.72

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
/// esquerdo (dentro da faixa reservada da HUD): sorte a esquerda, reves ao lado.
/// @param {string} _tipo  "sorte" ou "reves"
/// @returns {struct} { x, y } centro em coordenadas de GUI
function carta_corner_pos(_tipo) {
    var _tw     = CARD_W * CARD_THUMB_SCALE;
    var _th     = CARD_H * CARD_THUMB_SCALE;
    var _margin = 5;
    var _y      = GAME_HEIGHT - _margin - _th / 2;
    var _x0     = _margin + _tw / 2;                 // centro do 1o slot (sorte)
    var _x      = (_tipo == "sorte") ? _x0 : _x0 + _tw + 4;
    return { x: _x, y: _y };
}

/// Suavizacao (smootherstep) para o deslize ate o canto comecar/terminar macio.
/// @param {real} _t  progresso 0..1
/// @returns {real} 0..1 suavizado
function carta_ease(_t) {
    _t = clamp(_t, 0, 1);
    return _t * _t * _t * (_t * (_t * 6 - 15) + 10);
}
