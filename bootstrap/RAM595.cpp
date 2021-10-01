/*
 * Library to read and write a SRAM IC
 * using 2 595 shift registers
 */

#include "Arduino.h"
#include "RAM595.h"

RAM595::RAM595(int BE, int CLOCK, int LATCH, int DS)
{
  pinMode(CLOCK, OUTPUT);
  pinMode(LATCH, OUTPUT);
  pinMode(BE, OUTPUT);
  pinMode(DS, OUTPUT);

  // BE Controla el BUS
  // BE HIGH : Los shift registers estan OFF y el  65c02 ON
  // BE LOW  : Los shift registers estan ON  y el  65c02 OFF
  digitalWrite(CLOCK, LOW);
  digitalWrite(LATCH, LOW);
  digitalWrite(BE, LOW);
  digitalWrite(DS, LOW);

  _BE = BE;
  _CLOCK = CLOCK;
  _LATCH = LATCH;
  _DS = DS;

}

void RAM595::setAddress (long address)
{
      digitalWrite(_CLOCK, LOW);
      digitalWrite(_LATCH, LOW);
      //get high - byte of 16 bit address
      byte hi = address >> 8;
      //get low - byte of 16 bit address
      byte lo = address & 0xff;
//    shiftOut(_DS, _CLOCK, MSBFIRST, hi);
//    shiftOut(_DS, _CLOCK, MSBFIRST, lo);
      fastShiftOut (hi);
      fastShiftOut (lo);
      digitalWrite(_LATCH, HIGH);

}

//faster shiftOut function then normal IDE function (about 4 times)
void RAM595::fastShiftOut(byte data) {
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