.data 
vector:.word 4,3,1
 
.globl main

 .text 
 main:
li $a0,0
li $a1,2
la $a2, vector

jal quicksort
move $s0,$a0
impresion:
bgt $s0, $a1, finpress
move $t0, $s0
sll $t0,$t0,2
add $t0,$a2,$t0
lw $a0,0($t0)
li $v0,1
syscall
addi $s0,$s0,1
j impresion
 finpress:
li $v0,10
syscall 

quicksort:
addi $sp,$sp,-16
sw $s0,8($sp)
sw $a0,0($sp)
sw $a1,4($sp)
sw $ra,12($sp)
bge $a0,$a1,endquick
jal particion
move $a0,$v0
move $s0,$v0
addi $a0,$a0,1
jal quicksort
lw $a0, 0($sp)
move $a1,$s0
addi $a1,$a1,-1
jal quicksort
endquick:
lw $s0,8($sp)
lw $a0,0($sp)
lw $a1,4($sp)
lw $ra ,12($sp)
addi $sp,$sp,16
jr $ra

particion:
sll $t0,$a1,2
add $t0,$t0,$a2
lw $t5,0($t0)    #t5 es el pivote con el que se compara, y $t0 es su direccion en el vector ahora $t5
addi $t6,$a0,-1  #t6 es el indice del valor previo a la posicion del pivote $t6
move $t7,$a0    #t7 es el indice del ciclo 
ciclo:
bge $t7, $a1,finciclo

move $t1, $t7
sll $t1 $t1,2    #elemento a evaluar
add $t1,$t1,$a2
lw $t2,0($t1)  #$t2 tiene el valor del vector en la posicion del indice del ciclo y $t1 su direccion

bge $t2,$t5,skip
addi $t6,$t6,1
move $t3,$t6
sll $t3,$t3,2 
add $t3,$t3,$a2 #$t3 tiene el valor de la direccion de la posicion del indice previo al pivote
lw $t4,0($t3)
sw $t4,0($t1)
sw $t2,0($t3)
skip:
addi $t7,$t7,1
j ciclo

 finciclo:
addi $t6,$t6,1
move $v0,$t6
move $t1,$v0
sll $t1,$t1,2 #direccion de la posicion donde ira el pivote
add $t1,$t1,$a2
lw $t2,0($t1)
sw $t5,0($t1)
sw $t2,0($t0)

jr $ra
