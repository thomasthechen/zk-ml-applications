pragma circom 2.0.3;
//include "./add_arrays.circom"


template CrossCorrelation(H, W){
    signal input v1[H][W];
    signal input v2[H][W];
    signal prod[H][W];
    for(var i = 0; i < H; i++){
        for(var j = 0; j < W; j++){
            prod[i][j] <== v1[i][j] * v2[i][j];
        }
    }
    signal cummulative[H * W];
    
    for(var i = 0; i < H; i++){
        for(var j = 0; j < W; j++){
            var index = i * W + j;
            cummulative[index] <== index == 0? v1[i][j] * v2[i][j] : v1[i][j] * v2[i][j] + cummulative[index - 1];
        }
    }
    signal output out <== cummulative[H * W - 1];
}



template CrossCorrelationChannels(H, W, IN_CHANNEL){
    signal input image_slice[IN_CHANNEL][H][W];
    signal input kernel_slice[IN_CHANNEL][H][W];
    signal input bias;
    signal cummulative[IN_CHANNEL];
    component cross_correlators[IN_CHANNEL];
    //feed stuff to cross correlation components
    for (var t = 0; t < IN_CHANNEL; t++){
        cross_correlators[t] = CrossCorrelation(H, W);
        for (var i = 0; i < H; i++){
            for(var j = 0; j < W; j++){
                cross_correlators[t].v1[i][j] <== image_slice[t][i][j];
                cross_correlators[t].v2[i][j] <== kernel_slice[t][i][j];
            }
        }
    }
    //add up correlation outputs
    cummulative[0] <== cross_correlators[0].out;
    for(var i = 1; i < IN_CHANNEL; i++){
        cummulative[i] <== cross_correlators[i].out + cummulative[i - 1];
    }
    signal output out <== cummulative[IN_CHANNEL - 1] + bias;
}


template Conv2d(OUT_CHANNELS, IN_CHANNEL, KERNEL_H, KERNEL_W, STRIDE, IMAGE_H, IMAGE_W, OUT_H, OUT_W){
    assert(OUT_H == ((IMAGE_H - KERNEL_H + 1) \ STRIDE));
    assert(OUT_W == ((IMAGE_W - KERNEL_W + 1) \ STRIDE));
    signal input image[IN_CHANNEL][IMAGE_H][IMAGE_W];
    signal input kernel[IN_CHANNEL][OUT_CHANNELS][KERNEL_H][KERNEL_W];
    signal input bias[OUT_CHANNELS];
    signal output out[OUT_CHANNELS][OUT_H][OUT_W];
    component entry_computers[OUT_CHANNELS][OUT_H][OUT_W];
    for(var out_c = 0; out_c < OUT_CHANNELS; out_c++){
        for(var i = 0; i < OUT_H; i++){
            for(var j = 0; j < OUT_W; j++){
                entry_computers[out_c][i][j] = CrossCorrelationChannels(KERNEL_H, KERNEL_W, IN_CHANNEL);
            }
        }
    }
    for(var out_c = 0; out_c < OUT_CHANNELS; out_c++){
        for(var i = 0; i < OUT_H; i+= 1){
            for(var j = 0; j < OUT_W; j+=1){
                //fill the inputs of an entry computer
                entry_computers[out_c][i][j].bias <== bias[out_c];
                for(var in_c = 0; in_c < IN_CHANNEL; in_c++){
                    for (var h = 0; h < KERNEL_H; h++){
                        for(var w = 0; w < KERNEL_W; w++){
                            entry_computers[out_c][i][j].image_slice[in_c][h][w] <== image[in_c][h + i * STRIDE][w + j * STRIDE];
                            entry_computers[out_c][i][j].kernel_slice[in_c][h][w] <== kernel[in_c][out_c][h][w];
                        }
                    }
                }
                out[out_c][i][j] <== entry_computers[out_c][i][j].out;
                /*
                log("entry");
                log(i);
                log(j);
                log(out_c);
                log(out[out_c][i][j]);
                */
            }
        }
    }
}
// component main = Conv2d(2, 3, 2, 2, 1, 3, 3, 2 ,2);

/*

*/

