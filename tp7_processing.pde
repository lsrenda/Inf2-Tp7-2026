import processing.serial.*;

final int NUM = 2;
final int BAUD = 9600;

// Dejar en -1 para autodetectar (ttyACM, ttyUSB, usbmodem, COM).
// Si falla, poner aquí el índice de Serial.list() que imprime la consola.
int PORT_INDEX = -1;

Serial port;
String portName = "(sin conexión)";

boolean[] inputHigh = new boolean[NUM];
boolean[] ledOn     = new boolean[NUM];

// Geometría (ventana 700 x 400, similar a la figura del enunciado)
int[] colX = {430, 560};
int rowIn = 140, rowOut = 270;
int boxW = 90, boxH = 56, ledR = 32;

color cHigh = color(46, 160, 67);
color cLow  = color(200, 55, 55);
color cOn   = color(255, 214, 10);
color cOff  = color(190);

void setup() {
  size(700, 400);
  textAlign(CENTER, CENTER);
  textSize(20);
  for (int i = 0; i < NUM; i++) inputHigh[i] = true;  // con pull-up reposa en alto
  connect();
}

void connect() {
  if (port != null) {
    port.stop();
    port = null;
  }
  String[] ports = Serial.list();
  println("Puertos disponibles:");
  printArray(ports);

  int idx = PORT_INDEX;
  if (idx < 0) {
    for (int i = 0; i < ports.length; i++) {
      String p = ports[i];
      if (p.contains("ttyACM") || p.contains("ttyUSB") || p.contains("usbmodem")
          || p.contains("usbserial") || p.startsWith("COM")) {
        idx = i;
        break;
      }
    }
  }

  if (idx >= 0 && idx < ports.length) {
    try {
      port = new Serial(this, ports[idx], BAUD);
      port.bufferUntil('\n');
      portName = ports[idx];
      delay(1800);        // el Arduino se reinicia al abrir el puerto
      port.write("?\n");  // pedir estado inicial
    } catch (Exception e) {
      println("No se pudo abrir " + ports[idx] + ": " + e.getMessage());
      port = null;
      portName = "(error al abrir)";
    }
  } else {
    portName = "(sin Arduino)";
  }
}

void draw() {
  background(255);
  stroke(0);
  strokeWeight(2);
  noFill();
  rect(10, 10, width - 20, height - 20);

  // Etiquetas de sector
  stroke(90);
  strokeWeight(1);
  fill(150, 180, 220);
  rect(110, rowIn - 28, 150, 56);
  fill(252, 228, 214);
  rect(110, rowOut - 28, 150, 56);
  fill(0);
  text("Entradas", 185, rowIn);
  text("Salidas", 185, rowOut);

  // Entradas: color según nivel alto/bajo
  for (int i = 0; i < NUM; i++) {
    stroke(0);
    strokeWeight(2);
    fill(inputHigh[i] ? cHigh : cLow);
    rect(colX[i] - boxW / 2, rowIn - boxH / 2, boxW, boxH);
    fill(255);
    text("E" + (i + 1) + (inputHigh[i] ? " ALTO" : " BAJO"), colX[i], rowIn);
  }

  // Salidas: LEDs
  for (int i = 0; i < NUM; i++) {
    stroke(0);
    strokeWeight(3);
    fill(ledOn[i] ? cOn : cOff);
    ellipse(colX[i], rowOut, ledR * 2, ledR * 2);
    fill(0);
    text("L" + (i + 1), colX[i], rowOut);
  }

  // Estado de la conexión
  fill(80);
  textSize(13);
  text("Puerto: " + portName + "   |   click en un LED para alternarlo   |   'r' = reconectar",
       width / 2, height - 28);
  textSize(20);
}

void mousePressed() {
  for (int i = 0; i < NUM; i++) {
    if (dist(mouseX, mouseY, colX[i], rowOut) <= ledR) {
      boolean nuevo = !ledOn[i];
      if (port != null) {
        port.write("L" + (i + 1) + ":" + (nuevo ? 1 : 0) + "\n");
        // El estado real se actualiza cuando el Arduino confirma.
      } else {
        ledOn[i] = nuevo;   // modo demostración sin placa
      }
    }
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') connect();
}

void serialEvent(Serial p) {
  String line = p.readStringUntil('\n');
  if (line == null) return;
  line = trim(line);
  if (line.length() < 4 || line.charAt(2) != ':') return;

  int n = line.charAt(1) - '0';
  if (n < 1 || n > NUM) return;
  boolean value = line.charAt(3) == '1';

  if (line.charAt(0) == 'E') inputHigh[n - 1] = value;
  else if (line.charAt(0) == 'L') ledOn[n - 1] = value;
}
