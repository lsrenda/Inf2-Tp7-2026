**TP7 – Entorno gráfico: control de E/S de Arduino con Processing**  
   
 **Cátedra:** Informática II · **Carrera:** Ingeniería en Telecomunicaciones · **Ciclo lectivo:** 2026  
   
 Interfaz gráfica hecha en **Processing** que muestra y controla las entradas y salidas de una placa **Arduino** conectada por USB.  
   
 **Qué hace**  
  
|  |  |  
| - | - |  
|   |    |  
| **Punto del TP** |  **Cómo se resuelve** |  
| 1. Mostrar estados |  El sector **Entradas** (E1, E2) se pinta en verde (alto) o rojo (bajo); el sector **Salidas** (L1, L2) muestra los LEDs encendidos (amarillo) o apagados (gris). |  
| 2. Activar salidas con el mouse |  Al hacer click sobre un LED en la interfaz, Processing envía la orden al Arduino y este enciende/apaga el LED real. |  
| 3. Activar salidas con las entradas |  Al pulsar E1 o E2 en el Arduino, se alterna el LED correspondiente (L1 o L2) y la interfaz lo refleja. |  
| 4. Comunicación |  Protocolo de texto por puerto serie, bidireccional (ver abajo). |  
  
   
   
   
 **Estructura del repositorio**  
```  
.    
  ├── p7_arduino.ino        # sketch del Arduino    
  ├── tp7_processing.pde  # interfaz en Processing    
  ├── esquematico.svg                # esquema de conexión    
  └── README.md    
      
   
```  
**Hardware**  
- Arduino Mega 2560.  
- 2 pulsadores: **E1 → D2**, **E2 → D3**, el otro terminal a GND (se usa `INPUT_PULLUP`, no hace falta resistencia externa).  
- 2 LEDs con resistencia de 220 Ω: **L1 → D8**, **L2 → D9**, cátodo a GND.  
- Cable USB a la PC.  
   
 Ver `esquematico.svg`.  
 **Protocolo serie (9600 baudios, una orden por línea con** `\n`**)**  
  
|  |  |  |  
| - | - | - |  
|   |    |    |  
| **Sentido** |  **Mensaje** |  **Significado** |  
| Arduino → PC |  `E<n>:<0\|1>` |  Nivel de la entrada *n* (1 = alto, 0 = bajo) |  
| Arduino → PC |  `L<n>:<0\|1>` |  Estado del LED *n* (1 = encendido) |  
| PC → Arduino |  `L<n>:<0\|1>` |  Encender/apagar el LED *n* |  
| PC → Arduino |  `?` |  Pedir el estado completo |  
  
   
   
   
 El Arduino siempre informa el estado real de sus LEDs, de modo que la interfaz nunca queda desincronizada (por ejemplo, si se acciona un botón físico y un click a la vez).  
   
 **Cómo probarlo**  
1. Cargar `tp7_arduino.ino` con  `arduino-cli` en la placa.  
2. **Cerrar el Monitor Serie** (ocupa el puerto).  
3. Abrir `tp7_processing.pde` en Processing 4 y ejecutar. El puerto se detecta solo (`ttyACM`, `ttyUSB`, `usbmodem`, `COM`). Si hay varios, editar `PORT_INDEX` con el índice que se imprime en la consola.  
4. Tecla `r` en la ventana para reconectar.  
   
 En Linux puede ser necesario agregar el usuario al grupo `uucp` (Arch) o `dialout` (Debian/Ubuntu) para acceder al puerto.  
