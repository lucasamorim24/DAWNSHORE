/// obj_mare - Create Event
/// Marcador "Mare": cronometro regressivo de 5 minutos, fixo no topo-centro da tela.
/// Quando chega a zero e o momento da "Mare" (re-randomizacao do tabuleiro,
/// KICKOFF secao 6) - por enquanto o ciclo apenas recomeca. Aqui e no Step fica
/// a LOGICA; o evento Draw GUI so le o estado e pinta.

// Fonte de verdade do ciclo, em SEGUNDOS (estado, nunca pixel). Facil de mudar
// a duracao num lugar so, e de consumir por outras mecanicas depois.
mare_duration_seconds = 5 * 60; // 5 minutos
mare_time_left        = mare_duration_seconds;

// Quantas vezes a mare ja virou (gancho reservado: turnos / re-randomizacao).
mare_cycles = 0;

// Distancia da extremidade superior da tela ate o TOPO do bloco da Mare, em
// pixels de GUI. Espaco de respiro no header (>= 24) para nao colar na borda.
mare_margin_top = 24;
