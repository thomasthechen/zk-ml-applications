pragma circom 2.0.3;

template Flatten(n, m, k) {
    signal input y[n][m][k];
    // signal intermediate[n * m * k];
    signal output out[n * m * k];

    for(var i = 0; i < n; i++){
        for(var j = 0; j < m; j++){
            for (var l = 0; l < k; l++){
                out[k * m * i + k * j + l] <== y[i][j][l];
            }
        }
    }
}
// component main = Flatten(2,2, 2);

