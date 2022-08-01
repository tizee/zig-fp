# zig-fp

Functional programmimng style iterator patterns in Zig lang.

```
zig version
0.10.0-dev.3340+c6f5832bb
```

Currently Zig does not support closure but we can achieve similar functionality with `comptime` and `type` to build the context for reusing the same iterator interface.

## TODO

- [x] Iterator type
  - [x] General iterator
    - [x] filter_map
    - [x] find
    - [x] fold
    - [x] for_each
    - [x] map
    - [x] next
    - [x] peek
    - [x] peekAhead
    - [x] reduce
    - [x] skip
  - [x] Double-ended iterator
    - [x] filter_map
    - [x] find
    - [x] fold
    - [x] for_each
    - [x] map
    - [x] next
    - [x] peek
    - [x] peekAhead
    - [x] reduce
    - [x] reverse
    - [x] skip
  - [x] RangeIterator (Double-ended iterator)
  - [x] SliceIterator (Double-ended iterator)
  - [x] MapIterator (Wrapper)
  - [x] ReverseIterator (Wrapper)
  - [x] FilterIterator (Wrapper)
  - [x] EnumerateIterator (Wrapper)
  - [x] FilterMapIterator (Wrapper)
