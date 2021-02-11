;*******************************************************************************                                                                       *
;    Filename:		    Laboratorio_1.0.asm                              *
;    Date:                  20/07/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           SUMADOR DE 4 BITS                                                                                                                *
;*******************************************************************************

#include "p16f887.inc"

; CONFIG1
; __config 0x20D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0x3FFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 

; TODO PLACE VARIABLE DEFINITIONS GO HERE

 
GPR_VAR		UDATA
    CONT1	RES	1	; VARIABLE PARA REALIZAR DELAY_SMALL
	; VARIABLE PARA REALIZAR DELAY_MED
 
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG   CODE     0x0100                 ; let linker place main program

START
SETUP:
    ; BANK STATUS BITS 6, 5
    BANKSEL PORTA  ; BANCO 0
    CLRF    PORTA  ; BORRA EL PUERTO A
    CLRF    PORTB  ; BORRA EL PUERTO B
    CLRF    PORTC  ; BORRA EL PUERTO C
    CLRF    PORTD
    CLRF    PORTE; BORRA EL PUERTO D
    
    BANKSEL ANSEL   ; BANCO 3 
    CLRF    ANSEL
    CLRF    ANSELH  ; BORRA EL CONTROL DE ENTRADAS ANALÓGICAS
    
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA
    MOVLW   b'11110000' 
    MOVWF   TRISA   ; HABILITAR LA MITAD DE LOS PORTA COMO ENTRADAS Y LA MITAD COMO SALIDAS 
    CLRF    TRISB
    COMF    TRISB   ; HABILITAR TODOS LOS PORTB COMO ENTRDAS 
    MOVLW   .255
    MOVWF   WPUB    
    BCF	OPTION_REG, 7	; ACTIVAR LOS PULL UPS DEL PORTB
    CLRF    TRISC
    MOVLW   b'11100000'
    MOVWF   TRISC   ;HABILITAR 5 PUERTOS DEL PORTC COMO SALIDAS Y Y 3 COMO ENTRADAS 
    CLRF    TRISD
    MOVLW   b'11110000'
    MOVWF   TRISD   ;HABLITAR LA MITAD DE LOS PUERTOS D COMO SALIDAS Y LA MITAD COMO ENTRADAS 
   
   
    
    BANKSEL PORTA  ; REGRESO AL BANCO 0
    CLRF    PORTC
    CLRF    PORTA
    CLRF    PORTB 
    CLRF    PORTD

;*******************************************************************************
; MAIN LOOP
;*******************************************************************************    
    
LOOP:
    CALL    DELAY_SMALL  ;AL FINAL, LIMPIER EL PUERTO C
    BTFSS   PORTB,.5	;SI EL BIT 5 DEL PORTB ESTA EN 0 PARA REALIZAR LA SIGUIENTE INSTRUCCION 
    CALL    INC_PORTA
    BTFSS   PORTB,.4	;SI EL BIT 4 DEL PORTB ESTA EN 0 PARA REALIZAR LA SIGUIENTE INSTRUCCION 
    CALL    DEC_PORTA
    BTFSS   PORTB,.7	;SI EL BIT 7 DEL PORTB ESTA EN 0 PARA REALIZAR LA SIGUIENTE INSTRUCCION 
    CALL    INC_PORTB
    BTFSS   PORTB,.6	;SI EL BIT 6 DEL PORTB ESTA EN 0 PARA REALIZAR LA SIGUIENTE INSTRUCCION 
    CALL    DEC_PORTB
    BTFSS   PORTB,.3	;SI EL BIT 3 DEL PORTB ESTA EN 0 PARA REALIZAR LA SIGUIENTE INSTRUCCION 
    CALL    SUMADOR
    CALL    DELAY_SMALL
    CALL    DELAY_SMALL
    GOTO LOOP


;*******************************************************************************
; RUTINA DE DELAY
;*******************************************************************************
    
SUMADOR 
    BTFSS   PORTB, .3
    GOTO    SUMADOR
    MOVFW   PORTA   ;MUEVE EL ESTADO DE PORTA A W
    ADDWF   PORTD, 0	; SUMA EL ESTADO DE PORTA CON EL DE PORTD Y LO GUARDA EN W
    MOVWF   PORTC   ; ASIGNA LA SUMA ALMACENADA EN W A PORTC
    RETURN
INC_PORTA
    BTFSS   PORTB, .5	;AL SOLTAR EL PUSH INCREMENTA EL PORTA , DE LO CONTRARIO NO HACE NADA 
    GOTO    INC_PORTA
    INCF    PORTA
    RETURN
DEC_PORTA
    BTFSS   PORTB, .4	;AL SOLTAR EL PUSH DECREMENTA EL PORTA , DE LO CONTRARIO NO HACE NADA 
    GOTO    DEC_PORTA
    DECF    PORTA
    RETURN
INC_PORTB
    BTFSS   PORTB, .7	;AL SOLTAR EL PUSH INCREMENTA EL PORTD , DE LO CONTRARIO NO HACE NADA 
    GOTO    INC_PORTB
    INCF    PORTD
    RETURN
DEC_PORTB
    BTFSS   PORTB, .6	;AL SOLTAR EL PUSH DECREMENTA EL PORTD , DE LO CONTRARIO NO HACE NADA 
    GOTO    DEC_PORTB
    DECF    PORTD
    RETURN  
DELAY_SMALL
    MOVLW   .255    ;DELAY QUE DURA 50MS
    MOVWF   CONT1
    DECFSZ  CONT1, F
    GOTO    $-1	    ; IR A PC - 1 
    RETURN
 
;*******************************************************************************

  END