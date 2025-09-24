   ; Programa que calcula la secuencia de Fibonacci (Fn)
        ; Para n en el rango 0 <= n <= 47
        ; Los resultados se almacenan en memoria SRAM
        ; AGUILAR ANDRADE ANGEL DE JESUS

;-------Definicion de nombres para registros-------
APUNTA	RN	r0	
ENTRADA	RN	r1	
SALIDA	RN	r2	
Fn1		rn	r3
Fn2		RN	r4

        AREA    constantes, DATA, READWRITE
;-------Dirección base en SRAM donde se guardarán los resultados-------
START	equ	0x20000000
; Número de términos de la secuencia (n)
NUMERO	dcd	20
;---------------------------------------------------

        AREA    Act_2, CODE, READONLY
        THUMB
        EXPORT  __main

__main
; ----------------------------
; Inicialización de variables
; - Se apunta a la dirección base en SRAM
; - Se carga el número de términos a calcular (NUMERO)
; ----------------------------
	ldr	SALIDA,=START
	ldr	APUNTA,=NUMERO
	ldr APUNTA, [APUNTA]
; ----------------------------
; Casos especiales
; Si n = 0 -> solo guardar F(1)
; Si n = 1 -> solo guardar F(1) y F(2)
; ----------------------------
	cmp APUNTA, #0
	beq salida0
	cmp APUNTA, #1
	beq salida1
; ----------------------------
; Guardar los dos primeros términos de la secuencia:
; F(0) = 0 y F(1) = 1
; ----------------------------
	mov ENTRADA, #0
	str ENTRADA, [SALIDA], #4
	mov ENTRADA, #1
	str ENTRADA, [SALIDA], #4      

; Inicializar el índice en i = 2       
	mov ENTRADA, #2

ciclo
; ----------------------------
; Cálculo iterativo de Fibonacci:
; F(i) = F(i-1) + F(i-2)
; Se leen los dos valores anteriores desde SRAM,
; se suman y se guarda el nuevo término.
; ----------------------------
	ldr Fn1, [SALIDA, #-4]
	ldr Fn2, [SALIDA, #-8]
	add Fn1, Fn1, Fn2
	str Fn1, [SALIDA], #4
 ; ----------------------------
 ; Incrementar el índice y seguir hasta n
 ; ----------------------------
	add ENTRADA, ENTRADA, #1
	cmp ENTRADA, APUNTA
	ble ciclo
	bl	sub1
fin	b	fin
	
sub1	
		ldr	r7,=START
		mov r6,#0
		str	r6,[r7,#48]
		bx lr
; ----------------------------
; Manejo de casos especiales
; ----------------------------
salida0
	str ENTRADA, [SALIDA], #4
	cmp APUNTA, #0
	beq salida2
salida1
	str ENTRADA, [SALIDA], #4
	str APUNTA, [SALIDA], #4
salida2
	end