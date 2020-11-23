;*******************************************************************************                                                                       *
;    Filename:		    Proyecto_3.0.asm                              *
;    Date:                  08/09/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           carro seguidor de luz                                                                                                            *
;*******************************************************************************
#include "p16f887.inc"

; CONFIG1
; __config 0x20D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 ;****************************************************************************** 
 ; variables
 ;******************************************************************************
GPR_VAR		UDATA
    CONT1	RES	1
    UNIDADES	RES	1
    CONT2	RES	1
    CONT3	RES	1
    CONT4	RES	1
    CONT6	RES	1
    CONT7	RES	1
    CONT8	RES	1
    CONT9	RES	1
    CONT10	RES	1
    CONT11	RES	1
    CONT12	RES	1
    CONT13	RES	1
    W_TEMP	RES	1
    STATUS_TEMP RES	1
    INDICADOR	RES	1
    INDICADOR2	RES	1
    SERVO	RES	1
    CAMBIO	RES	1
    PARTEALTA	RES	1
    PARTEBAJA	RES	1
    ACCION	RES	1
    CHECK	RES	1
    LUCES	RES	1
    PUSH_BUTTON	RES	1
;*******************************************************************************
; Reset Vector
;*******************************************************************************
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START   
ISR_VECT  CODE	  0x0004
PUSH:
    BCF	    INTCON, GIE
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
ISR:
    BTFSC   INTCON, T0IF
    CALL    INTERRUPCION_TMRO
    BTFSC   PIR1, TMR1IF
    CALL    INTERRUPCION_TMR1
    ;BTFSC   PIR1, RCIF
    ;CALL    INTERRUPCION_RECIBIR
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS 
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

INTERRUPCION_TMRO:
    BTFSC  SERVO, 0
    GOTO   APAGAR_19.3MS
ENCENDER_0.7MS:
    MOVFW   PARTEALTA    ;valor para una interrupcion cada 2ms
    MOVWF   TMR0
    BSF	    PORTA, 1
    BSF	    SERVO, 0
    BCF	    INTCON, T0IF 
    RETURN 
APAGAR_19.3MS:
    MOVFW   PARTEBAJA    ;valor para una interrupcion cada 2ms
    MOVWF   TMR0
    BCF	    PORTA, 1
    BCF	    SERVO, 0
    BCF	    INTCON, T0IF 
    RETURN 
;INTERRUPCION_RECIBIR:
;    MOVFW   RCREG
;    MOVWF   ACCION
;    RETURN
INTERRUPCION_TMR1:
    MOVLW   0x0B
    MOVWF   TMR1H
    MOVLW   0xDC
    MOVLW   TMR1L  
    BCF	    PIR1, TMR1IF
    ;CALL    SELECCION ;rutina que verifica el orden de displays y los convierte 
    CALL    ANTIRREBOTE
    BTFSS   CHECK, 1
    GOTO    $+2
    CALL    NOVENTAGRADOS 
    BCF	    CHECK, 1
    RETURN 

;*******************************************************************************
; TABLAS
;*******************************************************************************
TABLA_ASCII:
    ANDLW   B'00001111'	
    ADDWF   PCL, F
    RETLW   .48	;0 = ascii(48)
    RETLW   .49	;1 = ascii(49)
    RETLW   .50	;2 = ascii(50)
    RETLW   .51	;3 = ascii(51)
    RETLW   .52	;4 = ascii(52)
    RETLW   .53	;5 = ascii(53)
    RETLW   .54	;6 = ascii(54)
    RETLW   .55	;7 = ascii(55)
    RETLW   .56	;8 = ascii(56)
    RETLW   .57	;9 = ascii(57)
    RETLW   .65	;A = ascii(65)  
    RETLW   .66	;B = ascii(66)  
    RETLW   .67	;C = ascii(67)  
    RETLW   .68	;D = ascii(68)  
    RETLW   .69	;E = ascii(69)  
    RETLW   .70	;F = ascii(70)
;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************
MAIN_PROG   CODE     0x0100                 ; let linker place main program
START
CALL SETUP
;*******************************************************************************
; MAIN LOOP
;*******************************************************************************
 LOOP:
    BTFSC   CHECK, 0
    CALL    ENCENDER_LUCES
    GOTO    LOOP

;******************RUTINAS AUXILIARES*******************************************
 NOVENTAGRADOS:
    MOVLW   .250
    MOVWF   PARTEALTA
    MOVLW   .184
    MOVWF   PARTEBAJA  
    RETURN 
CEROGRADOS:
    MOVLW   .254
    MOVWF   PARTEALTA
    MOVLW   .180
    MOVWF   PARTEBAJA
    RETURN 
;rutina de verificadcoin 
SELECCION:
    MOVLW   .48
    SUBWF   ACCION, W 
    MOVWF   ACCION 
    MOVLW   .0
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    INICIAR_CARRERA
    MOVLW   .1
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO   TERMINAR_CARRERA
    MOVLW   .2
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO   CEROGRADOS
    MOVLW   .3
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    NOVENTAGRADOS
    MOVLW   .4
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    BSF	    CHECK, 0
    MOVLW   .5
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    INCREMENTAR_CONTADOR
    RETURN
DELAY_SMALL:
    MOVLW	.255
    MOVWF	CONT1
    DECFSZ	CONT1, 1
    GOTO	$-1
    RETURN
ENCENDER_LUCES:
    BSF	    PORTD, RD7
    CALL    DELAY_BIG
    BCF	    PORTD, RD7
    BSF	    PORTD, RD6
    CALL    DELAY_BIG
    BCF	    PORTD, RD6
    BSF	    PORTD, RD5
    CALL    DELAY_BIG
    BCF	    PORTD, RD5
    BCF	    CHECK, 0
    RETURN 
INCREMENTAR_CONTADOR:
    MOVLW   .4
    SUBWF   LUCES, W
    BTFSC   STATUS,Z
    GOTO    QUINTA_CARRERA
    MOVLW   .3
    SUBWF   LUCES, W
    BTFSC   STATUS,Z
    GOTO    CUARTA_CARRERA
    MOVLW   .2
    SUBWF   LUCES, W
    BTFSC   STATUS,Z
    GOTO    TERCERA_CARRERA
    MOVLW   .1
    SUBWF   LUCES, W
    BTFSC   STATUS,Z
    GOTO    SEGUNDA_CARRERA
PRIMERA_CARRERA:
    MOVLW   .1
    MOVWF   PORTB
    INCF    LUCES
    RETURN 
SEGUNDA_CARRERA:
    MOVLW   .3
    MOVWF   PORTB
    INCF    LUCES
    RETURN 
TERCERA_CARRERA:
    MOVLW   .7
    MOVWF   PORTB
    INCF    LUCES
    RETURN 
CUARTA_CARRERA:
    MOVLW   .15
    MOVWF   PORTB
    INCF    LUCES
    RETURN 
QUINTA_CARRERA:
    MOVLW   .31
    MOVWF   PORTB
    CLRF    LUCES
    BSF	    CHECK, 1
    RETURN 
INICIAR_CARRERA:
    BSF	    CHECK, 0
    CALL    NOVENTAGRADOS
    RETURN 
TERMINAR_CARRERA:
    CLRF    PORTB
    CALL    CEROGRADOS
    RETURN
    
DELAY_BIG:
    MOVLW   .255
    MOVWF   CONT2
CONFIG1:
    CALL    DELAY_SMALL
    DECFSZ  CONT2, F
    GOTO    CONFIG1
    RETURN
    
ANTIRREBOTE:
    BTFSC   PUSH_BUTTON, 0
    GOTO    DEBOUNCE 
    BTFSC   PORTA, 0
    RETURN 
    BSF	    PUSH_BUTTON, 0
    RETURN 
DEBOUNCE:
    BTFSC   PUSH_BUTTON, 0
    CALL    ACCION_ANTIRREBOTE 
    RETURN
ACCION_ANTIRREBOTE:
    BTFSS   PORTA, 0
    RETURN
    BCF	    PUSH_BUTTON, 0
    CALL    INCREMENTAR_CONTADOR
    RETURN
;****************************CONFIGURACION**************************************
SETUP:
    BANKSEL PORTA  ; BANCO 0
    CLRF    PORTA  ; BORRA EL PUERTO 
    CLRF    PORTB  ; BORRA EL PUERTO B
    CLRF    PORTC 
    CLRF    PORTD  
    CLRF    PORTE
    BCF	    STATUS, Z
;***********************TMR2****************************************************
   CONFIGURACION_TIMER2:
    MOVLW   b'11111111'
    MOVWF   T2CON
 ;**************timer1**********************************************************   
    CLRF    T1CON
    BSF        T1CON,0      ; HABILITAMOS EL TIMER 1 (TMR1ON=1)
    BCF        T1CON,1      ; OSCILADOR INTERNO 
    BCF        T1CON,3      ; NO HABILITA EL OSCILADOR DEL TIMER 1 (T1OSCEN=0)
    BSF        T1CON,4      ; PRE DIVISOR DE FRECUENCIA EN 8 (T1CKPS0=0)
    BSF        T1CON,5  
 ;******************************************************************************
 
    
    BANKSEL ANSEL   ; BANCO 3 
    CLRF    ANSELH  ; BORRA EL CONTROL DE ENTRADAS ANALÓGICAS
    CLRF    ANSEL
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA 
    BSF	    TRISA, 0
    CLRF    TRISB
    CLRF    TRISC  
    CLRF    TRISD
    CLRF    TRISE
    ;BSF	    PIE1, TXIE
    ;BSF	    PIE1, RCIE
    CONFIGURACION_TIMER0:
    CLRWDT		; CONFIGURACIÓN PARA EL FUNCIONAMIENTO DEL TIMER0
    MOVLW   b'11010111'	
    MOVWF   OPTION_REG
    CONFIGURACION_INTERRUPCION:
    BANKSEL TRISA
    BSF	    PIE1, TMR1IE; HABILITA INTERRUPCION DEL TIMER1
    ;BSF	    PIE1, TMR2IE; HABILITA COMPARACION ENTRE PR2 Y TIMER2
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    MOVLW   .20	; PARA TMR2 FUNCIONAR CON 5ms
    MOVWF   PR2
    
     
;    CONFIGURACION_TRANSMISOR_Y_RECEPTOR:
;    BANKSEL TRISA
;    BCF	    TXSTA, TX9    
;    BCF	    TXSTA, SYNC	    
;    BSF	    TXSTA, BRGH	     
;
;    BANKSEL ANSEL
;    BCF	    BAUDCTL, BRG16  
;    
;    BANKSEL TRISA
;    MOVLW   .25
;    MOVWF   SPBRG	    
;    CLRF    SPBRGH	    
;    BSF	    TXSTA, TXEN
;
;    BANKSEL PORTA
;    BSF	    RCSTA, SPEN
;    BCF	    RCSTA, RX9
;    BSF	    RCSTA, CREN
    
    BANKSEL PORTA
    BSF	    INTCON, GIE ; HABILITA LAS INTERRUPCIONES
    BCF	    INTCON, T0IF; PARA ASEGURARSE DE QUE NO TENGA OVERFLOW AL INICIO
    BCF	    PIR1, TMR1IF
    BCF	    PIR1, TMR2IF
    CLRF    PORTC
    CLRF    PORTA
    CLRF    PORTB 
    CLRF    PORTD
    CLRF    PORTE
  ;****************SE DECLARAN LOS VALORES INICIALES DE LAS VARIABLES *********  
    CLRF    CONT1
    CLRF    CONT2
    CLRF    CONT3
    CLRF    CONT4
    CLRF    CONT6
    CLRF    CONT7
    CLRF    CONT8
    CLRF    CONT9
    CLRF    CONT10
    CLRF    CONT11
    CLRF    CONT12
    CLRF    CONT13	
    CLRF    CAMBIO 
    CLRF    SERVO
    CLRF    PARTEALTA
    CLRF    PARTEBAJA
    CLRF    ACCION 
    CLRF    CHECK
    CLRF    LUCES
    CLRF    PUSH_BUTTON 
    RETURN 
;*******************************************************************************

  END