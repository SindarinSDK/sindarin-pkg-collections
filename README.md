# Sindarin Collections

A pure [Sindarin](https://github.com/SindarinSDK/sindarin-compiler) collections library — no native C, no external dependencies. Provides generic data structures with iterator support for `for x in collection` loops.

## Installation

Add the package as a dependency in your `sn.yaml`:

```yaml
dependencies:
- name: sindarin-pkg-collections
  git: git@github.com:SindarinSDK/sindarin-pkg-collections.git
  branch: main
```

Then run `sn --install` to fetch the package.

## Collections

| Collection | Import | Description |
|------------|--------|-------------|
| `List<T>` | `import "collections/list"` | Dynamic array with push/pop/get/set |
| `Stack<T>` | `import "collections/stack"` | LIFO stack with push/pop/peek |
| `Queue<T>` | `import "collections/queue"` | FIFO queue with enqueue/dequeue |
| `Deque<T>` | `import "collections/deque"` | Double-ended queue |
| `MinHeap<T: Comparable>` | `import "collections/heap"` | Priority queue (min-heap) |
| `HashSet<T: Hashable>` | `import "collections/set"` | Set with add/contains |
| `HashMap<K: Hashable, V>` | `import "collections/map"` | Key-value map with set/get/has |
| `BitSet` | `import "collections/bitset"` | Fixed-size bit vector |
| `UnionFind` | `import "collections/unionfind"` | Disjoint set with path compression |
| `Graph` | `import "collections/graph"` | Directed graph with BFS/DFS/topological sort |
| `mergeSort` | `import "collections/sort"` | Stable O(n log n) merge sort |
| `insertionSort` | `import "collections/sort"` | Stable O(n^2) insertion sort |

## Quick Start

### List

```sindarin
import "collections/list"

var nums: List<int> = List<int> { items: {}, count: 0 }
nums.push(10)
nums.push(20)
nums.push(30)

println(nums.get(0))       # 10
println(nums.size())       # 3
println(nums.contains(20)) # true

for n in nums =>
    println(n)
```

### Queue

```sindarin
import "collections/queue"

var q: Queue<str> = Queue<str> { items: {}, head: 0, count: 0 }
q.enqueue("first")
q.enqueue("second")
q.enqueue("third")

println(q.peek())    # first
println(q.dequeue()) # first
println(q.dequeue()) # second
```

### MinHeap

Elements must implement `Comparable` (method `compare(other: Self): int`).

```sindarin
import "collections/heap"

struct Task =>
    priority: int

    fn compare(other: Task): int =>
        if self.priority < other.priority => return -1
        if self.priority > other.priority => return 1
        return 0

var pq: MinHeap<Task> = MinHeap<Task> { items: {}, count: 0 }
pq.push(Task { priority: 3 })
pq.push(Task { priority: 1 })
pq.push(Task { priority: 2 })

println(pq.pop().priority) # 1 (lowest priority first)
println(pq.pop().priority) # 2
```

### HashSet

Elements must implement `Hashable` (methods `hash(): int` and `equals(other: Self): bool`).

```sindarin
import "collections/set"

struct UserId =>
    id: int

    fn hash(): int => return self.id * 31
    fn equals(other: UserId): bool => return self.id == other.id

var seen: HashSet<UserId> = HashSet<UserId> { items: {}, count: 0 }
seen.add(UserId { id: 1 })
seen.add(UserId { id: 2 })

println(seen.contains(UserId { id: 1 })) # true
println(seen.contains(UserId { id: 3 })) # false
println(seen.size())                      # 2
```

### HashMap

Keys must implement `Hashable`.

```sindarin
import "collections/map"

struct StrKey =>
    name: str

    fn hash(): int =>
        var h: int = 0
        for i in 0..len(self.name) =>
            h = h * 31 + self.name[i]
        return h

    fn equals(other: StrKey): bool => return self.name == other.name

var scores: HashMap<StrKey, int> = HashMap<StrKey, int> { keys: {}, values: {}, count: 0 }
scores.set(StrKey { name: "alice" }, 95)
scores.set(StrKey { name: "bob" }, 82)

println(scores.get(StrKey { name: "alice" })) # 95
println(scores.has(StrKey { name: "bob" }))   # true

for entry in scores =>
    println(entry.key.name)
    println(entry.value)
```

## API Reference

### List\<T\>

| Method | Signature | Description |
|--------|-----------|-------------|
| `push` | `fn push(item: T): void` | Append item to end |
| `pop` | `fn pop(): T` | Remove and return last item |
| `get` | `fn get(index: int): T` | Get item at index |
| `set` | `fn set(index: int, value: T): void` | Set item at index |
| `size` | `fn size(): int` | Number of items |
| `isEmpty` | `fn isEmpty(): bool` | True if empty |
| `contains` | `fn contains(item: T): bool` | True if item exists |
| `clear` | `fn clear(): void` | Remove all items |
| `iter` | `fn iter(): ListIter<T>` | Iterator for `for x in list` |

### Queue\<T\>

| Method | Signature | Description |
|--------|-----------|-------------|
| `enqueue` | `fn enqueue(item: T): void` | Add item to back |
| `dequeue` | `fn dequeue(): T` | Remove and return front item |
| `peek` | `fn peek(): T` | View front item without removing |
| `size` | `fn size(): int` | Number of items |
| `isEmpty` | `fn isEmpty(): bool` | True if empty |
| `iter` | `fn iter(): QueueIter<T>` | Iterator for `for x in queue` |

### MinHeap\<T: Comparable\>

| Method | Signature | Description |
|--------|-----------|-------------|
| `push` | `fn push(item: T): void` | Insert item (maintains heap order) |
| `pop` | `fn pop(): T` | Remove and return smallest item |
| `peek` | `fn peek(): T` | View smallest item without removing |
| `size` | `fn size(): int` | Number of items |
| `isEmpty` | `fn isEmpty(): bool` | True if empty |

### HashSet\<T: Hashable\>

| Method | Signature | Description |
|--------|-----------|-------------|
| `add` | `fn add(item: T): void` | Add item (no-op if exists) |
| `contains` | `fn contains(item: T): bool` | True if item exists |
| `size` | `fn size(): int` | Number of items |
| `isEmpty` | `fn isEmpty(): bool` | True if empty |

### HashMap\<K: Hashable, V\>

| Method | Signature | Description |
|--------|-----------|-------------|
| `set` | `fn set(key: K, value: V): void` | Set key-value pair (overwrites if exists) |
| `get` | `fn get(key: K): V` | Get value for key |
| `has` | `fn has(key: K): bool` | True if key exists |
| `size` | `fn size(): int` | Number of entries |
| `isEmpty` | `fn isEmpty(): bool` | True if empty |
| `iter` | `fn iter(): HashMapIter<K, V>` | Iterator yielding `Entry<K, V>` |

### Stack\<T\>

| Method | Signature | Description |
|--------|-----------|-------------|
| `push` | `fn push(item: T): void` | Push item onto top |
| `pop` | `fn pop(): T` | Remove and return top item |
| `peek` | `fn peek(): T` | View top item without removing |
| `size` | `fn size(): int` | Number of items |
| `isEmpty` | `fn isEmpty(): bool` | True if empty |

### Deque\<T\>

| Method | Signature | Description |
|--------|-----------|-------------|
| `pushBack` | `fn pushBack(item: T): void` | Add item to back |
| `pushFront` | `fn pushFront(item: T): void` | Add item to front |
| `popBack` | `fn popBack(): T` | Remove and return back item |
| `popFront` | `fn popFront(): T` | Remove and return front item |
| `peekBack` | `fn peekBack(): T` | View back item |
| `peekFront` | `fn peekFront(): T` | View front item |
| `size` | `fn size(): int` | Number of items |
| `isEmpty` | `fn isEmpty(): bool` | True if empty |
| `iter` | `fn iter(): DequeIter<T>` | Iterator for `for x in deque` |

### BitSet

| Method | Signature | Description |
|--------|-----------|-------------|
| `set` | `fn set(index: int): void` | Set bit at index |
| `clear` | `fn clear(index: int): void` | Clear bit at index |
| `get` | `fn get(index: int): bool` | Test if bit is set |
| `clearAll` | `fn clearAll(): void` | Clear all bits |
| `popcount` | `fn popcount(): int` | Count set bits |

Create with: `newBitSet(n)` where `n` is the number of bits.

### UnionFind

| Method | Signature | Description |
|--------|-----------|-------------|
| `find` | `fn find(x: int): int` | Find root (with path compression) |
| `union` | `fn union(x: int, y: int): void` | Merge sets containing x and y |
| `connected` | `fn connected(x: int, y: int): bool` | True if x and y in same set |
| `componentCount` | `fn componentCount(): int` | Number of disjoint sets |

Create with: `newUnionFind(n)` where `n` is the number of elements.

### Graph

| Method | Signature | Description |
|--------|-----------|-------------|
| `addEdge` | `fn addEdge(from: int, to: int): void` | Add directed edge |
| `neighbors` | `fn neighbors(v: int): int[]` | Get adjacency list |
| `bfs` | `fn bfs(source: int): int[]` | Breadth-first traversal order |
| `dfs` | `fn dfs(source: int): int[]` | Depth-first traversal order |
| `topologicalSort` | `fn topologicalSort(): int[]` | Topological order (empty if cycle) |

Create with: `newGraph(n)` where `n` is the number of vertices.

### Sort Functions

```sindarin
import "collections/sort"

# Elements must implement Comparable (compare(other: Self): int)
var sorted: Val[] = mergeSort(arr)      # stable, O(n log n)
var sorted: Val[] = insertionSort(arr)  # stable, O(n^2)
```

## Testing

```bash
sn --install
make test
```

## Benchmarks

```bash
make benchmark            # Optimized build — peak RSS + CPU time
make benchmark-asan       # ASAN build — memory safety validation
make benchmark-valgrind   # Valgrind memcheck — leak detection
make benchmark-massif     # Valgrind massif — heap profiling
```

All benchmarks exercise every collection at scale (100k ops for O(n log n) structures, 5k for O(n^2) hash structures). Memory validation confirms zero leaks across 2.58M allocations.

## License

MIT
