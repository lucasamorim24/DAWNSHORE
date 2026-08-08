/// obj_carta_mar - Create Event
/// Carta "Propriedades do Mar": informativa, NAO selecionavel. Mesmo layout das
/// cartas de sorte/reves, mas mostra os 3 atributos do quadrante clicado (esforco/
/// resistencia/visibilidade no ciclo atual da Mare). Nasce dentro do quadrante e
/// cresce ate a frente das duas cartas, virando uma terceira miniatura. Objeto fino:
/// define o tipo e delega tudo para scr_carta. Os dados (nome, atributos, origem e
/// destino da animacao) sao injetados pelo obj_pescaria (carta_spawn_mar).

tipo = "mar";
carta_init();
