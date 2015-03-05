
public class BinaryTreeNode
	<DataType extends Comparable<DataType>>
{
	DataType data;
	BinaryTreeNode<DataType> left, right, parent;
	BinaryTreeNode(DataType data) {
		this.data = data;
		this.parent = null;
	}
	private BinaryTreeNode(DataType data,
			BinaryTreeNode<DataType> parent) {
		this.data = data;
		this.parent = parent;
	}
	void add(DataType moreData) {
		BinaryTreeNode<DataType> node = findNode(moreData);
		if (node.data.compareTo(moreData) <= 0) {
			node.right = new BinaryTreeNode<DataType>(moreData, this);
		} else {
			node.left = new BinaryTreeNode<DataType>(moreData, this);
		}
	}
	boolean remove (DataType item) {
		BinaryTreeNode<DataType> node = findNode(item);
		// If we didn't find the item
		if (!node.data.equals(item)) {
			return false;
		}
		// If we got here, we got work to do.
		// if the node has no left and no right child
		if (node.left == null && node.right == null) {
			if (node.parent != null) {
				if (node.parent.left == node) {
					node.parent.left = null;
				} else {
					node.parent.right = null;
				}
			}
		}
		// if the node has one child figure out what to do
		// if the node has two kids it gets messy
		BinaryTreeNode<DataType> pointer;
		for (pointer = node.left;
				pointer.right != null;
				pointer = pointer.right);
		
		return false;
	}
	// Return a node with the data in it, or the parent
	BinaryTreeNode<DataType> findNode (DataType data) {
		int result = this.data.compareTo(data);
		// The data we're looking for is not in this node
		if (result < 0) {
			if (right == null) {
				return this;
			} else {
				return right.findNode(data);
			}
		// The data we're looking is in this node
		} else if (result == 0) {
			return this;
		// The data we're looking for is not in this node
		} else {
			if (left == null) {
				return this;
			} else {
				return left.findNode(data);
			}
		}
	}
	// You can write this function!
	// Do what you do in the add function
	boolean contains (DataType data) {
		BinaryTreeNode<DataType> node = findNode(data);
		return node.data.equals(data);
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
