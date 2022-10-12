ldr r5,=dl+6 @stores address of dl
ldrb r6,[r5] @stores the "byte" of r5 in r6 
a1: mov r1, #20
a2: mov r2,#29
sub r0,r2,r1
add r0,r0,#1
l1: add r3,r3,r1
add r1,r1,#1
subs r0,r0,#1
bne l1

dl: .word 21,25,2004,25