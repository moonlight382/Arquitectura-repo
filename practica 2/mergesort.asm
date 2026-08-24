.data
vector:.word 7,3
 
.globl main

 .text 
 main:
li $a0,0
li $a1,1
la $a2, vector

jal mergesort
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
mergesort:
addi $sp,$sp,-16
sw $a0,0($sp)
sw $a1,4($sp)
sw $s0,8($sp)
sw $ra,12($sp)
add $s0,$a0,$a1
srl $s0,$s0,1 #indice del medio
bge $a0,$a1,endmerge
move $a1,$s0
jal mergesort
lw $a1,4($sp)
addi $a0,$s0,1
jal mergesort
lw $a0,0($sp)
move $a3,$s0
jal merge
endmerge:
lw $s0,8($sp)
lw $ra,12($sp)
addi $sp,$sp,16
jr $ra

merge:
addi $sp,$sp,-8
sw $s1,0($sp) 
sw $s3,4($sp)
sub $t6,$a3,$a0
addi $t6,$t6,1 #t6 es el tamano del vector izquierdo
sll $t1,$t6,2 #tamano del vector auxiliar izquirdo en bytes
sub $sp,$sp,$t1  
move $s1,$sp   #s1 es la direccion donde comienza el vector izquierdo

sub $t2,$a1,$a3
move $t7,$t2 #s2 es el tamano del vector derecho
sll $t2,$t2,2 
sub $sp,$sp,$t2
move $s3,$sp #$s3 es la direccion donde comienza el vector derecho

move $t0,$a0 #indice del vector principal
li $t1,0	#indice del vector izq
vector1:
bgt $t0,$a3,finv1 
move $t2,$t0,
sll $t2,$t2,2
add $t2,$t2,$a2 #direccion del elemento del vector original que se colocara en el vector auxiliar izquierdo
lw $t3,0($t2)	
move $t4,$t1
sll $t4,$t4,2
add $t4,$t4,$s1
sw $t3,0($t4)
addi $t0,$t0,1
addi $t1,$t1,1
j vector1
finv1:
li $t1,0

move $t0,$a3
addi $t0,$t0,1

vector2:
bgt $t0,$a1,finv2 
move $t2,$t0,
sll $t2,$t2,2
add $t2,$t2,$a2 #direccion del elemento del vector original que se colocara en el vector auxiliarderecho
lw $t3,0($t2)	
move $t4,$t1
sll $t4,$t4,2
add $t4,$t4,$s3
sw $t3,0($t4)
addi $t0,$t0,1
addi $t1,$t1,1
j vector2
finv2:

li $t0,0 #indice del vector izquierdo auxiliar
move $t1,$a0 #indice del vector principal
li $t2,0 #indice del vector derecho auxiliar

mescla:
bge $t0,$t6,finmescla
bge $t2,$t7,finmescla

move $t3,$t0
sll $t3,$t3,2
add $t3,$s1,$t3
lw $t3,0($t3) #t3 es el valor a evaluar del vector izquierdo

move $t4,$t2
sll $t4,$t4,2
add $t4,$s3,$t4
lw $t4,0($t4) #t4 es el valor del vector derecho

move $t5, $t1
sll $t5,$t5,2
add $t5,$a2,$t5

blt $t3,$t4,verdadero
sw $t4,0($t5)
addi $t2,$t2,1
j finif
verdadero:
sw $t3,0($t5)
addi $t0,$t0,1
finif:
addi $t1,$t1,1
j mescla

finmescla:

restoizq:
bge $t0,$t6,finizq
move $t3,$t0
sll $t3,$t3,2
add $t3,$t3,$s1
lw $t3,0($t3)
move $t4,$t1
sll $t4,$t4,2
add $t4,$t4,$a2
sw $t3,0($t4)
addi $t0,$t0,1
addi $t1,$t1,1
j restoizq
finizq:

restoder:
bge $t2,$t6,finder
move $t3,$t2
sll $t3,$t3,2
add $t3,$t3,$s3
lw $t3,0($t3)
move $t4,$t1
sll $t4,$t4,2
add $t4,$t4,$a2
sw $t3,0($t4)
addi $t2,$t2,1
addi $t1,$t1,1
j restoder
finder:
move $t1,$t6
move $t2,$t7
sll $t1,$t1,2
sll $t2,$t2,2
add $sp,$sp,$t1
add $sp,$sp,$t2
lw $s1,0($sp) 
lw $s3,4($sp)
addi $sp,$sp,8
jr $ra














