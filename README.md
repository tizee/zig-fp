# zig-fp

Iterators in Zig lang.

```
zig version
0.10.0-dev.3340+c6f5832bb
```

Currently Zig does not support closure but we can achieve similar functionality with `comptime` and `type` to build the context for reusing the same iterator interface.

## TODO

- [x] Iterator type
  - [x] Iterator Interface
    - [x] for_each
    - [x] map
    - [x] next
    - [x] peek
    - [x] peekAhead
    - [x] skip
    - [ ] fold
    - [ ] reduce
    - [ ] find
  - [x] RangeIterator
  - [x] SliceIterator
  - [x] MapIterator
  - [x] ReverseIterator
  - [ ] FlatMapIterator
  - [ ] Enumerate
  - [ ] Filter
  - [ ] FilterMap
