import java.awt.List;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public abstract class WordPicker {
	ArrayList<String> words;
	ArrayList<HashMap<Character,HashSet<Integer>>> cool = new ArrayList<HashMap<Character,HashSet<Integer>>>();
	
	// Subclasses may, of course, extend this as necessary
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
	
	// Super duper easy
	// One subclass (LinearWordPicker) implements a simple
	// linear search
	// Iterate through and see if you find the string
	// If you find it, great! If not, that's okay too.
	
	// The other subclass (FancyWordPicker) will have a
	// Set<String> (the set of words in the dictionary.)
	// That'll be super easy, too.
	// The implementation type could be a HashSet<String>
	public abstract boolean isWord(String string);
	
	// LinearWordPicker will use the string as a pattern
	// It'll just use the matches method in the string class
	// to build up a list of matching words in the dictionary
	// the gist of it is: grep pattern words
	// Iterate through and do the string match, as you build
	// up a list of words
	
	// FancyWordPicker won't match all possible regexen
	// (that'd be crazy). Instead, it'll be able to match
	// regex of this form: letter or anything for each spot
	// in a string.
	// Let's build up an index for each possible character
	// position in a sequence.
	// 
	// ArrayList<HashMap<Character,HashSet<Integer>>>
	public abstract List matchingWords(String pattern);
}
