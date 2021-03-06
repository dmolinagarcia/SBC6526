EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 9 10
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
L 74xx:74LS14 U?
U 7 1 5FFACB47
P 5400 2650
AR Path="/5FFACB47" Ref="U?"  Part="7" 
AR Path="/5FFAA38F/5FFACB47" Ref="U8"  Part="7" 
F 0 "U8" V 5150 2400 50  0000 C CNN
F 1 "74AC14" V 5150 2800 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 5400 2650 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS14" H 5400 2650 50  0001 C CNN
	7    5400 2650
	0    1    1    0   
$EndComp
$Comp
L 74xx:74LS74 U?
U 3 1 5FFACB4D
P 5400 2150
AR Path="/5FFACB4D" Ref="U?"  Part="3" 
AR Path="/5FFAA38F/5FFACB4D" Ref="U7"  Part="3" 
F 0 "U7" V 5150 1900 50  0000 C CNN
F 1 "74AC74" V 5150 2300 50  0000 C CNN
F 2 "" H 5400 2150 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 5400 2150 50  0001 C CNN
	3    5400 2150
	0    1    1    0   
$EndComp
$Comp
L 74xx:74LS139 U?
U 3 1 5FFACB41
P 5400 3150
AR Path="/5FA78BCC/5FFACB41" Ref="U?"  Part="3" 
AR Path="/5FFACB41" Ref="U?"  Part="3" 
AR Path="/5FFAA38F/5FFACB41" Ref="U9"  Part="3" 
F 0 "U9" V 5150 2900 50  0000 C CNN
F 1 "74AC139" V 5150 3300 50  0000 C CNN
F 2 "Package_SO:SOIC-16_3.9x9.9mm_P1.27mm" H 5400 3150 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn74ls139a.pdf" H 5400 3150 50  0001 C CNN
	3    5400 3150
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR0153
U 1 1 5FFB2EE1
P 6200 1950
F 0 "#PWR0153" H 6200 1800 50  0001 C CNN
F 1 "VCC" H 6215 2123 50  0000 C CNN
F 2 "" H 6200 1950 50  0001 C CNN
F 3 "" H 6200 1950 50  0001 C CNN
	1    6200 1950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0154
U 1 1 5FFB3598
P 4750 3350
F 0 "#PWR0154" H 4750 3100 50  0001 C CNN
F 1 "GND" H 4755 3177 50  0000 C CNN
F 2 "" H 4750 3350 50  0001 C CNN
F 3 "" H 4750 3350 50  0001 C CNN
	1    4750 3350
	1    0    0    -1  
$EndComp
$Comp
L Device:C C1
U 1 1 5FFF16C4
P 2050 1300
F 0 "C1" V 1798 1300 50  0000 C CNN
F 1 "100n" V 1889 1300 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 1150 50  0001 C CNN
F 3 "~" H 2050 1300 50  0001 C CNN
	1    2050 1300
	0    1    1    0   
$EndComp
$Comp
L Device:C C2
U 1 1 5FFF228C
P 2050 1700
F 0 "C2" V 1798 1700 50  0000 C CNN
F 1 "100n" V 1889 1700 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 1550 50  0001 C CNN
F 3 "~" H 2050 1700 50  0001 C CNN
	1    2050 1700
	0    1    1    0   
$EndComp
$Comp
L Device:C C3
U 1 1 5FFF2422
P 2050 2100
F 0 "C3" V 1798 2100 50  0000 C CNN
F 1 "100n" V 1889 2100 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 1950 50  0001 C CNN
F 3 "~" H 2050 2100 50  0001 C CNN
	1    2050 2100
	0    1    1    0   
$EndComp
$Comp
L Device:C C4
U 1 1 5FFF2513
P 2050 2500
F 0 "C4" V 1798 2500 50  0000 C CNN
F 1 "100n" V 1889 2500 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 2350 50  0001 C CNN
F 3 "~" H 2050 2500 50  0001 C CNN
	1    2050 2500
	0    1    1    0   
$EndComp
Wire Wire Line
	1900 1300 1900 1700
Wire Wire Line
	1900 1700 1900 2100
Connection ~ 1900 1700
Wire Wire Line
	1900 2100 1900 2500
Connection ~ 1900 2100
Connection ~ 1900 2500
Wire Wire Line
	2200 2500 2200 2100
Wire Wire Line
	2200 2100 2200 1700
Connection ~ 2200 2100
Wire Wire Line
	2200 1700 2200 1300
Connection ~ 2200 1700
Wire Wire Line
	2200 1300 2200 850 
Connection ~ 2200 1300
$Comp
L power:VCC #PWR02
U 1 1 5FFF3BE5
P 2200 850
F 0 "#PWR02" H 2200 700 50  0001 C CNN
F 1 "VCC" H 2215 1023 50  0000 C CNN
F 2 "" H 2200 850 50  0001 C CNN
F 3 "" H 2200 850 50  0001 C CNN
	1    2200 850 
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR01
U 1 1 5FFF428F
P 1900 7100
F 0 "#PWR01" H 1900 6850 50  0001 C CNN
F 1 "GND" H 1905 6927 50  0000 C CNN
F 2 "" H 1900 7100 50  0001 C CNN
F 3 "" H 1900 7100 50  0001 C CNN
	1    1900 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 2500 1900 2900
$Comp
L Device:C C7
U 1 1 5FFF5DA1
P 2050 2900
F 0 "C7" V 1798 2900 50  0000 C CNN
F 1 "100n" V 1889 2900 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 2750 50  0001 C CNN
F 3 "~" H 2050 2900 50  0001 C CNN
	1    2050 2900
	0    1    1    0   
$EndComp
$Comp
L Device:C C8
U 1 1 5FFF60F7
P 2050 3350
F 0 "C8" V 1798 3350 50  0000 C CNN
F 1 "100n" V 1889 3350 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 3200 50  0001 C CNN
F 3 "~" H 2050 3350 50  0001 C CNN
	1    2050 3350
	0    1    1    0   
$EndComp
$Comp
L Device:C C9
U 1 1 5FFF648D
P 2050 3750
F 0 "C9" V 1798 3750 50  0000 C CNN
F 1 "100n" V 1889 3750 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 3600 50  0001 C CNN
F 3 "~" H 2050 3750 50  0001 C CNN
	1    2050 3750
	0    1    1    0   
$EndComp
$Comp
L Device:C C10
U 1 1 5FFF6950
P 2050 4150
F 0 "C10" V 1798 4150 50  0000 C CNN
F 1 "100n" V 1889 4150 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 4000 50  0001 C CNN
F 3 "~" H 2050 4150 50  0001 C CNN
	1    2050 4150
	0    1    1    0   
$EndComp
$Comp
L Device:C C11
U 1 1 5FFF6CA6
P 2050 4600
F 0 "C11" V 1798 4600 50  0000 C CNN
F 1 "100n" V 1889 4600 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 4450 50  0001 C CNN
F 3 "~" H 2050 4600 50  0001 C CNN
	1    2050 4600
	0    1    1    0   
$EndComp
Wire Wire Line
	2200 4600 2200 4150
Wire Wire Line
	2200 4150 2200 3750
Connection ~ 2200 4150
Wire Wire Line
	2200 3750 2200 3350
Connection ~ 2200 3750
Wire Wire Line
	2200 3350 2200 2900
Connection ~ 2200 3350
Wire Wire Line
	2200 2500 2200 2900
Connection ~ 2200 2500
Connection ~ 2200 2900
Connection ~ 1900 2900
Wire Wire Line
	1900 2900 1900 3350
Connection ~ 1900 3350
Wire Wire Line
	1900 3350 1900 3750
Connection ~ 1900 3750
Wire Wire Line
	1900 3750 1900 4150
Connection ~ 1900 4150
Wire Wire Line
	1900 4150 1900 4600
Connection ~ 1900 4600
Wire Wire Line
	1900 4600 1900 5000
$Comp
L Device:CP C14
U 1 1 5FFFB90F
P 2050 5000
F 0 "C14" V 1795 5000 50  0000 C CNN
F 1 "10u" V 1886 5000 50  0000 C CNN
F 2 "Capacitor_THT:CP_Radial_D6.3mm_P2.50mm" H 2088 4850 50  0001 C CNN
F 3 "~" H 2050 5000 50  0001 C CNN
	1    2050 5000
	0    1    1    0   
$EndComp
Connection ~ 1900 5000
Wire Wire Line
	1900 5000 1900 5400
Connection ~ 2200 4600
Wire Wire Line
	4750 3350 4750 3150
Wire Wire Line
	4750 2150 5000 2150
Wire Wire Line
	4900 2650 4750 2650
Connection ~ 4750 2650
Wire Wire Line
	4750 2650 4750 2150
Wire Wire Line
	4900 3150 4750 3150
Connection ~ 4750 3150
Wire Wire Line
	4750 3150 4750 2650
Wire Wire Line
	5900 3150 6200 3150
Wire Wire Line
	6200 3150 6200 2650
Wire Wire Line
	5800 2150 6200 2150
Connection ~ 6200 2150
Wire Wire Line
	6200 2150 6200 1950
Wire Wire Line
	5900 2650 6200 2650
Connection ~ 6200 2650
Wire Wire Line
	6200 2650 6200 2150
$Comp
L Device:C CEXT1
U 1 1 5FCD560C
P 2050 5400
F 0 "CEXT1" V 1798 5400 50  0000 C CNN
F 1 "100n" V 1889 5400 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 2088 5250 50  0001 C CNN
F 3 "~" H 2050 5400 50  0001 C CNN
	1    2050 5400
	0    1    1    0   
$EndComp
Connection ~ 1900 5400
Wire Wire Line
	1900 5400 1900 5850
Wire Wire Line
	2200 4600 2200 5000
Connection ~ 2200 5000
Wire Wire Line
	2200 5000 2200 5400
$Comp
L 74xx:74LS14 U8
U 3 1 5FBC2197
P 2200 5850
F 0 "U8" H 2200 6167 50  0000 C CNN
F 1 "74AC14" H 2200 6076 50  0000 C CNN
F 2 "" H 2200 5850 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS14" H 2200 5850 50  0001 C CNN
	3    2200 5850
	1    0    0    -1  
$EndComp
Connection ~ 1900 5850
Wire Wire Line
	1900 5850 1900 6200
$Comp
L 74xx:74LS14 U8
U 4 1 5FBC471A
P 2200 6200
F 0 "U8" H 2200 6517 50  0000 C CNN
F 1 "74AC14" H 2200 6426 50  0000 C CNN
F 2 "" H 2200 6200 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS14" H 2200 6200 50  0001 C CNN
	4    2200 6200
	1    0    0    -1  
$EndComp
Connection ~ 1900 6200
Wire Wire Line
	1900 6200 1900 6550
$Comp
L 74xx:74LS14 U8
U 5 1 5FBC603E
P 2200 6550
F 0 "U8" H 2200 6867 50  0000 C CNN
F 1 "74AC14" H 2200 6776 50  0000 C CNN
F 2 "" H 2200 6550 50  0001 C CNN
F 3 "http://www.ti.com/lit/gpn/sn74LS14" H 2200 6550 50  0001 C CNN
	5    2200 6550
	1    0    0    -1  
$EndComp
Connection ~ 1900 6550
Wire Wire Line
	1900 6550 1900 6950
$Comp
L 74xx:74HC74 U7
U 1 1 5FBC9A2E
P 2200 7050
F 0 "U7" H 2200 7531 50  0000 C CNN
F 1 "74AC74" H 2200 7440 50  0000 C CNN
F 2 "" H 2200 7050 50  0001 C CNN
F 3 "74xx/74hc_hct74.pdf" H 2200 7050 50  0001 C CNN
	1    2200 7050
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 7050 1900 7100
Wire Wire Line
	1900 6950 1900 7050
Connection ~ 1900 6950
Connection ~ 1900 7050
Wire Wire Line
	2200 6750 2650 6750
Wire Wire Line
	2200 7350 2650 7350
Wire Wire Line
	2650 7350 2650 6750
Wire Wire Line
	2650 6750 2650 5400
Wire Wire Line
	2650 5400 2200 5400
Connection ~ 2650 6750
Connection ~ 2200 5400
NoConn ~ 2500 5850
NoConn ~ 2500 6200
NoConn ~ 2500 6550
NoConn ~ 2500 6950
NoConn ~ 2500 7150
$EndSCHEMATC
