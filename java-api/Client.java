import java.io.*;
import java.net.*;

public class Client {

	int portNumber;
	Socket theSocket;
	ObjectOutputStream out;
 	ObjectInputStream in;
	String inMsg;

	public Client(int aPort) {
		portNumber = aPort;
	}

	public void run() {
		try {
			theSocket = new Socket("localhost", portNumber);
			out = new ObjectOutputStream(theSocket.getOutputStream());
			out.flush();
			in = new ObjectInputStream(theSocket.getInputStream());

			try {
				sendMessage("<start>This is a test from Java<end>");
				say("message sent");
				inMsg = (String)in.readObject();
				say("got: "+inMsg);
			}
			catch (ClassNotFoundException classNot) {
				System.err.println("data received in unknown format");
			}
		}
		catch(UnknownHostException unknownHost){
			System.err.println("You are trying to connect to an unknown host!");
		}
		catch(IOException ioException){
			ioException.printStackTrace();
		}
		finally{
			try{
				in.close();
				out.close();
				theSocket.close();
			}
			catch(IOException ioException){
				ioException.printStackTrace();
			}
		}
	}

	private void say(String aText) {
		System.out.println(aText);
	}

	private void send(String aMsg) {
		try{
			out.writeObject(aMsg);
			out.flush();
		}
		catch(IOException ioException){
			ioException.printStackTrace();
		}
	}

	public static void main(String[] args) {
		say(args[0]);
		say(args[1]);
		Client aClient = new Client(args[1]);
		client.run();
	}
}
