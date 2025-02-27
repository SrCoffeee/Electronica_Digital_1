# Voltimetro
- Brigitte Vanessa Quiñonez Capera
- Juan Sebastián Otálora Quiroga
- Carlos Fernando Quintero Castillo

## Introducción

En esta práctica se desarrollará un voltímetro basado en FPGA, utilizando un circuito de rectificación y un transformador de 120V a 6V (RMS) para la conversión de tensión. Además, se empleará el conversor analógico-digital ADC0808 para digitalizar la señal y permitir su procesamiento dentro de la FPGA. Los valores medidos serán visualizados en un display de 7 segmentos, permitiendo una lectura clara del voltaje.

El objetivo de la práctica es diseñar un sistema de medición de voltaje que integre distintos componentes electrónicos para la adquisición, procesamiento y visualización de datos. Para ello, se acondicionará la señal proveniente de la red eléctrica mediante un transformador y un circuito rectificador, seguido de la conversión digital con el ADC0808. Posteriormente, la FPGA interpretará los datos y controlará el display de 7 segmentos para mostrar el voltaje medido en tiempo real.

A través de esta práctica, se analizará el funcionamiento de cada uno de los componentes involucrados y se explorará la integración de hardware y software en sistemas de medición con dispositivos programables, enfatizando la conversión y visualización de señales analógicas en formato digital.

## Dominio comportamental (especificación y algoritmo)

Se sabe que la tensión RMS que se emite en Colombia es de 120V, la cual al realizar la conversión a valor pico, nos entrega un valor de aproximada mente 170 Vp. De manera pŕactica se tiene que la tensión que debe entrar hacia el ADC es de 5V si tomamos en cuenta el máximo valor de registro de tensión pico, que serían 255, por ende es necesario realizar una equivalencia para saber qué tensión debe ir hacia el ADC teniendo en cuenta que la tensión a la que nos manejamos es de 170Vp y no 255, por lo que se debe implementar un circuito de acople el cual reciba la tensión del tranformador, la rectifique y por medio de un divisor de tensión realizado con un trimmer, obtener la tensión de entrada hacia el ADC. Además, para evitar daños por malas conexiones y/o cortocircuitos provocados por el error humano, se tendrá un diodo zenner de 5.1V para regular la tensión de salida en caso de fallas.
### Circuito de acople
![circuito_acople](Imagenes/circuito_acople.png)
#### Reducción de voltaje:
En primer lugar, se tiene que el transformador nos suministra un valor 6.2V RMS (una relación de transformación de 19.4 aproximadamente), lo que en valor pico sería aprximadamente **8.77Vp**.

#### Rectificación y acondicionamiento de señal:
Al pasar por el circuito rectificador, realizado por el dispositvo W04m, el cual es un puente rectificador y una vez realizado el filtro y suavizado de la señal gracias al condensador, se tiene que la tensión saliente es de aproximadamente 7.3V.

#### Equivalencia de tensión de salida
Se tiene que la referencia de tensión que maneja el ADC es de 5V, lo que se traduce que a dicha entrada mostraria 255Vp, lo cual no es lo que queremos, por ende realizamos un equivalencia de tensión junto con un divisor, para establecer la tensión que necesitamos. Realizando una regla de 3, se establece que la tensión que necesitamos es de 3.33V para una tensión de entrada de 170Vp, sabiendo que la tensión que tenemos hasta el momento es de **7.3V**, es necesario realizar un divisor de tensión, en donde tendremos en cuenta que el trimmer es de 100K ohmios por ende la suma de las resistencia es de 100K y que la tensión que cae entre R1 y tierra es de 7.3V, obteniendo lo siguiente:

$$V_{sal}=\frac{V*R2}{R1 + R2}$$

En donde que la resistencia R2 que es donde caen los 3.33V debe ser **45.62K ohmios**, la cual se ajusta en el trimmer.


### Conversión analógico-digital (ADC0808):
![datasheet_adc0808](Imagenes/datasheet_adc0808.png)
Para conversión en el ADC, lo que se realiza en primer lugar es seleccionar la entrada que vamos a usar por medio del multiplexor con los selectores ADD, los cuales ponemos a tierra asegurando que la entrada a usar va a ser la 0 a la cual van a ingresar los **3.33V** que obtuvimos anteriormente. Posteriormente fijamos nuestro valor de referencia en el ADC a 5V y lo alimentamos a la misma tensión. Luego ponemos en retroalimentación las salidas START y EOC, la cuales serán las encargadas de iniciar y finalizar el proceso de conversión y la ponemos de esta forma para sincronizar dicho proceso y asegurar que las muestras de datos se tomen y procesen en el momento adecuado. En cuanto a las salidas ALE y OE, las ponemos a 5V para asegurar que la lectura constante de información de las entradas analógicas y la que las salidas digitales del ADC esten activas y puedan leer la conversión realizada. Por último enviamos las salidas digitales del ADC hacia la FPGA para procesamiento de datos y poder desplegar la información en los 3 módulos 7 segmentos, los cuales mostraran la información en **centenas, decenas y unidades**.

#### Entradas

Para el dispositivo, se recibira la señal directamente del tomacorriente , donde se recivira la onda AC.

#### Salidas

Se tendran tres salidas, 3 paneles 7 segmentos en los cuales se mostrara las unidades, decenas y centenas del la magnitud de la red.
## Dominio estructural (red de compuertas lógicas)

### Esquema de montaje RTL

![esquema](Imagenes/rtl.png)

### Divisor de frecuencia 
Se realiza un divisor de frecuencia, con el objetivo e relacionar el clock de la FPGA que es de 50 MHz con uno a la que el ADC0808 pudiese funcionar, en este caso se estableció de 10KHz, para este divisor se implementó el siguiente módulo.

```
module clk_divider #(
     parameter integer FREQ_IN = 50000000,
    parameter integer FREQ_OUT = 10000,
    parameter integer INIT = 0
) (
    // Inputs and output ports
    input CLK_IN,
    output reg CLK_OUT = 0
);

  localparam integer COUNT = (FREQ_IN / FREQ_OUT) / 2;
  localparam integer SIZE = $clog2(COUNT);
  localparam integer LIMIT = COUNT - 1;

  // Declaración de señales [reg, wire]
  reg [SIZE-1:0] count = INIT;

  // Descripción del comportamiento
  always @(posedge CLK_IN) begin
    if (count == LIMIT) begin
      count   <= 0;
      CLK_OUT <= ~CLK_OUT;
    end else begin
      count <= count + 1;
    end
  end
endmodule

```


### Conversión binario a BCD

Para ello, implementamos el siguiente módulo en la FPGA, el cual vemos cómo hacemos la equivalencia para centenas, decenas y unidades. Este módulo será el encargado de recibir el número binario a mostrar en el 7 segmentos y lo pone en las unidades correspondientes.

```

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

```

### Visualización de 7 segmentos
Para ello en primer lugar se le asignan las letras que conformanlos 7 segmentos de la FPGA. Posteriormente se la asigna cada número hallado por el módulo *binary_to_bcd* y registra la salida del número al módulo 7 segmentos. Aquí también se le asigna los 3 ánodos correspondientes a centenas, decenas y unidades en los que se mostrará la información.

```
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

```

### Módulo top.v

Este módulo encapsula la información de los otros módulos, asociando las entradas y salidas con los pines digitales.

```
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

```
### Asignación de pines
```
##  CONFIGURACIÓN DE PROYECTO agregar en el archivo top.qsf ##

set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE10E22C8
set_global_assignment -name TOP_LEVEL_ENTITY top
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY build

# def clk
set_location_assignment PIN_23 -to clk

# Datos del ADC
set_location_assignment PIN_28 -to adc_data[0]
set_location_assignment PIN_30 -to adc_data[1]
set_location_assignment PIN_31 -to adc_data[2]
set_location_assignment PIN_32 -to adc_data[3]
set_location_assignment PIN_33 -to adc_data[4]
set_location_assignment PIN_34 -to adc_data[5]
set_location_assignment PIN_38 -to adc_data[6]
set_location_assignment PIN_39 -to adc_data[7]

# Señales de control

set_location_assignment PIN_52 -to adc_clk

# Asignaciones para los segmentos (a-g)
set_location_assignment PIN_127 -to segmentos[0]  # Segmento a
set_location_assignment PIN_126 -to segmentos[1]  # Segmento b
set_location_assignment PIN_125 -to segmentos[2]  # Segmento c
set_location_assignment PIN_124 -to segmentos[3]  # Segmento d
set_location_assignment PIN_121 -to segmentos[4]  # Segmento e
set_location_assignment PIN_120 -to segmentos[5]  # Segmento f
set_location_assignment PIN_119 -to segmentos[6]  # Segmento g

# Asignaciones para los ánodos (3 displays)
set_location_assignment PIN_128 -to anodos[0]     # Ánodo 1 (Display 1)
set_location_assignment PIN_129 -to anodos[1]     # Ánodo 2 (Display 2)
set_location_assignment PIN_132 -to anodos[2]     # Ánodo 3 (Display 3)




set_global_assignment -name LAST_QUARTUS_VERSION "23.1std.1 Lite Edition"

```
## Dominio físico inicial (circuito eléctrico):



### Video de implementación y montaje físico



Puedes ver el video de la implementación [aquí]()
