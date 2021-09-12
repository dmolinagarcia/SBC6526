/*
 * Library to read and write a SRAM IC
 * using 2 595 shift registers
 */

#ifndef RAM595_h
#define RAM595_h

class RAM595
{
  public:
    RAM595(int BE, int CLOCK, int LATCH, int DS);
    void setAddress (long address);
  private:
    void fastShiftOut (byte data);
    int _BE;
    int _CLOCK;
    int _LATCH;
    int _DS;
};

#endif
