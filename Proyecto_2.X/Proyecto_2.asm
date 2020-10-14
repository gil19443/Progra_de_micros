;*******************************************************************************                                                                       *
;    Filename:		    Proyecto_2.0.asm                              *
;    Date:                  08/09/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           Interfaz gr�fica                                                                                                            *
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
    NIBBLE_H	RES	1
    NIBBLE_L	RES	1
    DISPLAY0    RES	1
    DISPLAY1    RES	1
    DISPLAY2    RES	1
    DISPLAY3    RES	1
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
    BTFSC   PIR1, TMR2IF
    CALL    INTERRUPCION_TMR2
    BTFSC   PIR1, ADIF
    CALL    INTERRUPCION_ADC
    BTFSC   PIR1, TXIF
    CALL    INTERRUPCION_TX
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS 
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

INTERRUPCION_TMRO:
    MOVLW   .248    ;valor para una interrupcion cada 2ms
    MOVWF   TMR0
    BCF	    INTCON, T0IF 
    CALL    DISPLAY_VAR	;rutina que muxea la se;al en los 4 display cada 2ms
    cALL    SEP_NIBBLES 
    RETURN 
    
INTERRUPCION_TMR1:
    MOVLW   0x0B
    MOVWF   TMR1H
    MOVLW   0xDC
    MOVLW   TMR1L   ;valor para un ainterrupcion cada medio segundo 
    BCF	    PIR1, TMR1IF
    INCF    CONT3   ;contador auxiliar para que se llame la rutina de incremento auotmatico cada 120 interrupciones  
    RETURN

INTERRUPCION_TMR2:
    BCF	    PIR1, TMR2IF
    INCF    CONT7
    MOVLW   .20
    SUBWF   CONT7, W
    BTFSS   STATUS, Z
    RETURN 
    
INTERRUPCION_ADC:
    MOVF    ADRESH, W	;GUARDO ADRESH PORTB
    MOVWF   PORTB
    BCF	    PIR1, ADIF
    BSF	    ADCON0, 1;PONER EN 0 BANDERA DE LA INETRRUPCION 
    RETURN
INTERRUPCION_TX:
    MOVFW   PORTB
    MOVWF   TXREG
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
    GOTO LOOP 
;******************MUXEAR LOS 2 DISPLAY*****************************************
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
	BSF	PORTA, RA3
	BSF	INDICADOR, 0
	RETURN
    DISPLAY_1:
	MOVFW   DISPLAY1
	CALL    TABLA
	MOVWF   PORTD
	BSF	PORTA, RA4
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
	BSF	PORTA, RA1
	BSF	INDICADOR, 0
	RETURN
    DISPLAY_3:
    	MOVFW   DISPLAY3
	CALL    TABLA
	MOVWF   PORTC
	BSF	PORTA, RA2
	BCF	INDICADOR, 0
	RETURN
SEP_NIBBLES:
    MOVFW   PORTB
    MOVWF   DISPLAY0
    SWAPF   PORTB, W
    MOVWF   DISPLAY1
    RETURN
    
;****************************CONFIGURACION**************************************
SETUP:
    BANKSEL PORTA  ; BANCO 0
    CLRF    PORTA  ; BORRA EL PUERTO A
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
    CLRF    ANSEL
    CLRF    ANSELH  ; BORRA EL CONTROL DE ENTRADAS ANAL�GICAS
    
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA  
    CLRF    TRISB
    CLRF    TRISC  
    CLRF    TRISD
    CLRF    TRISE
    BSF	    PIE1, ADIE
    BSF	    PIE1, TXIE;INTERRUPCION DEL ADC  
    CONFIGURACION_TIMER0:
    CLRWDT		; CONFIGURACI�N PARA EL FUNCIONAMIENTO DEL TIMER0
    MOVLW   b'01010111'	; PARA LA CONFIGURACI�N DEL TIMER0, EL BIT 7 NO IMPORTA. SIN EMBARGO, SE COLOCA EN 0 PARA NO ARRUINAR LA INSTRUCCI�N DE LA L�NEA 132 -PARA EL FUNCIONAMIENTO DE PULL UPS-
    MOVWF   OPTION_REG
       
    CONFIGURACION_INTERRUPCION:
    BANKSEL TRISA
    BSF	    PIE1, TMR1IE; HABILITA INTERRUPCION DEL TIMER1
    BSF	    PIE1, TMR2IE; HABILITA COMPARACION ENTRE PR2 Y TIMER2
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    MOVLW   .196	; PARA TMR2 FUNCIONAR CON 50ms
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
    CLRF    DISPLAY0
    CLRF    DISPLAY1
    CLRF    DISPLAY2
    CLRF    DISPLAY3
    RETURN 
;*******************************************************************************

  END