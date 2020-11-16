byte read_data_bus() {
  // Returns current byte on the data bus  
    byte readByte = (
      (digitalRead(D7) << 7) +
      (digitalRead(D6) << 6) +
      (digitalRead(D5) << 5) +
      (digitalRead(D4) << 4) +
      (digitalRead(D3) << 3) +
      (digitalRead(D2) << 2) +
      (digitalRead(D1) << 1) +
      (digitalRead(D0))
    );
    return readByte;
}

void setBusOutput() {
  // Sets data bus as output
    pinMode(D0, OUTPUT);
    pinMode(D1, OUTPUT);
    pinMode(D2, OUTPUT);
    pinMode(D3, OUTPUT);
    pinMode(D4, OUTPUT);
    pinMode(D5, OUTPUT);
    pinMode(D6, OUTPUT);
    pinMode(D7, OUTPUT);
}

void setBusInput() {
  // Sets data bus as input
    pinMode(D0, INPUT);
    pinMode(D1, INPUT);
    pinMode(D2, INPUT);
    pinMode(D3, INPUT);
    pinMode(D4, INPUT);
    pinMode(D5, INPUT);
    pinMode(D6, INPUT);
    pinMode(D7, INPUT);
}

void setAddress (long address) {
  // Sets address bus
    digitalWrite(CLOCK, LOW);
    digitalWrite(LATCH, LOW);
  //get high - byte of 16 bit address
    byte hi = address >> 8;
  //get low - byte of 16 bit address
    byte lo = address & 0xff;
    fastShiftOut (hi);
    fastShiftOut (lo);
    digitalWrite(LATCH, HIGH);
}
