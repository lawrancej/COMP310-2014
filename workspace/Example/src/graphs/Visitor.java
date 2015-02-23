package graphs;

public interface Visitor<T> {
	void visit(Node<T> node);
	void visit(Graph<T> graph);
}
