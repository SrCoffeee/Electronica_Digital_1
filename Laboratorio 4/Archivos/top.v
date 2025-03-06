module top(
    input clk,          // Reloj del sistema
    input sensor1,      // Entrada del sensor 1
    input sensor2,      // Entrada del sensor 2
    output reg led,     // Salida para el LED
    output reg buzzer,  // Salida para el buzzer
    output reg [6:0] seg7 // Salida 7 segmentos (a-g)
);

// Definición de estados
parameter S0 = 2'b00;
parameter S1 = 2'b01;
parameter S2 = 2'b10;

// Registros de estado con inicialización
reg [1:0] current_state = S0;  // Inicializado en S0
reg [1:0] next_state;

// Temporizador con inicialización
parameter TIMER_LIMIT = 50_000_000;
reg [31:0] timer = 0;          // Inicializado en 0

// Codificación 7 segmentos
parameter SEG_0 = 7'b0000001;
parameter SEG_1 = 7'b1001111;

// Lógica de secuencia (sin reset)
always @(posedge clk) begin
    current_state <= next_state;
    
    // Control del temporizador
    if(current_state == S1) begin
        timer <= (timer < TIMER_LIMIT) ? timer + 1 : 0;
    end else begin
        timer <= 0;
    end
end

// Lógica de transición de estados (sin cambios)
always @(*) begin
    case(current_state)
        S0: next_state = (sensor1 && sensor2) ? S1 : S0;
        S1: next_state = (timer >= TIMER_LIMIT) ? S2 : S1;
        S2: next_state = (sensor1 && sensor2) ? S1 : S0;
        default: next_state = S0;
    endcase
end

// Lógica de salida (sin cambios)
always @(*) begin
    case(current_state)
        S0: {led, buzzer, seg7} = {1'b0, 1'b1, SEG_0};
        S1: {led, buzzer, seg7} = {1'b1, 1'b0, SEG_1};
        S2: {led, buzzer, seg7} = {1'b0, 1'b1, SEG_0};
        default: {led, buzzer, seg7} = {1'b0, 1'b1, SEG_0};
    endcase
end

endmodule
