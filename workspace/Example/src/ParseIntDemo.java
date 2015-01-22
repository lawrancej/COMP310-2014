
public class ParseIntDemo {
	public static void main(String[] args) {
		try {
			int year = Integer.parseInt("Hello");
			System.out.println(year);
		} catch (NumberFormatException e) {
			System.out.println("Not a number, silly");
		}
	}
}
