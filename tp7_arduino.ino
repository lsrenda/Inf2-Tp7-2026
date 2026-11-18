const uint8_t NUM = 2;
const uint8_t PIN_IN[NUM]  = {2, 3};
const uint8_t PIN_LED[NUM] = {8, 9};

const unsigned long DEBOUNCE_MS = 25;
const unsigned long BAUD = 9600;

bool ledState[NUM]          = {false, false};
bool lastReading[NUM]       = {HIGH, HIGH};   // última lectura cruda
bool stableLevel[NUM]       = {HIGH, HIGH};   // nivel estable (antirrebote)
unsigned long lastChange[NUM] = {0, 0};

String rxLine = "";

void sendInput(uint8_t i) {
  Serial.print('E');
  Serial.print(i + 1);
  Serial.print(':');
  Serial.println(stableLevel[i] == HIGH ? 1 : 0);
}

void sendLed(uint8_t i) {
  Serial.print('L');
  Serial.print(i + 1);
  Serial.print(':');
  Serial.println(ledState[i] ? 1 : 0);
}

void sendAll() {
  for (uint8_t i = 0; i < NUM; i++) {
    sendInput(i);
    sendLed(i);
  }
}

void setLed(uint8_t i, bool on) {
  ledState[i] = on;
  digitalWrite(PIN_LED[i], on ? HIGH : LOW);
  sendLed(i);
}

void processLine(const String &line) {
  if (line.length() == 0) return;

  if (line[0] == '?') {
    sendAll();
    return;
  }

  // Formato esperado: L<n>:<0|1>
  if (line[0] == 'L' && line.length() >= 4 && line[2] == ':') {
    int n = line[1] - '0';
    char v = line[3];
    if (n >= 1 && n <= NUM && (v == '0' || v == '1')) {
      setLed(n - 1, v == '1');
    }
  }
}

void readSerial() {
  while (Serial.available() > 0) {
    char c = (char)Serial.read();
    if (c == '\n') {
      rxLine.trim();
      processLine(rxLine);
      rxLine = "";
    } else if (c != '\r') {
      if (rxLine.length() < 16) rxLine += c;   // evita desbordar
      else rxLine = "";
    }
  }
}

void readButtons() {
  for (uint8_t i = 0; i < NUM; i++) {
    bool reading = digitalRead(PIN_IN[i]);

    if (reading != lastReading[i]) {
      lastReading[i] = reading;
      lastChange[i] = millis();
    }

    if ((millis() - lastChange[i]) > DEBOUNCE_MS && reading != stableLevel[i]) {
      stableLevel[i] = reading;
      sendInput(i);
      // Flanco descendente = pulsador oprimido (INPUT_PULLUP): alterna el LED.
      if (stableLevel[i] == LOW) {
        setLed(i, !ledState[i]);
      }
    }
  }
}

void setup() {
  Serial.begin(BAUD);
  for (uint8_t i = 0; i < NUM; i++) {
    pinMode(PIN_IN[i], INPUT_PULLUP);
    pinMode(PIN_LED[i], OUTPUT);
    digitalWrite(PIN_LED[i], LOW);
    lastReading[i] = stableLevel[i] = digitalRead(PIN_IN[i]);
  }
  sendAll();
}

void loop() {
  readSerial();
  readButtons();
}
