.section .data
input1: .byte 0x80, 0x15, 0x00, 0x00, 0x00, 0x1A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
b12: .word 0b00000000000000000000111111111111
b19: .word 0b00000000000001111111111111111111
b0: .word 0xfffff000

@ 8 sections for 2 NFP, following 8 for storage locations

.section .text
.global _start

@ first nfp -> r0
@ second nfp -> r2
@ first mantisa -> r8
@ second mantisa -> r9
@ first exponent -> r6
@ second exponent -> r7
@ first sign bit -> r4
@ second sign bit -> r5
@ final sign bit -> r4
@ final exponent -> r7
@ final mantissa -> r3
@ final result -> r0
@ offset for addressing -> r6 

ldNum1:
    stmfd sp!, {r2, r3, r4, r5, r6, r7, r8, r9, lr}
    mov r9, #3
    mov r8, #0
    mov r0, #0
    loop1:              @ start
    ldrb r7, [r1, r8]
    add r0, r0, r7
    mov r0, r0, LSL #8
    add r8, r8, #1
    subs r9, r9, #1
    bne loop1           @ end
    ldrb r7, [r1, r8]
    add r0, r0, r7
    ldmfd sp!, {r2, r3, r4, r5, r6, r7, r8, r9, pc}
ldNum2:
    stmfd sp!, {r3-r9, lr}
    mov r9, #3
    mov r8, #4
    mov r2, #0
    loop2:
    ldrb r7, [r1, r8]
    add r2, r2, r7
    mov r2, r2, LSL #8
    add r8, r8, #1
    subs r9, r9, #1
    bne loop2
    ldrb r7, [r1, r8]
    add r2, r2, r7
    ldmfd sp!, {r3-r9, pc}
getMantissa:
    stmfd sp!, {r3, lr}
    ldr r3,=b19
    ldr r3,[r3]
    AND r8, r0, r3         @ mantissa of first NFP in r8
    AND r9, r2, r3         @ manitssa of second NFP in r9
    mov r0, r0, LSR #19    @ modify number 1
    mov r2, r2, LSR #19    @ modify number 2
    ldmfd sp!, {r3, pc}
exponent:
    stmfd sp!, {r3, lr}
    ldr r3,=b12
    ldr r3,[r3]  
    AND r6, r0, r3         @ exponent of first num in r6
    AND r7, r2, r3         @ exponent of second num in r7
    mov r0, r0, LSR #12
    mov r2, r2, LSR #12
    ldmfd sp!, {r3, pc}
signbit:
    stmfd sp!, {r3, lr}

    mov r3, #1
    AND r4, r0, r3         @ sign bit of first num in r4
    AND r5, r2, r3         @ sign bit of second num in r5

    ldmfd sp!, {r3, pc}

renormalize:
    stmfd sp!, {r6, lr}

    mov r6, #1572864      @ 0b 11000000..... 20 and 21st bits are 1
    AND r0, r3, r6        @ finding the 20th and 21st bit of mantissa
    mov r0, r0, LSR #19   

    cmp r0, #3            @ comparing it with 11
    moveq r3, r3, LSR #1  @ if equal, then right shift mantissa by 1
    addeq r7, r7, #1      @ increase the exponent by 1

    cmp r0, #2            @ comparing it with 10 
    moveq r3, r3, LSR #1  @ if equal then right shift mantissa by 1
    addeq r7, r7, #1      @ if equal then increase the exponent by 1

    cmp r0, #0            @ comparing it with 00
    subeq r7, #1          @ now we have our mantissa as 0.1_ _ _ _ _ _, so decrease the exponent by 1
    LSLeq r3, #1          @ left shift the mantissa

    sub r3, r3, #524288   @ remove the significant part-> 0b10000000000000000000

    ldmfd sp!, {r6, pc}

finalresult:
    stmfd sp!, {r2, lr}

    mov r0, r4, LSL #31   @ r0 = resulting nfp
    mov r7, r7, LSL #19   @ shifting the exponent by 19 (mantissa) bits
    ORR r0, r0, r7        @ putting the exponent to final nfp (r0)
    ORR r0, r0, r3        @ putting the mantissa to final nfp (r0)

    ldmfd sp!, {r2, pc}

storing:
    stmfd sp!, {r3,r4, lr}

    mov r4, #4            @ r4 = no. of loops
    mov r3, #0xFF         @ r3 = 1111 1111
    loop7:
    AND r2, r0, r3    @ extracting the first 8 bits
    strb r2, [r1, r6] @ storing the extracted bit at r1 address with r6 offset
    sub r6, r6, #1    @ decreasing the offset
    LSR r0, #8        @ shifting the final nfp by 8 bits to the right
    subs r4, r4, #1   @ decreasing the no. of loops by 1
    bne loop7         

    ldmfd sp!, {r3,r4, pc}

ADD:
    stmfd sp!, {r0, r2-r9, lr}

    bl ldNum1
    bl ldNum2

    bl getMantissa
    bl exponent  
    bl signbit
    
    @ extending the sign bit of exponent
    ldr r0,=b0
    ldr r0,[r0]

    mov r3, #0x800      @ 0b 100000000000
    AND r3, r3, r6      @ first bit of exponent
    LSR r3, #11
    
    cmp r3, #1          @ if sign bit is 1
    orreq r6, r6, r0    @ make all left bits 1

    mov r3, #0x800      @ line:146
    AND r3, r3, r7
    LSR r3, #11

    cmp r3, #1
    orreq r7, r7, r0

    @ extension complete;
    @ making the exponent same r7 = exponent

    mov r3, #1
    mov r3, r3, LSL #19
    ORR r9, r9, r3    @ making the mantissa as 1.XXXX
    ORR r8, r8, r3    @ making the mantissa as 1.XXXX

    cmp r6, r7             @ comparing the exponents and storing deficit
    subgt r3, r6, r7       @ r3 = r6 - r7   if : r6 > r7
    sublt r3, r7, r6       @ r3 = r7 - r6   if : r6 < r7
    addgt r7, r7, r3       @ r7 = r7 + r3   if : r6 > r7
    addlt r6, r6, r3       @ r6 = r6 + r3   if : r6 < r7
    movgt r9, r9, LSR r3   @ shift the mantissa of 2nd nfp by r3 bits
    movlt r8, r8, LSR r3   @ shift the mantissa of 1st nfp by r3 bits

    @ adding the mantissa r4 = sign bit

    mov r6, #0
    cmp r4, #1
    subeq r8, r6, r8       @ if sgnBit=1, make r8<0

    cmp r5, #1
    subeq r9, r6, r9       @ if the sgnBit=1, make r9<0

    add r3, r8, r9        @ r3 = mantissa-> r3 = r8 + r9

    cmp r3, #0
    movgt r4, #0          @ if r3 is greater than 0 i.e. positive then sign bit i.e. r4=0
    movlt r4, #1          @ if r3 is less than 0 i.e. negative then sign bit i.e. r4=1

    cmp r3, #0
    sublt r3, r6, r3      @ if final addition result is negative then make it positive

    cmp r3, #0
    moveq r4, #0          @ if r3 is equal to 0 then sign bit i.e. r4=0

    bl renormalize
    bl finalresult

    mov r6, #11
    bl storing

    ldmfd sp!, {r0, r2-r9, pc}

MUL:
    stmfd sp!, {r0, r2-r9, lr}
    
    bl ldNum1
    bl ldNum2

    bl getMantissa

    bl exponent

    mov r3, #1
    mov r3, r3, LSL #19
    ORR r9, r9, r3    @ making the mantissa as 1.XXXX 
    ORR r8, r8, r3    @ making the mantissa as 1.XXXX

    bl signbit  

    @ extending the sign bit of exponent
    ldr r0,=b0
    ldr r0,[r0]

    mov r3, #0x800
    AND r3, r3, r6
    LSR r3, #11
    
    cmp r3, #1
    orreq r6, r6, r0

    mov r3, #0x800
    AND r3, r3, r7
    LSR r3, #11

    cmp r3, #1
    orreq r7, r7, r0

    @ adding the exponent
    add r7, r7, r6

    @ final sign bit
    EOR r4, r4, r5

    @ multiplying the mantissa
    UMULL r3, r2, r8, r9            @ r2, r3 stores the final mantissa

    @ renormalizing
    mov r0, #13
    mov r6, #1
    LSL r6, #31

    loop6:                 @ bringing the mantissa in r2
    AND r5, r6, r3
    LSR r5, #31
    LSL r2, #1
    add r2, r2, r5
    subs r0, r0, #1
    LSL r3, #1
    bne loop6

    mov r3, r2          @ moving the mantissa in r3
    bl renormalize
    bl finalresult

    mov r6, #15
    bl storing

    ldmfd sp!, {r0, r2-r9, pc}

_start:
ldr r1, =input1
bl ADD
bl MUL