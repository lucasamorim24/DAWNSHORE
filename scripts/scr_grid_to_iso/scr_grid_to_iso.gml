/// scr_grid_to_iso
/// Converte uma posicao de grade (column_index, row_index) em coordenadas de
/// tela isometricas. Cole este conteudo em um Script chamado "scr_grid_to_iso".
///
/// @param {real} _column_index  indice da coluna (0 = A, 1 = B, 2 = C, 3 = D)
/// @param {real} _row_index     indice da linha (0 = linha 1, 1 = linha 2, ...)
/// @param {real} _origin_x      x de origem do tabuleiro na tela (topo do quadrante A1)
/// @param {real} _origin_y      y de origem do tabuleiro na tela (topo do quadrante A1)
/// @returns {struct}            { x, y } - vertice superior do losango do quadrante

function grid_to_iso(_column_index, _row_index, _origin_x, _origin_y) {
    var _iso_x = _origin_x + (_column_index - _row_index) * (TILE_WIDTH  / 2);
    var _iso_y = _origin_y + (_column_index + _row_index) * (TILE_HEIGHT / 2);

    return {
        x: _iso_x,
        y: _iso_y
    };
}

/// iso_to_grid
/// Inverso de grid_to_iso: converte uma coordenada de tela (ex: mouse) no
/// (column_index, row_index) do quadrante isometrico sob aquele ponto.
///
/// @param {real} _screen_x   x na tela (ex: mouse_x)
/// @param {real} _screen_y   y na tela (ex: mouse_y)
/// @param {real} _origin_x   mesma origem usada em grid_to_iso (topo do quadrante A1)
/// @param {real} _origin_y   mesma origem usada em grid_to_iso (topo do quadrante A1)
/// @returns {struct}         { column_index, row_index } - pode cair fora do tabuleiro

function iso_to_grid(_screen_x, _screen_y, _origin_x, _origin_y) {
    // grid_to_iso devolve o vertice de topo do losango; o centro fica meia
    // altura de tile abaixo. Trabalhamos a partir do centro para inverter.
    var _center_origin_y = _origin_y + TILE_HEIGHT / 2;

    var _u = (_screen_x - _origin_x)        / (TILE_WIDTH  / 2); // = column - row
    var _v = (_screen_y - _center_origin_y) / (TILE_HEIGHT / 2); // = column + row

    return {
        column_index: round((_u + _v) / 2),
        row_index:    round((_v - _u) / 2)
    };
}
