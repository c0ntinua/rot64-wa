(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32) ))
    (global $stdout i32 (i32.const 1))
    (global $iovecp i32 (i32.const 0))
    (global $iovecl i32 (i32.const 4))
    (global $out i32 (i32.const 8))
    (memory 1)
    (export "memory" (memory 0))
    (func $print (param $byte i32)
        (local $location i32)
        (local.set $location (i32.const 100))
        (i32.store (global.get $iovecp) (local.get $location))
        (i32.store (global.get $iovecl) (i32.const 1)) 
        (i32.store (local.get $location) (local.get $byte))
        (call $fd_write 
            (global.get $stdout) 
            (global.get $iovecp) 
            (global.get $iovecl)
            (local.get $location)
        )
        (drop)
    )
    (func $print_bit_as_block (param $bit i64)
        (if (i32.wrap_i64 (local.get $bit)) 
            (then (call $print_block ))
            (else (call $print (i32.const 0x20)))
        )
    )
    (func $ith_bit (param $x i64) (param $i i64) (result i64)
        (local $mask i64)
        (local.set $mask (i64.rotl (i64.const 1) (local.get $i)))
        (local.set $mask (i64.and (local.get $mask) (local.get $x)))
        (i64.rotr (local.get $mask) (local.get $i) )
    )
    (func $print_block 
        (call $print (i32.const 0xE2))
        (call $print (i32.const 0x96))
        (call $print (i32.const 0x88))
    )
    (func $print_i64_as_blocks (param $x i64) 
        (local $i i64 ) 
        (local.set $i (i64.const 64))
        (loop $loop
            (call $print_bit_as_block ( call $ith_bit (local.get $x) (local.get $i) ))
            (local.set $i (i64.sub (local.get $i) (i64.const 1))) 
            (br_if $loop (i64.le_s (i64.const 0) (local.get $i) ))
        )
    )
    (func $rand_64 (result i64)
        (call $random_get (global.get $iovecp) (i32.const 8) )
        drop
        (i64.load (global.get $iovecp))
    )
    (func $neighbor_code (param $x i64) (param $i i64) (result i64)
        (i64.rotr ( i64.and ( i64.rotl (i64.const 63 ) (local.get $i)) (local.get $x) ) (local.get $i))
    )
    (func $trident (param $x i64) (param $i i64) (result i64)
        (i64.rotr ( i64.and (  i64.rotl (i64.const 7) (local.get $i) )  (local.get $x)) (local.get $i))
    )
    (func $wings (param $x i64) (param $i i64) (result i64)
        (i64.or 
            (call $trident (local.get $x) (local.get $i)) 
            (i64.rotl ( call $trident (local.get $x) (i64.add (local.get $i) (i64.const 4))) (i64.const 3))
        )
    )
    (func $eval (param $f i64) (param $i i64) (result i64)
        (i64.rotr (i64.and ( i64.rotl (i64.const 1) (local.get $i) ) (  local.get $f )) (local.get $i))
    )
    (func $next (param $s i64) (param $f i64) (param $i i64) (result i64)
        (i64.rotl (call $eval (local.get $f) (call $wings (local.get $s) (local.get $i))) (i64.add (local.get $i) (i64.const 3)))
    )
    (func $turn (param $s i64) (param $f i64) (result i64)
        (local $i i64)
        (local $r i64)
        (local.set $r (i64.const 0))
        (local.set $i (i64.const 0)) 
        (loop $loop 
            (local.set $r (i64.or (local.get $r) (call $next (local.get $s) (local.get $f)(local.get $i))))
            (local.set $i (i64.add (local.get $i) (i64.const 1)))
            (br_if $loop (i64.ge_s (i64.const 64) (local.get $i)))
            
        )
        (local.get $r)
    )
    (func $main (export "_start")
        (local $f i64)
        (local $s i64)
        (local $i i64)
        (local.set $f (call $rand_64))
        (local.set $s (local.get $f)) 
        (local.set $i (i64.const 0)) 
        (loop $loop 
            (local.set $s (call $turn (local.get $s) (local.get $f)))
            (call $print_i64_as_blocks (local.get $s))
            (call $print (i32.const 0x0A))
            (local.set $i (i64.add (local.get $i) (i64.const 1)))
            (br_if $loop (i64.ge_s (i64.const 32) (local.get $i)))
        )
        (call $print (i32.const 0x0A))
    )
)