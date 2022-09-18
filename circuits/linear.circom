pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/switcher.circom";

template Linear(dim_in, dim_out) {
    signal input inputs[dim_in];
    signal input weights[dim_out][dim_in];
    signal input bias[dim_out];
    signal output outs[dim_out];
    signal sum[dim_out][dim_in];

    for(var i = 0; i < dim_out; i++) {
        sum[i][0] <==  inputs[0] * weights[i][0];
        for (var j = 1; j < dim_in; j++){
            sum[i][j] <== sum[i][j-1] + weights[i][j] * inputs[j];
        }
        outs[i] <== sum[i][dim_in-1] + bias[i];
    }
}

template ArgMax (n) {
    signal input in[n];
    signal output out;
    component gts[n];        // store comparators
    component switchers[n+1];  // switcher for comparing maxs
    component aswitchers[n+1]; // switcher for arg max

    signal maxs[n+1];
    signal amaxs[n+1];

    maxs[0] <== in[0];
    amaxs[0] <== 0;
    for(var i = 0; i < n; i++) {
        gts[i] = GreaterThan(30);
        switchers[i+1] = Switcher();
        aswitchers[i+1] = Switcher();

        gts[i].in[1] <== maxs[i];
        gts[i].in[0] <== in[i];

        switchers[i+1].sel <== gts[i].out;
        switchers[i+1].L <== maxs[i];
        switchers[i+1].R <== in[i];

        aswitchers[i+1].sel <== gts[i].out;
        aswitchers[i+1].L <== amaxs[i];
        aswitchers[i+1].R <== i;
        amaxs[i+1] <== aswitchers[i+1].outL;
        maxs[i+1] <== switchers[i+1].outL;
    }

    out <== amaxs[n];
}



// component main = Linear(3, 3);