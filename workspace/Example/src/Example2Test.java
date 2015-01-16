import static org.junit.Assert.*;

import org.junit.Test;


public class Example2Test {

	@Test
	public void testIsPalindrome() {
		assertFalse(Example2.isPalindrome("hello"));
		assertTrue(Example2.isPalindrome("racecar"));
		assertTrue(Example2.isPalindrome("lionoil"));
		assertTrue(Example2.isPalindrome("tacocat"));
	}

	@Test
	public void testAreAnagrams() {
		fail("Not yet implemented");
	}

}
