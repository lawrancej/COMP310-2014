import java.util.Dictionary;
import java.util.HashMap;
import java.util.Map;

// internationalization -> i18n
// localization -> l10n
public class I18n {
	
	// Key is:   abbreviated string
	// Value is: unabbreviated string
	Map<String,String> dictionary = new HashMap<String,String>();

	// Given a string, convert that string into an abbreviated
	// form. The abbreviation must be shorter than the given string.
	// Count up the number of characters between the first and last
	// characters.
	public static String abbreviate (String input) {
		if (input.length() > 3) {
			int sublength = input.length() - 2;
//			return String.format("%c%d%c", input.charAt(0), sublength,
//			input.charAt(input.length()-1));
			return ""+input.charAt(0)+sublength+input.charAt(input.length()-1);
		} else {
			return input;
		}
	}
	
	// Tell this object that we want want to abbreviate this input string
	public void addAbbreviation(String input) {
		if (!dictionary.containsKey(abbreviate(input))) {
			dictionary.put(abbreviate(input), input);
		}
	}
	
	// See above. However, if two strings have the same abbreviation,
	// only abbreviate one of them
	public String getAbbreviation(String input) {
		String abbreviation = abbreviate(input);
		if (dictionary.containsKey(abbreviation)) {
			String value = dictionary.get(abbreviation);
			if (value.equals(input)) {
				return abbreviation;
			}
		}
		return input;
	}
}
