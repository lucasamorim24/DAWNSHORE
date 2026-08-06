/// obj_board - Create Event
/// Cole este conteudo no evento Create de um objeto chamado "obj_board".
/// Requer os scripts scr_board_config e scr_grid_to_iso no projeto.

// Origem do tabuleiro na tela (vertice superior do quadrante A1)
board_origin_x = room_width / 2;
board_origin_y = 120;

// Quadrante atualmente sob o cursor do mouse (-1 = nenhum / fora do tabuleiro).
// Recalculado a cada Draw e lido tambem pelo obj_player para saber quando ficar
// translucido.
hovered_column = -1;
hovered_row    = -1;

// Letras das colunas, secao 2: "colunas = letras, linhas = numeros" (estilo batalha naval)
column_letters = ["A", "B", "C", "D"];

// Matriz [row_index][column_index] com os dados de cada um dos 16 quadrantes
quadrantes = array_create(BOARD_ROWS);

for (var _row_index = 0; _row_index < BOARD_ROWS; _row_index++) {
    quadrantes[_row_index] = array_create(BOARD_COLUMNS);

    for (var _column_index = 0; _column_index < BOARD_COLUMNS; _column_index++) {
        var _iso_position = grid_to_iso(_column_index, _row_index, board_origin_x, board_origin_y);

        var _quadrante = {
            column_index: _column_index,
            row_index:    _row_index,
            label:        column_letters[_column_index] + string(_row_index + 1), // ex: "A1", "D4"
            iso_x:        _iso_position.x,
            iso_y:        _iso_position.y,

            // Propriedades do quadrante (secao 2 e 6). Ficam zeradas por enquanto -
            // a re-randomizacao via Mare (secao 6) e quem vai popular esses valores
            // dentro dos intervalos pre-estabelecidos. Isso entra numa proxima etapa.
            esforco:      0,
            resistencia:  0,
            visibilidade: 0
        };

        quadrantes[_row_index][_column_index] = _quadrante;
    }
}
