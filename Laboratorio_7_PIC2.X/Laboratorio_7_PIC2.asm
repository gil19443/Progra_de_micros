;*******************************************************************************                                                                       *
;    Filename:		    Laboratorio_6.0.asm                              *
;    Date:                  11/08/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           lectura de potenciometro                                                                                                              *
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
    UNIDADES	RES	1
    CONT2	RES	1
    CONT3	RES	1
    CONT4	RES	1
    DECENAS	RES	1
    CONT6	RES	1
    CONT7	RES	1
    W_TEMP	RES	1
    STATUS_TEMP RES	1
    INDICADOR	RES	1
    INDICADOR2	RES	1
    NIBBLE_H	RES	1
    NIBBLE_L	RES	1
    SEGUNDOS	RES	1
    DISPLAY	RES	1
	
	
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
    BTFSC   PIR1, ADIF
    CALL    INTERRUPCION_ADC
    BTFSC   PIR1, TXIF
    CALL    INTERRUPCION_TX
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS 
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    BSF	    INTCON, GIE
    RETFIE    
INTERRUPCION_ADC:
    MOVF    ADRESH, W	;GUARDO ADRESH PORTB
    MOVWF   UNIDADES 
    BCF	    PIR1, ADIF
    BSF	    ADCON0, 1;PONER EN 0 BANDERA DE LA INETRRUPCION 
    RETURN
INTERRUPCION_TX:
    MOVFW   UNIDADES
    MOVWF   TXREG
    RETURN 

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
    GOTO    LOOP
;*******************************************************************************
; SUB RUTINAS 
;*******************************************************************************       
SETUP:
    BANKSEL PORTA  ; BANCO 0
    CLRF    PORTA  ; BORRA EL PUERTO A
    CLRF    PORTB  ; BORRA EL PUERTO B
    CLRF    PORTC 
    CLRF    PORTD  
    CLRF    PORTE
    BCF	    STATUS, Z
    BCF	    PIR1, TMR1IF
    BCF	    PIR1, TMR2IF
;***********************TMR2****************************************************
    CLRF    T2CON
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
    
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA  
    CLRF    TRISB

    CLRF    TRISC
    CLRF    TRISD
    CLRF    TRISE
    BSF	    PIE1, ADIE
    BSF	    PIE1, TXIE;INTERRUPCION DEL ADC   
    CONFIGURACION_TIMER2:
    MOVLW   b'11111111'
    MOVWF   T2CON
        
    CONFIGURACION_INTERRUPCION:
    BANKSEL TRISA
    BSF	    PIE1, TMR1IE; HABILITA INTERRUPCION DEL TIMER1
    BSF	    PIE1, TMR2IE; HABILITA COMPARACION ENTRE PR2 Y TIMER2
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    
    MOVLW   .196	; TECHO PARA TIMER2 - PARA FUNCIONAR CON 50ms
    MOVWF   PR2
    
    CONFIGURACION_ADC:
    BANKSEL ADCON1 ;
    CLRF    ADCON1
    BANKSEL TRISA ;
    BSF	    TRISA,0 ;Set RA0 to input
    BANKSEL ANSEL ;
    BSF	    ANSEL,0 ;Set RA0 to analog
    BANKSEL ADCON0 ;
    MOVLW   B'10000011' ;ADC Frc clock,
    MOVWF   ADCON0 ;AN0, On
    BSF	    ADCON0, ADON
    BSF	    ADCON0, GO
    BANKSEL PORTA
    BSF	    INTCON, GIE ; HABILITA LAS INTERRUPCIONES
    BCF	    INTCON, T0IF; PARA ASEGURARSE DE QUE NO TENGA OVERFLOW AL INICI

CONFIGURACION_TRANSMISOR:
    BANKSEL TRISA
    MOVLW   0x03
    MOVWF   SPBRGH
    MOVLW   0x40
    MOVWF   SPBRG
    BANKSEL TXSTA
    BSF	    TXSTA, BRGH
    BANKSEL ANSEL
    BSF	    BAUDCTL, BRG16
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN
    BANKSEL TXSTA
    BCF	    TXSTA, TX9
    BSF	    TXSTA, TXEN

    BANKSEL PORTA  ; REGRESO AL BANCO 0
    CLRF    PORTC
    CLRF    PORTA
    CLRF    PORTB 
    CLRF    PORTD
    CLRF    PORTE
    CLRF    ADRESH
    BSF	    PIR1, ADIF
    
    CLRF    SEGUNDOS 
    CLRF    DECENAS 
    CLRF    UNIDADES 
    CLRF    CONT3
    CLRF    CONT4
    CLRF    CONT6
    CLRF    CONT7
    CLRF    NIBBLE_H
    CLRF    NIBBLE_L
    CLRF    DISPLAY
    RETURN 
;*******************************************************************************

  END