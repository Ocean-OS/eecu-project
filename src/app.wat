(module
    (import "env" "document.querySelector" (func $document.querySelector (param i32
            ) (result i32)
        )
    )
    (import "env" "document.querySelectorAll" (func $document.querySelectorAll (param i32
            ) (result i32)
        )
    )
    (import "env" "Reflect.get" (func $Reflect.get (param i32 i32) (result i32))
    )
    (import "env" "Reflect.set" (func $Reflect.set (param i32 i32 i32)))
    (import "env" "Object.create" (func $Object.create (result i32)))
    (import "env" "JSON.stringify" (func $JSON.stringify (param i32) (result i32
            )
        )
    )
    (import "env" "JSON.parse" (func $JSON.parse (param i32) (result i32)))
    (import "env" "localStorage" (global $localStorage i32))
    (import "env" "place_iterable" (func $place_iterable (param i32 i32)))
    (memory (export "memory") 2048)
    (memory $malloc_map 1024)
    (memory $freed_map 1024)
    ;;; given a `$ptr`, returns `0` if it is not in the map, and the index of the `$ptr`'s entry in the map if it is present. 
    (func $map_get (param $ptr i32) (param $is_malloc i32) (result i32)
        (local $i i32)
        (local $res i32)
        (local $size i32)
        (if
            (i32.eqz
                (local.get $is_malloc)
            )
            (then
                (local.set $size
                    (memory.size $malloc_map)
                )
            )
            (else
                (local.set $size
                    (memory.size $freed_map)
                )
            )
        )
        (local.set $i
            (i32.const 0)
        )
        (loop $find
            (if
                (i32.eqz
                    (local.get $is_malloc)
                )
                (then
                    (if
                        (i32.eq
                            (i32.load $freed_map
                                (local.get $i)
                            )
                            (local.get $ptr)
                        )
                        (then
                            (local.set $res
                                (i32.load $freed_map
                                    (local.get $i)
                                )
                            )
                        )
                    )
                )
                (else
                    (if
                        (i32.eq
                            (i32.load $malloc_map
                                (local.get $i)
                            )
                            (local.get $ptr)
                        )
                        (then
                            (local.set $res
                                (i32.load $freed_map
                                    (local.get $i)
                                )
                            )
                        )
                    )
                )
            )
            (local.set $i
                (i32.add
                    (local.get $i)
                    (i32.const 8)
                )
            )
            (br_if $find
                (i32.and
                    (i32.ne
                        (local.get $res)
                        (local.get $ptr)
                    )
                    (i32.eqz
                        (i32.gt_s
                            (local.get $i)
                            (local.get $size)
                        )
                    )
                )
            )
        )
        (return
            (i32.sub
                (local.get $i)
                (i32.const 8)
            )
        )
    )
    ;;; given a `$size`, returns `0` if no entry with that value exists in the map, and returns the index of the entry if the value does exist
    (func $map_keyof (param $size i32) (param $is_malloc i32) (result i32)
        (local $i i32)
        (local $res i32)
        (local $map_size i32)
        (if
            (i32.eqz
                (local.get $is_malloc)
            )
            (then
                (local.set $map_size
                    (memory.size $malloc_map)
                )
            )
            (else
                (local.set $map_size
                    (memory.size $freed_map)
                )
            )
        )
        (local.set $i
            (i32.const 4)
        )
        (loop $find
            (if
                (i32.eqz
                    (local.get $is_malloc)
                )
                (then
                    (if
                        (i32.eq
                            (i32.load $freed_map
                                (local.get $i)
                            )
                            (local.get $size)
                        )
                        (then
                            (local.set $res
                                (i32.load $freed_map
                                    (local.get $i)
                                )
                            )
                        )
                    )
                )
                (else
                    (if
                        (i32.eq
                            (i32.load $malloc_map
                                (local.get $i)
                            )
                            (local.get $size)
                        )
                        (then
                            (local.set $res
                                (i32.load $freed_map
                                    (local.get $i)
                                )
                            )
                        )
                    )
                )
            )
            (local.set $i
                (i32.add
                    (local.get $i)
                    (i32.const 8)
                )
            )
            (br_if $find
                (i32.and
                    (i32.ne
                        (local.get $res)
                        (local.get $size)
                    )
                    (i32.eqz
                        (i32.gt_s
                            (local.get $i)
                            (local.get $map_size)
                        )
                    )
                )
            )
        )
        (return
            (i32.sub
                (local.get $i)
                (i32.const 12)
            )
        )
    )
    (func $append_to_map (param $ptr i32) (param $size i32
        ) (param $is_malloc i32)
        (local $i i32)
        (local.set $i
            (call $map_get
                (i32.const 0)
                (local.get $is_malloc)
            )
        )
        (if
            (i32.eqz
                (local.get $is_malloc)
            )
            (then
                (if
                    (i32.eqz
                        (i32.load $malloc_map
                            (local.get $i)
                        )
                    )
                    (then
                        (i32.store $malloc_map
                            (local.get $i)
                            (local.get $ptr)
                        )
                        (i32.store $malloc_map
                            (i32.add
                                (local.get $i)
                                (i32.const 4)
                            )
                            (local.get $size)
                        )
                        (return)
                    )
                    (else
                        (unreachable)
                    )
                )
            )
            (else
                (if
                    (i32.eqz
                        (i32.load $freed_map
                            (local.get $i)
                        )
                    )
                    (then
                        (i32.store $freed_map
                            (local.get $i)
                            (local.get $ptr)
                        )
                        (i32.store $freed_map
                            (i32.add
                                (local.get $i)
                                (i32.const 4)
                            )
                            (local.get $size)
                        )
                        (return)
                    )
                    (else
                        (unreachable)
                    )
                )
            )
        )
    )
    ;;; allocates `$size` number of bits and returns a pointer to the allocation.
    (func $malloc (param $size i32) (result i32)
        (local $freed_ptr i32)
        (local $ptr i32)
        (local $i i32)
        (local $max i32)
        (local $curr i32)
        (if
            (i32.eqz
                (local.get $size)
            )
            (then
                (unreachable)
            )
        )
        (if
            (i32.eqz
                (i32.load $freed_map
                    (i32.const 4)
                )
            )
            (then
                (call $append_to_map
                    (i32.const 0)
                    (local.get $size)
                    (i32.const 1)
                )
                (return
                    (i32.const 0)
                )
            )
        )
        (local.set $freed_ptr
            (call $map_keyof
                (local.get $size)
                (i32.const 0)
            )
        )
        (if
            (local.tee $ptr
                (i32.load $freed_map
                    (local.get $freed_ptr)
                )
            )
            (then
                (memory.fill $freed_map
                    (local.get $freed_ptr)
                    (i32.const 0)
                    (i32.const 8)
                )
                (call $append_to_map
                    (local.get $ptr)
                    (local.get $size)
                    (i32.const 1)
                )
                (return
                    (local.get $ptr)
                )
            )
        )
        (local.set $i
            (i32.const 0)
        )
        (loop $find_max
            (local.set $curr
                (i32.add
                    (i32.load $malloc_map
                        (local.get $i)
                    )
                    (i32.load $malloc_map
                        (i32.add
                            (local.get $i)
                            (i32.const 4)
                        )
                    )
                )
            )
            (if
                (i32.lt_s
                    (i32.add
                        (i32.load $malloc_map
                            (local.get $max)
                        )
                        (i32.load $malloc_map
                            (i32.add
                                (local.get $max)
                                (i32.const 4)
                            )
                        )
                    )
                    (local.get $curr)
                )
                (then
                    (local.set $max
                        (local.get $i)
                    )
                )
            )
            (local.set $i
                (i32.add
                    (local.get $i)
                    (i32.const 8)
                )
            )
            (br_if $find_max
                (i32.lt_s
                    (local.get $i)
                    (memory.size $malloc_map)
                )
            )
        )
        (if
            (i32.ge_s
                (i32.load $malloc_map
                    (i32.add
                        (local.get $max)
                        (i32.const 4)
                    )
                )
                (local.get $size)
            )
            (then
                (call $append_to_map
                    (i32.add
                        (i32.load $malloc_map
                            (local.get $max)
                        )
                        (i32.load $malloc_map
                            (i32.add
                                (local.get $max)
                                (i32.const 4)
                            )
                        )
                    )
                    (local.get $size)
                    (i32.const 1)
                )
                (return
                    (i32.add
                        (i32.load $malloc_map
                            (local.get $max)
                        )
                        (i32.load $malloc_map
                            (i32.add
                                (local.get $max)
                                (i32.const 4)
                            )
                        )
                    )
                )
            )
        )
        (unreachable)
    )
    ;;; frees the memory at a given `$ptr` pointer to a memory allocation made with `$malloc`.
    (func $free (param $ptr i32)
        (local $index i32)
        (local $size i32)
        (local.get $index
            (call $map_get
                (local.get $ptr)
                (i32.const 1)
            )
        )
        (if
            (i32.eq
                (i32.load $malloc_map
                    (local.get $index)
                )
                (local.get $ptr)
            )
            (then
                (local.set $size
                    (i32.load $malloc_map
                        (i32.add
                            (local.get $index)
                            (i32.const 4)
                        )
                    )
                )
                (memory.fill
                    (local.get $ptr)
                    (i32.const 0)
                    (local.get $size)
                )
                (call $append_to_map
                    (local.get $ptr)
                    (local.get $size)
                    (i32.const 0)
                )
                (return)
            )
            (else
                (unreachable)
            )
        )
        (return)
    )
    (data $input_selector
        (i32.const 1024) ".active > .category-costs input[type=number]"
    )
    (data $select_selector
        (i32.const 1152) ".active > .category-costs select"
    )
    (data $value
        (i32.const 1280) "value"
    )
    (data $localstorage_key
        (i32.const 1408) "data"
    )
    (data $length
        (i32.const 1536) "length"
    )
    (func $sum (export "sum") (param $ptr i32) (param $len i32) (result i32)
        (local $res i32)
        (local $i i32)
        (local.set $res
            (i32.const 0)
        )
        (local.set $i
            (local.get $ptr)
        )
        (loop $loop
            (local.set $res
                (i32.add
                    (local.get $res)
                    (i32.load
                        (local.get $ptr)
                    )
                )
            )
            (local.set $ptr
                (i32.add
                    (local.get $ptr)
                    (i32.const 4)
                )
            )
            (br_if $loop
                (i32.le_s
                    (local.get $ptr)
                    (i32.add
                        (local.get $len)
                        (local.get $i)
                    )
                )
            )
        )
        (return
            (local.get $res)
        )
    )
    (func $sum_category (export "sum_category") (param $ptr i32) (param $len i32
        ) (result f64)
        (local $res f64)
        (local $i f64)
        (local $curr i32)
        (local.set $curr
            (local.get $ptr)
        )
        (loop $sum
            (local.set $i
                (f64.load
                    (local.get $curr)
                )
            )
            ;; if the value is meant to be a yearly amount, divide by 12 to get the monthly rate
            (if
                (f64.eq
                    (f64.load
                        (i32.add
                            (local.get $curr)
                            (i32.const 8)
                        )
                    )
                    (f64.const 1)
                )
                (then
                    (local.set $i
                        (f64.div
                            (local.get $i)
                            (f64.const 12)
                        )
                    )
                )
            )
            (local.set $res
                (f64.add
                    (local.get $res)
                    (local.get $i)
                )
            )
            ;; basic pointer arithmetic - a float64 is 8 bytes, so two float64s are 16 bytes
            (local.set $curr
                (i32.add
                    (local.get $curr)
                    (i32.const 16)
                )
            )
            (br_if $sum
                (i32.le_s
                    (local.get $curr)
                    (i32.add
                        (local.get $ptr)
                        (local.get $len)
                    )
                )
            )
        )
        ;; truncate value to 2 decimal places
        (local.set $res
            (f64.mul
                (local.get $res)
                (f64.const 100)
            )
        )
        (local.set $res
            (f64.trunc
                (local.get $res)
            )
        )
        (local.set $res
            (f64.div
                (local.get $res)
                (f64.const 100)
            )
        )
        (return
            (local.get $res)
        )
    )
    (func $calculate (export "calculate") (result i32)
        (local $inputs i32)
        (local $input_values i32)
        (local $selects i32)
        (local $select_values i32)
        (local $length i32)
        (local $to_sum i32)
        (local $i i32)
        (local.set $inputs
            (call $document.querySelectorAll
                (i32.const 1024)
            )
        )
        (local.set $selects
            (call $document.querySelectorAll
                (i32.const 1152)
            )
        )
        (local.set $length
            (call $Reflect.get
                (local.get $inputs)
                (i32.const 1536)
            )
        )
        (local.set $input_values
            (call $malloc
                (i32.mul
                    (local.get $length)
                    (i32.const 4)
                )
            )
        )
        (call $place_iterable
            (local.get $inputs)
            (local.get $input_values)
        )
        (local.set $select_values
            (call $malloc
                (i32.mul
                    (local.get $length)
                    (i32.const 4)
                )
            )
        )
        (call $place_iterable
            (local.get $selects)
            (local.get $select_values)
        )
        (local.set $to_sum
            (call $malloc
                (i32.mul
                    (local.get $length)
                    (i32.const 8)
                )
            )
        )
        (loop $build_to_sum
            
        )
        (return
            (local.get $input_values)
        )
    )
)
