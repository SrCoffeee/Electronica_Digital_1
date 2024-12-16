
module top  (
  input Ei,
  input A,
  input B,
  input C,
  output CM,
  output M
);
  assign CM = (~ B & C);
  assign M = ((A & ~ Ei) | (B & ~ Ei) | (C & ~ Ei));
endmodule
