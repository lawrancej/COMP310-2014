
public class Example {
	/*
	 * Write a program that counts from 1 to 100
	 * with the exception that if the number is
	 * a multiple of 3, print Fizz instead of the number
	 * if the number is a multiple of 5, print Buzz
	 * instead. and if it's a multiple of 3 and 5, 
	 * print FizzBuzz.
	 */
	public static void main(String[] args) {
		for (int i = 1; i <= 100; i++) {
			System.out.println(fizzbuzzer(i));
		}
	}

	private static String fizzbuzzer(int i) {
		if (i % 15 == 0) {
			return "FizzBuzz";
		} else if (i % 3 == 0) {
			return "Fizz";
		} else if (i % 5 == 0) {
			return "Buzz";
		}
		return Integer.toString(i);
	}
}
