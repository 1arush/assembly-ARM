.d1: .float 1.6,1.5,1.4,1.3,1.5,1.6,1.9,2.5,2.7,2.8
.d2: .float 0

mov r1,#1
.text
.global _start

.start:
ldr r0,=dl
vldr s1,[r0]
l1: vldr s1,[r0]
vadd.f32 s0,s0,s1
add r0,#4
subs r1,r1,#10
add r1,r1,#1
bne l1
ldr r3,=d2
vstr s0,[r3]
