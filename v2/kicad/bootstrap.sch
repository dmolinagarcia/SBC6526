EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 10
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L MCU_Module:Arduino_Nano_v2.x NANO1
U 1 1 5FB03AC9
P 4450 3550
F 0 "NANO1" H 5150 2550 50  0000 C CNN
F 1 "Arduino_Nano_v2.x" H 5150 2450 50  0000 C CNN
F 2 "Module:Arduino_Nano" H 4450 3550 50  0001 C CIN
F 3 "https://www.arduino.cc/en/uploads/Main/ArduinoNanoManual23.pdf" H 4450 3550 50  0001 C CNN
	1    4450 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 4050 2900 4050
Text HLabel 2900 4050 0    50   Output ~ 0
RESET
Wire Wire Line
	3950 4250 2900 4250
Text HLabel 2900 4250 0    50   Output ~ 0
TOD
Wire Wire Line
	4950 4250 5950 4250
Text HLabel 2900 4350 0    50   Input ~ 0
TODENABLE
$Comp
L power:VCC #PWR0131
U 1 1 5FF0216C
P 4650 2550
F 0 "#PWR0131" H 4650 2400 50  0001 C CNN
F 1 "VCC" H 4665 2723 50  0000 C CNN
F 2 "" H 4650 2550 50  0001 C CNN
F 3 "" H 4650 2550 50  0001 C CNN
	1    4650 2550
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 3950 2900 3950
Text HLabel 2900 3950 0    50   Output ~ 0
~CE
Wire Wire Line
	3950 4150 2900 4150
Text HLabel 2900 4150 0    50   Output ~ 0
R~W
Text HLabel 2850 1750 0    50   Output ~ 0
A[0..15]
Wire Wire Line
	3950 3850 3500 3850
Entry Wire Line
	3500 3850 3400 3750
Wire Wire Line
	3950 3750 3500 3750
Entry Wire Line
	3500 3750 3400 3650
Wire Wire Line
	3950 3650 3500 3650
Entry Wire Line
	3500 3650 3400 3550
Wire Wire Line
	3950 3550 3500 3550
Entry Wire Line
	3500 3550 3400 3450
Wire Wire Line
	3950 3450 3500 3450
Entry Wire Line
	3500 3450 3400 3350
Wire Wire Line
	3950 3350 3500 3350
Entry Wire Line
	3500 3350 3400 3250
Wire Wire Line
	3950 3250 3500 3250
Entry Wire Line
	3500 3250 3400 3150
Wire Wire Line
	3950 3150 3500 3150
Entry Wire Line
	3500 3150 3400 3050
Wire Bus Line
	2850 2950 3400 2950
Text HLabel 2850 2950 0    50   Output ~ 0
D[0..7]
$Comp
L 74xx:74HC595 U5
U 1 1 5FF111BA
P 7950 3150
F 0 "U5" H 8250 3850 50  0000 C CNN
F 1 "74HC595" H 8250 3750 50  0000 C CNN
F 2 "Package_SO:SOIC-16_3.9x9.9mm_P1.27mm" H 7950 3150 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74hc595.pdf" H 7950 3150 50  0001 C CNN
	1    7950 3150
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74HC595 U6
U 1 1 5FF11C6B
P 7950 5000
F 0 "U6" H 8250 5700 50  0000 C CNN
F 1 "74HC595" H 8250 5600 50  0000 C CNN
F 2 "Package_SO:SOIC-16_3.9x9.9mm_P1.27mm" H 7950 5000 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74hc595.pdf" H 7950 5000 50  0001 C CNN
	1    7950 5000
	1    0    0    -1  
$EndComp
Text Label 5100 3550 0    50   ~ 0
CLOCK
Text Label 5100 3650 0    50   ~ 0
LATCH
Text Label 5100 3950 0    50   ~ 0
DS
Wire Wire Line
	5950 3950 5950 2750
Wire Wire Line
	5950 2750 7550 2750
Wire Wire Line
	4950 3950 5950 3950
Wire Wire Line
	5850 3550 5850 2950
Wire Wire Line
	5850 2950 7050 2950
Wire Wire Line
	4950 3550 5850 3550
Wire Wire Line
	7050 2950 7050 4800
Wire Wire Line
	7050 4800 7550 4800
Connection ~ 7050 2950
Wire Wire Line
	7050 2950 7550 2950
Wire Wire Line
	5900 3650 5900 3250
Wire Wire Line
	5900 3250 6950 3250
Wire Wire Line
	4950 3650 5900 3650
Wire Wire Line
	6950 3250 6950 5100
Wire Wire Line
	6950 5100 7550 5100
Connection ~ 6950 3250
Wire Wire Line
	6950 3250 7550 3250
Wire Wire Line
	6650 3750 6650 5200
Wire Wire Line
	6650 5200 7550 5200
$Comp
L power:VCC #PWR0134
U 1 1 5FF1820B
P 7150 2550
F 0 "#PWR0134" H 7150 2400 50  0001 C CNN
F 1 "VCC" H 7165 2723 50  0000 C CNN
F 2 "" H 7150 2550 50  0001 C CNN
F 3 "" H 7150 2550 50  0001 C CNN
	1    7150 2550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7150 2550 7150 3050
Wire Wire Line
	7150 3050 7550 3050
Wire Wire Line
	7150 3050 7150 4900
Wire Wire Line
	7150 4900 7550 4900
Connection ~ 7150 3050
Wire Wire Line
	8350 3650 8450 3650
Wire Wire Line
	8450 3650 8450 4150
Wire Wire Line
	8450 4150 7450 4150
Wire Wire Line
	7450 4150 7450 4600
Wire Wire Line
	7450 4600 7550 4600
Wire Bus Line
	2850 1750 8950 1750
Wire Wire Line
	8350 5300 8850 5300
Entry Wire Line
	8850 5300 8950 5200
Wire Wire Line
	8350 5200 8850 5200
Entry Wire Line
	8850 5200 8950 5100
Wire Wire Line
	8350 5100 8850 5100
Entry Wire Line
	8850 5100 8950 5000
Wire Wire Line
	8350 5000 8850 5000
Entry Wire Line
	8850 5000 8950 4900
Wire Wire Line
	8350 4900 8850 4900
Entry Wire Line
	8850 4900 8950 4800
Wire Wire Line
	8350 4800 8850 4800
Entry Wire Line
	8850 4800 8950 4700
Wire Wire Line
	8350 4700 8850 4700
Entry Wire Line
	8850 4700 8950 4600
Wire Wire Line
	8350 4600 8850 4600
Entry Wire Line
	8850 4600 8950 4500
Wire Wire Line
	8350 3450 8850 3450
Entry Wire Line
	8850 3450 8950 3350
Wire Wire Line
	8350 3350 8850 3350
Entry Wire Line
	8850 3350 8950 3250
Wire Wire Line
	8350 3250 8850 3250
Entry Wire Line
	8850 3250 8950 3150
Wire Wire Line
	8350 3150 8850 3150
Entry Wire Line
	8850 3150 8950 3050
Wire Wire Line
	8350 3050 8850 3050
Entry Wire Line
	8850 3050 8950 2950
Wire Wire Line
	8350 2950 8850 2950
Entry Wire Line
	8850 2950 8950 2850
Wire Wire Line
	8350 2850 8850 2850
Entry Wire Line
	8850 2850 8950 2750
Wire Wire Line
	8350 2750 8850 2750
Entry Wire Line
	8850 2750 8950 2650
Text Label 8550 2750 0    50   ~ 0
A0
Text Label 8550 2850 0    50   ~ 0
A1
Text Label 8550 2950 0    50   ~ 0
A2
Text Label 8550 3050 0    50   ~ 0
A3
Text Label 8550 3150 0    50   ~ 0
A4
Text Label 8550 3250 0    50   ~ 0
A5
Text Label 8550 3350 0    50   ~ 0
A6
Text Label 8550 3450 0    50   ~ 0
A7
Text Label 8550 4600 0    50   ~ 0
A8
Text Label 8550 4700 0    50   ~ 0
A9
Text Label 8550 4800 0    50   ~ 0
A10
Text Label 8550 4900 0    50   ~ 0
A11
Text Label 8550 5000 0    50   ~ 0
A12
Text Label 8550 5100 0    50   ~ 0
A13
Text Label 8550 5200 0    50   ~ 0
A14
Text Label 8550 5300 0    50   ~ 0
A15
Wire Wire Line
	4950 3750 6650 3750
Wire Wire Line
	6650 5200 3700 5200
Wire Wire Line
	3700 5200 3700 4450
Connection ~ 6650 5200
Text HLabel 2900 4450 0    50   Output ~ 0
BE
Wire Wire Line
	6650 3350 6650 3750
Wire Wire Line
	6650 3350 7550 3350
Connection ~ 6650 3750
NoConn ~ 8350 5500
NoConn ~ 3950 2950
NoConn ~ 3950 3050
NoConn ~ 4350 2550
NoConn ~ 4550 2550
NoConn ~ 4950 3050
NoConn ~ 4950 2950
NoConn ~ 4950 3350
NoConn ~ 4950 3850
NoConn ~ 4950 4050
NoConn ~ 4950 4150
$Comp
L power:GND #PWR0130
U 1 1 5FFD50E9
P 4500 4750
F 0 "#PWR0130" H 4500 4500 50  0001 C CNN
F 1 "GND" H 4505 4577 50  0000 C CNN
F 2 "" H 4500 4750 50  0001 C CNN
F 3 "" H 4500 4750 50  0001 C CNN
	1    4500 4750
	1    0    0    -1  
$EndComp
Wire Wire Line
	4450 4550 4450 4750
Wire Wire Line
	4450 4750 4500 4750
Wire Wire Line
	4500 4750 4550 4750
Wire Wire Line
	4550 4750 4550 4550
Connection ~ 4500 4750
Wire Wire Line
	3700 4450 2900 4450
Wire Wire Line
	2900 4350 3800 4350
Wire Wire Line
	3800 4350 3800 5100
Wire Wire Line
	3800 5100 5950 5100
Wire Wire Line
	5950 5100 5950 4250
Wire Wire Line
	7950 3850 7950 3900
Wire Wire Line
	7950 2550 7950 2500
$Comp
L power:VCC #PWR0132
U 1 1 5FC1CDD0
P 7950 2500
F 0 "#PWR0132" H 7950 2350 50  0001 C CNN
F 1 "VCC" H 7965 2673 50  0000 C CNN
F 2 "" H 7950 2500 50  0001 C CNN
F 3 "" H 7950 2500 50  0001 C CNN
	1    7950 2500
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0133
U 1 1 5FC1D29C
P 7950 3900
F 0 "#PWR0133" H 7950 3650 50  0001 C CNN
F 1 "GND" H 7955 3727 50  0000 C CNN
F 2 "" H 7950 3900 50  0001 C CNN
F 3 "" H 7950 3900 50  0001 C CNN
	1    7950 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	7950 5700 7950 5750
Wire Wire Line
	7950 4400 7950 4350
$Comp
L power:VCC #PWR0135
U 1 1 5FC21070
P 7950 4350
F 0 "#PWR0135" H 7950 4200 50  0001 C CNN
F 1 "VCC" H 7965 4523 50  0000 C CNN
F 2 "" H 7950 4350 50  0001 C CNN
F 3 "" H 7950 4350 50  0001 C CNN
	1    7950 4350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0136
U 1 1 5FC214BD
P 7950 5750
F 0 "#PWR0136" H 7950 5500 50  0001 C CNN
F 1 "GND" H 7955 5577 50  0000 C CNN
F 2 "" H 7950 5750 50  0001 C CNN
F 3 "" H 7950 5750 50  0001 C CNN
	1    7950 5750
	1    0    0    -1  
$EndComp
Wire Bus Line
	3400 2950 3400 3750
Wire Bus Line
	8950 1750 8950 5200
Text Label 3750 3150 0    50   ~ 0
D7
Text Label 3750 3250 0    50   ~ 0
D6
Text Label 3750 3350 0    50   ~ 0
D5
Text Label 3750 3450 0    50   ~ 0
D4
Text Label 3750 3550 0    50   ~ 0
D3
Text Label 3750 3650 0    50   ~ 0
D2
Text Label 3750 3750 0    50   ~ 0
D1
Text Label 3750 3850 0    50   ~ 0
D0
$EndSCHEMATC
