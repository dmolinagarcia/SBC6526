javac -cp ..\ramFlasher\jSerialComm-2.6.1.jar;. ..\ramFlasher\ramFlasher.java
java -cp "z:\Sublime Text\KickAss.jar" cml.kickass.KickAssembler logisim.asm -log bin\logisim_BuildLog.txt -showmem -odir bin -afo
java -cp "z:\Sublime Text\KickAss.jar" cml.kickass.KickAssembler sbc_test2.asm -log bin\sbc_test2_BuildLog.txt -showmem -odir bin -afo
java -cp ..\ramFlasher\jSerialComm-2.6.1.jar;..\ramFlasher\ ramFlasher bin\sbcv1.bin

