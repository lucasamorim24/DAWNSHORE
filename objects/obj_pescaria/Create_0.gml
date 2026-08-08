/// obj_pescaria - Create Event
/// Controlador da SESSAO de cartas (a "pescaria"), criado quando o jogador clica em
/// "Pescar". Orquestra as duas fases em sequencia (sorte -> reves), desenha o overlay
/// escuro + o titulo do topo, cria as cartas e coleta o resultado. Existe apenas
/// enquanto a sessao esta ativa: some (instance_destroy) ao terminar, deixando so as
/// duas miniaturas (instancias de carta em estado "thumb") no canto da tela.
///
/// SO ESTADO aqui e no Step; o desenho vive no Draw GUI.

// Limpa miniaturas de uma pescaria anterior, para comecar sempre do zero.
with (obj_carta_sorte) instance_destroy();
with (obj_carta_reves) instance_destroy();
with (obj_carta_mar)   instance_destroy();

// Overlay por cima da Mare e do tabuleiro, mas atras das cartas (ver macros).
depth = CARD_OVERLAY_DEPTH;

// Quadrante clicado para pescar (o obj_player preenche logo apos criar esta
// instancia). E a origem da carta "Propriedades do Mar" e a fonte dos atributos
// exibidos nela.
target_col = -1;
target_row = -1;

// Carta "Propriedades do Mar": criada so ao FINAL (fase "mar"), depois de escolher
// sorte e reves. Guardamos a referencia para saber quando ela assentou no canto.
mar_card = noone;

// Fase atual da sessao: "sorte" -> "reves" -> "mar" (encerramento).
fase = "sorte";

// Handshake com as cartas: a carta clicada se registra aqui (fonte de verdade de
// "quem foi escolhido nesta fase"). noone = ainda escolhendo.
picked = noone;

// Contagem regressiva da pausa apos revelar (para ler antes de ir pro canto).
hold_timer = -1; // -1 = ainda nao armado nesta fase

// Resultados guardados SEPARADAMENTE por fase (tambem espelhados no obj_player).
resultado_sorte = undefined;
resultado_reves = undefined;

// Cria o baralho da primeira fase.
carta_spawn_deck("sorte");
