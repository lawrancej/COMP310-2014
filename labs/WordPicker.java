import java.awt.List;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;


public class WordPicker {
	ArrayList<String> words;
	
	public WordPicker() throws IOException {
		URL url = new URL("https://raw.githubusercontent.com/lawrancej/COMP310-2014/master/labs/american-english.txt");
		
		InputStream stream = url.openStream();
		BufferedReader reader = new BufferedReader
				(new InputStreamReader(stream));
		
		String word;
		
		System.currentTimeMillis();
		// Read line by line
		while ((word = reader.readLine()) != null) {
			words.add(word);
		}
	}
	
	public boolean isWord(String string) {
		return false;
	}
	
	public List matchingWords(String pattern) {
		return null;
	}
}
