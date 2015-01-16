import java.util.HashSet;
import java.util.Set;


public class SetDemo {
	public static void main(String[] args) {
		// Set<Thing>
		Set<Integer> set = new HashSet<Integer>();
		// Sets are a collection of things.
		// 1. There's no order to them
		// 2. Everything is unique
		set.add(5);
		set.add(10);
		set.add(5);
		set.add(11);
		set.add(12);
		set.add(13);
		set.add(14);
		set.add(15);
		set.add(16);
		set.add(17);
		set.add(18);
		
		for (int item : set) {
			System.out.println(item);
		}
	}
}
