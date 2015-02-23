// Visitor design pattern tortured into doing basic tree
// traversal
public class Traversal<DataType> {
	public interface Visitor<DataType> {
		void visit(BinaryTreeNode<DataType> node);
	}
	public static class BinaryTreeNode<DataType>
	{
		DataType data;
		BinaryTreeNode<DataType> left, right;
		void accept(Visitor<DataType> v) {
			v.visit(this);
		}
	}
	public static class PrefixVisitor<DataType> implements
	Visitor<DataType> {
		@Override
		public void visit(BinaryTreeNode<DataType> node) {
			System.out.println(node.data);
			
			if (node.left != null) {
				node.left.accept(this);
			}
			if (node.right != null) {
				node.right.accept(this);
			}
		}
	}
	public static class PostfixVisitor<DataType> implements
	Visitor<DataType> {
		@Override
		public void visit(BinaryTreeNode<DataType> node) {
			
			if (node.left != null) {
				node.left.accept(this);
			}
			if (node.right != null) {
				node.right.accept(this);
			}
			System.out.println(node.data);
		}
	}
	public static class InfixVisitor<DataType> implements
	Visitor<DataType> {
		@Override
		public void visit(BinaryTreeNode<DataType> node) {
			
			if (node.left != null) {
				node.left.accept(this);
			}
			System.out.println(node.data);
			if (node.right != null) {
				node.right.accept(this);
			}
		}
	}
	public static void main(String[] args) {
		BinaryTreeNode<String> root = new BinaryTreeNode<String>();
		root.data = "Ian";
		root.left = new BinaryTreeNode<String>();
		root.left.data = "andy";
		root.right = new BinaryTreeNode<String>();
		root.right.data = "joey";
		
		root.left.left = new BinaryTreeNode<String>();
		root.left.left.data = "amanda";
		root.left.right = new BinaryTreeNode<String>();
		root.left.right.data = "zack";

		root.right.left = new BinaryTreeNode<String>();
		root.right.left.data = "tyler";
		root.right.right = new BinaryTreeNode<String>();
		root.right.right.data = "mallory";
		
		PrefixVisitor<String> prefix = new PrefixVisitor<String>();
		root.accept(prefix);
		PostfixVisitor<String> postfix = new PostfixVisitor<String>();
		root.accept(postfix);
		InfixVisitor<String> infix = new InfixVisitor<String>();
		root.accept(infix);

	}
}
