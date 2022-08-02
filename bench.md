## Range

- see `bench/range_bench.zig`

Following are results for `range` and `RangeContext`, the time cost is about a factor of 2 compared to the `while` loop code.

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
