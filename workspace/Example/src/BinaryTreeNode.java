
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
			} else {
				// keep looking recursively
			}
		} else {
			// it goes to the left
			if (left == null) {
				// create a node and call it a day
			} else {
				// keep looking recursively
			}
		}
		// put it there
	}
	public static void main(String[] args) {
		System.out.println("Hello".compareTo("World"));
	}
}
