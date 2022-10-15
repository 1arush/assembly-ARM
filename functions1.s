dl: .word 14,5
res: .word 0

.global _start
fun:
stmfd sp!, {r0-r3,lr}
mul r6,r0,r1
str r6,[r2]
ldmfd sp!, {r0-r3,pc}

_start:
ldr r3,=dl
ldr r0,[r3]
ldr r2,=res
add r3,r3,#4
ldr r1,[r3]
bl fun
ldr r5,[r2]


nop