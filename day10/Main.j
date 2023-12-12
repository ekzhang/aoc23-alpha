; Yes, this is Java bytecode. I'm basically solving this problem in assembly.
;
; This problem is a bit of a slog honestly. But I've already started, and hey,
; it's not like this will be _impossible_ to solve or anything.
;
; I was originally using JASM but switched to Jasmin because it was emitting
; invalid bytecode for branches (goto, ifeq, etc.) that went to labels on a
; negative byte offset. Jasmin is more verbose, but less buggy.
;
; Reference:
; - https://docs.oracle.com/javase/specs/jvms/se21/jvms21.pdf
; - https://en.wikipedia.org/wiki/Java_bytecode
; - https://en.wikipedia.org/wiki/List_of_Java_bytecode_instructions
; - https://jasmin.sourceforge.net/instructions.html

.class public Main
.super java/lang/Object


.method static getInput()[[C
    .limit stack 8
    .limit locals 8

    ; %1 = new BufferedReader(new InputStreamReader(System.in))
    getstatic java/lang/System/in Ljava/io/InputStream;
    new java/io/InputStreamReader
    dup
    astore_1
    swap
    invokespecial java/io/InputStreamReader/<init>(Ljava/io/InputStream;)V
    new java/io/BufferedReader
    dup
    aload_1
    invokespecial java/io/BufferedReader/<init>(Ljava/io/Reader;)V
    astore_1

    ; %2 = new ArrayList()
    new java/util/ArrayList
    dup
    invokespecial java/util/ArrayList/<init>()V
    astore_2

    ; while (true)
Loop:
    ; %3 = %1.readLine()
    aload_1
    invokevirtual java/io/BufferedReader/readLine()Ljava/lang/String;
    astore_3
    aload_3
    ifnull Endloop

    ; %2.add(%3.toCharArray())
    aload_2
    aload_3
    invokevirtual java/lang/String/toCharArray()[C
    invokevirtual java/util/ArrayList.add(Ljava/lang/Object;)Z
    pop

    goto Loop

Endloop:
    ; return %2.toArray()
    aload_2
    iconst_0
    anewarray [C
    invokevirtual java/util/ArrayList.toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    checkcast [[C
    areturn
.end method


.method static getPath(Ljava/util/ArrayList;[[CIII)V
    .limit stack 8
    .limit locals 8

    ; %0: output list
    ; %1: grid
    ; %2: row
    ; %3: col
    ; %4: direction: 0 = right, 1 = down, 2 = left, 3 = up

    PathLoop:
    aload_0
    new java/lang/Integer
    dup
    iload_2
    invokespecial java/lang/Integer/<init>(I)V
    invokevirtual java/util/ArrayList.add(Ljava/lang/Object;)Z
    pop

    aload_0
    new java/lang/Integer
    dup
    iload_3
    invokespecial java/lang/Integer/<init>(I)V
    invokevirtual java/util/ArrayList.add(Ljava/lang/Object;)Z
    pop

    ; %5 = grid[row][col]
    aload_1
    iload_2
    aaload
    iload_3
    caload
    istore 5

    ; if (%5 == 'S') return;
    iload 5
    bipush 83
    if_icmpne NotEnd
    return

    NotEnd:
    ; We now compute the next direction and put it on the stack. This will be stored in %6.
    iload 5
    bipush 124  ; '|'
    if_icmpeq Straight
    iload 5
    bipush 45   ; '-'
    if_icmpeq Straight
    iload 5
    bipush 76   ; 'L'
    if_icmpeq TurnL7
    iload 5
    bipush 70   ; 'F'
    if_icmpeq TurnFJ
    iload 5
    bipush 74   ; 'J'
    if_icmpeq TurnFJ
    iload 5
    bipush 55   ; '7'
    if_icmpeq TurnL7
    goto Else

    Straight:
    iload 4
    goto Advance

    TurnFJ:  ; up <-> right, left <-> down
    iconst_3
    iload 4
    isub
    goto Advance

    TurnL7:  ; up <-> left, right <-> down
    iconst_5
    iload 4
    isub
    iconst_4
    irem
    goto Advance

    Else:  ; raise an exception with the character being invalid
    new java/lang/RuntimeException
    dup
    new java/lang/StringBuilder
    dup
    ldc "Invalid character in path: "
    invokespecial java/lang/StringBuilder/<init>(Ljava/lang/String;)V
    iload 5
    invokevirtual java/lang/StringBuilder/append(C)Ljava/lang/StringBuilder;
    invokevirtual java/lang/StringBuilder/toString()Ljava/lang/String;
    invokespecial java/lang/RuntimeException/<init>(Ljava/lang/String;)V
    athrow

    Advance:
    istore 6
    ; move (%2, %3) in the direction %6
    iload 6
    tableswitch 0
        GoRight
        GoDown
        GoLeft
        GoUp
        default : GoNoDirection

    GoRight:
    iinc 3 1
    goto EndAdvance

    GoDown:
    iinc 2 1
    goto EndAdvance

    GoLeft:
    iinc 3 -1
    goto EndAdvance

    GoUp:
    iinc 2 -1
    goto EndAdvance

    GoNoDirection:
    ; raise an exception with the direction being invalid
    new java/lang/RuntimeException
    dup
    new java/lang/StringBuilder
    dup
    ldc "Invalid direction: "
    invokespecial java/lang/StringBuilder/<init>(Ljava/lang/String;)V
    iload 6
    invokevirtual java/lang/StringBuilder/append(I)Ljava/lang/StringBuilder;
    invokevirtual java/lang/StringBuilder/toString()Ljava/lang/String;
    invokespecial java/lang/RuntimeException/<init>(Ljava/lang/String;)V
    athrow

    EndAdvance:
    ; loop through the function!
    iload 6
    istore 4
    goto PathLoop

    return
.end method


.method static getArea(Ljava/util/ArrayList;)I
    .limit stack 8
    .limit locals 8

    ; compute via summation
    iconst_0
    istore_1  ; i

    iconst_0
    istore_2  ; area

    Loop:
    iload_1
    aload_0
    invokevirtual java/util/ArrayList.size()I
    if_icmpge EndLoop

    ; area += %0[i] * (%0[(i+3) % %0.size()] - %0[i+1])
    aload_0
    iload_1
    invokevirtual java/util/ArrayList.get(I)Ljava/lang/Object;
    checkcast java/lang/Integer
    invokevirtual java/lang/Integer/intValue()I
    aload_0
    iload_1
    iconst_3
    iadd
    aload_0
    invokevirtual java/util/ArrayList.size()I
    irem
    invokevirtual java/util/ArrayList.get(I)Ljava/lang/Object;
    checkcast java/lang/Integer
    invokevirtual java/lang/Integer/intValue()I
    aload_0
    iload_1
    iconst_1
    iadd
    invokevirtual java/util/ArrayList.get(I)Ljava/lang/Object;
    checkcast java/lang/Integer
    invokevirtual java/lang/Integer/intValue()I
    isub
    imul

    iload_2
    iadd
    istore_2

    iinc 1 2
    goto Loop

    EndLoop:
    ; return Math.abs(area)
    iload_2
    invokestatic java/lang/Math/abs(I)I
    ireturn
.end method


.method public static main([Ljava/lang/String;)V
    .limit stack 8
    .limit locals 8

    ; getstatic java/lang/System/out Ljava/io/PrintStream;
    ; ldc "Hello World!"
    ; invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    getstatic java/lang/System/out Ljava/io/PrintStream;
    invokestatic Main/getInput()[[C
    astore_0

    ; aload_0
    ; invokestatic java.util.Arrays/deepToString([Ljava/lang/Object;)Ljava/lang/String;
    ; invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    ; %1 = %0.length
    aload_0
    arraylength
    istore_1

    ; %2 = %0[0].length
    aload_0
    iconst_0
    aaload
    arraylength
    istore_2

    ; Find the coordinates of 'S', the starting position
    iconst_0
    istore 3
    iconst_0
    istore 4

    FindLoop1:
    iload_3
    iload 1
    if_icmpge FindLoop1End

    iconst_0
    istore 4
    FindLoop2:
    iload 4
    iload 2
    if_icmpge FindLoop2End
    aload_0
    iload_3
    aaload
    iload 4
    caload
    bipush 83
    if_icmpeq FindLoop1End
    iinc 4 1
    goto FindLoop2

    FindLoop2End:
    iinc 3 1
    goto FindLoop1

    FindLoop1End:
    ; Now (%3, %4) is the starting position

    ; %5 = new ArrayList()
    new java/util/ArrayList
    dup
    invokespecial java/util/ArrayList/<init>()V
    astore 5

    ; Just going to assume we go "up" from the starting position.
    ; You need to edit this to reflect your version of the input. I didn't bother
    ; making this detect automatically; that's too much work :')

    ; getPath(%5, %0, %3-1, %4, 3)
    aload 5
    aload_0
    iload_3
    iconst_1
    isub
    iload 4
    iconst_3
    invokestatic Main/getPath(Ljava/util/ArrayList;[[CIII)V

    ; System.out.println(%5.toString())
    ; getstatic java/lang/System/out Ljava/io/PrintStream;
    ; aload 5
    ; invokevirtual java/util/ArrayList.toString()Ljava/lang/String;
    ; invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    ;; Part 1
    ; %6 = %5.size() / 4
    aload 5
    invokevirtual java/util/ArrayList.size()I
    iconst_4
    idiv
    istore 6

    ; System.out.println(%6)
    getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 6
    invokevirtual java/io/PrintStream/println(I)V

    ;; Part 2
    ; %7 = getArea(%5)
    aload 5
    invokestatic Main/getArea(Ljava/util/ArrayList;)I
    istore 7

    ; Pick's theorem: A = i + b/2 - 1
    ; System.out.println(%7 - %6 + 1)
    getstatic java/lang/System/out Ljava/io/PrintStream;
    iload 7
    iload 6
    isub
    iconst_1
    iadd
    invokevirtual java/io/PrintStream/println(I)V

    return
.end method
