
public class BinaryTreeNode
	<DataType extends Comparable<DataType>>
{
	DataType data;
	BinaryTreeNode<DataType> left, right;
	BinaryTreeNode(DataType data) {
		this.data = data;
	}
	void add(DataType moreData) {
		// figure out which side to place it
		if (data.compareTo(moreData) <= 0) {
			// it goes to the right
			if (right == null) {
				// create a node with the data and call it a day
				right = new BinaryTreeNode<DataType>(moreData);
			} else {
				// keep looking recursively
				right.add(moreData);
			}
		} else {
			// it goes to the left
			if (left == null) {
				// create a node and call it a day
				left = new BinaryTreeNode<DataType>(moreData);
			} else {
				// keep looking recursively
				left.add(moreData);
			}
		}
	}
	// Can you write this function?
	// Hint: try doing what you do in the add function
	boolean contains (DataType moreData) {
		return false;
	}
	public static void main(String[] args) {
		System.out.println("Hello".compareTo("World"));
	}
	public static interface Visitor<T extends Comparable<T>> {
		public void visit(BinaryTreeNode<T> node);
	}
	public void accept(Visitor<DataType> v) {
		v.visit(this);
	}
}
