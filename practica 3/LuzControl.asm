.data
LuzControl: .word 0
LuzEstado: .word 0
LuzDatos: .word 2
Error:.asciiz "fallo de hardware"
.globl main

.text
main: 
la $s0,LuzControl
lw $a0,0($s0)
li $v0,1
syscall
jal InicializarSensorLuz
la $s0,LuzControl
lw $a0,0($s0)
li $v0,1
syscall
jal LeerLuminosidad
move $a0,$v0
li $v0,1
syscall
move $a0,$v1
li $v0,1
syscall
li $v0,10
syscall

InicializarSensorLuz:
la $t0,LuzControl
la $t2,LuzEstado
li $t1,0x1
sw $t1,0($t0)
li $t4,1
li $t5,0
li $v0,0 
check:
lw $t3,0($t2)  #cargar el valor de luzestado
beq $t3,$t4,fincheck
blt $t3,$t5,Problema
j check
Problema:
li $v0,4
la $a0,Error
syscall
li $v0,-1 # No se inicio
fincheck:
jr $ra

LeerLuminosidad:
la $t0,LuzEstado
lw $t0,0($t0)
li $v1,-1
beq $t0,0,nolisto
beq $t0,1,iniciado
li $v0,4
la $a0,Error
syscall
j final
nolisto:
li $v0,-1
li $v1,0
j final
iniciado:
la $t4,LuzDatos
lw $t5,0($t4) #valor de luzdatos
li $t1,0
li $t2,1023
bgt $t5,$t2,final
blt $t5,$t1,final
move $v0,$t5
li $v1,0
final:
jr $ra


