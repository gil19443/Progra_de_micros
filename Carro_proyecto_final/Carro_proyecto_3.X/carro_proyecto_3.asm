;*******************************************************************************                                                                       *
;    Filename:		    carro_proyecto_3.asm                              *
;    Date:                  08/09/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           carro seguidor de luz                                                                                                           *
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
    DISPLAY0    RES	1
    DISPLAY1    RES	1
    DISPLAY2    RES	1
    DISPLAY3    RES	1
    X		RES	1
    Y		RES	1
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
    BTFSC   INTCON, T0IF
    CALL    INTERRUPCION_TMRO
    
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS 
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

INTERRUPCION_TMRO:
    MOVLW   .216    ;valor para una interrupcion cada 2ms
    MOVWF   TMR0 
    CALL    MAPEO_CCP1
    CALL    MAPEO_CCP2
    BCF	    INTCON, T0IF
    RETURN 
;mux de lectura del ADC, cada vez que entra a una interrupcion cambia de canal, lo lee y guarda el valor leido en una variable diferente  
INTERRUPCION_ADC:
    BTFSC   CONT3, 0
    GOTO    INTERRUPCION_Y
INTERRUPCION_X:
    MOVF    ADRESH, W	
    MOVWF   X
    BCF	    PIR1, ADIF
    CALL    CONFIGURACION_ADC_Y
    BSF	    ADCON0, 1
    BSF	    CONT3, 0
    RETURN
INTERRUPCION_Y:
    MOVF    ADRESH, W	
    MOVWF   Y
    BCF	    PIR1, ADIF
    CALL    CONFIGURACION_ADC_X
    BSF	    ADCON0, 1
    BCF	    CONT3, 0
    RETURN      
;*******************************************************************************
; MAIN PROGRAM
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
MAIN_PROG   CODE     0x0100                 ; let linker place main program
START
CALL SETUP
;*******************************************************************************
; MAIN LOOP
;*******************************************************************************
 LOOP:	    
	
    GOTO    LOOP 
;******************RUTINAS AUXILIARES*******************************************
    MAPEO_CCP1:
    MOVFW   X
    MOVWF   CCPR1L
    RETURN 
    
    MAPEO_CCP2:
    MOVFW   Y
    MOVWF   CCPR2L
    RETURN 
    
;****************************CONFIGURACION**************************************
;configuraciones para el cambio de canal****************************************
CONFIGURACION_ADC_X:
    BCF	    ADCON0, 4
    RETURN 
CONFIGURACION_ADC_Y:
    BSF	    ADCON0, 4
    RETURN
;*******************************************************************************
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
    BANKSEL PORTA
    MOVLW   b'11111111'
    MOVWF   T2CON 
 ;******************************************************************************
    BANKSEL ANSEL   ; BANCO 3 
    CLRF    ANSELH  ; BORRA EL CONTROL DE ENTRADAS ANALÓGICAS
    CLRF    ANSEL
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA  
    CLRF    TRISB
    CLRF    TRISC  
    CLRF    TRISD
    CLRF    TRISE
    CLRWDT	
    CONFIGURACION_TIMER0:
     ; CONFIGURACIÓN PARA EL FUNCIONAMIENTO DEL TIMER0
    MOVLW   b'01010111'	
    MOVWF   OPTION_REG
       
    CONFIGURACION_INTERRUPCION:
    BANKSEL TRISA
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    BSF	    PIE1, ADIE

    
    CONFIGURACION_ADC:
    BANKSEL ADCON1 ;
    CLRF    ADCON1
    BANKSEL TRISA ;
    BSF	    TRISA,0
    BSF	    TRISA,5
    BANKSEL ADCON0
    BSF	    ADCON0, 7
    BSF	    ADCON0, ADON
    BSF	    ADCON0, GO
    BCF	    ADCON0, 6
    BCF	    ADCON0, 5
    BCF	    ADCON0, 3
    BCF	    ADCON0, 2
    BANKSEL ANSEL ;
    BSF	    ANSEL,0
    BSF	    ANSEL, 5
    
    CONFIGURACION_CCP1:
    BANKSEL TRISC
    MOVLW   .255	; PARA TMR2 FUNCIONAR CON 3ms
    MOVWF   PR2
    BANKSEL CCP1CON
    BCF	    CCP1CON, 7
    BCF	    CCP1CON, 6		
    BCF	    CCP1CON, 5		
    BCF	    CCP1CON, 4	
    BSF	    CCP1CON, 3
    BSF	    CCP1CON, 2
    BCF	    CCP1CON, 1
    BCF	    CCP1CON, 0
    CONFIGURACION_CCP2:    
    BANKSEL CCP2CON
    BCF	    CCP2CON, 5		
    BCF	    CCP2CON, 4
    BSF	    CCP2CON, 3
    BSF	    CCP2CON, 2
    BSF	    CCP2CON, 1
    BSF	    CCP2CON, 0

    BANKSEL PORTA
    BSF	    INTCON, GIE ; HABILITA LAS INTERRUPCIONES
    BCF	    INTCON, T0IF; PARA ASEGURARSE DE QUE NO TENGA OVERFLOW AL INICIO
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
    CLRF    DISPLAY0
    CLRF    DISPLAY1
    CLRF    DISPLAY2
    CLRF    DISPLAY3
    CLRF    X
    CLRF    Y	
    RETURN 
;*******************************************************************************
  END