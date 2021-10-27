@echo off
REM javac -cp ..\ramFlasher\jSerialComm-2.6.1.jar;. ..\ramFlasher\ramFlasher.java
java -cp "z:\Sublime Text\KickAss.jar" cml.kickass.KickAssembler 00.logisim.asm -log bin\logisim_BuildLog.txt -showmem -odir bin -afo
REM java -cp "z:\Sublime Text\KickAss.jar" cml.kickass.KickAssembler 00.sbc6526_v2.asm -log bin\sbc6526_v2_BuildLog.txt -showmem -odir bin -afo
REM java -cp ..\ramFlasher\jSerialComm-2.6.1.jar;..\ramFlasher\ ramFlasher bin\sbcv1.bin
  
