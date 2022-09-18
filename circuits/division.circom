pragma circom 2.0.3;

include "../node_modules/circomlib/circuits/sign.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

// NB: RangeProof is inclusive.
// input: field element, whose abs is claimed to be <= than max_abs_value
// output: none
// also checks that both max and abs(in) are expressible in `bits` bits
template RangeProof(bits) {
    signal input in; 
    signal input max_abs_value;

    /* check that both max and abs(in) are expressible in `bits` bits  */
    component n2b1 = Num2Bits(bits+1);
    n2b1.in <== in + (1 << bits);
    component n2b2 = Num2Bits(bits);
    n2b2.in <== max_abs_value;

    /* check that in + max is between 0 and 2*max */
    component lowerBound = LessThan(bits+1);
    component upperBound = LessThan(bits+1);

    lowerBound.in[0] <== max_abs_value + in; 
    lowerBound.in[1] <== 0;
    lowerBound.out === 0;

    upperBound.in[0] <== 2 * max_abs_value;
    upperBound.in[1] <== max_abs_value + in; 
    upperBound.out === 0;
}


// input: any field elements
// output: 1 if field element is in (p/2, p-1], 0 otherwise
template IsNegative() {
    signal input in;
    signal output out;

    component num2Bits = Num2Bits(254);
    num2Bits.in <== in;
    component sign = Sign();
    
    for (var i = 0; i < 254; i++) {
        sign.in[i] <== num2Bits.out[i];
    }

    out <== sign.sign;
}

template Division(divisor) {
  signal input dividend; 
  signal output quotient;

  component is_neg = IsNegative();
  is_neg.in <== dividend;

  signal is_dividend_negative;
  is_dividend_negative <== is_neg.out;

  signal dividend_adjustment;
  dividend_adjustment <== 1 + is_dividend_negative * -2; // 1 or -1

  signal abs_dividend;
  signal abs_quotient;
  abs_dividend <== dividend * dividend_adjustment; // 8
  abs_quotient <-- abs_dividend \ divisor;

  signal abs_product;
  abs_product <== abs_quotient * divisor;

  component quotientUpper = LessEqThan(16);
  quotientUpper.in[0] <== abs_product;
  quotientUpper.in[1] <== abs_dividend;
  quotientUpper.out === 1;

  component quotientLower = LessThan(16);
  quotientLower.in[0] <== abs_dividend - divisor;
  quotientLower.in[1] <== abs_product;
  quotientLower.out === 1;

  component quotientCheck = LessThan(16);
  quotientCheck.in[0] <== abs_quotient;
  quotientCheck.in[1] <== abs_dividend;
  quotientCheck.out === 1;

  quotient <== abs_quotient * dividend_adjustment;

  component checkRange = RangeProof(16);
  checkRange.in <== abs_dividend;
  checkRange.max_abs_value <== 16384;
}  

template DivisionArray(divisor, dim) {
  component divisions[dim];
  signal input inputs[dim];
  signal output outs[dim];

  for(var i = 0; i < dim; i++){
    divisions[i] = Division(divisor);
    divisions[i].dividend <== inputs[i];
    outs[i] <== divisions[i].quotient;
  }
}

component main = DivisionArray(3, 3);