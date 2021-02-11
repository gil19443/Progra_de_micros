;*******************************************************************************                                                                       *
;    Filename:		    Laboratorio_2.0.asm                              *
;    Date:                  11/08/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           contador con display                                                                                                               *
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
    CONT1	RES	1	; VARIABLE PARA REALIZAR DELAY_SMALL
    CONT2	RES	1
    CONTA	RES	1
    CONT3	RES	1
;*******************************************************************************
; Reset Vector
;*******************************************************************************

;*******************************************************************************
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START   
; TABLA
;*******************************************************************************
TABLA:
    ANDLW   B'00001111'
    ADDWF   PCL, F
    RETLW   B'11000000' ;0
    RETLW   B'11111001'	;1
    RETLW   B'00100100'	;2
    RETLW   B'10110000'	;3
    RETLW   B'10011001'	;4
    RETLW   B'00010010'	;5
    RETLW   B'00000010'	;6
    RETLW   B'01111000'	;7
    RETLW   b'00000000' ;8
    RETLW   b'00011000' ;9
    RETLW   b'00001000' ;A
    RETLW   b'00000011' ;b
    RETLW   b'01000110' ;C
    RETLW   b'00100001' ;d
    RETLW   b'00000110' ;E
    RETLW   b'00001110' ;F
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
    CALL FASE2
    GOTO LOOP
;*******************************************************************************
; SUB RUTINAS 
;*******************************************************************************  
ALARMA:
    MOVFW   PORTA
    SUBWF   PORTD, W
    BTFSC   STATUS, Z
    CALL LED_ENCENDER
    RETURN
LED_ENCENDER:
    CLRF    PORTA
    CALL    DELAY_BIG
    BSF	    PORTE, .0
    CALL    DELAY_BIG
    CLRF    PORTE
    RETURN 
BOTTON:
    BTFSS   PORTB, .7
    CALL    INC_PORTB
    BTFSS   PORTB, .6
    CALL    DEC_PORTB
    RETURN
    
DEC_PORTB:
    BTFSS   PORTB, .6	;AL SOLTAR EL PUSH DECREMENTA EL PORTD , DE LO CONTRARIO NO HACE NADA 
    GOTO    DEC_PORTB
    DECF    PORTD
    RETURN  
    
INC_PORTB:
    BTFSS   PORTB, .7	;AL SOLTAR EL PUSH INCREMENTA EL PORTD , DE LO CONTRARIO NO HACE NADA 
    GOTO    INC_PORTB
    INCF    PORTD
    RETURN
 
 DISPLAY:
    MOVF    PORTD, W
    CALL    TABLA 
    MOVWF   PORTC
    RETURN
    
CASO0:
    MOVLW   .0
    MOVWF   CONTA
    MOVFW   CONTA 
    ADDWF   PORTD, W
    RETURN
FASE0:
    INCF    PORTA
    CALL    CONTADOR_TIMER0
    RETURN 
FASE1:
    CALL    DISPLAY
    CALL    BOTTON 
    CALL    ALARMA 
    CALL    CASO0
    BTFSC   STATUS, Z
    GOTO    FASE1
    CALL    FASE0
    RETURN 
FASE2:
    CALL    DISPLAY
    CALL    BOTTON 
    CALL    ALARMA 
    CALL    CASO0
    BTFSC   STATUS, Z
    CLRF    PORTA
    CALL    FASE1
    RETURN
    

CONTADOR_TIMER0:
    MOVLW   .10
    MOVWF   CONT2
TIEMPO1:
    BCF	    INTCON, T0IF
    MOVLW   .61
    MOVWF   TMR0
TIEMPO2:
    BTFSS   INTCON, T0IF
    GOTO    TIEMPO2
    DECFSZ  CONT2, F
    GOTO    TIEMPO1
    RETURN 
    
SETUP:
    BANKSEL PORTA  ; BANCO 0
    CLRF    PORTA  ; BORRA EL PUERTO A
    CLRF    PORTB  ; BORRA EL PUERTO B
    CLRF    PORTC 
    CLRF    PORTD  
    CLRF    PORTE; BORRA EL PUERTO C
    
    BANKSEL ANSEL   ; BANCO 3 
    CLRF    ANSEL
    CLRF    ANSELH  ; BORRA EL CONTROL DE ENTRADAS ANALÓGICAS
    
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA
    MOVLW   b'11110000' 
    MOVWF   TRISA   ; HABILITAR LA MITAD DE LOS PORTA COMO ENTRADAS Y LA MITAD COMO SALIDAS 
    CLRF    TRISB
    MOVLW   B'11000000'
    MOVWF   TRISB
    MOVLW   .255
    MOVWF   WPUB 
    CLRWDT
    MOVLW B'01010111'
    MOVWF   OPTION_REG
    BCF	 INTCON, T0IF
    CLRF    TRISC
    MOVLW   b'00000000'
    MOVWF   TRISC   ;HABILITAR 5 PUERTOS DEL PORTC COMO SALIDAS Y Y 3 COMO ENTRADAS 
    CLRF    TRISD
    MOVLW   b'11110000'
    MOVWF   TRISD
    CLRF    TRISE
    
      ;HABLITAR LA MITAD DE LOS PUERTOS D COMO SALIDAS Y LA MITAD COMO ENTRADAS 
    
    BANKSEL PORTA  ; REGRESO AL BANCO 0
    CLRF    PORTC
    CLRF    PORTA
    CLRF    PORTB 
    CLRF    PORTD
    CLRF    PORTE
    RETURN 
DELAY_FINAL:
    MOVLW .5
    MOVWF CONT3
CONFIG2:
    CALL    DELAY_BIG
    DECFSZ  CONT3, F
    GOTO    CONFIG2
    RETURN  
DELAY_BIG:
    MOVLW .255
    MOVWF CONT2
CONFIG1:
    CALL    DELAY_SMALL
    DECFSZ  CONT2, F
    GOTO    CONFIG1
    RETURN 
DELAY_SMALL:
    MOVLW   .255    ;DELAY QUE DURA 50MS
    MOVWF   CONT1
    DECFSZ  CONT1, F
    GOTO    $-1	    ; IR A PC - 1 
    RETURN
;*******************************************************************************

  END