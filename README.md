# zig-fp

Functional programmimng style iterator patterns in Zig lang.

```
zig version
0.10.0-dev.3340+c6f5832bb
```

Currently Zig does not support closure but we can achieve similar functionality with `comptime` and `type` to build the context for reusing the same iterator interface.

## Usage

```zig
const std = @import("std");
const it = @import("zig-fp");

fn isEven(val: u32) bool {
  return val % 2 == 0;
}

fn toChar(val: u32) u8 {
  if(val % 4 == 0) {
    return '0';
  }else{
    return '1';
  }
}

fn print(val: u8) void{
  std.debug.print("{}\n", .{val});
}


it.range(u32,0,100,1)
  .filter(isEven)
  .map(toChar)
  .for_each(print);
```

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
    - [x] size_hint
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
    - [x] size_hint
    - [x] skip
  - [x] EnumerateIterator (Wrapper)
  - [x] FilterIterator (Wrapper)
  - [x] FilterMapIterator (Wrapper)
  - [x] MapIterator (Wrapper)
  - [x] RangeIterator (Double-ended iterator)
  - [x] ReverseIterator (Wrapper)
  - [x] SliceIterator (Double-ended iterator)
