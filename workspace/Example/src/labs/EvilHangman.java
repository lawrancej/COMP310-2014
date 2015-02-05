package labs;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.Scanner;

/**
 * In Evil Hangman, the computer maintains a list of every word in the
 * English language, then continuously pares down the word list to try
 * to dodge the player's guesses as much as possible.
 *
 * Details here:
 * http://nifty.stanford.edu/2011/schwarz-evil-hangman/Evil_Hangman.pdf
 */
public class EvilHangman extends Hangman {
	EvilHangman() throws FileNotFoundException {
		super();
		File file = new File("resources/dictionary.txt");
		FileReader reader = new FileReader(file);
		Scanner scanner = new Scanner(reader);
		// TODO: build up a data structure here
		while (scanner.hasNextLine()) {
			System.out.println(scanner.nextLine());
		}
	}
	// TODO: extend existing methods to be evil
}
