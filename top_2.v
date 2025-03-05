`include "./uart_tx_8n1.v"

module top(
    input clk,          // Reloj del sistema
    input sensor1,      // Entrada del sensor 1
    input sensor2,      // Entrada del sensor 2
    output reg led,     // Salida para el LED
    output reg buzzer,  // Salida para el buzzer
    output reg [6:0] seg7, // Salida 7 segmentos (a-g)
    output tx_pin,      // Salida UART
    output reg busy     // Indica si el UART está ocupado
);

// Definición de estados
parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;

// Registros de estado
reg [1:0] current_state = S0;
reg [1:0] next_state;

// Temporizador
parameter TIMER_LIMIT = 50_000_000;
reg [31:0] timer = 0;

// Codificación 7 segmentos
parameter SEG_0 = 7'b0000001;
parameter SEG_1 = 7'b1001111;

// Registro para UART
reg [7:0] byte2send;
reg tx_start;
wire tx_done;
reg [1:0] uart_step = 0;

// Instancia del módulo UART
uart_tx_8n1 uart_tx (
    .clk(clk),
    .txbyte(byte2send),
    .senddata(tx_start),
    .txdone(tx_done),
    .tx(tx_pin)
);

// Lógica de secuencia
always @(posedge clk) begin
    current_state <= next_state;
    
    if(current_state == S1) begin
        timer <= (timer < TIMER_LIMIT) ? timer + 1 : 0;
    end else begin
        timer <= 0;
    end
end

// Lógica de transición de estados
always @(*) begin
    case(current_state)
        S0: next_state = (sensor1 && sensor2) ? S1 : S0;
        S1: next_state = (timer >= TIMER_LIMIT) ? S2 : S1;
        S2: next_state = (sensor1 && sensor2) ? S1 : S0;
        default: next_state = S0;
    endcase
end

// Lógica de salida
always @(posedge clk) begin
    case(current_state)
        S0: {led, buzzer, seg7} <= {1'b0, 1'b0, SEG_0};
        S1: {led, buzzer, seg7} <= {1'b1, 1'b1, SEG_1};
        S2: {led, buzzer, seg7} <= {1'b0, 1'b0, SEG_0};
        default: {led, buzzer, seg7} <= {1'b0, 1'b0, SEG_0};
    endcase
end


always @(posedge clk) begin
    if (sensor1 && sensor2 && !busy) begin
        if (tx_done) begin
            case (uart_step)
                0: begin
                    byte2send <= "a";
                    tx_start <= 1;
                    uart_step <= 1;
                end
                1: begin
                    byte2send <= {7'b0000000, led};
                    tx_start <= 1;
                    uart_step <= 2;
                end
                2: begin
                    byte2send <= "b";
                    tx_start <= 1;
                    uart_step <= 3;
                end
                3: begin
                    byte2send <= {7'b0000000, buzzer};
                    tx_start <= 1;
                    uart_step <= 4;
                end
                4: begin
                    byte2send <= "c";
                    tx_start <= 1;
                    uart_step <= 5;
                end
                5: begin
                    byte2send <= seg7;
                    tx_start <= 1;
                    uart_step <= 0;
                    busy <= 1;
                end
            endcase
        end else begin
            tx_start <= 0;
        end
    end
    
    if (tx_done && uart_step == 0) begin
        busy <= 0; 
    end
end

endmodule

