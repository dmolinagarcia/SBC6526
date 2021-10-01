/**********************************
 * ROM PROGRAMMER FOR SBC TESTBED *
 **********************************/

// Define control signals
#define TOD   13
#define CLOCK 14
#define LATCH 15
#define BE    16
#define DS    18
#define TODE  21
#define D0    2
#define D1    3
#define D2    4
#define D3    5
#define D4    6
#define D5    7
#define D6    8
#define D7    9
#define RESET 11
#define CE    10
#define RW    12

// Buffer for serial buik write 
#define BUFFERSIZE 1024
byte buffer[BUFFERSIZE];

/**********************************
 * SETUP
 */

void setup() {

  // Configure TIMER1 to generate a 60Hz Interrupt
    cli();                      // stop interrupts
    TCCR1A = 0;                 // set entire TCCR1A register to 0
    TCCR1B = 0;                 // same for TCCR1B
    TCNT1  = 0;                 // initialize counter value to 0
  // set compare match register for 60 Hz increments
    OCR1A = 33332;              // = 16000000 / (8 * 60) - 1 
  // turn on CTC mode
    TCCR1B |= (1 << WGM12);
  // Set CS12, CS11 and CS10 bits for 8 prescaler
    TCCR1B |= (0 << CS12) | (1 << CS11) | (0 << CS10);
  // enable timer compare interrupt
    TIMSK1 |= (1 << OCIE1A);
    sei();                      // allow interrupts
   
  // Configure control signals
    pinMode(RESET, INPUT);
    digitalWrite (RESET, HIGH);
    pinMode(CE, OUTPUT);
    digitalWrite (CE, LOW);
    pinMode(RW, OUTPUT);
    digitalWrite (RW, HIGH);

  // Shift Registers
    pinMode(CLOCK, OUTPUT);
    digitalWrite(CLOCK, LOW);
    pinMode(LATCH, OUTPUT);
    digitalWrite(LATCH, LOW);
    pinMode(DS, OUTPUT);
    digitalWrite(DS, LOW);

  // BE acts as bus arbitrer
  // BE HIGH : Shift Registers disabled   65c02 enabled   >>  65c02 owns the bus  
  // BE LOW  : Shift Registers enabled    65c02 disabled  >>  Nano  owns the bus
    pinMode(BE, OUTPUT);
    digitalWrite(BE, LOW);

  // Data Bus. Start as input to avoid bus contention
    pinMode(D0, INPUT);
    pinMode(D1, INPUT);
    pinMode(D2, INPUT);
    pinMode(D3, INPUT);
    pinMode(D4, INPUT);
    pinMode(D5, INPUT);
    pinMode(D6, INPUT);
    pinMode(D7, INPUT);

  // Initialize Serial Port
    Serial.begin(115200);
}

ISR(TIMER1_COMPA_vect){
  // timer interrupt to toggle TOD
  // TO-DO if todenable=1, set pin as input
  if (analogRead(7) > 250) 
    pinMode (TOD, INPUT);
  else
    pinMode (TOD, OUTPUT);
  
    PINB = PINB | 0b00100000; // toggle TOD
    PINB = PINB | 0b00100000; // toggle TOD
}

// REVISAR

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



//faster shiftOut function then normal IDE function (about 4 times)
void fastShiftOut (byte data) {
  //clear data pin
  bitClear(PORTC,4);
  //Send each bit of the myDataOut byte MSBFIRST
  for (int i=7; i>=0; i--)  {
    bitClear(PORTC,0);
    //--- Turn data on or off based on value of bit
    if ( bitRead(data,i) == 1) {
      bitSet(PORTC,4);
    }
    else {      
      bitClear(PORTC,4);
    }
    //register shifts bits on upstroke of clock pin  
    bitSet(PORTC,0);
    //zero the data pin after shift to prevent bleed through
    bitClear(PORTC,4);
  }
  //stop shifting
  bitClear(PORTC,0);
}


// Modo lectura
void readMem() {
  digitalWrite(RW, HIGH);
}

// Modo escritura
void writeMem() {
  digitalWrite(RW, LOW);
}

// Pone byte en el data Bus
void setData(byte value) {
  //2 bits belong to PORTB and have to be set separtely
  digitalWrite(D0, (value >> 0) & 0x01);
  digitalWrite(D1, (value >> 1) & 0x01);
  digitalWrite(D2, (value >> 2) & 0x01);
  digitalWrite(D3, (value >> 3) & 0x01);
  digitalWrite(D4, (value >> 4) & 0x01);
  digitalWrite(D5, (value >> 5) & 0x01);
  digitalWrite(D6, (value >> 6) & 0x01);
  digitalWrite(D7, (value >> 7) & 0x01);
}

byte readAddress(long address)
{
  setBusInput();
  readMem();
  setAddress(address);
  delay(1);
  byte ret = read_data_bus();
  delay(1);
  return ret;
}

void writeAddress(long address, byte value) {
  setAddress(address);
  setData(value);
  digitalWrite(RW, LOW);
  setBusOutput();
  digitalWrite(RW, HIGH);
  setBusInput();
}

/**********************************
   SERIAL COMMS
*/

//command buffer for parsing commands
#define COMMANDSIZE 32
char cmdbuf[COMMANDSIZE];

//waits for a string submitted via serial connection
//returns only if linebreak is sent or the buffer is filled
void readCommand() {
  //first clear command buffer
  for (int i = 0; i < COMMANDSIZE; i++) cmdbuf[i] = 0;
  //initialize variables
  char c = ' ';
  int idx = 0;
  //now read serial data until linebreak or buffer is full
  do {
    if (Serial.available()) {
      c = Serial.read();
      cmdbuf[idx++] = c;
    }
  }
  while (c != '\n' && idx < (COMMANDSIZE)); //save the last '\0' for string end
  //change last newline to '\0' termination
  cmdbuf[idx - 1] = 0;
}

byte hexDigit(char c)
{
  if (c >= '0' && c <= '9') {
    return c - '0';
  }
  else if (c >= 'a' && c <= 'f') {
    return c - 'a' + 10;
  }
  else if (c >= 'A' && c <= 'F') {
    return c - 'A' + 10;
  }
  else {
    return 0;   // getting here is bad: it means the character was invalid
  }
}

unsigned int hexWord(char* data) {
  return ((hexDigit(data[0]) * 4096) +
          (hexDigit(data[1]) * 256) +
          (hexDigit(data[2]) * 16) +
          (hexDigit(data[3])));
}

byte hexByte(char* a)
{
  return ((hexDigit(a[0]) * 16) + hexDigit(a[1]));
}

/**********************************
   MAIN LOOP
*/

void loop() {
  readCommand();
  String outputString;

  // CMDBUF
  // 0123456789ABCD
  // W FFFF FF FFFF
  //First string is command
  cmdbuf[1]  = 0;
  //second string is address (4 bytes)
  cmdbuf[6]  = 0;
  //third string is byte (2 bytes)
  cmdbuf[9] = 0;
  //4th is end address
  cmdbuf[14] = 0;

  unsigned int Address = hexWord(cmdbuf + 2);
  unsigned int Value = hexByte(cmdbuf + 7);
  unsigned int Length = hexWord(cmdbuf + 10);
  switch (cmdbuf[0]) {
    case 'A':
      outputString = outputString + "A:" + Address;
      setAddress(Address);
      break;
    case 'R':
      outputString = outputString + "READ :" + Address;
      outputString = readAddress(Address);
      break;
    case 'W':
      outputString = outputString + "WRITE :" + Address + " " + Value;
      writeAddress(Address, Value);
      break;
    case 'X':
      outputString = outputString + "RESET";
      pinMode (RESET, OUTPUT);
      digitalWrite (RESET, HIGH);
      pinMode (RW, INPUT_PULLUP);
      setBusInput();
      digitalWrite (BE, HIGH);    // Devolvemos bus al 6502
      delay(50);
      pinMode (RW, INPUT);
      delay(50);
      pinMode (RESET, INPUT);
      outputString = "Reiniciando 6502 y devolviendo bus...";

      break;
    case 'S':
      // STOP
      pinMode(RW, INPUT_PULLUP);
      setAddress(32768);
      digitalWrite (BE, LOW);     // Sacabmos el 6502 del bus
      pinMode(RW, OUTPUT);
      outputString = "Retomando control del bus";
      break;
    case 'B':
      // Bulk
      outputString = "Bulk Start : ";
      outputString = outputString + Address;
      outputString = outputString + " Length : ";
      outputString = outputString + Length;
      Serial.print("@");
      long position = 0;
      while (position < Length) {
        if (Serial.available()) buffer[position++] = Serial.read();
      }
      for (unsigned int i = 0; i < Length; i++) {
        writeAddress(Address + i, buffer[i]);
      }
      break;
    default:
      outputString = "Comando no reconocido";
  }

  Serial.println(outputString);
  Serial.print("@");
}
