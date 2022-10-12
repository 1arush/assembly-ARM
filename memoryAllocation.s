dl: .word 21,36,43,26,5,7,5,9,8,70
d2: .word 0
.text
.global _start

_start:
    @Storing register is r3 // Sum is stored in r3
    a1: ldr r0,=dl
    ldrb r1,[r0]
    ldr r2,=dl+4
    ldrb r2,[r2]
    mov r4,#10
    l: add r0,r0,#4
    ldrb r5,[r0]
    add r3,r3,r5
    subs r4,r4,#1
    bne l
    ldr r8,=d2
    strb r0,[r8]

    nop
