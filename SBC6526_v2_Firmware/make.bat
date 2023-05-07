@echo off
REM 	javac -cp ..\ramFlasher\jSerialComm-2.6.1.jar;. ..\ramFlasher\ramFlasher.java
REM java -cp "z:\Sublime Text\KickAss.jar" cml.kickass.KickAssembler 00.logisim.asm -log bin\logisim_BuildLog.txt -showmem -odir bin -afo
java -cp "z:\Sublime Text\KickAss.jar" cml.kickass.KickAssembler 00.sbc6526_v2.asm -log bin\sbc6526_v2_BuildLog.txt -showmem -odir bin -afo
IF %ERRORLEVEL% NEQ 0 exit
java -cp ..\ramFlasher\jSerialComm-2.6.1.jar;..\ramFlasher\ ramFlasher bin\sbc6526_v2.bin
  
