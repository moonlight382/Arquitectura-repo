.data 
mensaje:.asciiz "escribe el numero"

.text  
.globl main

main:
 li $v0,4
 la $a0,mensaje
 syscall
 li $v0,5
 syscall 
 add $a0,$v0,$zero
 jal paridad
 add $t0,$zero,$v0
 
 li $v0,1
 add $a0,$t0,$zero
 syscall
 li $v0,10
 syscall  



paridad:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	beq $a0,$zero,casobase
	addi $a0,$a0,-1
	jal paridad
	lw $ra,0($sp)
	addi $sp,$sp,4
	addi $t0,$zero,1
	sub $v0,$t0,$v0
	jr $ra
	
	casobase:
	addi $sp,$sp,4
	add $v0,$zero,$zero
	jr $ra 
		
	
