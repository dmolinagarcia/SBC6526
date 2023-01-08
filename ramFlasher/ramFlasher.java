import com.fazecast.jSerialComm.*;
import java.util.*;
import java.io.*;
import java.util.Scanner;

/* Cargador de memoria ram para SBCv2
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

	static SerialPort getPort() {

		Scanner keyboard = new Scanner(System.in);

		// Obtenemos lista de puertos COM disponibles
		SerialPort ports[] = SerialPort.getCommPorts();

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

		return ports[selectedPort-1];
	}
	
	public static void main(String[] args) throws InterruptedException,IOException {

		String binFile = args[0];
		
	// START F000 END FF00
	// AMPLIAR SEGUN SE NECESITE
		int startAddress = 0xE000;
		int endAddress   = 0xFFFF;
		int block_size   = 0x0400;
		int blocks		 = (endAddress - startAddress + 1) / block_size ;
		
		System.out.println(" --= Programador para SBCv2 =--");
		System.out.println(" Programando fichero " + binFile);
		
	// Abrimos el puerto	
		SerialPort port = getPort();
		port.setFlowControl( SerialPort.FLOW_CONTROL_DISABLED );
		port.clearDTR();
		port.openPort();
		port.setComPortParameters(115200, 8, 1, 0);
		port.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, 0, 0);
		
	// Esperamos 5 segundos, que se abra y reinicie el NANO
		Thread.sleep(1500);
		
	// Iniciamos bulk bytes
		System.out.println ("Start program at      : " + startAddress);
		System.out.println ("End program at        : " + endAddress);
		System.out.println (block_size + " byte blocks        : " + blocks);
		
		long startTime = System.nanoTime();

	// Abrimos el fichero
		File file = new File (binFile);
		
		byte[] ram = new byte[(int) file.length()];
		FileInputStream fis = new FileInputStream(file);
		fis.read(ram); 
		fis.close();
		
			InputStream in = port.getInputStream();
			char caracter;
			
			String comando = "S\n";
			byte[] b = comando.getBytes();
		    port.writeBytes(b, b.length);
	        Thread.sleep(20);
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
			Thread.sleep(10);

		for (int block = 0; block < blocks; block++) {
			
			comando = "B " + Integer.toHexString(startAddress+block_size*block).toUpperCase() + " 00 " + 
			                        padLeftZeros(Integer.toHexString(block_size).toUpperCase() + "\n",5);
			b = comando.getBytes();
		    port.writeBytes(b, b.length);
	        Thread.sleep(4);
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
			Thread.sleep(4);
			
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

		long stopTime = System.nanoTime();
		System.out.println((stopTime - startTime)/1000000);

    }

}

// z:
// cd Z:\proyectos\SBCv1\RAMFlasher
// javac -cp Z:\proyectos\SBCv1\RAMFlasher\jSerialComm-2.6.1.jar;. ramFlasher.java
// java -cp Z:\proyectos\SBCv1\RAMFlasher\jSerialComm-2.6.1.jar;. ramFlasher

