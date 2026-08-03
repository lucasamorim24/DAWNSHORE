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
