import java.util.HashMap;
import java.util.Map;


public class Example2 {
	public static String reverse(String str) {
		return new StringBuilder(str).reverse().toString();
	}
	/*
	 * Given a string, return whether the string
	 * is a palindrome.
	 */
	public static boolean isPalindrome(String str) {
		return reverse(str).equals(str);
	}
	/*
	 * Given two strings, return whether str1
	 * is an anagram of string2.
	 * Look at each string.
	 * Compute the frequency of each character in the string
	 * (i.e., count the number of occurrences of each character)
	 * compare whether the two maps match up.
	 */
	public static boolean areAnagrams(String str1, String str2) {
		Map<Character,Integer> dict1 = new HashMap<Character,Integer>();
		Map<Character,Integer> dict2 = new HashMap<Character,Integer>();
		
		return false;
	}
	public static void main(String[] args) {
		
	}
}
