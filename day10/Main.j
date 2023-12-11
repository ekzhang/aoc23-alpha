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


.method static getInput()[Ljava/lang/String;
    .limit stack 16
    .limit locals 4

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

    ; %2.add(%3)
    aload_2
    aload_3
    invokevirtual java/util/ArrayList.add(Ljava/lang/Object;)Z
    pop

    goto Loop

Endloop:
    ; return %2.toArray()
    aload_2
    iconst_0
    anewarray java/lang/String
    invokevirtual java/util/ArrayList.toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    checkcast [Ljava/lang/String;
    areturn
.end method


.method public static main([Ljava/lang/String;)V
    .limit stack 16

    getstatic java/lang/System/out Ljava/io/PrintStream;
    ldc "Hello World!"
    invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    getstatic java/lang/System/out Ljava/io/PrintStream;
    invokestatic Main/getInput()[Ljava/lang/String;
    invokestatic java.util.Arrays/deepToString([Ljava/lang/Object;)Ljava/lang/String;
    invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V

    return
.end method
