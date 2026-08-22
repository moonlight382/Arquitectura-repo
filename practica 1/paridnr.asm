.data 
mensaje: .asciiz "escribe el numero"

.text
.globl main

main:
li $v0,4
la $a0,mensaje
syscall
li $v0,5
syscall
move $s0,$v0	#n $s0 es el numero a evaluar
li $t0,0  #contador del ciclo
li $s1,0	#paridad
li $t1,1 #suma fija de la paridad
ciclo:
beq $t0,$s0,exit
sub $s1,$t1,$s1
addi $t0,$t0,1
j ciclo
exit:
move $a0,$s1
li $v0,1
syscall
li $v0,10
syscall   
	