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
    (memory (export "memory") 2048)
    (data $input_selector
        (i32.const 1024) ".current-page > input[type=number]"
    )
    (data $select_selector
        (i32.const 1152) ".current-page > select"
    )
    (data $value
        (i32.const 1280) "value"
    )
    (data $localstorage_key
        (i32.const 1408) "data"
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
    ;; (func $calculate (export "calculate") (result f64)
    ;;     (local $inputs i32)
    ;;     (local $input_values i32)
    ;;     (local $selects i32)
    ;;     (local.set $inputs (call $document.querySelectorAll (i32.const 64)))
    ;;     (local.set $selects (call $document.querySelectorAll (i32.const 128)))

    ;; )
)
