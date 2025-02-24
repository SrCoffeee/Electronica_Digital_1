module seven_segment_driver (
    input wire clk,
    input wire reset_n,
    input wire [3:0] digit0,
    input wire [3:0] digit1,
    input wire [3:0] digit2,
    output reg [6:0] segmentos,
    output reg [2:0] anodos
);

reg [1:0] contador;
reg [15:0] prescaler;
reg [3:0] digito_actual;

always @(*) begin
    case (digito_actual)
        4'h0: segmentos = 7'b1000000;
        4'h1: segmentos = 7'b1111001;
        4'h2: segmentos = 7'b0100100;
        4'h3: segmentos = 7'b0110000;
        4'h4: segmentos = 7'b0011001;
        4'h5: segmentos = 7'b0010010;
        4'h6: segmentos = 7'b0000010;
        4'h7: segmentos = 7'b1111000;
        4'h8: segmentos = 7'b0000000;
        4'h9: segmentos = 7'b0010000;
        default: segmentos = 7'b1111111;
    endcase
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        prescaler <= 0;
        contador <= 0;
        anodos <= 3'b111;
    end else begin
        if (prescaler == 16'd50000) begin
            prescaler <= 0;
            case (contador)
                2'b00: begin
                    digito_actual <= digit0;
                    anodos <= 3'b110;
                end
                2'b01: begin
                    digito_actual <= digit1;
                    anodos <= 3'b101;
                end
                2'b10: begin
                    digito_actual <= digit2;
                    anodos <= 3'b011;
                end
            endcase
            contador <= contador + 1;
        end else begin
            prescaler <= prescaler + 1;
        end
    end
end

endmodule
