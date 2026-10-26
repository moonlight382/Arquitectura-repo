.data
iniciado:.word 0
Salto_linea: .asciiz "\n"
Verde: .asciiz "Verde \n\nSemáforo en verde, esperando pulsador"
verde_amarillo:.asciiz " \nPulsador activado: en 20 segundos, el semáforo cambiará a amarillo\n\n"
Amarillo: .asciiz "Amarillo\nSemáforo en amarillo,en 10 segundos, semáforo en rojo\n\n"
Rojo: .asciiz "Rojo\nSemáforo en rojo, en 30 segundos, semáforo en verde\n\n"

.kdata
salvar_registros:   .word 0, 0, 0, 0 #Para preservar los registros que se usaran durante la interruccion

.globl main

.text
main:
	lui   $t0, 0xFFFF          # $t0 = 0xFFFF0000 (base MMIO)
	li    $t1, 2
	sw    $t1, 0($t0)          # Habilitar el bit 1 para la entrada del teclado
	mfc0  $t0, $12             # leer Status
	ori   $t0, $t0, 0x0101     # Se pone en 1 los bits 8 y 0
	mtc0  $t0, $12	           #Se guarda en el status
	
	Semaforo_verde:
		li    $v0, 4        			#Aviso del semaforo verde
		la    $a0, Verde
		syscall   
		####Loop para checkear cuando se active el pulsador
		chequeo_tecla:
			la $t1,iniciado
			lw $t2,0($t1)
			beq $t2,$zero,chequeo_tecla
		
		jal Consultar_tiempo
		move $s0,$v0 				#$s0 contiene el tiempo de inicio del contador
		li   $v0, 4        			#Aviso del semaforo verde
		la   $a0, verde_amarillo
		syscall
		esperar_verde:
			jal Consultar_tiempo
			move $t0,$v0			#$t0 son los ms actuales
			sub  $t1, $t0, $s0 		#$t1 son los ms transcurridos        
			slti $t2, $t1, 20000      	#t2 es 1 si el tiempo transcurrido son menos de 20 s
			bne  $t2, $zero, esperar_verde
		
	########Semaforo amarillo
	jal Consultar_tiempo
	move $s0,$v0 				#$s0 contiene el tiempo de inicio del contador
	li   $v0, 4        			#Aviso del semaforo amarillo
	la   $a0, Amarillo		
	syscall
	esperar_amarillo:
		jal Consultar_tiempo
		move $t0,$v0			#$t0 son los ms actuales
		sub  $t1, $t0, $s0 		#$t1 son los ms transcurridos        
		slti $t2, $t1, 10000      	#t2 es 1 si el tiempo transcurrido son menos de 20 s
		bne  $t2, $zero, esperar_amarillo
	
	jal Consultar_tiempo
	move $s0,$v0 				#$s0 contiene el tiempo de inicio del contador
	li   $v0, 4        			#Aviso del semaforo amarillo
	la   $a0, Rojo		
	syscall
	esperar_rojo:
		jal Consultar_tiempo
		move $t0,$v0			#$t0 son los ms actuales
		sub  $t1, $t0, $s0 		#$t1 son los ms transcurridos        
		slti  $t2, $t1, 30000      	#t2 es 1 si el tiempo transcurrido son menos de 20 s
		bne   $t2, $zero, esperar_rojo
	la $t0,iniciado
	li $t1,0
	sw $t1,0($t0)
	j Semaforo_verde
		
			
			

Consultar_tiempo:
	li    $v0, 30
	syscall                    # $a0 = tiempo del sistema en ms
	move  $v0, $a0	           #regresa el tiempo actual en ms
	jr $ra	
	
	
.ktext	0x80000180
	move  $k1, $at          
	##Preservar los registros que se utilizaran durante la interruccion
	la    $k0, salvar_registros
	sw    $t0, 0($k0)
	sw    $t1, 4($k0)
	sw    $t2, 8($k0)
	sw    $t3, 12($k0)
	
	mfc0  $t0, $13             # $t0 = Cause
				   #Verificar el origen de la interruccion
	andi  $t1, $t0, 0x0100     # aislar bit 8 de Cause para saber si la interruccion fue pedida por el teclado
	beq   $t1, $zero, fin    # si es 0, no fue el teclado
	
	#Leer el caracter escrito
	lui   $t1, 0xFFFF          
	lb    $t2, 4($t1)
	## Verificar si es una s
	li    $t3, 115
	bne   $t2,$t3,fin
	#Si es una s poner la bandera en 1
	la    $t2,iniciado
	li    $t3,1
	sw    $t3,0($t2)
	 
	fin:
	 	lw    $t0, 0($k0)
		lw    $t1, 4($k0)
		lw    $t2, 8($k0)
		lw    $t3, 12($k0)
		eret

