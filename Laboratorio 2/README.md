# Mi primer diseño
- Brigitte Vanessa Quiñonez Capera
- Juan Sebastián Otálora Quiroga
- Carlos Fernando Quintero Castillo
---
Para este laboratorio, se tuvo el reto de a partir de un problema, diseñar un sistema de control que permitiera el uso de eficiente de energía eléctrica en una residencia a partir de unos requerimientos funcionales en la misma. En este se aplicaron técnicas de identificación de situaciones posibles desde lo simbólico hasta su abstracción a electrónica digital, aplicando conceptos cómo cajas negras, mapas de Karnaugth, compuertas lógicas y diagramas esquemáticos.

## Caja negra

Después de realizar una valoración del problema, se obtuvo el siguiente resultado de entradas y salidas del sistema.

![caja_negra](Imagenes\caja_negra.png)

Donde las variables en verde son las entradas y las en rojo son las salidas, las cuales representan lo siguiente:

#### Entradas
- A → Sensor de luz
- B → Sensor de carga de batería (_Indica si está cargada la batería)_
- C → Sensor de red elétrica (_Indica la presencia de red elécrica_) 
- P → Paro de emergencia (_Corta el suministro eléctrico en caso de activarse_)
#### Salidas
- Q1→ Relé conmutador entre la red eléctrica y la red por baterías.
- Q2→ Relé conmutador de suministro eléctrico a la residencia

Cómo aclaración, el relé conmutador de sumnistro eléctrico se adaptará cómo un indacador de red eléctrica (discriminando el tipo)