.include "gpio.inc" @ Includes definitions from gpio.inc file

.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "nvic.inc"



delay:
        # Prologue
        push    {r7} @ backs r7 up
        sub     sp, sp, #28 @ reserves a 32-byte function frame
        add     r7, sp, #0 @ updates r7
        str     r0, [r7] @ backs ms up
        # Body function
        mov     r0, #255 @ ticks = 255, adjust to achieve 1 ms delay
        str     r0, [r7, #16]
# for (i = 0; i < ms; i++)
        mov     r0, #0 @ i = 0;
        str     r0, [r7, #8]
        b       F3
# for (j = 0; j < tick; j++)
F4:     mov     r0, #0 @ j = 0;
        str     r0, [r7, #12]
        b       F5
F6:     ldr     r0, [r7, #12] @ j++;
        add     r0, #1
        str     r0, [r7, #12]
F5:     ldr     r0, [r7, #12] @ j < ticks;
        ldr     r1, [r7, #16]
        cmp     r0, r1
        blt     F6
        ldr     r0, [r7, #8] @ i++;
        add     r0, #1
        str     r0, [r7, #8]
F3:     ldr     r0, [r7, #8] @ i < ms
        ldr     r1, [r7]
        cmp     r0, r1
        blt     F4
        # Epilogue
        adds    r7, r7, #28
        mov	    sp, r7
        pop	    {r7}
        bx	    lr


@ Esta funcion reinicia el contador a 0
reset:
        @ Prologo
        push    {r7, lr} @ respalda r7 y lr
        sub     sp, sp, #8 @ respalda un marco de 16 bytes
        add     r7, sp, #0 @ actualiza r7

        ldr     r0, =GPIOB_ODR @ carga la direccion de GPIOA_ODR a r0
        mov     r1, #0  @ carga un 0 en r1 (reset de leds en 0)
        str     r1, [r0] @ almacena 0 en r0
        mov     r0, #500 @ 500ms a delay
        bl delay

        @ Epilogo
        mov     r0, #0
        adds    r7, r7, #8
        mov	sp, r7
        pop	{r7, lr}
        bx	lr      




                @ PAGINA 378 PDF LIBRO ZHU 





# Esta funcion lee que se esta presionado (boton PA4 incremento. PA0 Decremento o ambos para reiniciar)
read_button_input:
        @Prologo
	push	{r7} @ respalda 
	sub 	sp, sp, #4                       @ revisar, deberia respaldar un marco de 16 bytes con #12
	add	r7, sp, #0 @ actualiza r7

	str 	r0, [r7] @ respalda el argumento recibido (que boton se presiona o ambos)
        ldr     r1, =GPIOA_IDR
        ldr     r1, [r1]
	ldr 	r0, [r7]
	and	r1, r1, r0
	cmp	r1, r0
	beq	.L0
	mov	r0, #0
.L0:
	adds 	r7, r7, #4
	mov	sp, r7
	pop 	{r7}
	bx	lr


# Esta funcion realiza el debouncing si se presiona un boton o ambos
is_button_pressed:
	push 	{r7, lr}
	sub	sp, sp, #16
	add	r7, sp, #0
        
	str 	r0, [r7, #4]
	# read button input
	ldr	r0, [r7, #4]
	bl	read_button_input
	ldr 	r3, [r7, #4]
	cmp	r0, r3
	beq	LL1
	mov	r0, #0
	adds	r7, r7, #16
	mov	sp, r7
	pop 	{r7}
	pop 	{lr}
	bx	lr
LL1:
	# counter = 0
	mov	r3, #0
	str	r3, [r7, #8]
	# for (int i = 0, i < 10, i++) 
	mov     r3, #0 @ j = 0;
        str     r3, [r7, #12]
        b       LL2
LL5:     
	# wait 5 ms
	mov 	r0, #50
	bl   	delay
	# read button input
	ldr	r0, [r7, #4]
	bl	read_button_input
	ldr 	r3, [r7, #4]
	cmp	r0, r3
	beq 	LL3
	mov 	r3, #0
	str	r3, [r7, #8]
LL3:		
	# counter = counter + 1
	ldr 	r3, [r7, #8]
	add	r3, #1
	str 	r3, [r7, #8]
	ldr 	r3, [r7, #8]
	cmp	r3, #4
	blt	LL4
	ldr	r0, [r7, #4]
	adds	r7, r7, #16
	mov	sp, r7
	pop 	{r7}
	pop 	{lr}
	bx	lr
LL4:
	ldr     r3, [r7, #12] @ j++;
        add     r3, #1
        str     r3, [r7, #12]
LL2:     
	ldr     r3, [r7, #12] @ j < 10;
        cmp     r3, #10
        blt     LL5

	# Epilogo
	mov 	r0, #0
	adds	r7, r7, #16
	mov	sp, r7
	pop 	{r7}
	pop 	{lr}
	bx	lr









setup:
        @Prologo
        push 	{r7, lr} @ respalda r7 y lr
	sub 	sp, sp, #8 @ respalda un marco de 16 bytes
	add	r7, sp, #0 @ actualiza r7


@ Configuracion de puertos de reloj
        @ Habilitacion de puertos A y B
        ldr     r1, =RCC_APB2ENR @ carga la direccion 0x40021018 a r1
        mov     r2, 0xC @ carga 12 (1100) en r2 para habilitar reloj en puertos A (IOPA) y puertos B (IOPB)
        str     r2, [r1] @ M[RCC_APB2ENR] escribe 4


@ configuracion de pines de entrada y salida
        @ Configura los puertos PA4 y PA0 como entradas (2 push button) 
        ldr     r1, =GPIOA_CRL @ carga la direccion de GPIOA_CRL a r1
        ldr     r2, =0x44484448 @ constante que establece el estado de pines 
        str     r2, [r1] @ M[GPIOA_CRL] obtiene el valor 0x44484448

        @ Configura los puertos PA15 - PA8 en modo reset
        ldr     r1, =GPIOA_CRH @ carga la direccion de GPIOA_CRH a r1
        ldr     r2, =0x44444444 @ constante que establece el estado de pines 
        str     r2, [r1] @ M[GPIOA_CRH] obtiene el valor 0x44444444

        @ Configura los puertos PB7 - PB5 como salidas push pull (3 LEDS) y PB4 - PB0 en modo reset
        ldr     r1, =GPIOB_CRL @ carga la direccion de GPIOB_CRL a r1
        ldr     r2, =0x33344444 @ constante que establece el estado de pines 
        str     r2, [r1] @ M[GPIOB_CRL] obtiene el valor 0x33344444

        @ Configura los puertos PB15 en reset y PB14 - PB8 como salidas push pull (7 LEDS)
        ldr     r1, =GPIOB_CRH @ carga la direccion de GPIOB_CRH a r1
        ldr     r2, =0x43333333 @ constante que establece el estado de pines 
        str     r2, [r1] @ M[GPIOB_CRH] obtiene el valor 0x43333333

        

@ Inicializacion de leds 
        ldr     r3, =GPIOB_ODR  @ carga la direccion de GPIOB_ODR a r3
        mov     r4, 0x0 @ inicializa los leds como apagados
        str     r4, [r3] @ guarda en r4 el estado de los leds (0)
        mov     r3, 0x0 @ contador de leds inicializado en 0
        str     r3, [r7, #4] @ guarda el valor del contador para los leds dentro del marco

         
loop:   
@ Verificar si ambos push button estan presionados
        mov     r0, 0x11 @ carga un valor de 17 (0001 0001) para indicar que se quiere leer los bits 5 y 0 (PA4, PA0; 2 push button)
        bl      is_button_pressed 
        cmp     r0, 0x11
        bne     L0 @ Si ambos no estan presionados, ver si alguno esta presionado
        bl      reset
        str     r0, [r7, #4] @ guarda el estado de los leds dentro del marco
L0:
@ Verificar si algun boton se presiona 
@ Si se presiona el boton del pin PA4 (incremento)
        mov     r0, 0x10 @ carga un valor de 16 (0001 0000) para indicar que se quiere leer el bit 5 (PA4 push button para incremento)
        bl      is_button_pressed 
        cmp     r0, 0x10
        bne     L1 @ si no se presiona, ver si el pin PB6 se presiona
        @ si se presiona, entonces incrementa 
        ldr     r1, =GPIOB_ODR @ carga la direccion de GPIOB_ODR a r1
        ldr     r2, [r7, #4] @ carga en r2 el valor actual del contador 
        adds    r2, r2, #1 @ aumenta en 1 el valor del contador
        str     r2, [r7,#4] @ almacena el nuevo valor del contador dentro del marco
        mov     r3, r2 @ carga en r3 el valor del contador
        lsl     r3, r3, #5 @ desplaza 5 unidades a la izquierda por el desfase donde se ubican los leds (el primer led se ubica en la 5ta posicion PA4)
        str     r3, [r1] @ almacena el nuevo valor de los LEDS (GPIOA_ODR) +1        

L1:     
@ Si se presiona el boton del pin PA0 (decremento)
        mov     r0, 0x01 @ carga un valor de 1 (0001) para indicar que se quiere leer el bit 0 (PA0 push button para decremento)
        bl      is_button_pressed
        cmp     r0, 0x01
        bne     L2 @ Si no se presiona, vuelve a loop
        @ si se presiona, entonces decrementa 
        ldr     r1, =GPIOB_ODR @ carga la direccion de GPIOA_IDR a r1
        ldr     r2, [r7, #4] @ carga en r2 el valor actual del contador
        sub     r2, r2, #1 @ decrementa en 1 el valor del contador
        str     r2, [r7, #4] @ almacena el nuevo valor del contador dentro del marco
        mov     r3, r2 @ carga en r3 el valor del contador
        lsl     r3, r3, #5 @ desplaza 5 unidades a la izquierda por el desfase donde se ubican los leds (el primer led se ubica en la 5ta posicion PA4)
        str     r3, [r1] @ almacena el nuevo valor de los LEDS (GPIOA_ODR) -1       

L2:
        b       loop
