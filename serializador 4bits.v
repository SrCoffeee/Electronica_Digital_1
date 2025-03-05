module serializer_4bit (
    input wire clk,         // Reloj
    input wire rst,        
    input wire [3:0] din,   
    input wire load,        // Señal para cargar la entrada en el registro
    output reg dout         
);

    reg [3:0] shift_reg; // Registro de desplazamiento
    reg [1:0] bit_count; // Contador de bits

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 4'b0000;
            bit_count <= 2'b00;
            dout <= 1'b0;
        end else begin
            if (load) begin
                shift_reg <= din; 
                bit_count <= 2'b00;
            end else begin
                dout <= shift_reg[0]; // Enviar el bit menos significativo
                shift_reg <= shift_reg >> 1; // Desplazar bits a la derecha
                bit_count <= bit_count + 1;
            end
        end
    end
endmodule