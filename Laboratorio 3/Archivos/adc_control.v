module adc_control (
    input wire clk,
    input wire reset_n,
    input wire eoc,
    output reg start,
    output reg oe
    // Se eliminó "output reg [2:0] channel_sel"
);

// Estados definidos con parámetros
localparam [1:0] 
    IDLE      = 2'b00,
    START_CONV = 2'b01,
    WAIT_EOC   = 2'b10,
    READ_DATA  = 2'b11;

reg [1:0] state;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state <= IDLE;
        start <= 0;
        oe <= 0;
        // Se eliminó "channel_sel <= 3'b000"
    end else begin
        case (state)
            IDLE: begin
                start <= 1;
                state <= START_CONV;
            end
            
            START_CONV: begin
                start <= 0;
                state <= WAIT_EOC;
            end
            
            WAIT_EOC: begin
                if (eoc) begin
                    oe <= 1;
                    state <= READ_DATA;
                end
            end
            
            READ_DATA: begin
                oe <= 0;
                state <= IDLE;
            end
        endcase
    end
end

endmodule
