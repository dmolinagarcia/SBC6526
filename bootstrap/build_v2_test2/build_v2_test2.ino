/**********************************
 * ROM PROGRAMMER FOR SBC TESTBED *
 **********************************/

 /* Test 2
  *  Test address and data buses
  */

// Define 595 control signals
#define CLOCK 14      // 595 clock
#define LATCH 15      // 595 latch
#define DS    18      // 595 serial data
#define BE    16      // 595 /OE and 6502 BE

// Define Data bus
#define D0    9
#define D1    8
#define D2    7
#define D3    6
#define D4    5
#define D5    4
#define D6    3
#define D7    2


void setup() {
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

// Fast Shiftout
// faster shiftOut function then normal IDE function (about 4 times)
void fastShiftOut (byte data) {
  // portc, 4 = DATA SERIAL
  // portc, 0 = CLOCK SERIAL
  
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

// Bus control
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

// BUS IO

void setData(byte value) {
  // Pone byte en el data Bus
    digitalWrite(D0, (value >> 0) & 0x01);
    digitalWrite(D1, (value >> 1) & 0x01);
    digitalWrite(D2, (value >> 2) & 0x01);
    digitalWrite(D3, (value >> 3) & 0x01);
    digitalWrite(D4, (value >> 4) & 0x01);
    digitalWrite(D5, (value >> 5) & 0x01);
    digitalWrite(D6, (value >> 6) & 0x01);
    digitalWrite(D7, (value >> 7) & 0x01);
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

void loop() {
    setBusOutput();

    Serial.println ("Vamos a probar el bus");
    
    readCommand();
    setAddress(1); setData(0);
    Serial.println ("A: 00000000 00000001  D: 00000000");

    readCommand();
    setAddress(2); setData(0);
    Serial.println ("A: 00000000 00000010  D: 00000000");

    readCommand();
    setAddress(4); setData(0);
    Serial.println ("A: 00000000 00000100  D: 00000000");

    readCommand();
    setAddress(8); setData(0);
    Serial.println ("A: 00000000 00001000  D: 00000000");

    readCommand();
    setAddress(16); setData(0);
    Serial.println ("A: 00000000 00010000  D: 00000000");

    readCommand();
    setAddress(32); setData(0);
    Serial.println ("A: 00000000 00100000  D: 00000000");

    readCommand();
    setAddress(64); setData(0);
    Serial.println ("A: 00000000 01000000  D: 00000000");

    readCommand();
    setAddress(128); setData(0);
    Serial.println ("A: 00000000 10000000  D: 00000000");

    readCommand();
    setAddress(256); setData(0);
    Serial.println ("A: 00000001 00000000  D: 00000000");

    readCommand();
    setAddress(512); setData(0);
    Serial.println ("A: 00000010 00000000  D: 00000000");

    readCommand();
    setAddress(1024); setData(0);
    Serial.println ("A: 00000100 00000000  D: 00000000");

    readCommand();
    setAddress(2048); setData(0);
    Serial.println ("A: 00001000 00000000  D: 00000000");

    readCommand();
    setAddress(4096); setData(0);
    Serial.println ("A: 00010000 00000000  D: 00000000");

    readCommand();
    setAddress(8192); setData(0);
    Serial.println ("A: 00100000 00000000  D: 00000000");

    readCommand();
    setAddress(16384); setData(0);
    Serial.println ("A: 01000000 00000000  D: 00000000");

    readCommand();
    setAddress(32768); setData(0);
    Serial.println ("A: 10000000 00000000  D: 00000000");

    readCommand();
    setAddress(0); setData(1);
    Serial.println ("A: 00000000 00000000  D: 00000001");

    readCommand();
    setAddress(0); setData(2);
    Serial.println ("A: 00000000 00000000  D: 00000010");

    readCommand();
    setAddress(0); setData(4);
    Serial.println ("A: 00000000 00000000  D: 00000100");

    readCommand();
    setAddress(0); setData(8);
    Serial.println ("A: 00000000 00000000  D: 00001000");

    readCommand();
    setAddress(0); setData(16);
    Serial.println ("A: 00000000 00000000  D: 00010000");

    readCommand();
    setAddress(0); setData(32);
    Serial.println ("A: 00000000 00000000  D: 00100000");

    readCommand();
    setAddress(0); setData(64);
    Serial.println ("A: 00000000 00000000  D: 01000000");

    readCommand();
    setAddress(0); setData(128);
    Serial.println ("A: 00000000 00000000  D: 10000000");

}
