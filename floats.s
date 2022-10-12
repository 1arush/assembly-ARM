dl: .float 1.25,2.55
d0: .float 1.2
.text
.global _start

_start:
ldr r0,=dl
vldr s0,[r0]
add r0,#4
vldr s1,[r0]
vadd.f32 s2,s0,s1
ldr r1,=d0
vstr s3,[r1]


