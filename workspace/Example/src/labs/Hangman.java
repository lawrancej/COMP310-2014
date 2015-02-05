package labs;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class Hangman {
	private String word;
	private Set<Character> guesses = new HashSet<Character>();
	private Set<Character> correct = new HashSet<Character>();
	// Reset the game
	public void reset() {
		guesses.clear();
		correct.clear();
	}
	// Begin the game
	public void setWord(String word) {
		this.word = word;
	}
	// Get the word
	public String getWord() {
		return word;
	}
	// Get guesses
	public Set<Character> getGuesses() {
		return guesses;
	}
	// Make a guess. Returns whether the guess was added
	public boolean makeGuess(char letter) {
		if (guesses.contains(letter)) {
			return false;
		}
		guesses.add(letter);
		if (word.contains("" + letter)) {
			correct.add(letter);
		}
		return true;
	}
	// What can the player see?
	public String visible() {
		StringBuilder b = new StringBuilder();
		for (char letter : word.toCharArray()) {
			b.append(guesses.contains(letter) ? letter : '*');
		}
		return b.toString();
	}
	// Did the player win?
	public boolean won() {
		return word.equals(visible());
	}
	// How many guesses remain?
	public int guessesRemaining() {
		return 6 - (guesses.size() - correct.size());
	}
	// Is the game over?
	public boolean isOver() {
		return (guessesRemaining() <= 0) || won();
	}
}
