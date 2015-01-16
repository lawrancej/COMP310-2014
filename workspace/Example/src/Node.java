
public class Node<Type> {
	private Type data;
	private Node<Type> link;
	public Type getData() {
		return data;
	}
	public void setData(Type data) {
		this.data = data;
	}
	public Node<Type> getLink() {
		return link;
	}
	public void setLink(Node<Type> link) {
		this.link = link;
	}
}
