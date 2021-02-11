;"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
; Filename: Lab 1 principal
; Date: 21/07/2020
; Author: Carlos Gil 
; Company: UVG
; Description : Incremente el puerto A, cada cierto retardo 
;"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 ;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
GPR_VAR	    UDATA
    CONT1   RES 1 ;VARIABLE PARA REAIZAR DELAY_SMALL
    CONT2   RES 1 ;VARIABLE PARA REALIZAR DELAY_BIG
    CONT3   RES 1 ;VARIABLE PARA REALIZAR DELAY_MED
 ;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
; MAIN PROGRAM
;"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
MAIN_PROG CODE     0x0100                 ; let linker place main program
START
SETUP:
    ; BANK STATUS BITS 6,5
    BCF STATUS, 5
    BCF STATUS, 6 ; BANCO 0
    CLRF    PORTA ;BORRAR EL PUERTO A
    CLRF    PORTC 
    
    BSF STATUS, 5
    BSF STATUS, 6 ;BANCO 3
    CLRF    ANSEL ;BORRA EL CONTROL DE ENTRADAS ANALOGICAS 
    CLRF    ANSELH ;BORRA EL CONTROL DE ENTRADAS ANALOGICAS 
    
    BCF STATUS, 6
    BSF STATUS, 5 ;BANCO 1
    SETF    TRISA
    CLRF    TRISC
    
    BCF STATUS, 5 ;BANCO 0
    CLRF    PORTC
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
; MAIN LOOP 
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
LOOP:
    INCF PORTA, 1 ;INCREMENTAR EL PUERTO A Y GUARDAR EN F (1)
    CALL DELAY_BIG ; LLAMAR A RUTINA DE DELAY 
	
    GOTO LOOP ; SALTO HACIA EL LOOP 
; """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
DELAY_BIG 
    MOVLW .177
    MOVWF CONT2
CONFIG1:
    CALL    DELAY_SMALL
    CALL    DELAY_MED
    DECFSZ  CONT2, F
    GOTO    CONFIG1
RETURN 
DELAY_SMALL
    MOVLW	.23
    MOVWF	CONT1
    DECFSZ	CONT1, F
    GOTO	$-1
RETURN
DELAY_MED
    MOVLW	.255
    MOVWF	CONT3
    DECFSZ	CONT3, F
    GOTO	$-1
RETURN
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
TRISA = 0x00
    
END