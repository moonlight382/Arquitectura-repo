.data
indice:      .word 0   #Indice actual del buffer         
.eqv tamaño 3    #tamaño real del buffer
buffer:      .space tamaño #buffer donde se guardaran los caracteres.          
imprimiendo: .word 0   # Bandera para indica que ahora se esta imprimiendo  
cuenta: .word 0		#Tamaño real del vel buffer
Salto_linea:      .asciiz "\n"
Mensaje_escritura: .asciiz "Puedes escribir\n"
Mensaje_impresion: .asciiz "Teclado cerrado\n"
.kdata
salvar_registros:   .word 0, 0, 0, 0

.globl main
.text
main:
	lui   $t0, 0xFFFF          # $t0 = 0xFFFF0000 (base MMIO)
	li    $t1, 2
	sw    $t1, 0($t0)          # Habilitar el bit 1 para la entrada del teclado
	mfc0  $t0, $12             # leer Status
	ori   $t0, $t0, 0x0101     # Se pone en 1 los bits 8 y 0
	mtc0  $t0, $12		   #Se guarda en el status

	inicio:
						
		li    $v0, 4        			#Avisar que se puede escribir
		la    $a0, Mensaje_escritura
		syscall                    
		
		li    $v0, 30
		syscall                    # $a0 = tiempo del sistema en ms
		move  $s0, $a0             # $s0 = instante en que empezo el ciclo
		espera:
			li    $v0, 30
			syscall                    # leer la hora otra vez
			sub  $t0, $a0, $s0        # $t0 = ms transcurridos
			slti  $t1, $t0, 20000      # $t1 = 1 si aun no pasan 20 s
			bne   $t1, $zero, espera   # si faltan, seguir esperando


	###### Preparar la impresion
		li    $v0, 4			#Avisar que se esta imprimiendo
		la    $a0, Mensaje_impresion
		syscall                    
		li    $t0, 1
		sw    $t0, imprimiendo     
		li    $v0, 4
		la    $a0, Salto_linea
		syscall                    # Salto de linea
		lw    $t1, cuenta          
		li    $t2, 0               # $t2 es el indice de impresion

	## Iniciar la impresion
		print_loop:
			
			beq   $t2, $t1, print_fin     
			lb    $a0, buffer($t2)     
			li    $v0, 11             
			syscall
			addiu $t2, $t2, 1         
			j     print_loop

		print_fin:
			
			li    $v0, 4
			la    $a0, Salto_linea
			syscall                   
			sw    $zero, indice        # reiniciar ciclo
			sw    $zero, cuenta
			sw    $zero, imprimiendo   # Reabre el teclado al handler
			j     inicio               # volver a tomar la hora inicial

.ktext 0x80000180

	move  $k1, $at          
	la    $k0, salvar_registros    #Salvar los registros que se usaran en la interruccion    
	sw    $t0, 0($k0)
	sw    $t1, 4($k0)
	sw    $t2, 8($k0)
	sw    $t3, 12($k0)
	mfc0  $t0, $13             # $t0 = Cause
				   #Verificar el origen de la interruccion
	andi  $t1, $t0, 0x0100     # aislar bit 8 de Cause para saber si la interruccion fue pedida por el teclado
	beq   $t1, $zero, h_fin    # si es 0, no fue el teclado
	
	#Leer el caracter escrito
	lui   $t1, 0xFFFF          
	lb    $t2, 4($t1)          # leer tecla
	
	#Verificar si es una letra mayuscula
	li    $t3, 65
	blt   $t2, $t3, h_fin      # menor que 'A'
	li    $t3, 90
	bgt   $t2, $t3, h_fin      # mayor que 'Z'
	
	lw    $t3, imprimiendo #Verificar que no se este imprimiendo ahorita
	
	bne   $t3, $zero, h_fin    # si no son iguales main esta imprimiendo se omite lo que sigue
	lw    $t3, indice
	sb    $t2, buffer($t3)     # buffer[indice] = tecla
	addiu $t3, $t3, 1
	rem   $t3, $t3, tamaño     # indice = (indice+1) mod tamaño
	sw    $t3, indice
	lw    $t3, cuenta
	slti  $t1, $t3, tamaño     # $t1 = 1 si cuenta < tamaño 0 si es mayor o igual
	beq   $t1, $zero, h_fin    # si $t1 es mayor o igual que cero el buffer esta lleno
	addiu $t3, $t3, 1
	sw    $t3, cuenta

	h_fin:
		la    $k0, salvar_registros      # Restaurar registros
		lw    $t0, 0($k0)         
		lw    $t1, 4($k0)
		lw    $t2, 8($k0)
		lw    $t3, 12($k0)
		move  $at, $k1             
		eret                       # 4) volver a main
