pragma circom 2.0.3;

template AddArrays(X, Y, Z){
    signal input A[X][Y][Z];
    signal input B[X][Y][Z];
    signal output C[X][Y][Z];
    for(var i = 0; i < X; i++){
        for(var j = 0; j < Y; j++){
            for(var k = 0; k < Z; k++){
                C[i][j][k] <== A[i][j][k] + B[i][j][k];
            }
        }
    }
}

component main = AddArrays(1, 1, 2);
