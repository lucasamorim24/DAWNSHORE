/// obj_pescaria - Step Event
/// Sequenciador da sessao. Le o handshake `picked` (a carta escolhida da fase) e a
/// maquina de estados dela para avancar: revelar -> pausar para leitura -> mandar a
/// carta ao canto -> registrar a propriedade -> proxima fase (ou encerrar). SO ESTADO.

// Fase de encerramento: a carta "Propriedades do Mar" cresce do quadrante ate o
// canto; quando vira miniatura, a sessao encerra (overlay some, sobram 3 miniaturas
// no canto). Se nao foi possivel cria-la, encerra na hora.
if (fase == "mar") {
    if (!instance_exists(mar_card) || mar_card.state == "thumb") instance_destroy();
    exit;
}

// Ainda escolhendo nesta fase: nada a sequenciar.
if (picked == noone) exit;
if (!instance_exists(picked)) { picked = noone; exit; }

switch (picked.state) {
    case "flip":
        break; // virando; aguarda revelar

    case "revealed":
        if (hold_timer < 0) {
            // 1o frame revelado: destroi a carta perdedora e arma a pausa de leitura.
            carta_destroy_losers(picked);
            hold_timer = CARD_HOLD_FRAMES;
        } else if (hold_timer > 0) {
            hold_timer--;
        } else {
            picked.state = "to_corner"; // pausa acabou: desliza pro canto
        }
        break;

    case "to_corner":
        break; // aguarda o deslize terminar

    case "thumb":
        // Chegou ao canto: registra a propriedade e avanca a fase.
        var _res = {
            nome:       picked.nome,
            prop_label: picked.prop_label,
            stat:       picked.stat,
            delta:      picked.delta
        };

        if (fase == "sorte") {
            resultado_sorte = _res;
            if (instance_exists(obj_player)) obj_player.carta_sorte = _res;

            // Automaticamente abre a fase de reves, repetindo o comportamento.
            fase       = "reves";
            picked     = noone;
            hold_timer = -1;
            carta_spawn_deck("reves");
        } else {
            resultado_reves = _res;
            if (instance_exists(obj_player)) obj_player.carta_reves = _res;

            // Sorte e reves escolhidas: SO AGORA nasce a carta "Propriedades do Mar",
            // que cresce do quadrante clicado e enfileira como 3a miniatura no canto.
            // O overlay ja some (ver Draw GUI) para ela surgir sobre o tabuleiro.
            mar_card = carta_spawn_mar();
            fase     = "mar";
        }
        break;
}
