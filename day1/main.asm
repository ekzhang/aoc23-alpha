.global _main
.balign 8
_main:
    // Set up the stack frame
    stp x29, x30, [sp, -16]!
    mov x29, sp

    adr x0, message
    bl _printf  // printf(message)

    // Allocate 32 bytes on the stack
    //  [x29, -8]: array address
    //  [x29, -16]: loop counter
    //  [x29, -24]: unused
    //  [sp]: vararg for printf()
    sub sp, sp, 32

    // Loop 100 times using a counter in [x29, -16]
    mov x0, 0
    str x0, [x29, -16]

loop_start:
    ldr x0, [x29, -16]
    cmp x0, 100
    b.ge loop_end
    str x0, [sp]  // vararg for printf()
    add x0, x0, 1
    str x0, [x29, -16]

    // Call malloc on 16 bytes
    mov x0, 16
    bl _malloc
    str x0, [x29, -8]  // [x29, -8] is the address of the array

    mov w1, 'H'
    strb w1, [x0]
    mov w1, 'i'
    strb w1, [x0, 1]
    mov w1, ' '
    strb w1, [x0, 2]
    mov w1, '%'
    strb w1, [x0, 3]
    mov w1, 'd'
    strb w1, [x0, 4]
    mov w1, '\n'
    strb w1, [x0, 5]
    mov w1, 0
    strb w1, [x0, 6]

    bl _printf  // printf(array)

    // Call free on the array
    ldr x0, [x29, -8]
    bl _free

    b loop_start

loop_end:
    // Set the return value to 0
    mov x0, 0

    // Clean up the stack frame and return
    mov sp, x29
    ldp x29, x30, [sp], 16
    ret

message:
    .asciz "Hello, World!\n"
