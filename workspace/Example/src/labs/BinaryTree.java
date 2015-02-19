package labs;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * Binary Tree using an ArrayList
 */
public class BinaryTree<T extends Comparable<T>> implements Iterable<T> {
	private ArrayList<T> elements;
	public BinaryTree() {
		elements = new ArrayList<T>();
	}
	public int left(int index) {
		return 2 * index + 1;
	}
	public int right(int index) {
		return 2 * index + 2;
	}
	public int parent(int index) {
		return (index - 1) / 2;
	}
	public T get(int index) {
		try {
			return elements.get(index);
		} catch (Exception e) {
			return null;
		}
	}
	public void set(int index, T element) {
		elements.set(index, element);
	}
	public int add(T element) {
		// just add it to the end
		elements.add(element);
		return elements.size() - 1;
	}
	public int search(T element) {
		// linear search
		return elements.lastIndexOf(element);
	}
	@Override
	public Iterator<T> iterator() {
		// delegation, ftw
		return elements.iterator();
	}
}
