package labs;

import static org.junit.Assert.*;

import java.util.Iterator;

import org.junit.Test;

public class HashSetTest {

	@Test
	public void testHashSet() {
		HashSet<String> set = new HashSet<String>();
		set.add("hello");
		assertEquals(1, set.size());
		set.add("world");
		assertEquals(2, set.size());
		set.add("hello");
		assertEquals(2, set.size());
		assertTrue(set.contains("hello"));
		assertTrue(set.contains("world"));
		assertFalse(set.contains("bogus"));
		for (String s : set) {
			System.out.println(s);
		}
		for (Iterator<String> it = set.iterator();
				it.hasNext(); ) {
			String s = it.next();
			System.out.println(s);
		}
	}


}
