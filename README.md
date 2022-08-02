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

## Performance

- Range

```
  times: 40
  while  :       1000ns  base
  context:       4000ns ~3.997002997002997e+00 times
  range  :       1000ns ~1.0e+00 times



  times: 400
  while  :       2000ns  base
  context:       3000ns ~1.4997501249375311e+00 times
  range  :       3000ns ~1.4997501249375311e+00 times



  times: 4000
  while  :       14000ns  base
  context:       32000ns ~2.28562245553889e+00 times
  range  :       31000ns ~2.2141989857867297e+00 times



  times: 40000
  while  :       144000ns  base
  context:       311000ns ~2.1597141686516066e+00 times
  range  :       310000ns ~2.1527697724321357e+00 times



  times: 400000
  while  :       1437000ns  base
  context:       3262000ns ~2.2700060751523488e+00 times
  range  :       3098000ns ~2.1558795018235895e+00 times



  times: 4000000
  while  :       14478000ns  base
  context:       31345000ns ~2.165008898673235e+00 times
  range  :       31183000ns ~2.1538195086462557e+00 times
```
