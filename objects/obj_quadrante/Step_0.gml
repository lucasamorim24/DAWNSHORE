/// obj_quadrante - Step Event
/// Logica propria da casa. Hoje ela so deriva o proprio estado de hover da fonte de
/// verdade do tabuleiro (obj_board.hovered_column/row) em vez de o board pintar tudo
/// de fora. E o lugar natural para as reacoes futuras da casa a eventos do jogo:
/// mudanca de "Mare", ocupacao pelo jogador, efeitos de esforco/resistencia, etc.

if (board == noone) exit;

hovered = (column_index == board.hovered_column && row_index == board.hovered_row);
