import java.util.Stack;


public class StackDemo {
	public static void main(String [] args) {
		Stack<String> names = new Stack<String>();
		names.push("Mike");
		names.push("Zack");
		names.push("Jake");
		names.push("Danielle");
		
		System.out.println(names.size());
		System.out.println(names.peek());
		names.pop();
		System.out.println(names.peek());
		names.pop();
		System.out.println(names.peek());
		names.pop();
		System.out.println(names.peek());
		names.pop();
		System.out.println(names.size());
	}
}
