# PROYECTO

- Brigitte Vanessa Quiñonez Capera
- Juan Sebastián Otálora Quiroga
- Carlos Fernando Quintero Castillo

## Introducción

Este proyecto implementa un sistema de monitoreo en una FPGA, utilizando un sensor de vibración y un sensor de movimiento para detectar anomalías en entornos industriales o de seguridad. La FPGA procesará las señales en tiempo real, permitiendo una respuesta rápida ante eventos críticos. La comunicación con un PC mediante UART facilitará la visualización y el análisis de los datos recopilados, optimizando la eficiencia y confiabilidad del sistema.

## Dominio comportamental (especificación y algoritmo)

El dominio comportamental de este sistema se centra en la detección y alerta de eventos mediante la combinación de sensores de vibración y movimiento. Cada sensor actúa como una entrada digital a la FPGA, activándose cuando se detecta una vibración o un movimiento significativo. Si cualquiera de los sensores se activa de manera individual, el sistema registra el evento, pero si ambos sensores se activan simultáneamente, se genera una respuesta combinada. En este caso, el sistema activa una salida sonora, como una alarma, y visualiza un código de advertencia en un display de 7 segmentos. Esta lógica garantiza una respuesta rápida y efectiva ante posibles situaciones anómalas, proporcionando un sistema de monitoreo confiable y en tiempo real.

### Procesamiento en la FPGA:

El sistema recibe como entradas las señales provenientes de un sensor de vibración y un sensor de movimiento, los cuales generan niveles lógicos según la detección de eventos. Estas señales son procesadas por una máquina de estados implementada en la FPGA, que evalúa las condiciones de activación de los sensores y determina el estado del sistema. Dependiendo de la combinación de entradas, la máquina de estados activa las salidas correspondientes, como una alerta sonora y una visualización en un display de 7 segmentos cuando ambos sensores están activos simultáneamente.

Para facilitar el monitoreo remoto, los estados de salida del sistema se serializan y se transmiten a través del puerto UART integrado en la FPGA. Esta información puede ser recibida y visualizada en una consola de PC, permitiendo un análisis en tiempo real de los eventos detectados. De este modo, el sistema no solo ofrece una respuesta inmediata a través de sus salidas físicas, sino que también proporciona un medio de supervisión y registro de datos para su análisis posterior.

### Caja negra




#### Entradas

Al dispositivo ingresan las señales del sensor de vibracion y del sensor de movimiento, estos envian un pulso al momento de recibir estimulacion externa y se conectan directamente a la FPGA sin algun adaptador extra.

#### Salidas

Consisten en una salida sonora de alerta, ademas de un aviso en panel 7 segmentosa de manra que alertara en informara al usuario de movimientos en el entorno.

### Tabla de verdad 


## Dominio físico:

El dominio físico del dispositivo está compuesto por una FPGA Cyclone IV, encargada de gestionar las señales de entrada y controlar las salidas. Los sensores de vibración y movimiento están conectados directamente a la FPGA a través de pines GPIO, funcionando con niveles lógicos compatibles. Las salidas incluyen un buzzer para la alerta sonora y un display de 7 segmentos para la visualización de estados, ambos controlados mediante señales digitales generadas por la FPGA.

Dado que se trata de un primer prototipo con una construcción tosca, el sistema está montado sobre una placa de pruebas (protoboard) o un PCB básico con cableado expuesto, sin una carcasa protectora ni optimización en la disposición de los componentes. La comunicación con la consola del PC se realiza a través del puerto UART, utilizando un convertidor USB-UART para la transmisión de datos. Este diseño inicial permite validar el funcionamiento lógico del sistema antes de una futura optimización en términos de tamaño, consumo y robustez.

## Dominio estructural (red de compuertas lógicas)

![caja_negra](Imagenes/caja_negra.png)


### Diagramas, tablas de verdad, simulaciones, mapas de Karnaugh, compuertas universales, LUT y suma de productos.



##  Descripción en lenguaje HDL (Hardware Description Language)


### Asignación de pines

## Síntesis en FPGA (dominio físico final)

## Video de FPGA 

Puedes ver el video de la implementación de la FPGA [aquí](https://www.youtube.com/watch?v=xz67W84lecs)
