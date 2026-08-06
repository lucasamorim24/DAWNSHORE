/// scr_display_config
/// Fonte de verdade UNICA da resolucao do jogo. Pixel art em resolucao base baixa
/// (proporcao 16:9, estilo Papers Please) que sobe por escala INTEIRA para telas
/// grandes. Um segundo momento (mobile) muda praticamente so estes numeros.
///
/// Escala perfeita a partir de 480x270:  x2 = 960x540,  x3 = 1440x810,  x4 = 1920x1080.

#macro GAME_WIDTH  480 // largura da resolucao base, em pixels de jogo
#macro GAME_HEIGHT 270 // altura  da resolucao base, em pixels de jogo (16:9)

// Escala inicial da janela no desktop (janela = base * escala). x3 = 1440x810.
#macro GAME_SCALE_INIT 3

// --- Layout de tela (faixas reservadas da HUD, em pixels de GUI) ---------------
// Duas faixas horizontais de largura TOTAL reservam a HUD - topo e base - e a area
// de jogo fica no meio, com margens laterais iguais. A faixa do TOPO tem tres
// espacos: canto superior esquerdo, centro (marcador "Mare") e canto superior
// direito. NAO existe painel vertical na direita: a superior-direita e so o canto
// direito dessa faixa de topo.
// FONTE DE VERDADE do layout: mexer aqui reposiciona tudo de uma vez (board, menu,
// guias). Ao encolher/crescer uma faixa, o tabuleiro se recentraliza sozinho.
#macro HUD_TOP_HEIGHT    40 // faixa superior (HUD, largura toda): esquerda + centro
                            // (Mare) + direita (info do personagem etc.)
#macro HUD_BOTTOM_HEIGHT 40 // faixa inferior (largura toda): reservada (a definir)
#macro HUD_SIDE_MARGIN   12 // margens laterais da area de jogo (iguais nos dois lados)

// Liga/desliga os retangulos-guia das faixas reservadas (dev). Ligar so quando
// precisar visualizar as areas; em jogo fica desligado (so a Mare aparece no topo).
#macro DEBUG_LAYOUT false

/// Retorna a "zona de jogo": o retangulo central onde o tabuleiro vive, ja
/// descontando as faixas reservadas da HUD (topo, base e margens laterais).
/// Coordenadas de GUI (= resolucao base). Consumido pelo board (centralizacao),
/// pelo menu (overlay) e pelas guias de dev, para que exista um unico lugar
/// definindo a area jogavel.
/// @returns {struct} { x1, y1, x2, y2 }
function game_play_zone() {
    return {
        x1: HUD_SIDE_MARGIN,
        y1: HUD_TOP_HEIGHT,
        x2: GAME_WIDTH  - HUD_SIDE_MARGIN,
        y2: GAME_HEIGHT - HUD_BOTTOM_HEIGHT
    };
}
