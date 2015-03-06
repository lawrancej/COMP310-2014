import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintStream;


public class GraphViz<T extends Comparable<T>>
	implements BinaryTreeNode.Visitor<T> {
	
	private int id = 0;
	
	PrintStream stream;
	
	GraphViz() {
		stream = System.out;
	}
	
	GraphViz(String path) throws IOException {
		stream = new PrintStream(path);
	}

	@Override
	public void visit(BinaryTreeNode<T> node) {
		// Print graph boilerplate
		if (node.parent == null) {
			id = 0;
			stream.println("digraph g { splines=false;" +
			"node [ fontsize = \"16\" shape = \"record\"];");
		}

		int temp = id;

		// Print node
		stream.format("node%d [ label = \"{ <f0> %s" +
		"| {<f1> left | <f2> right } } \" ];\n",
		id, node.data.toString());

		// Print left child
		if (node.left != null) {
			id = 2*id + 1;
			node.left.accept(this);
			id = temp;

			// Print edge
			stream.format("\"node%d\":f1 -> \"node%d\";\n", id, 2*id+1);
		}
		// Print right child
		if (node.right != null) {
			id = 2*id + 2;
			node.right.accept(this);
			id = temp;

			// Print edge
			stream.format("\"node%d\":f2 -> \"node%d\";\n", id, 2*id+2);
		}

		// End graph boilerplate
		if (node.parent == null) {
			stream.println("}");
		}
	}
}
