/// obj_carta_sorte - Create Event
/// Carta de SORTE (bonus). Objeto fino: define o tipo e delega todo o comportamento
/// (hover, virar, deslizar pro canto, desenhar) para scr_carta, compartilhado com
/// obj_carta_reves. Os dados (nome/propriedade) sao injetados pelo obj_pescaria ao
/// criar o baralho (carta_spawn_deck).

tipo = "sorte";
carta_init();
