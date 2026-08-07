/// scr_mare_randomize()
/// Gancho da "Mare" (KICKOFF secao 6): re-randomiza as propriedades de TODOS os
/// quadrantes do tabuleiro. Chamado pelo obj_mare toda vez que o cronometro vira
/// (e uma vez no boot, para o tabuleiro nunca comecar zerado).
///
/// So MEXE NO ESTADO: escreve esforco/resistencia/visibilidade em cada instancia de
/// obj_quadrante. A renderizacao (obj_quadrante Draw) apenas le esses campos depois.
/// Itera as INSTANCIAS diretamente (nao a matriz do board), entao funciona mesmo que
/// o numero de casas mude - escalavel, nao amarrado ao 4x4.
///
/// Intervalo do sorteio: [MARE_PROP_MIN, MARE_PROP_MAX] (scr_board_config), inclusivo
/// nas duas pontas. Depende de randomize() ter rodado no boot (obj_display) para que
/// cada partida gere valores diferentes.

function scr_mare_randomize() {
    with (obj_quadrante) {
        esforco      = irandom_range(MARE_PROP_MIN, MARE_PROP_MAX);
        resistencia  = irandom_range(MARE_PROP_MIN, MARE_PROP_MAX);
        visibilidade = irandom_range(MARE_PROP_MIN, MARE_PROP_MAX);
    }
}
