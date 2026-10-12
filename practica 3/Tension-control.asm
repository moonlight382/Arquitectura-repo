.data
TensionControl: .word 0
TensionEstado: .word 0
TensionSistol: .word 2
TensionDiastol: .word 3
Error:.asciiz "Hubo un fallo"
siastolica:.asciiz "presion sistolica"
diastolica:.asciiz "presion diastolica"

.globl main
.text
main:
jal controlador_tension
move $s0,$v0
li $v0,4
la $a0,siastolica
syscall 
move $a0,$s0
li $v0,1
syscall
li $v0,4
la $a0,diastolica
syscall 
move $a0,$v1
li $v0,1
syscall
li $v0,10
syscall

controlador_tension:
la $t0,TensionControl
li $t1,1
sw $t1,0($t0)
la $t2,TensionSistol
la $t3,TensionDiastol
la $t4,TensionEstado
verificacion:
lw $t5,0($t4) #Se carga el valor de tensionestado
bne $t5,0,exit
j verificacion

exit:
beq  $t5,1,final
li $v0,4
la $a0,Error
li $v0,-1
li $v1,-1
j salir
syscall
final:
lw $v0,0($t2)
lw $v1,0($t3)
salir:
jr $ra
