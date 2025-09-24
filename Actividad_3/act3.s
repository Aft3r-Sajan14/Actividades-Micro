;Aguilar Andrade Angel De Jesus
; -------------------------
; --- Definiciones ---
; -------------------------
		AREA	Constantes, DATA, READONLY 	; Área de datos de solo lectura
RCC_APB2ENR		EQU	0x40021018			; Dirección del registro de control de reloj RCC
GPIOC_CRL		EQU	0x40011000			; Dirección del registro para configuración del puerto C (baja)
GPIOC_CRH		EQU	0x40011004			; Dirección del registro para configuración del puerto C (alta)
GPIOC_IDR		EQU	0x40011008			; Dirección del registro de datos de entrada del puerto C
GPIOC_ODR		EQU	0x4001100C			; Dirección del registro de datos de salida del puerto C
GPIOC_BSRR		EQU	0x40011010			; Dirección del registro de reinicio/establecimiento de bits
GPIOC_BRR		EQU	0x40011014			; Dirección del registro de reinicio de bits

SRAM_BASE		EQU	0x20000100			; Dirección de inicio para almacenamiento de datos
FLAG_GENERATED	EQU	0x20000000			; Dirección para la bandera de números generados

		AREA	act3, CODE, READONLY 	; Área de código de solo lectura
		ENTRY
		EXPORT	__main				; Exporta a startup_stm32f10x_md.s

; ------------------------------------
; --- Inicio del programa principal ---
; ------------------------------------
__main
	; Habilita el reloj para el puerto C
	LDR		R0, =0x00000010			
	LDR		R1, =RCC_APB2ENR		
	STR		R0, [R1]				

	; Configuración de pines de entrada (PC0, PC1)
	; Establece los pines PC0 y PC1 como entradas con pull-up/pull-down
	LDR		R0, =GPIOC_CRL
	LDR		R1, [R0]
	BIC		R1, R1, #0x0000000F
	BIC		R1, R1, #0x000000F0	
	STR		R1, [R0]

	; Configuración del pin del LED (PC13) como salida
	LDR		R0, =GPIOC_CRH
	LDR		R1, [R0]
	BIC		R1, R1, #0x00F00000	
	ORR		R1, R1, #0x00200000	
	STR		R1, [R0]

	; Inicializar el LED apagado
	LDR		R0, =GPIOC_BRR
	LDR		R1, =0x00002000	
	STR		R1, [R0]
	
	B		inicio
; --------------------------------
; --- Estados del programa ---
; --------------------------------

; --- Estado: Inicio ---
inicio
	; Apaga el LED
	LDR		R0, =GPIOC_BRR
	LDR		R1, =0x00002000
	STR		R1, [R0]

	; Limpia la bandera de números generados
	LDR		R0, =FLAG_GENERATED
	MOV		R1, #0
	STR		R1, [R0]

	B		check_input	

; --- Verificación de entradas ---
check_input
	LDR		R0, =GPIOC_IDR
	LDR		R1, [R0]
	AND		R1, R1, #0x00000003

	CMP		R1, #0x00
	BEQ		inicio	

	CMP		R1, #0x01
	BEQ		opcion1	

	CMP		R1, #0x02
	BEQ		opcion2

	B		check_input
; --------------------------------
; --- Opción 1: Generar números pseudoaleatorios ---

opcion1
	; Enciende el LED y establece la bandera
	LDR		R0, =GPIOC_BSRR
	LDR		R1, =0x00002000	
	STR		R1, [R0]
	
	LDR		R0, =FLAG_GENERATED	
	MOV		R1, #1
	STR		R1, [R0]

	; Generar y almacenar 100 números pseudoaleatorios en SRAM
	LDR		R2, =SRAM_BASE
	MOV		R3, #0
	MOV		R4, #12345
	LDR		R5, =12345
gen_loop
	MOV		R4, R4, LSL #5
	ADD		R4, R4, R5
	AND		R4, R4, #0x000000FF	
	STRB	R4, [R2], #1
	ADD		R3, R3, #1
	CMP		R3, #100
	BNE		gen_loop

opcion1_check
	LDR		R0, =GPIOC_IDR
	LDR		R1, [R0]
	AND		R1, R1, #0x00000003
	CMP		R1, #0x00
	BEQ		inicio
	BNE		opcion1_check
; --------------------------------
; --- Opción 2: Ordenar números ---
opcion2
	; Verificar si se han generado los números aleatorios
	LDR		R0, =FLAG_GENERATED
	LDR		R1, [R0]
	CMP		R1, #0
	BEQ		inicio

	; Proceder a ordenar los números
	; Algoritmo de ordenamiento por selección
	LDR		R2, =SRAM_BASE
	MOV		R3, #99	
sort_outer_loop
	LDR		R4, =SRAM_BASE
	ADD		R4, R4, R3
	MOV		R5, R2
	MOV		R6, R2
sort_inner_loop
	ADD		R6, R6, #1
	LDRB	R7, [R6]
	LDRB	R8, [R5]
	CMP		R7, R8
	BGE		no_swap_needed
	MOV		R5, R6

no_swap_needed
	CMP		R6, R4
	BNE		sort_inner_loop

	; Intercambio de valores
	LDRB	R7, [R2]
	LDRB	R8, [R5]
	STRB	R8, [R2]
	STRB	R7, [R5]

	ADD		R2, R2, #1
	SUB		R3, R3, #1
	CMP		R3, #0
	BPL		sort_outer_loop

	; Enciende el LED y establece la bandera
	LDR		R0, =GPIOC_BSRR
	LDR		R1, =0x00002000
	STR		R1, [R0]

	LDR		R0, =FLAG_GENERATED
	MOV		R1, #1
	STR		R1, [R0]

opcion2_check
	LDR		R0, =GPIOC_IDR
	LDR		R1, [R0]
	AND		R1, R1, #0x00000003
	CMP		R1, #0x00
	BEQ		inicio
	CMP		R1, #0x02
	BEQ		opcion2_check
	B		opcion1_check
	
		END