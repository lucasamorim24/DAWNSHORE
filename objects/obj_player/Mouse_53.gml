/// obj_player - Global Left Pressed
/// A cada clique com o botao esquerdo, descobre sob qual quadrante o mouse esta
/// e move o jogador para la, guardando a nova posicao no grid.

if (board == noone) exit;

// Sessao de cartas (pescaria) ativa: o tabuleiro nao interage - o clique pertence
// as cartas (que tratam o proprio clique em coordenadas de GUI).
if (instance_exists(obj_pescaria)) exit;

// --- Janela de acao aberta: o clique interage com ela ---
// A janela e um overlay na camada GUI, entao o teste de clique usa o mouse em
// coordenadas de GUI (nao as coordenadas de mundo mouse_x/mouse_y).
if (menu_open) {
    var _gmx = device_mouse_x_to_gui(0);
    var _gmy = device_mouse_y_to_gui(0);

    var _mv = menu_button_rect(0); // Movimentar
    var _pe = menu_button_rect(1); // Pescar

    if (point_in_rectangle(_gmx, _gmy, _mv.x1, _mv.y1, _mv.x2, _mv.y2)) {
        // Movimentar: vai para o quadrante alvo e fecha a janela.
        place_on_tile(menu_target_col, menu_target_row);
    } else if (point_in_rectangle(_gmx, _gmy, _pe.x1, _pe.y1, _pe.x2, _pe.y2)) {
        // Pescar: abre a sessao de cartas (obj_pescaria) como overlay. Ela cuida das
        // duas fases (sorte -> reves) e some sozinha ao terminar. O depth definitivo
        // e ajustado no Create do controlador. Passa o quadrante clicado (alvo da
        // pescaria): e de onde a carta "Propriedades do Mar" brota e de onde ela le
        // os atributos exibidos.
        if (!instance_exists(obj_pescaria)) {
            var _p = instance_create_depth(0, 0, 0, obj_pescaria);
            _p.target_col = menu_target_col;
            _p.target_row = menu_target_row;
        }
    }
    // Qualquer clique (nos botoes ou fora) fecha a janela.
    menu_open = false;
    exit;
}

// --- Janela fechada: descobre o quadrante clicado ---
var _grid = iso_to_grid(mouse_x, mouse_y, board.board_origin_x, board.board_origin_y);
var _col  = _grid.column_index;
var _row  = _grid.row_index;

// Fora dos limites do tabuleiro 4x4: ignora.
if (_col < 0 || _col >= BOARD_COLUMNS || _row < 0 || _row >= BOARD_ROWS) exit;

if (is_yellow_neighbor(_col, _row)) {
    // Quadrante amarelo: abre a janela perguntando Movimentar ou Pescar.
    menu_open       = true;
    menu_target_col = _col;
    menu_target_row = _row;
} else {
    // Qualquer outro quadrante: movimenta direto.
    place_on_tile(_col, _row);
}
