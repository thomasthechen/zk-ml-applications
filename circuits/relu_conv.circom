pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/comparators.circom";

template ReLU_Conv(n, m, k) {
    signal input y[n][m][k];
    signal output out[n][m][k];
    component lessthan[n][m][k];

    for(var i = 0; i < n; i++){
        for(var j = 0; j < m; j++){
            for(var l = 0; l < k; l++){
                lessthan[i][j][l] = LessThan(32);
                lessthan[i][j][l].in[0] <== 0;
                lessthan[i][j][l].in[1] <== y[i][j][l];
                out[i][j][l] <== lessthan[i][j][l].out * y[i][j][l];
            }
        }
    }

}

/*

template Main(n){
    signal input x[n];
    signal input sgn[n];
    signal y[n];
    signal output out[n];

    for(var i = 0; i < n; i++){
        y[i] <== x[i] * (2 * sgn[i] - 1);
    }
    component relu = ReLU(n);
    for(var i = 0; i < n; i++){
        relu.y[i] <== y[i];
    }
    for(var i = 0; i < n; i++){
        out[i] <== relu.out[i];
    }

    log(out[0]);
    log(out[1]);
    log(out[2]);
}


component main = Main(3);
*/
