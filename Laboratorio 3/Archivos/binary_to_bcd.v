module binary_to_bcd (
    input wire [7:0] binary,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] unit
);

always @(*) begin
    hundreds = binary / 100;
    tens = (binary % 100) / 10;
    unit = binary % 10;
end

endmodule
