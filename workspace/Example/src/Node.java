
public class Node<Type> {
	private Type data;
	private Node<Type> next;
	private Node<Type> prev;
	public Type getData() {
		return data;
	}
	public void setData(Type data) {
		this.data = data;
	}
	public Node<Type> getNext() {
		return next;
	}
	public void setNext(Node<Type> node /* thing2 */) {
		this.next = node; // thing1.next = thing2
		node.prev = this; // thing2.prev = thing1
	}
	public Node<Type> getPrev() {
		return prev;
	}
	public void setPrev(Node<Type> node /* thing0 */) {
		this.prev = node; // thing1.prev = thing0
		node.next = this; // thing0.next = thing1
	}
}
