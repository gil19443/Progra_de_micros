;*******************************************************************************                                                                       *
;    Filename:		    Proyecto_2.0.asm                              *
;    Date:                  08/09/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           Interfaz grâfica                                                                                                            *
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
    NIBBLE_H	RES	1
    NIBBLE_L	RES	1
    DISPLAY0    RES	1
    DISPLAY1    RES	1
    DISPLAY2    RES	1
    DISPLAY3    RES	1
    X		RES	1
    Y		RES	1
    RECIBIDOX   RES	1
    RECIBIDOY	RES	1
    NHX		RES	1
    NLX		RES	1
    NHY		RES	1
    NLY		RES	1
    BYTE0	RES	1
    BYTE1	RES	1
    BYTE2	RES	1
    BYTE3	RES	1
    BYTE4	RES	1
    BYTE5	RES	1
    BYTE6	RES	1
    ORDEN	RES	1
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
    BTFSC   PIR1, TMR2IF
    CALL    INTERRUPCION_TMR2
    BTFSC   PIR1, RCIF
    CALL    INTERRUPCION_RECIBIR
    BTFSC   PIR1, TMR1IF
    CALL    INTERRUPCION_TMR1
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
    CALL    SEP_NIBBLES_Y
    CALL    SEP_NIBBLES_X
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
;mux encargado de que cada vez que entre a la interrupcion reciba un dato distinto y lo guarde en una variable diferente       
INTERRUPCION_TMR1:
    MOVLW   0x0B
    MOVWF   TMR1H
    MOVLW   0xDC
    MOVLW   TMR1L   ;valor para un ainterrupcion cada medio segundo 
    BCF	    PIR1, TMR1IF
    CALL    SEPARACION
    RETURN
INTERRUPCION_RECIBIR:
    MOVLW   .5
    SUBWF   ORDEN, W
    BTFSC   STATUS, Z
    GOTO    BYTE_5
    MOVLW   .4
    SUBWF   ORDEN, W
    BTFSC   STATUS, Z
    GOTO    BYTE_4
    MOVLW   .3
    SUBWF   ORDEN, W
    BTFSC   STATUS, Z
    GOTO    BYTE_3
    MOVLW   .2
    SUBWF   ORDEN, W
    BTFSC   STATUS, Z 
    GOTO    BYTE_2
    MOVLW   .1
    SUBWF   ORDEN, W
    BTFSC   STATUS,Z 
    GOTO    BYTE_1
BYTE_0:
    MOVFW   RCREG
    MOVWF   BYTE0
    INCF    ORDEN
    RETURN 
BYTE_1:
    MOVFW   RCREG
    MOVWF   BYTE1
    INCF    ORDEN
    RETURN 
BYTE_2:
    MOVFW   RCREG
    MOVWF   BYTE2
    INCF    ORDEN
    RETURN 
BYTE_3:
    MOVFW   RCREG
    MOVWF   BYTE3
    INCF    ORDEN
    RETURN 
BYTE_4:
    MOVFW   RCREG
    MOVWF   BYTE4
    INCF    ORDEN
    RETURN 
BYTE_5:
    MOVFW   RCREG
    MOVWF   BYTE5
    CLRF    ORDEN
    BSF	    CONT11, 0
    RETURN 
;interrupcion encargada de llamar la funcino que envia datos cada 5ms   
INTERRUPCION_TMR2:
    BCF	    PIR1, TMR2IF
    BTFSC   PIR1, TXIF
    CALL    INTERRUPCION_TX
    RETURN
;*******************************************************************************
; TABLA
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
;    BTFSC   CONT11, 0 
;    GOTO    $+2
;    GOTO    LOOP
;    BCF	    CONT11, 0
;    MOVLW   .44
;    SUBWF   BYTE2, W
;    BTFSS   STATUS, Z
;    GOTO    LIMPIAR
;    MOVFW   BYTE0
;    SUBLW   .48
;    MOVWF   DISPLAY0
;    MOVFW   BYTE1
;    SUBLW   .48
;    MOVWF   DISPLAY1
;    MOVFW   BYTE3
;    SUBLW   .48
;    MOVWF   DISPLAY2
;    MOVFW   BYTE4
;    SUBLW   .48
;    MOVWF   DISPLAY3
;    GOTO    LOOP
;LIMPIAR:
;    CLRF    BYTE0	
;    CLRF    BYTE1	
;    CLRF    BYTE2	
;    CLRF    BYTE3	
;    CLRF    BYTE4	
;    CLRF    BYTE5		
    GOTO    LOOP 
;******************MUXEAR LOS 2 DISPLAY*****************************************
SEP_NIBBLES_X:
    MOVFW   X
    MOVWF   NHX
    SWAPF   X, W
    MOVWF   NLX
    RETURN
SEP_NIBBLES_Y:
    MOVFW   Y
    MOVWF   NHY
    SWAPF   Y, W
    MOVWF   NLY
    RETURN 
    
INTERRUPCION_TX:
    MOVLW   .5
    SUBWF   CONT7, W
    BTFSC   STATUS, Z 
    GOTO    ESPACIO 
    MOVLW   .4
    SUBWF   CONT7, W
    BTFSC   STATUS, Z 
    GOTO    MANDAR_NHY
    MOVLW   .3
    SUBWF   CONT7, W
    BTFSC   STATUS, Z 
    GOTO    MANDAR_NLY
    MOVLW   .2
    SUBWF   CONT7, W
    BTFSC   STATUS, Z 
    GOTO    COMA 
    MOVLW   .1
    SUBWF   CONT7, W
    BTFSC   STATUS, Z 
    GOTO    MANDAR_NHX
MANDAR_NLX:
    MOVFW   NLX
    CALL    TABLA_ASCII
    MOVWF   TXREG
    INCF    CONT7
    RETURN
MANDAR_NHX:
    MOVFW   NHX
    CALL    TABLA_ASCII
    MOVWF   TXREG
    INCF    CONT7
    RETURN 
COMA:
    MOVLW   .44
    MOVWF   TXREG
    INCF    CONT7
    RETURN
MANDAR_NHY:
    MOVFW   NHY
    CALL    TABLA_ASCII
    MOVWF   TXREG
    INCF    CONT7
    RETURN 
MANDAR_NLY:
    MOVFW   NLY
    CALL    TABLA_ASCII
    MOVWF   TXREG
    INCF    CONT7
    RETURN
ESPACIO:
    MOVLW   .10
    MOVWF   TXREG
    CLRF    CONT7
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
SEPARACION:
    BTFSC   CONT11, 0 
    GOTO    $+2
    RETURN
    BCF	    CONT11, 0
    MOVLW   .44
    SUBWF   BYTE2, W
    BTFSS   STATUS, Z
    GOTO    LIMPIAR
    MOVLW   .48
    SUBWF   BYTE0, W
    MOVWF   DISPLAY0
    MOVLW   .48
    SUBWF   BYTE1, W
    MOVWF   DISPLAY3
    MOVLW   .48
    SUBWF   BYTE3, W
    MOVWF   DISPLAY2
    MOVLW   .48
    SUBWF   BYTE4, W
    MOVWF   DISPLAY1
    RETURN
LIMPIAR:
    CLRF    BYTE0	
    CLRF    BYTE1	
    CLRF    BYTE2	
    CLRF    BYTE3	
    CLRF    BYTE4	
    CLRF    BYTE5
    RETURN
;****************************CONFIGURACION**************************************
;configuraciones para el cambio de canal****************************************
CONFIGURACION_ADC_X:
    BANKSEL ADCON0 
    BCF	    ADCON0, 4
    RETURN 
CONFIGURACION_ADC_Y:
    BANKSEL ADCON0 
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
    ;BSF	    PIE1, TXIE
    BSF	    PIE1, RCIE
    CONFIGURACION_TIMER0:
    CLRWDT		; CONFIGURACIÓN PARA EL FUNCIONAMIENTO DEL TIMER0
    MOVLW   b'01010111'	
    MOVWF   OPTION_REG
       
    CONFIGURACION_INTERRUPCION:
    BANKSEL TRISA
    BSF	    PIE1, TMR1IE; HABILITA INTERRUPCION DEL TIMER1
    BSF	    PIE1, TMR2IE; HABILITA COMPARACION ENTRE PR2 Y TIMER2
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    MOVLW   .20	; PARA TMR2 FUNCIONAR CON 5ms
    MOVWF   PR2
    
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

     
    CONFIGURACION_TRANSMISOR_Y_RECEPTOR:
    BANKSEL TRISA
    BCF	    TXSTA, TX9    
    BCF	    TXSTA, SYNC	    
    BSF	    TXSTA, BRGH	     

    BANKSEL ANSEL
    BCF	    BAUDCTL, BRG16  
    
    BANKSEL TRISA
    MOVLW   .25
    MOVWF   SPBRG	    
    CLRF    SPBRGH	    
    BSF	    TXSTA, TXEN

    BANKSEL PORTA
    BSF	    RCSTA, SPEN
    BCF	    RCSTA, RX9
    BSF	    RCSTA, CREN
    
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
    CLRF    DISPLAY0
    CLRF    DISPLAY1
    CLRF    DISPLAY2
    CLRF    DISPLAY3
    CLRF    UNIDADES 
    CLRF    X
    CLRF    Y
    CLRF    RECIBIDOX
    CLRF    RECIBIDOY
    CLRF    NHX
    CLRF    NLX
    CLRF    NHY
    CLRF    NLY
    CLRF    BYTE0	
    CLRF    BYTE1	
    CLRF    BYTE2	
    CLRF    BYTE3	
    CLRF    BYTE4	
    CLRF    BYTE5	
    CLRF    BYTE6	
    CLRF    ORDEN	
    RETURN 
;*******************************************************************************

  END