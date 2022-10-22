dl: .word 6
res: .word 0

.global _start
fun:
stmfd sp!, {r0-r4,lr}
ldr r3,=dl
ldr r4,[r3]
mov r3,r4
sub r3,r3,#1
l: mul r4,r4,r3
subs r3,#1
bne l
str r4,[r2]
ldmfd sp!, {r0-r4,pc}

_start:
ldr r0,=dl
ldr r0,[r0]
ldr r2,=res
bl fun
ldr r5,[r2]


nop