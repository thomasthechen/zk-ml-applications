pragma circom 2.0.5;
include "./linear.circom";
include "./relu.circom";

template two_layer_mlp (dim_in, dim_mid, dim_out) {
    // FC, RELU, FC, RELU, ...
    component l1 = Linear(dim_in, dim_mid);
    component relu = ReLU(dim_mid);
    component l2 = Linear(dim_mid, dim_out);

    signal input w1[dim_mid][dim_in];
    signal input b1[dim_mid];

    signal input w2[dim_out][dim_mid];
    signal input b2[dim_out];

    signal input in[dim_in];
    signal z1[dim_mid];
    signal a1[dim_mid];
    signal output out[dim_out];

    signal input exp_output[dim_out]; // for testing 

    // l1
    for (var i = 0; i < dim_mid; i++) {
        for (var j = 0; j < dim_in; j++) {
            l1.weights[i][j] <== w1[i][j];
        }
    }

    for (var i = 0; i < dim_mid; i++) {
        l1.bias[i] <== b1[i];
    }

    // l2
    for (var i = 0; i < dim_out; i++) {
        for (var j = 0; j < dim_mid; j++) {
            l2.weights[i][j] <== w2[i][j];
        }
    }

    for (var i = 0; i < dim_out; i++) {
        l2.bias[i] <== b2[i];
    }

    // input
    for (var i = 0; i < dim_in; i++) {
        l1.inputs[i] <== in[i];
    }

    // first linear layer + load relu
    for (var i = 0; i < dim_mid; i++) {
        z1[i] <== l1.outs[i];
        relu.y[i] <== z1[i];
    }

    // relu + load 2nd linear layer
    for (var i = 0; i < dim_mid; i++) {
        a1[i] <== relu.out[i];
        l2.inputs[i] <== a1[i];
    }

    // output
    for (var i = 0; i < dim_out; i++) {
        out[i] <== l2.outs[i];
        out[i] === exp_output[i];
    }

}

component main = two_layer_mlp(5, 3, 1);