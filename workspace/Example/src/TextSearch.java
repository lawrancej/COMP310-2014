import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.MalformedURLException;
import java.net.URL;


public class TextSearch {
	
	public static void main(String[] args) throws IOException {
		// Read war and peace
		URL url = new URL("https://www.gutenberg.org/cache/epub/2600/pg2600.txt");
		
		InputStream warNPeace = url.openStream();
		BufferedReader reader = new BufferedReader
				(new InputStreamReader(warNPeace));
		
		String line;
		
		long startOfTime = System.nanoTime();
		
		System.currentTimeMillis();
		// Read line by line
		while ((line = reader.readLine()) != null) {
			if (line.contains("Professor Michael S. Hart is the originator of the Project Gutenberg-tm")) {
				System.out.println(System.nanoTime() - startOfTime);
			}
		}
	}

}
