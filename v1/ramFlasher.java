import com.fazecast.jSerialComm.*;
import java.util.*;
import java.io.*;
import java.util.Scanner;

/* Cargador de memoria ram para SBCv1
 *
 */
 
public class ramFlasher {
	
	static String padLeftZeros(String inputString, int length) {
    if (inputString.length() >= length) {
        return inputString;
    }
    StringBuilder sb = new StringBuilder();
    while (sb.length() < length - inputString.length()) {
        sb.append('0');
    }
    sb.append(inputString);
 
    return sb.toString();
}
	
	public static void main(String[] args) throws InterruptedException,IOException {
		
	// START FF00 END FF00
	// AMPLIAR SEGUN SE NECESITE
	int startAddress = 0xC000;
	int endAddress   = 0xFFFF;
	int block_size   = 0x0400;
	int blocks		 = (endAddress - startAddress + 1) / block_size ;
		
		Scanner keyboard = new Scanner(System.in);
		
		System.out.println(" --= Programador para SBCv1 =--");
		
	// Obtenemos lista de puertos COM disponibles
		SerialPort ports[] = SerialPort.getCommPorts();
		SerialPort port;
		
	// Seleccion de puerto
	
		int selectedPort = 0;
		if (ports.length == 1) selectedPort=1;
		while ( selectedPort < 1 || selectedPort > ports.length ) {
			for(int i=0; i<ports.length; i++) {
				System.out.println(i+1 + ". " + ports[i].getDescriptivePortName());
			}
			
			System.out.println("Seleccione un puerto... ");
			try { selectedPort = keyboard.nextInt(); } catch (Exception e) { selectedPort=0; keyboard.next(); }
		}
		
	// Abrimos el puerto	
		port = ports[selectedPort-1];
		port.openPort();
		port.setComPortParameters(115200, 8, 1, 0);
		port.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, 0, 0);
		
	// Esperamos 5 segundos, que se abra y reinicie el NANO
		Thread.sleep(2000);
		
	// Iniciamos bulk bytes
		System.out.println ("Start program at      : " + startAddress);
		System.out.println ("End program at        : " + endAddress);
		System.out.println (block_size + " byte blocks        : " + blocks);
		
	// Abrimos el fichero
		File file = new File("Z:\\proyectos\\SBCv1\\RAMFlasher\\sbcv1.bin");
		byte[] ram = new byte[(int) file.length()];
		FileInputStream fis = new FileInputStream(file);
		fis.read(ram); 
		fis.close();
		
			InputStream in = port.getInputStream();
			char caracter;
			
			String comando = "S\n";
			byte[] b = comando.getBytes();
		    port.writeBytes(b, b.length);
	        Thread.sleep(200);
			try {
				while (true) {
					caracter = (char)in.read();
					if ( caracter == '@' )
						break;
					else
						System.out.print(caracter);
				}
				in.close();
			} catch (Exception e) { e.printStackTrace(); }
			Thread.sleep(1000);

		
		for (int block = 0; block < blocks; block++) {
			
			comando = "B " + Integer.toHexString(startAddress+block_size*block).toUpperCase() + " 00 " + 
			                        padLeftZeros(Integer.toHexString(block_size).toUpperCase() + "\n",5);
			b = comando.getBytes();
		    port.writeBytes(b, b.length);
	        Thread.sleep(5);
			try {
				while (true) {
					caracter = (char)in.read();
					if ( caracter == '@' )
						break;
					else
						System.out.print(caracter);
				}
				in.close();
			} catch (Exception e) { e.printStackTrace(); }
			//Thread.sleep(5);
			port.writeBytes (ram, block_size, block*block_size);
			Thread.sleep(5);
			
			try {
				while (true) {
					caracter = (char)in.read();
					if ( caracter == '@' )
						break;
					else
						System.out.print(caracter);
				}
				in.close();
			} catch (Exception e) { e.printStackTrace(); }
		}
		
			comando = "X\n";
			b = comando.getBytes();
		    port.writeBytes(b, b.length);
	        Thread.sleep(200);
			try {
				while (true) {
					caracter = (char)in.read();
					if ( caracter == '@' )
						break;
					else
						System.out.print(caracter);
				}
				in.close();
			} catch (Exception e) { e.printStackTrace(); }
			Thread.sleep(1);
		
		port.closePort();
    }

}

// z:
// cd Z:\proyectos\SBCv1\RAMFlasher
// javac -cp Z:\proyectos\SBCv1\RAMFlasher\jSerialComm-2.6.1.jar;. ramFlasher.java
// java -cp Z:\proyectos\SBCv1\RAMFlasher\jSerialComm-2.6.1.jar;. ramFlasher

