;*******************************************************************************                                                                       *
;    Filename:		    Laboratorio_6.0.asm                              *
;    Date:                  11/08/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           lectura de potenciometro y guardar el EEPROM                                                                                                            *
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
    ADC_VAR	RES	1
    NIBBLE_L	RES	1
    SEGUNDOS	RES	1
    DISPLAY0	RES	1
    DISPLAY1	RES	1
    DISPLAY2	RES	1
    DISPLAY3	RES	1
    LECTURA	RES	1

	
	
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
    CALL    DISPLAY_VAR
    CALL    SEP_NIBBLES
    BCF	    INTCON, T0IF
    RETURN 
    
INTERRUPCION_ADC:
    MOVF    ADRESH, W	;GUARDO ADRESH PORTB
    MOVWF   ADC_VAR
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
    CALL    LECTURA_EEPROM
    BTFSS   PORTB, RB0
    GOTO    REVISAR
    GOTO    LOOP
REVISAR:
    BTFSS   PORTB, RB0
    GOTO    REVISAR
    CALL    ESCRITURA_EEPROM
    GOTO    LOOP
;*******************************************************************************
; SUB RUTINAS 
;*******************************************************************************  
SEP_NIBBLES:
    MOVFW   ADC_VAR
    MOVWF   DISPLAY3
    SWAPF   ADC_VAR, W
    MOVWF   DISPLAY0
    MOVFW   LECTURA
    MOVWF   DISPLAY1
    SWAPF   LECTURA, W
    MOVWF   DISPLAY2
    RETURN
LECTURA_EEPROM:
    BCF	    INTCON,GIE    ; Todas las interrupciones deshabilitadas
    MOVLW   0x00	 ; Mover la dirección al registro W
    BANKSEL EEADR
    MOVWF   EEADR      ; Escribir la dirección
    BANKSEL EECON1
    BCF	    EECON1,EEPGD ; Seleccionar la EEPROM
    BSF	    EECON1,RD    ; Leer los datos
    BANKSEL EEDATA
    MOVFW   EEDATA   ; Dato se almacena en el registro W
    BANKSEL PORTA
    MOVWF   LECTURA
    BSF	    INTCON, GIE
    RETURN
ESCRITURA_EEPROM:
    BANKSEL EEADR
    MOVLW   0x00	; Mover la dirección a W
    MOVWF   EEADR      ; Escribir la dirección
    BANKSEL PORTA
    MOVFW   ADC_VAR      ; Mover los datos a W
    BANKSEL EEDAT
    MOVWF   EEDAT     ; Escribir los datos
    BANKSEL EECON1
    BCF	    EECON1,EEPGD ; Seleccionar la EEPROM
    BSF	    EECON1,WREN  ; Escritura a la EEPROM habilitada
    BCF	    INTCON,GIE    ; Todas las interrupciones deshabilitadas
    MOVLW   0x55
    MOVWF   EECON2
    MOVLW   0xAA
    MOVWF   EECON2
    BSF	    EECON1,WR
    BSF	    INTCON,GIE   ; Interrupciones habilitadas
    BCF	    EECON1,WREN  ; Escritura a la EEPROM deshabilitada
    BANKSEL PORTA
    RETURN 
DISPLAY_VAR:
    BCF	    PORTA, RA1	    
    BCF	    PORTA, RA2
    BCF	    PORTA, RA3
    BCF	    PORTA, RA4
    BTFSC   INDICADOR, 1    
    GOTO    DISPLAY_2Y3
DISPLAY_0Y1:
    BTFSC   INDICADOR, 0
    GOTO    DISPLAY_1
    BSF	    INDICADOR, 1
    DISPLAY_0:
	MOVFW   DISPLAY0
	CALL    TABLA
	MOVWF   PORTD
	BSF	PORTA, RA4
	BSF	INDICADOR, 0
	RETURN
    DISPLAY_1:
	MOVFW   DISPLAY1
	CALL    TABLA
	MOVWF   PORTD
	BSF	PORTA, RA1
	BCF	INDICADOR, 0
	RETURN
DISPLAY_2Y3:
    BTFSC   INDICADOR, 0
    GOTO    DISPLAY_3
    BCF	    INDICADOR, 1
    DISPLAY_2:
	MOVFW   DISPLAY2
	CALL    TABLA
	MOVWF   PORTD
	BSF	PORTA, RA2
	BSF	INDICADOR, 0
	RETURN
    DISPLAY_3:
    	MOVFW   DISPLAY3
	CALL    TABLA
	MOVWF   PORTD
	BSF	PORTA, RA3
	BCF	INDICADOR, 0
	RETURN
  
SETUP:
    BANKSEL PORTA  ; BANCO 0
    CLRF    PORTA  ; BORRA EL PUERTO A
    CLRF    PORTB  ; BORRA EL PUERTO B
    CLRF    PORTC 
    CLRF    PORTD  
    CLRF    PORTE
    BCF	    STATUS, Z
 ;******************************************************************************
    BANKSEL ANSEL   ; BANCO 3 
    CLRF    ANSELH  ; BORRA EL CONTROL DE ENTRADAS ANALÓGICAS
    
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA  
    CLRF    TRISB
    BSF	    TRISB, RB0
    MOVLW   B'01010111'
    MOVWF   OPTION_REG
    CLRF    WPUB
    BSF	    WPUB, 0
    CLRWDT
    CLRF    TRISC
    CLRF    TRISD
    CLRF    TRISE
        
    CONFIGURACION_INTERRUPCION:
    BANKSEL TRISA
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    BSF	    PIE1, ADIE ;INTERRUPCION DEL ADC   
    
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
    CLRF    INDICADOR2
    CLRF    SEGUNDOS 
    CLRF    DECENAS 
    CLRF    UNIDADES 
    CLRF    CONT3
    CLRF    CONT4
    CLRF    CONT6
    CLRF    CONT7
    CLRF    NIBBLE_L
    CLRF    DISPLAY0
    CLRF    DISPLAY1
    CLRF    DISPLAY2
    CLRF    DISPLAY3
    CLRF    ADC_VAR
    CLRF    LECTURA
    RETURN 
;*******************************************************************************

  END