pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/comparators.circom";

template ReLU(n) {
    signal input y[n];
    // signal input sgn[n];
    signal output out[n];
    /*
    signal y[n];

    for(var i = 0; i < n; i++){
        y[i] <== x[i] * (2 * sgn[i] - 1);
    }
    */

    component lessthan[n];
    for(var i = 0; i < n; i++){
        lessthan[i] = LessThan(32);
        lessthan[i].in[0] <== 0;
        lessthan[i].in[1] <== y[i];
        out[i] <== lessthan[i].out * y[i];
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
