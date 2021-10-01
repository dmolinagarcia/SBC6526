javac -cp ..\ramFlasher\jSerialComm-2.6.1.jar;. ..\ramFlasher\ramFlasher.java
java -cp "z:\Sublime Text\KickAss.jar" cml.kickass.KickAssembler sbc_test1.asm -log bin\sbc_test1_BuildLog.txt -showmem -odir bin -afo
java -cp ..\ramFlasher\jSerialComm-2.6.1.jar;..\ramFlasher\ ramFlasher bin\sbcv1.bin

