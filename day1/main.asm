.global _main
.balign 8
_main:
    // Set up the stack frame
    stp x29, x30, [sp, -16]!
    mov x29, sp

    // Allocate 64 bytes on the stack
    //  [x29, -8]: array address
    //  [x29, -16]: sum of calibration values (part 1)
    //  [x29, -24]: sum of calibration values (part 2)
    //  [x29, -32]: unused
    //  ...
    //  [sp]: varargs
    sub sp, sp, 64

    // Allocate the array
    mov x0, 1000
    bl _malloc
    str x0, [x29, -8]

    // Initialize locals
    mov x0, 0
    str x0, [x29, -16]
    str x0, [x29, -24]

loop1_start:  // For each line in input
    adrp x0, scanf1@PAGE
    add x0, x0, scanf1@PAGEOFF

    ldr x1, [x29, -8]  // array address...
    str x1, [sp]       // placed in vararg for scanf()

    bl _scanf  // scanf("%999s\n", word);
    cmp x0, 1
    b.ne loop1_end

    // Part 1
    ldr x0, [x29, -8]  // array address
    // bl _printf  // printf(word);
    mov x1, 0
    bl _get_calibration_value
    ldr x1, [x29, -16]
    add x1, x1, x0
    str x1, [x29, -16]

    // Part 2
    ldr x0, [x29, -8]  // array address
    mov x1, 1
    bl _get_calibration_value
    ldr x1, [x29, -24]
    add x1, x1, x0
    str x1, [x29, -24]

    b loop1_start

loop1_end:
    adrp x0, printf2@PAGE
    add x0, x0, printf2@PAGEOFF
    ldr x1, [x29, -16]
    ldr x2, [x29, -24]
    stp x1, x2, [sp]
    bl _printf  // printf("%d\n%d\n", sum1, sum2);

    // Set the return value to 0
    mov x0, 0

    // Clean up the stack frame and return
    mov sp, x29
    ldp x29, x30, [sp], 16
    ret


.global _get_calibration_value
.balign 8
_get_calibration_value: // int get_calibration_value(const char* word, bool part2)
    stp x29, x30, [sp, -16]!
    mov x29, sp

    // Allocate 64 bytes on the stack
    //  [x29, -8]: current *word pointer
    //  [x29, -16]: bool part2
    //  [x29, -24]: first digit in word (or -1)
    //  [x29, -32]: last digit in word (or -1)
    //  [x29, -40]: inner loop pointer into *numerals array
    //  [x29, -48]: numeral temp storage
    //  [x29, -56]: unused
    sub sp, sp, 64

    // Initialize locals
    stp x1, x0, [x29, -16]  // Save arguments
    mov x0, -1
    stp x0, x0, [x29, -32]  // w7 = -1, w8 = -1

loop2_start:  // For each character in word
    ldr x0, [x29, -8]
    mov x1, 0
    ldrb w1, [x0], 1  // w1 = *word++
    str x0, [x29, -8]

    cmp w1, 0
    b.eq loop2_end

    cmp w1, '0'
    b.lt loop2_alpha
    cmp w1, '9'
    b.gt loop2_alpha

    sub w1, w1, '0'
    b loop2_found_number

loop2_alpha:  // Check if it is a numeral using string comparison
    ldr x0, [x29, -16]
    cmp w0, 0
    b.eq loop2_start  // part 1, so we skip this step

    adrp x0, numerals@PAGE
    add x0, x0, numerals@PAGEOFF
    str x0, [x29, -40]  // Store pointer to numerals array

loop3_start:  // For each numeral in numerals array
    ldr x0, [x29, -40]
    ldr x1, [x0], 8  // x1 = *numerals++
    str x0, [x29, -40]

    cmp x1, 0
    b.eq loop2_start  // Failed to find a matching numeral, continue

    str x1, [x29, -48]  // Store numeral in temp storage
    mov x0, x1
    bl _strlen  // x2 = strlen(numeral)
    mov x2, x0

    ldr x0, [x29, -8]
    sub x0, x0, 1  // cancel out the previous increment (oops)
    ldr x1, [x29, -48]
    bl _strncmp  // strncmp(word, numeral, strlen(numeral));
    cmp x0, 0
    b.ne loop3_start  // Go to the next numeral

    // Found a matching numeral
    adrp x0, numerals@PAGE
    add x0, x0, numerals@PAGEOFF
    ldr x1, [x29, -40]
    sub x1, x1, x0  // x1 = index of numeral in numerals array
    mov x0, 8
    udiv x1, x1, x0
    b loop2_found_number

loop2_found_number:  // The numeric digit is now stored in w1
    ldr x0, [x29, -24]
    cmp w0, -1
    b.ne loop2_if_skip
    str x1, [x29, -24]
loop2_if_skip:
    str x1, [x29, -32]
    b loop2_start

loop2_end:
    ldp x8, x7, [x29, -32]
    mov x0, 10
    mul w0, w0, w7
    add w0, w0, w8

    mov sp, x29
    ldp x29, x30, [sp], 16
    ret


.data
scanf1:
    .asciz "%999s\n"
printf2:
    .asciz "%d\n%d\n"

// Numerals for part 2
one:
    .asciz "one"
two:
    .asciz "two"
three:
    .asciz "three"
four:
    .asciz "four"
five:
    .asciz "five"
six:
    .asciz "six"
seven:
    .asciz "seven"
eight:
    .asciz "eight"
nine:
    .asciz "nine"
.balign 8
numerals:
    .xword one, two, three, four, five, six, seven, eight, nine, 0
