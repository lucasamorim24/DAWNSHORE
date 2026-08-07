/// scr_display_config
/// Fonte de verdade UNICA da resolucao do jogo. Pixel art em resolucao base baixa
/// (proporcao 16:9, estilo Papers Please) que sobe por escala INTEIRA para telas
/// grandes. Um segundo momento (mobile) muda praticamente so estes numeros.
///
/// Base 320x180 (classico pixel art 16:9). Escala perfeita: x4 = 1280x720,
/// x5 = 1600x900, x6 = 1920x1080. Base MENOR = tabuleiro/arte MAIORES na tela (o
/// tabuleiro tem ~128px, entao ocupa mais da tela quanto menor for a base). Para
/// deixar maior/menor, mexa SO em GAME_WIDTH/GAME_HEIGHT mantendo 16:9 (ex.: 256x144
/// deixa tudo ainda maior; 384x216, menor). NAO escalar sprites: isso quebra o
/// pixel-perfect - o zoom vem daqui + da escala inteira em obj_display.

#macro GAME_WIDTH  320 // largura da resolucao base, em pixels de jogo
#macro GAME_HEIGHT 180 // altura  da resolucao base, em pixels de jogo (16:9)

// Escala inicial da janela no desktop (janela = base * escala), limitada ao maior
// inteiro que cabe no monitor (obj_display). x5 = 1600x900; cai pra x4 (1280x720)
// em telas 1366x768.
#macro GAME_SCALE_INIT 5

// --- Layout de tela (faixas reservadas da HUD, em pixels de GUI) ---------------
// Duas faixas horizontais de largura TOTAL reservam a HUD - topo e base - e a area
// de jogo fica no meio, com margens laterais iguais. A faixa do TOPO tem tres
// espacos: canto superior esquerdo, centro (marcador "Mare") e canto superior
// direito. NAO existe painel vertical na direita: a superior-direita e so o canto
// direito dessa faixa de topo.
// FONTE DE VERDADE do layout: mexer aqui reposiciona tudo de uma vez (board, menu,
// guias). Ao encolher/crescer uma faixa, o tabuleiro se recentraliza sozinho.
#macro HUD_TOP_HEIGHT    28 // faixa superior (HUD, largura toda): esquerda + centro
                            // (Mare) + direita (info do personagem etc.)
#macro HUD_BOTTOM_HEIGHT 28 // faixa inferior (largura toda): reservada (a definir)
#macro HUD_SIDE_MARGIN   8  // margens laterais da area de jogo (iguais nos dois lados)

// Liga/desliga os retangulos-guia das faixas reservadas (dev). Ligar so quando
// precisar visualizar as areas; em jogo fica desligado (so a Mare aparece no topo).
#macro DEBUG_LAYOUT false

// --- Tamanho unico de texto da interface ---------------------------------------
// A fonte padrao do GameMaker e grande demais para a resolucao base (320x180): um
// caractere cheio "come" o tabuleiro. Todos os textos (label do quadrante, Mare,
// menu de acao, tooltip de propriedades) desenham por draw_text_transformed com
// ESTE fator, entao ficam do mesmo tamanho da leitura da grade. Fonte de verdade
// unica: mexa aqui para escalar toda a tipografia de uma vez. 1 = fonte cheia.
// Some quando entrar uma fonte de pixel art propria no tamanho certo.
#macro UI_TEXT_SCALE 0.7

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
