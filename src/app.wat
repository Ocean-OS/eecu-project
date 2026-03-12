(module
    (import "env" "syscall" (func $syscall (param i32) (result i32)))
    (memory (export "memory") 1024)
    (type $Numbers (array (mut i32)))
    (global $inputs (mut (ref $Numbers))
        (array.new $Numbers
            (i32.const 0)
            (i32.const 0)
        )
    )
    (func $sum (export "sum") (param $ptr i32) (param $len i32) (result i32)
        (local $nums (ref $Numbers))
        (local $res i32)
        (local $i i32)
        (local $j i32)
        (local.set $nums
            (array.new_default $Numbers
                (local.get $len)
                (i32.const 0)
            )
        )
        (loop $apply
            (local.set $j
                (i32.load
                    (i32.add
                        (local.get $i)
                        (local.get $ptr)
                    )
                )
            )
            (array.set $Numbers
                (local.get $nums)
                (local.get $i)
                (local.get $j)
            )
            (local.set $i
                (i32.add
                    (local.get $i)
                    (i32.const 1)
                )
            )
            (br_if $apply
                (i32.le_s
                    (local.get $i)
                    (local.get $len)
                )
            )
        )
        (local.set $res
            (i32.const 0)
        )
        (local.set $i
            (i32.const 0)
        )
        (loop $loop
            (local.set $res
                (i32.add
                    (local.get $res)
                    (array.get $Numbers
                        (local.get $nums)
                        (local.get $i)
                    )
                )
            )
            (local.set $i
                (i32.add
                    (local.get $i)
                    (i32.const 1)
                )
            )
            (br_if $loop
                (i32.le_s
                    (local.get $i)
                    (local.get $len)
                )
            )
        )
        (return
            (local.get $res)
        )
    )
)
