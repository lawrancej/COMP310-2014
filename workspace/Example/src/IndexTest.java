import static org.junit.Assert.*;

import java.util.Set;

import org.junit.Test;


public class IndexTest {

	@Test
	public void testAddItem() {
		Index<String> index = new Index<String>();
		index.addItem("Well", 1);
		index.addItem("Prince", 1);
		index.addItem("Anna", 1);
		index.addItem("Anna", 2);
		index.addItem("Pavlovna", 2);
		
		Set<Integer> chapters = index.getIndices("Anna");
		assertTrue(chapters.contains(1));
		assertTrue(chapters.contains(2));
		
		chapters = index.getIndices("Well");
		assertTrue(chapters.contains(1));
		assertFalse(chapters.contains(2));

		chapters = index.getIndices("Pavlovna");
		assertTrue(chapters.contains(2));
		assertFalse(chapters.contains(1));

	}


}
