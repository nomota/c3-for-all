# Collections

C3 provides a bunch of data structures. or containers. All of them are generic modules. They are all in `std::collections` library module and you have to put `import std::collections;` in your code to use. See also [Generics](generics.md)

* Lists
  * `List{Type}`: general list of `Type`
  * `ElasticArray{Type. MAX_SIZE}`: array of `Type` with `MAX_SIZE`
  * `AnyList`: heterogeneous list of `any`, it holds not only `any` itbut also the things that `any` is pointing to
  * `InterfaceList{Interface}`: list of interfaces, not only the interface itbut also the real object that is implimenting the interface
  * `LinkedList{Type}`: linked list of `Type`
* Maps
  * `LinkedHashMap{Key,Value}`: map of `Key` to `Value`
  * `HashMap{Key, Value}`: general map of `Key` to `Value`
  * `EnumMap{Enum. Value}`: enum-keyed map
* Sets
  * `BitSet{SIZE}`: set of bits
  * `EnumSet{Enum}`: set of enums
  * `HashSet{Type}`: set of `Type`
  * `LinkedHashSet{Type}`: set of `Type`
* Queues
  * `LinkedBlockingQueue{Value}`: queue of `Value`, thread safe queue
  * `PriorityQueue{Value}`: queue of `Value`, values are partially ordered
  * `RingBuffer{Value}`: ring buffer
* Others
  * `Object`: object that can hold any kind of data (for decoding json)
  * `Maybe{Type}`: something that may or may not hold a data of `Type`
  * `Range{Type}`: range of data of `Type`, that can iterate without memory consumption
  * `Pair{Type1,Type2}`, `Triple{Type1,Type2,Type3}`: tuples
 
### List {Type}

List is a linear collection of same `Type`.

Following is the complete list of functions/macros available for `List{Type}`. For `Allocator`, see also [Memory Allocation](memory-allocation.md)

```c3
import std::collections::list;

Allocator allocx;
List{Type} list;

// initialize and returns it
List{Type}* l = list.init(allocx, usz initial_capacity = 16);
List{Type}* l = list.tinit(usz initial_capacity = 16);
List{Type}* l = list.init_with_array(allocx, Type[] values);
List{Type}* l = list.tinit_with_array(Type[] val);
```

If you want to view an array as a list. you can use following method. Note that it's an array, and it's not allowed beyond array.len.

```c3
void list.init_wrapping_array(allocx, Type[] array);
```

If you want to print the entire list using `io::printfn()` with `%s` spefifier, define following `@dynamic` function.

```c3
usz? List{Type}.to_format(&self, Formatter* f) @dynamic 
{
    // n = f.print(sel.xxx);
    // n += f.printf("%x", self.yyy);
    // return n;
}
```

```c3
void list.push(Type element);
Type? item = list.pop();
void list.clear();
Type? item = list.pop_first();
void list.remove_at(usz index);
void list.add_all(List{Type}* other_list);
Type[] array = list.to_aligned_array(allocx);
Type[] array = list.to_array(allocx);
Type[] array = list.to_tarray();
void list.reverse();
Type[] array = list.array_view();
void list.push_all(Type[] array);
void list.push_front(Type data);
void list.insert_at(usz index, Type data);
void list.set_at(usz index, Type data);

// following functions may return ERROR?, but that can be ignored without `(void)` casting.
void? list.remove_last() @maydiscard;
void? list.remove_first() @maydiscard;

Type? value = list.first();
Type? value = list.last();
bool b = list.is_empty();
usz n = list.byte_size();
Type value = list.get(usz index);
void list.free();
void list.swap(usz i, usz j);
void list.reserve(usz added);
```

If you want to remove or retain elements using specific condition, you can define your own filter function like this.

```c3
bool filter1(Type* data) {
    // return true or false
    // depending on the data
}
usz n = list.remove_if(&filter1);
usz n = list.retain_if(&filter1);

bool filter2(Type* data, any context) {
    // return true or false
    // depending on the data
    // in certain context
}
usz n = list.remove_using_test(&filter2, any context);
usz n = list.retain_using_test(&filter2, any context);
```

`List{Type}` can be treated like arrays, using `[]` indexing and `.len` operator, thanks to following functions.

```c3
usz n = list.len() @operator(len);
Type value = list.@item_at(usz index) @operator([]);
Type* ptr = list.get_ref(usz index); @operator(&[]);
void list.set(usz index, Type value) @operator([]=);
```

A `Type` is equitable if `Type.less()`, `Type.compare_to()`, or `Type.equals()` is defined.

```c3
usz? idx = list.index_of(Type value) @if (ELEMENT_IS_EQUATABLE);
usz? idx = list.rindex_of(Type value) @if (ELEMENT_IS_EQUATABLE);
bool b = list.equals(List{Type} other_list) @if(ELEMENT_IS_EQUATABLE);
bool b = list.contains(Type value) @if(ELEMENT_IS_EQUATABLE);
bool b = list.remove_last_item(Type value) @if(ELEMENT_IS_EQUATABLE);
bool b = list.remove_first_item(Type value) @if(ELEMENT_IS_EQUATABLE);
usz n = list.remove_item(Type value) @if(ELEMENT_IS_EQUATABLE);
void list.remove_all_from(List{Type}* other_list) @if(ELEMENT_IS_EQUATABLE);
```

If the elements of a list are pointers,some of them could be `null`, then we can remove them to make a compact list.

```c3
usz n = list.compact_count() @if(ELEMENT_IS_POINTER);
usz n = list.compact() @if(ELEMENT_IS_POINTER);
```

In order to sort a list, we can use algorithms in `std::sort` module. To use sorting algorithms, we need to supply comparison function.

```c3
import std::sort;

// comparison function shoud return -1, 0, 1 depending on relative order of a and b
int cmp(Type a, Type b) 
{
    // if a < b return -1
    // if b < a return 1
    // else return 0
}

// sort is done in place, so pass &list as reference
void sort::quicksort(&list, &cmp);
void sort::insertionsort(&list, &cmp);
void sort::countingsort(&list, &cmp);

// for simple arrays, slice is ok, not &slice, because slice is a kind of pointer
int[] slice = { 1, 3, 9, 6 };
void sort::quicksort(slice, &cmp);

// two more functions are in std::sort module
bool b = sort::is_sorted(list, &cmp);
// binarysearch() returns idx position where x can be inserted to preserve ordered
usz idx = sort::binarysearch(&list, x, &cmp);
```

### HashMap{Key, Val}

`HashMap{Key,Value}` is a map of `Key` to `Value`. It's a collection of `Entry`s which has `.key` and `.value`. For dynamic allocation, you need to supply `allocator`. See also [Memory Allocation](memory-allocation.md)
Initializers return itself. Capacity and load factor drastically affect on space and time efficiency. Default capacity is 16 and default load factor is 0.75.

```c3
import std::collections::map;

HashMap{Key,Value} hashmap;
Allocator allocx;

HashMap* map = hashmap.init(allocx, uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashMap* map = hashmap.tinit(uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashMap* map =  hashmap.init_with_key_values(allocx, ..., uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashMap* map = hashmap.tinit_with_key_values(..., uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashMap* map = hashmap.init_from_keys_and_values(allocx, Key[] keys, Value[] values, uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashMap* map = hashmap.tinit_from_keys_and_values(Key[] keys, Value[] values, uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
bool b = hashmap.is_initialized();
HashMap* map = hashmap.init_from_map(allocx, HashMap* other_map);
HashMap* map = hashmap.tinit_from_map(HashMap* other_map);
```

```
bool b = hashmap.is_empty();
usz n = hashmap.len();
Value*? val = hashmap.get_ref(Key key);
Entry*? entry = hashmap.get_entry(Key key);
Value val = hashmap.@get_or_set(Key key, Value #expr);
bool b = hashmap.has_key(Key key);
```

Thanks to following functions, we can access map like arrays `map[key] = val` or `val = map[key]`.

```c3
bool b = hashmap.set(Key key, Value value) @operator([]=);
Value? val = hashmap.get(Key key) @operator([]);
Value* val = hashmap.get_or_create_ref(Key key) @operator(&[]);
```

```c3
// returning error can be discarded without (void) casting.
void? hashmap.remove(Key key) @maydiscard;

void hashmap.clear();
void hashmap.free();
Key[] keys = hashmap.tkeys();
Key[] keys = hashmap.keys(allocx);
```

C3 macro accepts trailing body as an argument and it makes C3 macros powerful. Following are macros that iterate through the map.

```c3
macro HashMap.@each(self; @body(key, value)); // semicolon separates arguments and trailing body

hashmap.@each(; key, value) { // key and value are after semicolon. they are @body's arguments
    // process with key and value
};
// semicolon is needed

macro HashMap.@each_entry(self; @body(entry));

hashmap.@each_e try(; entry) { // semicolon
    // process with entry.key and entry.value
};
```

```c3
Value[] vals = hashmap.tvalues();
Value[] vals = hashmap.values(allocx);
bool b = hashmap.has_value(Value v) @if(VALUE_IS_EQUATABLE);
```

Three different iterators are provided. Iterators behave like arrays because they implement `[]` operator and `.len()` method.

```c3
HashMapIterator map_iter = hashmap.iter();
HashMapValueIterator val_iter =  hashmap.value_iter();
HashMapKeyIterator key_iter = hashmap.key_iter();
Entry entry = map_iter.get(usz idx) @operator([]);
Value val = val_iter.get(usz idx) @operator([]);
Key key = key_iter.get(usz idx) @operator([]);
usz n = val_iter.len() @operator(len);
usz n = key_iter.len() @operator(len);
usz n = map_iter.len() @operator(len);

foreach(entry: hashmap.iter()) {
    // process with entry.key and entry.value
}

foreach(key: hashmap.key_iter()) {
    // process with key
}

foreach(value: hashmap.value_iter()) {
    // process with value
}
```

If you want to traverse a map in sorted order, you can define macros as follows.

```c3
module std::collections::map{Key,Value};

import std::sort; // for quicksort()
import std::collections::list; // for List{Entry}

<* 
 @param cmp `cmp must compare two Key`
*>
macro HashMap.@each_sort_keys(self, cmp; @body(idx, key)) 
{
    @pool() {
        Key[] keys = self.tkeys();
        sort::quicksort(keys, cmp);
        foreach(idx, key: keys) {
            @body(idx, key);
        }
    };
}

<* 
 @param cmp `cmp must compare two Entry{Key,Value} object's .value`
*>
macro HashMap.@each_sort_values(self, cmp; @body(idx, value, key)) 
{
    @pool() {
        List{Entry} entries;
        foreach(entry: self.iter()) {
            entries.push(entry);
        }
        sort::quicksort(&entries, cmp);
        foreach(idx, entry: entries) {
            @body(idx, entry.value, entry.key);
        }
    };
}
```

They are used as follows.

```c3
module main;

import std::io;
import std::collections::map;
import libc; // for strncmp()

// sample key compare function for int key
fn int key_cmp(int a, int b) 
{
    if (a < b) return -1;
    if (b < a) return 1;
    return 0;
}

// sample value compare function for Entry{int,String}
fn int entity_value_cmp(Entry{int,String} a, Entry{int,String} b) 
{
    return libc::strncmp(a.value, b.value, a.value.len);
}

fn void main() 
{
    HashMap{int,String} map;
    map[7] = "abc";
    map[2] = "def";
    map[9] = "ABC";
    map.@each_sort_keys(&key_cmp; idx, key)
    {
        io::printfn("%d %d:%s", idx, key, map[key]);
    }
    map.@each_sort_values(&entry_value_cmp; idx, value, key) 
    {
        io::printfn("%d %d:%s", idx, value, key);
    }
}
```

### HashSet{Value}

`HashSet` is a collection of `Value`s and no duplication is allowed.

module std::collections::set {Value};
```c3
HashSet set;
Allocator allocx;

int n = set.len() @operator(len);
HashSet* s = set.init(allocx, usz capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashSet* s = set.tinit(uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashSet* s = set.init_with_values(allocx, ..., uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashSet* s = set.tinit_with_values(..., uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashSet* s = set.init_from_values(allocx, Value[] values, uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
HashSet* s = set.tinit_from_values(Value[] values, uint capacity = DEFAULT_INITIAL_CAPACITY, float load_factor = DEFAULT_LOAD_FACTOR);
bool b = set.is_initialized();
HashSet* s = set.init_from_set(allocx, HashSet* other_set);
HashSet* s = set.tinit_from_set(HashSet* other_set)
```

```c3
bool b = set.is_empty();
usz n = set.add_all(Value[] list);
usz n = set.add_all_from(HashSet* other);
bool b = set.add(Value value);
```

You can iterate by using this macro.

```c3
macro HashSet.@each(self; @body(value)); // semicolon separates arguments and trailing body

set.@each(; value) { // semicolon
    // process with value
};
// semicolon
```

```c3
bool b = set.contains(Value value);

// return error can be ignored without (void) casting
void? set.remove(Value value) @maydiscard;

usz n = set.remove_all(Value[] values);
usz n = set.remove_all_from(HashSet* other);
void set.free();
void set.clear();
void set.reserve(usz capacity);

Value[] vals = set.tvalues();
Value[] vals = set.values(allocx);
```

Union, intersection, difference, and subset are typical set operations.

```c3
HashSet s = set.set_union(allocx, HashSet* other);
HashSet s = set.tset_union(HashSet* other);
HashSet s = set.intersection(allocx, HashSet* other);
HashSet s = set.tintersection(HashSet* other);
HashSet s =  set.difference(allocx, HashSet* other);
HashSet s = set.tdifference(HashSet* other);
HashSet s = set.symmetric_difference(allocx, HashSet* other);
HashSet s = set.tsymmetric_difference(HashSet* other);
bool b = set.is_subset(HashSet* other);
```

Using iterater you can enumerate elements in a set.

```c3
HashSetIterator iter = set.iter();
Value? val = iter.next();
usz n = itef.len() @operator(len);

while (try val = iter.next()) {
    // process with val
}
```
