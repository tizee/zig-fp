# zig-fp

Functional programmimng style patterns in Zig lang.

```
zig version
0.10.0-dev.3340+c6f5832bb
```

## Features

- Iterators
- Monad

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

> Currently Zig does not support closure but we can achieve similar functionality with `comptime` and `type` to build the context for reusing the same iterator interface.
