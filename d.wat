(module
  (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32)))
  (global $stdout i32 (i32.const 1))
  (global $iovecp i32 (i32.const 0))
  (global $iovecl i32 (i32.const 4))
  (global $out i32 (i32.const 8))
  (memory (;0;) 1)
  (export "memory" (memory 0))
  (func $print (param $byte i32)
    (local $location i32)
    i32.const 100
    local.set $location
    global.get $iovecp
    local.get $location
    i32.store
    global.get $iovecl
    i32.const 1
    i32.store
    local.get $location
    local.get $byte
    i32.store
    global.get $stdout
    global.get $iovecp
    global.get $iovecl
    local.get $location
    call $fd_write
    drop)
  (func $print_bit_as_block (param $bit i64)
    local.get $bit
    i32.wrap_i64
    if  ;; label = @1
      call $print_block
    else
      i32.const 32
      call $print
    end)
  (func $ith_bit (param $x i64) (param $i i64) (result i64)
    (local $mask i64)
    i64.const 1
    local.get $i
    i64.rotl
    local.set $mask
    local.get $mask
    local.get $x
    i64.and
    ;;local.set $mask
    ;;local.get $mask
    local.get $i
    i64.rotr)
  (func $print_block
    i32.const 226
    call $print
    i32.const 150
    call $print
    i32.const 136
    call $print)
  (func $print_i64_as_blocks (param $x i64)
    (local $i i64)
    i64.const 64
    local.set $i
    loop $loop
      local.get $x
      local.get $i
      call $ith_bit
      call $print_bit_as_block
      local.get $i
      i64.const 1
      i64.sub
      local.set $i
      i64.const 0
      local.get $i
      i64.le_s
      br_if $loop
    end)
  (func $rand_64 (result i64)
    global.get $iovecp
    i32.const 8
    call $random_get
    drop
    global.get $iovecp
    i64.load)
  (func $neighbor_code (param $x i64) (param $i i64) (result i64)
    i64.const 63
    local.get $i
    i64.rotl
    local.get $x
    i64.and
    local.get $i
    i64.rotr)
  (func $trident (param $x i64) (param $i i64) (result i64)
    i64.const 7
    local.get $i
    i64.rotl
    local.get $x
    i64.and
    local.get $i
    i64.rotr)
  (func $wings (param $x i64) (param $i i64) (result i64)
    local.get $x
    local.get $i
    call $trident
    local.get $x
    local.get $i
    i64.const 4
    i64.add
    call $trident
    i64.const 3
    i64.rotl
    i64.or)
  (func $eval (param $f i64) (param $i i64) (result i64)
    i64.const 1
    local.get $i
    i64.rotl
    local.get $f
    i64.and
    local.get $i
    i64.rotr)
  (func $next (param $s i64) (param $f i64) (param $i i64) (result i64)
    local.get $f
    local.get $s
    local.get $i
    call $wings
    call $eval
    local.get $i
    i64.const 3
    i64.add
    i64.rotl)
  (func $turn (param $s i64) (param $f i64) (result i64)
    (local $i i64) (local $r i64)
    i64.const 0
    local.set $r
    i64.const 0
    local.set $i
    loop $loop
      local.get $r
      local.get $s
      local.get $f
      local.get $i
      call $next
      i64.or
      local.set $r
      local.get $i
      i64.const 1
      i64.add
      local.set $i
      i64.const 64
      local.get $i
      i64.ge_s
      br_if $loop
    end
    local.get $r)
  (func $main
    (local $f i64) (local $s i64) (local $i i64)
    call $rand_64
    local.set $f
    local.get $f
    local.set $s
    i64.const 0
    local.set $i
    loop $loop
      local.get $s
      local.get $f
      call $turn
      local.set $s
      local.get $s
      call $print_i64_as_blocks
      i32.const 10
      call $print
      local.get $i
      i64.const 1
      i64.add
      local.set $i
      i64.const 32
      local.get $i
      i64.ge_s
      br_if $loop
    end
    i32.const 10
    call $print)
  (export "_start" (func $main))
  (type (;0;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;1;) (func (param i32 i32) (result i32)))
  (type (;2;) (func (param i32)))
  (type (;3;) (func (param i64)))
  (type (;4;) (func (param i64 i64) (result i64)))
  (type (;5;) (func))
  (type (;6;) (func (result i64)))
  (type (;7;) (func (param i64 i64 i64) (result i64))))
