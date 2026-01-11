module std::collections::map{Key,Value};

import std::collections::list;
import std::sort;

macro HashMap.@foreach_sorted_keys(self, cmp; @body(idx, key)) 
{
    @pool() {
        Key[] keys = self.tkeys();
        sort::quicksort(keys, cmp);
        foreach(idx, key: keys) {
            @body(idx, key);
        }
    };
}

macro HashMap.@foreach_sorted_values(self, cmp; @body(idx, value, key)) 
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

module main;

import std::io;
import std::collections::map;
import libc;

// sample key compare function
fn int key_cmp(int a, int b) {
    if (a < b) return -1;
    if (b < a) return 1;
    return 0;
}

fn int entry_value_cmp(Entry{int,String} a, Entry{int,String} b) {
    return libc::strncmp(a.value, b.value, a.value.len);
}

fn void main() {
  HashMap{int,String} m;
  m[7] = "stq";
  m[3] = "가나";
  m[5] = "abc";
  m.@each(; key, value) {
    io::printfn("%d:%s", key, value);
  };
  m.@foreach_sorted_keys(&key_cmp; i, k) {
    io::printfn("%d %d:%s", i, k, m[k])!!;
  };
  m.@foreach_sorted_values(&entry_value_cmp; i, v, k) {
    io::printfn("%d %s:%d", i, v, k)!!;
  };
}
