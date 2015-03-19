package labs;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;

public class HashSet<T> implements Set<T> {
	private ArrayList<LinkedList<T>> structure;
	private int size;
	public HashSet() {
		clear();
	}
	@Override
	public void clear() {
		// Let the garbage collector to the actual work for us :-)
		structure = new ArrayList<LinkedList<T>>();
		for (int i = 0; i < 13; i++) {
			structure.add(new LinkedList<T>());
		}
		size = 0;
	}

	@Override
	public int size() {
		return size;
	}

	@Override
	public boolean isEmpty() {
		return size == 0;
	}
	
	@Override
	public boolean add(Object arg0) {
//		Hint: use arg0.hashCode();
//		Hint: do proper bookkeeping on the size
		return false;
	}

	@Override
	public boolean contains(Object arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public Iterator<T> iterator() {
		return new Iterator<T>() {
			@Override
			public boolean hasNext() {
				// TODO Auto-generated method stub
				return false;
			}
			@Override
			public T next() {
				// TODO Auto-generated method stub
				return null;
			}
			
		};
	}

	@Override
	public boolean remove(Object arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	// These are all pretty similar in terms of implementation
	@Override
	public boolean addAll(Collection arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public boolean containsAll(Collection arg0) {
		// TODO Auto-generated method stub
		return false;
	}
	@Override
	public boolean removeAll(Collection arg0) {
		// TODO Auto-generated method stub
		return false;
	}

	@Override
	public Object[] toArray() {
		// TODO Auto-generated method stub
		return null;
	}

	// Don't bother implementing, unless you want to do reflection.
	@Override
	public Object[] toArray(Object[] arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	// Don't bother implementing.
	@Override
	public boolean retainAll(Collection arg0) {
		// TODO Auto-generated method stub
		return false;
	}

}
