/// obj_mare - Step Event
/// Regride o cronometro em tempo real (independente do framerate) ate zero e
/// reinicia, mantendo o marcador "sempre rodando". SO LOGICA.

// delta_time vem em microssegundos; convertemos para segundos.
mare_time_left -= delta_time / 1000000;

if (mare_time_left <= 0) {
    // GANCHO DA "MARE": re-randomiza esforco/resistencia/visibilidade de todos os
    // quadrantes (KICKOFF secao 6). O script so mexe no ESTADO; o Draw das casas le
    // os novos valores no frame seguinte.
    scr_mare_randomize();
    mare_cycles++;

    // Recomeca o ciclo somando a duracao (em vez de resetar) para nao perder
    // a fracao de segundo que passou do zero neste frame.
    mare_time_left += mare_duration_seconds;
}
