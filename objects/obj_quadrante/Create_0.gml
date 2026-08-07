/// obj_quadrante - Create Event
/// Um quadrante do tabuleiro agora e um OBJETO (instancia), nao mais um struct
/// dentro do obj_board. Assim cada casa pode: (1) receber seu proprio sprite
/// isometrico, (2) ter eventos proprios (Step/Alarm/Mouse/colisao) e (3) ser
/// referenciada/alvejada por outros objetos e pela mecanica da "Mare".
///
/// Quem cria as 16 instancias e o obj_board (fonte de verdade da origem/config do
/// grid). Ele guarda as referencias em `quadrantes[row][col]` e define, logo apos
/// criar cada casa, as variaveis abaixo (column_index, row_index, label, board,
/// depth). Por isso aqui so ficam os defaults.

// --- Identidade na grade (o obj_board sobrescreve apos criar) ---
column_index = 0;
row_index    = 0;
label        = "";     // ex: "A1" ... "D4"

// Vertice superior do losango na tela. Mantido igual ao x/y da instancia: o desenho
// e ancorado em x/y, ja pronto para draw_self() quando o sprite entrar. Guardado
// tambem com estes nomes por compatibilidade com o contrato de estado documentado.
iso_x = x;
iso_y = y;

// --- Propriedades da casa (RESERVADAS) ---
// Ficam zeradas por enquanto. A re-randomizacao via "Mare" (obj_mare) vai iterar as
// instancias de obj_quadrante (ou a matriz do board) e popular estes campos dentro
// de intervalos pre-estabelecidos. Sao variaveis de instancia justamente para que
// cada casa possa reagir a mudanca no seu proprio Step/evento no futuro.
esforco      = 0;
resistencia  = 0;
visibilidade = 0;

// --- Estado visual ---
// Verdadeiro quando o mouse esta sobre esta casa. Derivado no Step a partir da
// fonte de verdade do hover (obj_board.hovered_column/row).
hovered = false;

// Referencia ao tabuleiro (origem do grid + hover). Definida pelo obj_board.
board = noone;

// Ordem de desenho isometrica (o board reajusta apos definir column/row): casas
// "da frente" (maior column+row) desenham por cima das "de tras". Sempre atras do
// jogador (obj_player.depth = -100), que segue por cima do tabuleiro.
depth = 100;

// --- Dessincronizacao de tiles animados (agua) ---
// Todas as casas usam o mesmo sprite; sem isto, elas animam em UNISSONO e o mar
// parece uma grade "piscando junta", nao agua. Damos a cada casa uma FASE inicial
// aleatoria (quadro de partida diferente) e uma velocidade levemente variada -
// assim a superficie nunca re-sincroniza e o olho le como movimento organico.
// Vale para qualquer sprite animado (image_number > 1); tiles estaticos (1 quadro)
// ficam intactos. Precisa de randomize() no boot (obj_display) para variar por run.
if (sprite_index != -1 && image_number > 1) {
    image_index = irandom(image_number - 1);  // comeca num quadro qualquer
    image_speed = random_range(0.85, 1.15);    // +/-15% de velocidade, quebra o ritmo unico
}
