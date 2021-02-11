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
    BTFSC   INTCON, T0IF
    CALL    INTERRUPCION_TMRO
    BTFSC   PIR1, ADIF
    CALL    INTERRUPCION_ADC
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS 
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    BSF	    INTCON, GIE
    RETFIE

INTERRUPCION_TMRO:
    MOVLW   .248
    MOVWF   TMR0
    BCF	    INTCON, T0IF 
    CALL    DISPLAY_VAR
    CALL    SEP_NIBBLES
    RETURN 
    
INTERRUPCION_ADC:
    MOVF    ADRESH, W	;GUARDO ADRESH PORTB
    MOVWF   PORTB
    BCF	    PIR1, ADIF
    BSF	    ADCON0, 1;PONER EN 0 BANDERA DE LA INETRRUPCION 
    RETURN


;*******************************************************************************
; TABLA
;*******************************************************************************
TABLA:
    ANDLW   b'00001111' ; mascara
    ADDWF   PCL, F
    RETLW   b'10001000' ; 0
    RETLW   b'11101011'	; 1
    RETLW   b'01001100'	; 2
    RETLW   b'01001001'	; 3
    RETLW   b'00101011'	; 4
    RETLW   b'00011001'	; 5
    RETLW   b'00011000'	; 6
    RETLW   b'11001011'	; 7
    RETLW   b'00001000' ; 8
    RETLW   b'00001011' ; 9
    RETLW   b'00000010' ; A
    RETLW   b'00110000' ; b
    RETLW   b'10010100' ; C
    RETLW   b'01100000' ; d
    RETLW   b'00010100' ; E
    RETLW   b'00010110' ; F


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
SEP_NIBBLES:
    MOVFW   PORTB
    MOVWF   NIBBLE_H
    SWAPF   PORTB, W
    MOVWF   NIBBLE_L
    RETURN
    
DISPLAY_VAR:
    BCF	    PORTD, RD2
    BCF	    PORTD, RD1
    BTFSC   INDICADOR, 0
    GOTO    DISPLAY_1
DISPLAY_0:
    MOVFW   NIBBLE_L
    CALL    TABLA
    MOVWF   PORTC
    BSF	    PORTD, RD1
    BSF	    INDICADOR, 0
    RETURN
DISPLAY_1:
    MOVFW   NIBBLE_H
    CALL    TABLA
    MOVWF   PORTC
    BSF	    PORTD, RD2
    BCF	    INDICADOR, 0
    RETURN
  
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
    MOVLW   B'11010111'
    MOVWF   OPTION_REG
    CLRF    TRISC
    CLRF    TRISD
    CLRF    TRISE
    BSF	    PIE1, ADIE ;INTERRUPCION DEL ADC   
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