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
| `Queue<T>` | `import "collections/queue"` | FIFO queue with enqueue/dequeue |
| `MinHeap<T: Comparable>` | `import "collections/heap"` | Priority queue (min-heap) |
| `HashSet<T: Hashable>` | `import "collections/set"` | Set with add/contains |
| `HashMap<K: Hashable, V>` | `import "collections/map"` | Key-value map with set/get/has |

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

## Testing

```bash
sn --install
make test
```

## License

MIT
