dl: .word 2,4,3,5,1,3,3,2,6,1
res: .word 0

.global _start
fun:
stmfd sp!, {r0-r5,lr}
ldr r3,=dl
ldr r4,[r3]
add r1,#10
l: add r4,r4,r5
add r3,#4
ldr r5,[r3]
subs r1,#1
bne l
str r4,[r2]
ldmfd sp!, {r0-r5,pc}

_start:
ldr r0,=dl
ldr r0,[r0]
ldr r2,=res
bl fun
ldr r5,[r2]


nop