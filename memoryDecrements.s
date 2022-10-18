dl: .word 2,4,3,5,1,3,3,2,6,1
res: .word 0

.global _start

_start:
@ ldr r8,=dl
@ ldmia r8,{r0-r7}
ldr r0,=dl
ldr r1,[r0,#4]
ldr r2,[r0,#4]
ldr r3,[r0,#4]


nop