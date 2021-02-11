;*******************************************************************************                                                                       *
;    Filename:		    Proyecto_1.0.asm                              *
;    Date:                  08/09/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           reloj con alarma                                                                                                            *
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
    SEGUNDOS	RES	1
    HORAS	RES	1
    HORAS1	RES	1
    HORAS2	RES	1
    DIAS1	RES	1
    DIAS2	RES	1
    MESES1	RES	1
    MESES2	RES	1 
    ESTADO	RES	1
    DISPLAY0    RES	1
    DISPLAY1    RES	1
    DISPLAY2    RES	1
    DISPLAY3    RES	1
    ESPECIAL	RES	1
    PUSH_BOTTON RES	1
    TIMER1	RES	1
    TIMER2	RES	1
    TIMER3	RES	1
    TIMER4	RES	1
    CONTIMERS	RES	1
    CONTIMERM	RES	1
    ALARMA	RES	1
    CONT1	RES	1
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
    RETURN 
    
    INTERRUPCION_TMR1:
    MOVLW   0x0B
    MOVWF   TMR1H
    MOVLW   0xDC
    MOVLW   TMR1L   ;valor para un ainterrupcion cada medio segundo 
    BCF	    PIR1, TMR1IF
    INCF    CONT3   ;contador auxiliar para que se llame la rutina de incremento auotmatico cada 120 interrupciones  
    MOVLW   .120
    SUBWF   CONT3, W
    BTFSS   STATUS, Z
    RETURN 
    
    MOVFW   ESTADO
    SUBLW   .1		    ;declara que cuando se esten realizando los estados 3-7 la rutina atomatica debera parar 
    BTFSC   STATUS, C
    CALL    DISPLAY_UNIDADES
    CLRF    CONT3
    RETURN

INTERRUPCION_TMR2:
    BCF	    PIR1, TMR2IF
    INCF    CONT7
    MOVLW   .20
    SUBWF   CONT7, W
    BTFSS   STATUS, Z
    RETURN 
    CALL    LEDS_INTERMITENTES	    ;interrupcion para encender los leds cada segundo 
    CLRF    CONT7
    MOVLW   .7
    SUBWF   ESTADO,W		    ;indicadr para que al estar en el estado 7, se pueda usar la interrupcion para la funcion del timer 
    BTFSC   STATUS,Z
    CALL    DECREMENTAR_TIMER
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
    BTFSC   PUSH_BOTTON, .0
    GOTO    LOOP1
    BTFSC   PORTB, .7
    GOTO    ESTADOS			;rutina de antirebote para evitar que se quede trabado en el loop 
    BSF	    PUSH_BOTTON, .0		;push encargado de incrementar una variable que indica el estado que se ejecutara 
    GOTO    ESTADOS
LOOP1:
    BTFSC   PUSH_BOTTON, .0
    CALL    ACCIONI
ESTADOS:
    MOVLW   .7
    SUBWF   ESTADO, W
    BTFSC   STATUS, Z			;menu de seleccion de estado que lleva a lo que realiza cada esatado en espec[ifico 
    GOTO    ESTADO8			
    MOVLW   .6
    SUBWF   ESTADO, W
    BTFSC   STATUS, Z
    GOTO    ESTADO7
    MOVLW   .5
    SUBWF   ESTADO, W
    BTFSC   STATUS, Z
    GOTO    ESTADO6
    MOVLW   .4
    SUBWF   ESTADO, W
    BTFSC   STATUS, Z
    GOTO    ESTADO5
    MOVLW   .3
    SUBWF   ESTADO, W
    BTFSC   STATUS, Z
    GOTO    ESTADO4
    MOVLW   .2
    SUBWF   ESTADO, W
    BTFSC   STATUS, Z
    GOTO    ESTADO3
    MOVLW   .1
    SUBWF   ESTADO, W
    BTFSC   STATUS, Z
    GOTO    ESTADO2
    GOTO    ESTADO1 
;*******************************************************************************
; SUB RUTINAS 
;******************************************************************************* 
;*************mux 4:1 para controlar los display con 1 puerto*******************
DISPLAY_VAR:
    BCF	    PORTD, RD0	    
    BCF	    PORTD, RD1
    BCF	    PORTD, RD2
    BCF	    PORTD, RD3
    BTFSC   INDICADOR, 1    
    GOTO    DISPLAY_2Y3
DISPLAY_0Y1:
    BTFSC   INDICADOR, 0
    GOTO    DISPLAY_1
    BSF	    INDICADOR, 1
    DISPLAY_0:
	MOVFW   DISPLAY0
	CALL    TABLA
	MOVWF   PORTC
	BSF	PORTD, RD3
	BSF	INDICADOR, 0
	RETURN
    DISPLAY_1:
	MOVFW   DISPLAY1
	CALL    TABLA
	MOVWF   PORTC
	BSF	PORTD, RD0
	BCF	INDICADOR, 0
	RETURN
DISPLAY_2Y3:
    BTFSC   INDICADOR, 0
    GOTO    DISPLAY_3
    BCF	    INDICADOR, 1
    DISPLAY_2:
	MOVFW   DISPLAY2
	CALL    TABLA
	MOVWF   PORTC
	BSF	PORTD, RD2
	BSF	INDICADOR, 0
	RETURN
    DISPLAY_3:
    	MOVFW   DISPLAY3
	CALL    TABLA
	MOVWF   PORTC
	BSF	PORTD, RD1
	BCF	INDICADOR, 0
	RETURN
;*******************************************************************************
;********************contador automatico para fecha y hora**********************
DISPLAY_UNIDADES:
    INCF    UNIDADES
    MOVLW   .10		    ;incrementa la variable unidades, cuando esta llega a 9
    SUBWF   UNIDADES, W
    BTFSS   STATUS, Z   
    RETURN
				    
    CLRF    UNIDADES	    ;cada 0 unidades, se limpia la variable y se incrementa las decenas 
    INCF    DECENAS
    MOVLW   .6
    SUBWF   DECENAS, W	    ;contador automatico que hace que cada 59 minutos sea una hora 
    BTFSS   STATUS, Z
    RETURN 
    
    CLRF    DECENAS 
    MOVLW   .2		    ;luego de una hora se revisa si la decenas de las horas llego a 2, para que el limite de las unidades sea 3
    SUBWF   HORAS2, W	    ;o para que el limite de aumento sea 9
    BTFSS   STATUS, Z
    GOTO    TFHORAS
    
THORAS:
    INCF    HORAS1		;rutina auxiliar encargada de poner el tope de las unidades de la hora en 3, cuando las decenas de las horas
    MOVLW   .4			;este en 2
    SUBWF   HORAS1, W
    BTFSS   STATUS, Z
    RETURN 
    CLRF    HORAS1
    CLRF    HORAS2
    GOTO    MESES_DIAS 
 TFHORAS:
    INCF    HORAS1  ;rutina auxiliar que pone el tope de las horas en 9, cuando las decenas de las horas 
    MOVLW   .10	    ;no ha llegado a 2 aun. 
    SUBWF   HORAS1, W
    BTFSS   STATUS, Z
    RETURN 
    CLRF    HORAS1
    INCF    HORAS2
    RETURN   

MESES_DIAS:			
    MOVLW   .1		    ;revisa si las deceneas de los meses estan en uno para que el tope sea 2 o antes de 1
    SUBWF   MESES2, W	    ;para que el tope sea 9
    BTFSS   STATUS, Z 
    GOTO    MESES_FINAL
MESES_NORMAL:
    MOVLW   .3
    SUBWF   MESES1, W	    ;rutina auxiliar que pone el tope de las unidades de las horas en 2 cuando 
    BTFSS   STATUS, Z	    ;cuando las decenas de los meses estan en 1
    GOTO    CASO_MESES	    ;subrutina que separa los dias acorde con el mes y aumenta el mes 
    CLRF    MESES2
    MOVLW   .1
    MOVWF   MESES1
    MOVWF   CONT8	    ;contador encargado de incrementarse con el valor del mes, de modo que a traves de el se sepa en que mes se encuentra
    RETURN		    ;para poder fijar los limites de los dias de acuerdo de eso 
MESES_FINAL:
    MOVLW   .10		    ;rutina quq fija el limite de las unidades en 9, cunado las decenas de los meses es menor que 1
    SUBWF   MESES1, W
    BTFSS   STATUS,Z 
    GOTO    CASO_MESES
    CLRF    MESES1
    INCF    MESES2
    RETURN 
    
CASO_MESES:		    ;un contador se incrementa acorde con el mes, fijando la cantidad de dias maxima para cada mes 
    MOVLW   .12
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1
    MOVLW   .11
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3
    MOVLW   .10
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1
    MOVLW   .9
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3
    MOVLW   .8
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1
    MOVLW   .7
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1
    MOVLW   .6
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3
    MOVLW   .5
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1
    MOVLW   .4
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3
    MOVLW   .3
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1
    MOVLW   .2
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO2
    MOVLW   .1
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1
CASO1:			;se revisa las decenas de los dias, si estan en 3 para poner el tope en 1
    MOVLW   .3		;si es menor que 3 se fija el tope de las unidades en 9
    SUBWF   DIAS2, W
    BTFSS   STATUS, Z
    GOTO    DIAMAX1
DIAMIN1:
    INCF    DIAS1
    MOVLW   .2		;subrutina que fija el limite de las unidades de los dias en 1, cuando  
    SUBWF   DIAS1, W	;las decenas de los dias es 3
    BTFSS   STATUS, Z
    RETURN 
    
    MOVLW   .1
    MOVWF   DIAS1
    CLRF    DIAS2
    INCF    MESES1	;luego de llegar al limite de los dias del mes, se incrementa el valor del mes y el contador 
    INCF    CONT8	;asociado a los meses para colocarse en los limites correctos 
    RETURN 
  
DIAMAX1:
    INCF    DIAS1	;subrutina en cargada de fijar el tope de las unidades de los dias en 9
    MOVLW   .10		;cuando las decenas de los dias es menor que 3
    SUBWF   DIAS1,W
    BTFSS   STATUS, Z 
    RETURN 
    CLRF    DIAS1
    INCF    DIAS2
    RETURN 
    
CASO2:			    ;revisa si las decenas de los meses estan en 2, para que el tope de las unidades 
    MOVLW   .2		    ;sea 8 (caso febrero)
    SUBWF   DIAS2, W
    BTFSS   STATUS, Z
    GOTO    DIAMAX2
DIAMIN2:		    ;subrutina encargada de fijar el limite de las unidades de los dias en 8 cuando 
    INCF    DIAS1	    ;las decenas de los dias es menor a 2
    MOVLW   .9
    SUBWF   DIAS1,W
    BTFSS   STATUS, Z
    RETURN 
    
    MOVLW   .1
    MOVWF   DIAS1
    CLRF    DIAS2
    INCF    MESES1	    ;luego de llegar al limite de los dias del mes, se incrementa el valor del mes y el contador 
    INCF    CONT8	    ;asociado a los meses para colocarse en los limites correctos 
    RETURN
    
DIAMAX2:
    INCF    DIAS1	    ;subrutina que fija el limite de las unidades de los dias en 9, cunando las decenas 
    MOVLW   .10		    ;de los dias es menor que 2
    SUBWF   DIAS1, W
    BTFSS   STATUS, Z 
    RETURN 
    
    CLRF    DIAS1
    INCF    DIAS2
    RETURN 

CASO3:			    ;caso para los meses de 3 dias 
    MOVLW   .3
    SUBWF   DIAS2, W
    BTFSS   STATUS, Z 
    GOTO    DIAMAX3
DIAMIN:			;subrutina encargada de fijar el limite de las unidades de los dias en 0 cuando las decenas son 3
    MOVLW   .1
    MOVWF   DIAS1
    CLRF    DIAS2
    INCF    MESES1	;luego de llegar al limite de los dias del mes, se incrementa el valor del mes y el contador 
    INCF    CONT8	;asociado a los meses para colocarse en los limites correctos 
    RETURN 
DIAMAX3:		;subrutina encargada de fijar el limite de las unidades de los dias en 9 cuando las decenas son menores que 3
    INCF    DIAS1
    MOVLW   .10
    SUBWF   DIAS1, W
    BTFSS   STATUS, Z 
    RETURN 
    INCF    DIAS2
    CLRF    DIAS1
    RETURN 


;********CONTADOR NO AUTOMATICO PARA AUMENTAR FECHA Y HORA**********************
;aca se describen funciones como las mencioadas anteriormente, la diferencia es que estan aisladas en grupos de 2 display para controlarlas mecanicamente
DISPLAY_MINUTOS_N:	;rutina para incrementar los dos display encargados de los minutos 	 
    INCF    UNIDADES
    MOVLW   .10		;luego de que las unidades lleguen a 9, se ponen en 0 y se incrementa en uno las decenas 
    SUBWF   UNIDADES, W
    BTFSS   STATUS, Z 
    RETURN
    
    CLRF    UNIDADES
    INCF    DECENAS
    MOVLW   .6		;luego que las decenas lleguen a 5 se pone en cero y se vuelve a comenzar todo en 0
    SUBWF   DECENAS, W
    BTFSC   STATUS, Z
    CLRF    DECENAS 
    RETURN  

DISPLAY_HORAS_N:    ;rutina encargada de incrementar manualmente los display donde aparecen las horsa 
    MOVLW   .2	    ;revisa si las decenas de las horas es igual a dos para ver que tope fijar en las unidades 
    SUBWF   HORAS2, W
    BTFSS   STATUS, Z
    GOTO    TFHORAS_1  

    INCF    HORAS1  ;subrutina encargada de fijar el tope de las unidades de las horas en 3, cuando las decenas son iguales a 2
    MOVLW   .4
    SUBWF   HORAS1, W
    BTFSS   STATUS, Z
    RETURN 
    CLRF    HORAS1
    CLRF    HORAS2
    RETURN
 TFHORAS_1:	    ;subrutina que fija el tope de las unidades en 9 cuando las decenas son menores a 2
    INCF    HORAS1
    MOVLW   .10
    SUBWF   HORAS1, W
    BTFSS   STATUS, Z
    RETURN 
    CLRF    HORAS1
    INCF    HORAS2
    RETURN  

CASO_DIAS_N:		;con base en el valor del contador 8, determina si el tope de los dias es 30, 31 o 28 acorde con el mes 
    MOVLW   .12
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_1
    MOVLW   .11
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3_1
    MOVLW   .10
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_1
    MOVLW   .9
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3_1
    MOVLW   .8
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_1
    MOVLW   .7
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_1
    MOVLW   .6
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3_1
    MOVLW   .5
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_1
    MOVLW   .4
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3_1
    MOVLW   .3
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_1
    MOVLW   .2
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO2_1
    MOVLW   .1
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_1
CASO1_1:		;revisa si las decenas de los dias es igual o menor a 3para asignar un tope a las unidades 
    MOVLW   .3
    SUBWF   DIAS2, W
    BTFSS   STATUS, Z
    GOTO    DIAMAX1_1
DIAMIN1_1:	    ;si las decenas de los dias es igual a 3, asigna un tope de las unidades en 1
    INCF    DIAS1
    MOVLW   .2
    SUBWF   DIAS1, W
    BTFSS   STATUS, Z
    RETURN 
    
    MOVLW   .1
    MOVWF   DIAS1   
    CLRF    DIAS2
    RETURN 
  
DIAMAX1_1:		;revisa si las decenas son menores que 3 para fijar el tope de la sunidades en 9
    INCF    DIAS1
    MOVLW   .10
    SUBWF   DIAS1,W
    BTFSS   STATUS, Z 
    RETURN 
    CLRF    DIAS1
    INCF    DIAS2
    RETURN
    
FINAL_1:
    BSF	    CONT6, 1
    INCF    ESPECIAL
    RETURN      
    
CASO2_1:		;revisa si las decenas de los dias para asignarle un tope a las unidades acorde a ese valor 
    MOVLW   .2
    SUBWF   DIAS2, W
    BTFSS   STATUS, Z
    GOTO    DIAMAX2_1
DIAMIN2_1:		;si el valor de las decenas de los dias es igual a 2, pone el tope de las unidades en 8
    INCF    DIAS1
    MOVLW   .9
    SUBWF   DIAS1,W
    BTFSS   STATUS, Z
    RETURN 
    
    MOVLW   .1
    MOVWF   DIAS1
    CLRF    DIAS2
    RETURN
    
DIAMAX2_1:	    ;si el valor de las decenas es menor que 2, fija el tope de las unidades en 9
    INCF    DIAS1
    MOVLW   .10
    SUBWF   DIAS1, W
    BTFSS   STATUS, Z 
    RETURN 
    
    CLRF    DIAS1
    INCF    DIAS2
    RETURN 

CASO3_1:	    ;;revisa si las decenas de los dias para asignarle un tope a las unidades acorde a ese valor 
    MOVLW   .3
    SUBWF   DIAS2, W
    BTFSS   STATUS, Z 
    GOTO    DIAMAX3_1
DIAMIN3_1:	    ;si las decenas de los dias es igual a 3, fija el tope de las unidades en 0
    MOVLW   .1
    MOVWF   DIAS1
    CLRF    DIAS2 
    RETURN 
DIAMAX3_1:	    ;si las decenas de los dias es menor que tres, fija el tope de las unidades en 9
    INCF    DIAS1
    MOVLW   .10
    SUBWF   DIAS1, W
    BTFSS   STATUS, Z 
    RETURN 
    INCF    DIAS2
    CLRF    DIAS1
    RETURN 
    

CASO_MESES_N:	    ;revisa el valor de las decenas de los meses para fijar el limite de las undiades 
    MOVLW   .1
    SUBWF   MESES2, W
    BTFSS   STATUS, Z 
    GOTO    MESES_FINAL_1
MESES_NORMAL_1:	    ;si el valor de las decenas es igual a 1, fija el tope de los meses en 2
    INCF    CONT8
    INCF    MESES1
    MOVLW   .3
    SUBWF   MESES1, W
    BTFSS   STATUS, Z 
    RETURN
    CLRF    MESES2
    MOVLW   .1
    MOVWF   MESES1
    MOVLW   .1
    MOVWF   CONT8
    RETURN 
MESES_FINAL_1:	;si el valor de las decenas es menor que 1, fija el tope de las unidades en 9
    INCF    CONT8
    INCF    MESES1
    MOVLW   .10
    SUBWF   MESES1, W
    BTFSS   STATUS,Z 
    RETURN
    CLRF    MESES1
    INCF    MESES2
    RETURN
    
    
;*******************************************************************************   
;CONTADOR NO AUTOMATICO PARA DECREMENTAR FECHA Y HORA **************************
DECREMENTAR_MINUTOS:		;aca se detallan todas las funciones de dectementar la hora y fecha 
    MOVLW   .0			;se fijan los limites maximos y se decrementa hasta que en valor minimo, se vuelven a ingresar dichos limites 
    SUBWF   UNIDADES, W
    BTFSC   STATUS, Z
    GOTO    $+3
    DECF    UNIDADES
    RETURN 
    MOVLW   .9
    MOVWF   UNIDADES
    MOVLW   .0
    SUBWF   DECENAS, W
    BTFSC   STATUS, Z
    GOTO    $+3
    DECF    DECENAS
    RETURN
    MOVLW   .5
    MOVWF   DECENAS
    RETURN  
DECREMENTAR_HORAS:
    MOVLW   .0		    ;si las decenas de las horas es 0 al inicio, fija los limites en 23
    SUBWF   HORAS2, W
    BTFSC   STATUS, Z
    GOTO    $+18  
    MOVLW   .0		    ;parte del codigo encargada de decrementar el valor de la hora cuando las decenas son menores a 2
    SUBWF   HORAS1,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECF    HORAS1
    RETURN 
    MOVLW   .9
    MOVWF   HORAS1
    MOVLW   .0
    SUBWF   HORAS2,W
    BTFSC   STATUS, Z 
    GOTO    $+4
    DECF    HORAS2
    DECF    CONT9
    RETURN
    MOVLW   .1
    MOVWF   HORAS2
    RETURN 
    MOVLW   .1		;revisa que el con9 ya haya sido uno, indicando que ya paso por esta parte, 
    SUBWF   CONT9, W	;para que cuando las decenas vuelvan a ser 0 cuando solo hayan unidades, no vuelva a fijar los limites en 23
    BTFSC   STATUS, Z 
    GOTO    $-20
    MOVLW   .0
    SUBWF   HORAS1,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECF    HORAS1
    RETURN 
    MOVLW   .3
    MOVWF   HORAS1
    MOVLW   .0
    SUBWF   HORAS2,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECF    HORAS2
    RETURN
    MOVLW   .2
    MOVWF   HORAS2
    INCF    CONT9
    RETURN

DECREMENTAR_MESES:  ;rutina que decrementa, revisa si el contador que ubica los topes de los dias es 1
    MOVLW   .1	    ;para que en vez de seguirse decrementando, se le asigne el valor de 12 
    SUBWF   CONT8, W
    BTFSC   STATUS, Z 
    GOTO    CONTADORMESES		
PT1:
    MOVLW   .0	    ;revisa de las decenas de los meses es igual a 0 al inicio para que al decrementar se coloce el nummero m[aximo 
    SUBWF   MESES2, W
    BTFSC   STATUS, Z
    GOTO    $+19 
    
    MOVLW   .0		;parte de la subrutina encargada de decremetnar el valor de las unidades y decenas cuando las decenas son menors que 12
    SUBWF   MESES1, W
    BTFSC   STATUS, Z 
    GOTO    $+4
    DECF    CONT8
    DECF    MESES1
    RETURN 
    MOVLW   .9
    MOVWF   MESES1
    MOVLW   .0
    SUBWF   MESES2, W
    BTFSC   STATUS, Z 
    GOTO    $+4
    DECF    MESES2
    DECF    CONT10
    RETURN
    MOVLW   .0
    MOVWF   MESES2
    RETURN 
    
    MOVLW   .1	    ;revisa el valor del contador para que cuando las decenas vuelvan a ser 0 siga decrementando normal y no vuelva a colocar los valores maximos 
    SUBWF   CONT10, W
    BTFSC   STATUS, Z 
    GOTO    $-21
    
    MOVLW   .1
    SUBWF   MESES1, W
    BTFSC   STATUS, Z
    GOTO    $+4
    DECF    CONT8
    DECFSZ  MESES1
    RETURN 
    MOVLW   .2
    MOVWF   MESES1
    MOVLW   .0
    SUBWF   MESES2, W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECF    MESES2
    RETURN
    MOVLW   .1
    MOVWF   MESES2
    INCF    CONT10
    RETURN
CONTADORMESES:	    ;asigna el valor maximo al cont8 cuando este llega al valor minimo
    MOVLW   .12
    MOVWF   CONT8
    GOTO    PT1   
DECREMENTAR_DIAS:   ;dirige a la subrutina de los limites de los dias acorde con el valor que se incrementa con el valor del mes en que se encuentra 
    MOVLW   .11
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_2
    MOVLW   .10
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3_2
    MOVLW   .9
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3_2
    MOVLW   .8
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_2
    MOVLW   .7
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_2
    MOVLW   .6
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3_2
    MOVLW   .5
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_2
    MOVLW   .4
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO3_2
    MOVLW   .3
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_2
    MOVLW   .2
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO2_2
    MOVLW   .1
    SUBWF   CONT8, W
    BTFSC   STATUS, Z
    GOTO    CASO1_2
CASO1_2:	    ;revisa si el valor de las decenas de los dias se encuentra en 0 al inicio para fijar el valor maximo 
    MOVLW   .0
    SUBWF   DIAS2, W
    BTFSC   STATUS, Z
    GOTO    $+18  
    MOVLW   .0	    ;parte del codigo que se encarga de decrementar el valor del las unidades y decenas fijando los topes en para que sean 31 dias el maximo 
    SUBWF   DIAS1,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECFSZ  DIAS1   ;se utilizo esta instruccion para que nunca se decrementara hasta que llegara a 0, de modo que el valor minimo fuera 1
    RETURN 
    MOVLW   .9
    MOVWF   DIAS1
    MOVLW   .0
    SUBWF   DIAS2,W
    BTFSC   STATUS, Z 
    GOTO    $+4
    DECF    DIAS2
    DECF    CONT11
    RETURN
    MOVLW   .2
    MOVWF   DIAS2
    RETURN 
    MOVLW   .1		;revisa si se incremento el contador para evitar que los valores maximos se agreguen dos veces y ya no se decremente correctamente 
    SUBWF   CONT11, W
    BTFSC   STATUS, Z 
    GOTO    $-20
    MOVLW   .0
    SUBWF   DIAS1,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECFSZ  DIAS1
    RETURN 
    MOVLW   .1
    MOVWF   DIAS1
    MOVLW   .0
    SUBWF   DIAS2,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECF    DIAS2
    RETURN
    MOVLW   .3
    MOVWF   DIAS2
    INCF    CONT11
    RETURN
CASO2_2:	    ;revisa si el valor de las decenas se encuentra en 0 para dirigirse a la parte del codigo que le asigna el valor maximoa ambas bariables 
    MOVLW   .0
    SUBWF   DIAS2, W
    BTFSC   STATUS, Z
    GOTO    $+18  
    MOVLW   .0	    ;parte del codigo que se encarga de decrementar el valor del las unidades y decenas fijando los topes en para que sean 28 dias el maximo 
    SUBWF   DIAS1,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECFSZ    DIAS1 ;se utilizo esta instruccion para que nunca se decrementara hasta que llegara a 0, de modo que el valor minimo fuera 1
    RETURN 
    MOVLW   .9
    MOVWF   DIAS1
    MOVLW   .0
    SUBWF   DIAS2,W
    BTFSC   STATUS, Z 
    GOTO    $+4
    DECF    DIAS2
    DECF    CONT12
    RETURN
    MOVLW   .1
    MOVWF   DIAS2
    RETURN 
    MOVLW   .1	
    SUBWF   CONT12, W
    BTFSC   STATUS, Z 
    GOTO    $-20
    MOVLW   .0
    SUBWF   DIAS1,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECFSZ    DIAS1
    RETURN 
    MOVLW   .8
    MOVWF   DIAS1
    MOVLW   .0
    SUBWF   DIAS2,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECF    DIAS2
    RETURN
    MOVLW   .2
    MOVWF   DIAS2
    INCF    CONT12
    RETURN
CASO3_2:
    MOVLW   .0
    SUBWF   DIAS2, W
    BTFSC   STATUS, Z
    GOTO    $+18  
    MOVLW   .0
    SUBWF   DIAS1,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECFSZ    DIAS1
    RETURN 
    MOVLW   .9
    MOVWF   DIAS1
    MOVLW   .0
    SUBWF   DIAS2,W
    BTFSC   STATUS, Z 
    GOTO    $+4
    DECF    DIAS2
    DECF    CONT13
    RETURN
    MOVLW   .2
    MOVWF   DIAS2
    RETURN 
    MOVLW   .1	;revisa el valor del contador para que cuando las decenas vuelvan a ser 0 siga decrementando normal y no vuelva a colocar los valores maximos 
    SUBWF   CONT13, W
    BTFSC   STATUS, Z 
    GOTO    $-20
    MOVLW   .0
    SUBWF   DIAS1,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECFSZ    DIAS1
    RETURN 
    MOVLW   .0
    MOVWF   DIAS1
    MOVLW   .0
    SUBWF   DIAS2,W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECF    DIAS2
    RETURN
    MOVLW   .3
    MOVWF   DIAS2
    INCF    CONT13
    RETURN
;************************RUTINAS PARA TIMER************************************
CONFIGURACION_TIMER_1:	    ;aca se marcaron 2 rutinas automaticas con el fin de aumentar el contador para la funcion del timer 
    MOVLW   .60	;incrementa los display de los de los segundos del timer, de modo que llegue hasta 59
    MOVWF   ALARMA;fija el valor inicial de la variable alarma, de modo que siempre que se incremente se le asignara para que suene durante 1 minuto 
    INCF    TIMER1
    MOVLW   .10
    SUBWF   TIMER1, W
    BTFSS   STATUS, Z 
    RETURN
    CLRF    TIMER1
    INCF    TIMER2
    MOVLW   .6
    SUBWF   TIMER2, W
    BTFSS   STATUS, Z
    RETURN 
    CLRF    TIMER2
    MOVLW   .1
    MOVWF   TIMER1
    RETURN 
CONFIGURACION_TIMER_2:;rutnian encargada de incrementar los minutos del timer con tope en 9
    MOVLW   .60		
    MOVWF   ALARMA;fija el valor inicial de la variable alarma, de modo que siempre que se incremente se le asignara para que suene durante 1 minuto 
    INCF    TIMER3
    MOVLW   .10
    SUBWF   TIMER3, W
    BTFSS   STATUS, Z 
    RETURN
    CLRF    TIMER3
    INCF    TIMER4
    MOVLW   .10
    SUBWF   TIMER4, W
    BTFSS   STATUS, Z
    RETURN
    CLRF    TIMER4
    RETURN 
DECREMENTAR_TIMER:  ;esta funcion se encarga de decrementar el timer y asignar una alarma al momento en el que este llegue a ser 0
    MOVFW   TIMER1
    ADDWF   TIMER2, W
    MOVWF   CONTIMERS
    MOVFW   TIMER3
    ADDWF   TIMER4, W
    MOVWF   CONTIMERM
    MOVFW   CONTIMERS
    ADDWF   CONTIMERM, W
    BTFSC   STATUS, Z	;se agura que todos los display esten en 0 para saber que ese es el minimo y dirigirse a la rutina en la que se llama a la alarma 
    GOTO    ALARMAT
    MOVLW   .0	    ;aca se decrementa el valor asignado en el timer, de modo que cada 59 segundos se decrementa 1 en los minutos hasta que todos llegan a ser 0
    SUBWF   TIMER1, W	
    BTFSC   STATUS, Z
    GOTO    $+3
    DECF    TIMER1
    RETURN 
    MOVLW   .9
    MOVWF   TIMER1
    MOVLW   .0
    SUBWF   TIMER2, W
    BTFSC   STATUS, Z
    GOTO    $+3
    DECF    TIMER2
    RETURN
    MOVLW   .5
    MOVWF   TIMER2
    MOVLW   .0
    SUBWF   TIMER3, W
    BTFSC   STATUS, Z
    GOTO    $+3
    DECF    TIMER3
    RETURN
    MOVLW   .9
    MOVWF   TIMER3
    MOVLW   .0
    SUBWF   TIMER4, W
    BTFSC   STATUS, Z
    GOTO    $+3
    DECF    TIMER4
    RETURN
    MOVLW   .9
    MOVWF   TIMER4
    RETURN 
ALARMAT:	    ;debido a que el valor de la alarma es 60 y esta rutina se llama cada segundo, en esta parte se ejecuta el codigo de los display cada 60 seg y cuando este llega a 0 se deja de ejecutar 
    MOVLW   .0
    SUBWF   ALARMA, W
    BTFSC   STATUS, Z 
    GOTO    $+3
    DECF    ALARMA
    CALL    LEDS_ALARMA 
    RETURN 

;*******************************ALARMA******************************************
LEDS_ALARMA:			;rutina que enciende y apaga los leds cada segundo 
    BTFSC   CONT1, 0	;enciende y apaga los leds acorde con el valor de bit 0 del cont1
    GOTO    LED_0_A	;rutina que se utiliza para la alarma 
LED_1_A:
    BSF PORTE, RE2
    BSF	CONT1, 0
    RETURN 
LED_0_A:
    BCF PORTE, RE2
    BCF	CONT1, 0
    RETURN 
;************************rutina para leds intermitentes*************************
LEDS_INTERMITENTES:		    ;rutina para el indicador led de segundos 
    BTFSC   INDICADOR2, 0   ;enciende y apaga los leds acorde con el valor de bit 0 del indicador2
    GOTO    LED_0
LED_1:
    BSF PORTD, RD7
    BSF	INDICADOR2, 0
    RETURN 
LED_0:
    BCF PORTD, RD7
    BCF	INDICADOR2, 0
    RETURN  
;*******************************************************************************
;****************************INCREMENTAR EL PUSH DE OPCIONES********************
;rutinas auxiliares de los antirebotes de los push de cada estado 
;cada una de ellas esta asociada a una funcino en especifico 
ACCIONI:		    ;incrementa la variable estado y hace que al llegar al estado maximo, el siguiente estado sea 0
    BTFSS   PORTB, .7
    RETURN
    BCF	    PUSH_BOTTON, .0
    MOVLW   .7
    SUBWF   ESTADO, W
    BTFSS   STATUS, Z
    GOTO    NOLIMPIAR
LIMPIAR:
    CLRF    ESTADO
    RETURN 
NOLIMPIAR:
    INCF    ESTADO 
    RETURN 
    
ACCIOND:    ; incrementa los minutos manualmente 
    BTFSS   PORTB, .6
    RETURN
    BCF	    PUSH_BOTTON, .1
    CALL    DISPLAY_MINUTOS_N
    RETURN 
    
ACCIONU:    ;incrementa las horas manualmente 
    BTFSS   PORTB, .2
    RETURN
    BCF	    PUSH_BOTTON, .2
    CALL    DISPLAY_HORAS_N
    RETURN 
    
ACCIONDI:   ;incrementa los dias manualmente 
    BTFSS   PORTB, .6
    RETURN
    BCF	    PUSH_BOTTON, .3
    CALL    CASO_DIAS_N
    RETURN
    
ACCIONM:    ;incrementa los meses manualmente 
    BTFSS   PORTB, .2
    RETURN
    BCF	    PUSH_BOTTON, .4
    CALL    CASO_MESES_N
    RETURN
ACCIONDM:   ;decrementa los minutos manualmente 
    BTFSS   PORTB, .6
    RETURN
    BCF	    PUSH_BOTTON, .3
    CALL    DECREMENTAR_MINUTOS
    RETURN
ACCIONDH:   ;decrementa las horas manualmente 
    BTFSS   PORTB, .2
    RETURN
    BCF	    PUSH_BOTTON, .1
    CALL    DECREMENTAR_HORAS
    RETURN
ACCIONDMS:  ;decremeta los meses manualmente 
    BTFSS   PORTB, .6
    RETURN
    BCF	    PUSH_BOTTON, .3
    CALL    DECREMENTAR_MESES
    RETURN
ACCIONDD:   ;decrementa los dias manualmente 
    BTFSS   PORTB, .2
    RETURN
    BCF	    PUSH_BOTTON, .1
    CALL    DECREMENTAR_DIAS 
    RETURN
ACCIONT1:   ;incrementa los segundos del timer 
    BTFSS   PORTB, .6
    RETURN
    BCF	    PUSH_BOTTON, .1
    CALL    CONFIGURACION_TIMER_1 
    RETURN
ACCIONT2:   ;incrementa los minutos del timer 
    BTFSS   PORTB, .2
    RETURN
    BCF	    PUSH_BOTTON, .2
    CALL    CONFIGURACION_TIMER_2 
    RETURN
ACCIONALARMA:	;apaga manualmente la alarma 
    BTFSS   PORTB, .6
    RETURN
    BCF	    PUSH_BOTTON, .1 ;pone en 0 la variable de la alarma de modo que al presionar el push se apague automaticamdente 
    CLRF    ALARMA
    RETURN
;***************************RUTINAS DE CADA ESTADO******************************
ESTADO1:	;en los estados 1 y 2 se muestran las variables que se incrementan automaricas para la fecha y hora 
    MOVLW   .1
    MOVWF   PORTA
    MOVFW   DECENAS
    MOVWF   DISPLAY0
    MOVFW   UNIDADES
    MOVWF   DISPLAY1
    MOVFW   HORAS1
    MOVWF   DISPLAY2
    MOVFW   HORAS2
    MOVWF   DISPLAY3
    GOTO    LOOP 
ESTADO2:
    MOVLW   .2
    MOVWF   PORTA
    MOVFW   DIAS2
    MOVWF   DISPLAY0
    MOVFW   DIAS1
    MOVWF   DISPLAY1
    MOVFW   MESES1
    MOVWF   DISPLAY2
    MOVFW   MESES2
    MOVWF   DISPLAY3
    GOTO    LOOP 
ESTADO3:    ;en el estado 3 y 4 se muestran las variables no automaticas que incrementan la fecha y la hora 
    MOVLW   .3
    MOVWF   PORTA   ;se mueven las variables que se incrementan manualmente a las que se muestran en los display 
    MOVFW   DECENAS
    MOVWF   DISPLAY0
    MOVFW   UNIDADES
    MOVWF   DISPLAY1
    MOVFW   HORAS1
    MOVWF   DISPLAY2
    MOVFW   HORAS2
    MOVWF   DISPLAY3
    
    BTFSC   PUSH_BOTTON, .1 
    GOTO    ESTADO3_1
    BTFSC   PORTB, .6
    GOTO    PUSH_2
    BSF	    PUSH_BOTTON, .1
    GOTO    PUSH_2	;rutina de antirebotes para los bottones 	
ESTADO3_1:
    BTFSC   PUSH_BOTTON, .1 
    CALL    ACCIOND ;rutina auxiliar de los antirebotes 
    GOTO    PUSH_2
;si no sucede nada o luego de que suceda se va a revisr lo que sucede con el otro push 
PUSH_2:
    BTFSC   PUSH_BOTTON, .2
    GOTO    ESTADO3_2
    BTFSC   PORTB, .2
    GOTO    LOOP
    BSF	    PUSH_BOTTON, .2
    GOTO    LOOP ;rutina de antirebotes para los bottones 
ESTADO3_2:
    BTFSC   PUSH_BOTTON, .2
    CALL    ACCIONU ;rutina auxiliar de los antirebotes 
    GOTO    LOOP    
;suceda o no suceda nada con el push 2 siempre regresa al loop para evitar que se quede trabado    
ESTADO4:
    MOVLW   .4
    MOVWF   PORTA
    MOVFW   DIAS2
    MOVWF   DISPLAY0
    MOVFW   DIAS1
    MOVWF   DISPLAY1
    MOVFW   MESES1
    MOVWF   DISPLAY2
    MOVFW   MESES2
    MOVWF   DISPLAY3 ;se mueven las variables que se incrementan manualmente a las que se muestran en los display 
    
    BTFSC   PUSH_BOTTON, .3
    GOTO    ESTADO4_1
    BTFSC   PORTB, .6
    GOTO    PUSH_2_1
    BSF	    PUSH_BOTTON, .3
    GOTO    PUSH_2_1 ;rutina de antirebotes para los bottones
ESTADO4_1:
    BTFSC   PUSH_BOTTON, .3
    CALL    ACCIONDI ;rutina auxiliar de los antirebotes 
    GOTO    PUSH_2_1
 ;si no sucede nada o luego de que suceda se va a revisr lo que sucede con el otro push    
PUSH_2_1:
    BTFSC   PUSH_BOTTON, .4
    GOTO    ESTADO4_2
    BTFSC   PORTB, .2
    GOTO    LOOP
    BSF	    PUSH_BOTTON, .4
    GOTO    LOOP ;rutina de antirebotes para los bottones
ESTADO4_2:
    BTFSC   PUSH_BOTTON, .4
    CALL    ACCIONM ;rutina auxiliar de los antirebotes 
    GOTO    LOOP 
;suceda o no suceda nada con el push 2 siempre regresa al loop para evitar que se quede trabado 
ESTADO5:    ;en el estado 5 y 6 se muestran las variables no automaicas que decrementan la fecha y la hora 
    MOVLW   .5
    MOVWF   PORTA
    MOVFW   DECENAS
    MOVWF   DISPLAY0
    MOVFW   UNIDADES
    MOVWF   DISPLAY1
    MOVFW   HORAS1
    MOVWF   DISPLAY2
    MOVFW   HORAS2 
    MOVWF   DISPLAY3 ;se mueven las variables que se decrementan manualmente a las que se muestran en los display 
    
    BTFSC   PUSH_BOTTON, .1
    GOTO    ESTADO5_1
    BTFSC   PORTB, .2
    GOTO    PUSH_2_2
    BSF	    PUSH_BOTTON, .1
    GOTO    PUSH_2_2  ;rutina de antirebotes para los bottones
ESTADO5_1:
    BTFSC   PUSH_BOTTON, .1
    CALL    ACCIONDH ;rutina auxiliar de los antirebotes 
    GOTO    PUSH_2_2 
 ;si no sucede nada o luego de que suceda se va a revisr lo que sucede con el otro push    
PUSH_2_2:   
    BTFSC   PUSH_BOTTON, .3
    GOTO    ESTADO5_2
    BTFSC   PORTB, .6
    GOTO    LOOP
    BSF	    PUSH_BOTTON, .3
    GOTO    LOOP ;rutina de antirebotes para los bottones
ESTADO5_2:
    BTFSC   PUSH_BOTTON, .3
    CALL    ACCIONDM ;rutina auxiliar de los antirebotes 
    GOTO    LOOP    
 ;suceda o no suceda nada con el push 2 siempre regresa al loop para evitar que se quede trabado 
ESTADO6:
    MOVLW   .6
    MOVWF   PORTA
    MOVFW   DIAS2
    MOVWF   DISPLAY0
    MOVFW   DIAS1
    MOVWF   DISPLAY1
    MOVFW   MESES1
    MOVWF   DISPLAY2
    MOVFW   MESES2
    MOVWF   DISPLAY3 ;se mueven las variables que se decrementan manualmente a las que se muestran en los display 
    
    BTFSC   PUSH_BOTTON, .1
    GOTO    ESTADO6_1
    BTFSC   PORTB, .2
    GOTO    PUSH_3_1
    BSF	    PUSH_BOTTON, .1
    GOTO    PUSH_3_1  ;rutina de antirebotes para los bottones
ESTADO6_1:
    BTFSC   PUSH_BOTTON, .1
    CALL    ACCIONDD ;rutina auxiliar de los antirebotes 
    GOTO    PUSH_3_1
 ;si no sucede nada o luego de que suceda se va a revisr lo que sucede con el otro push    
PUSH_3_1:   
    BTFSC   PUSH_BOTTON, .3
    GOTO    ESTADO6_2
    BTFSC   PORTB, .6
    GOTO    LOOP
    BSF	    PUSH_BOTTON, .3
    GOTO    LOOP   ;rutina de antirebotes para los bottones
ESTADO6_2:
    BTFSC   PUSH_BOTTON, .3
    CALL    ACCIONDMS ;rutina auxiliar de los antirebotes 
    GOTO    LOOP
 ;suceda o no suceda nada con el push 2 siempre regresa al loop para evitar que se quede trabado  
ESTADO7:    ;en el estado 7 esta la funcino de incrementar los numeros del timer, el estado 8 decrementa automaticamente y tiene la opcion de apagar la alarma 
    MOVLW   .7
    MOVWF   PORTA
    MOVFW   TIMER2
    MOVWF   DISPLAY0
    MOVFW   TIMER1
    MOVWF   DISPLAY1
    MOVFW   TIMER3
    MOVWF   DISPLAY2
    MOVFW   TIMER4
    MOVWF   DISPLAY3 ;se mueven las variables que se incrementan manualmente a las que se muestran en los display 
    MOVLW   .0
    SUBWF   ALARMA, W	;se asegura que el valor minimo del timer luego de llamar a la alarma y apagarse sea 1 segundo 
    BTFSS   STATUS, Z 
    GOTO    $+3
    MOVLW   .1	
    MOVWF   TIMER1
    BTFSC   PUSH_BOTTON, .2
    GOTO    ESTADO7_2
    BTFSC   PORTB, .2
    GOTO    PUSH_3_2
    BSF	    PUSH_BOTTON, .2
    GOTO    PUSH_3_2 ;rutina de antirebotes para los bottones
ESTADO7_2:
    BTFSC   PUSH_BOTTON, .2
    CALL    ACCIONT2 ;rutina auxiliar de los antirebotes 
    GOTO    PUSH_3_2 
  ;si no sucede nada o luego de que suceda se va a revisr lo que sucede con el otro push    
PUSH_3_2:
    BTFSC   PUSH_BOTTON, .1
    GOTO    ESTADO7_1
    BTFSC   PORTB, .6
    GOTO    LOOP
    BSF	    PUSH_BOTTON, .1
    GOTO    LOOP ;rutina de antirebotes para los bottones
ESTADO7_1:
    BTFSC   PUSH_BOTTON, .1
    CALL    ACCIONT1 ;rutina auxiliar de los antirebotes 
    GOTO    LOOP 
 ;suceda o no suceda nada con el push 2 siempre regresa al loop para evitar que se quede trabado    
ESTADO8:    ;estado auxiliar del estado 7 encargado de decrementar los valores del timer y llamar la alarma asi como de poder pararla con el push 
    MOVLW   .7
    MOVWF   PORTA
    MOVFW   TIMER2
    MOVWF   DISPLAY0
    MOVFW   TIMER1
    MOVWF   DISPLAY1
    MOVFW   TIMER3
    MOVWF   DISPLAY2
    MOVFW   TIMER4
    MOVWF   DISPLAY3	;mueve las variables que se decrementan automaticamente a las que se muestran en el display
    
    BTFSC   PUSH_BOTTON, .1
    GOTO    ESTADO8_1
    BTFSC   PORTB, .6
    GOTO    LOOP
    BSF	    PUSH_BOTTON, .1
    GOTO    LOOP ;rutina de antirebotes para los bottones
ESTADO8_1:
    BTFSC   PUSH_BOTTON, .1
    CALL    ACCIONALARMA ;rutina auxiliar de los antirebotes 
    GOTO    LOOP 
 ;suceda o no suceda nada con el push 2 siempre regresa al loop para evitar que se quede trabado     
;configuracion******************************************************************
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
    CLRF    ANSELH  ; BORRA EL CONTROL DE ENTRADAS ANALÓGICAS
    
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA  
    CLRF    TRISB
    COMF    TRISB
    MOVLW   .255
    MOVWF   WPUB 
    CLRWDT
    CLRF    TRISC
    MOVLW   b'00000000'
    MOVWF   TRISC    
    CLRF    TRISD
    MOVLW   B'00000000'
    MOVWF   TRISD
    CLRF    TRISE
    
    CONFIGURACION_TIMER0:
    CLRWDT		; CONFIGURACIÓN PARA EL FUNCIONAMIENTO DEL TIMER0
    MOVLW   b'01010111'	; PARA LA CONFIGURACIÓN DEL TIMER0, EL BIT 7 NO IMPORTA. SIN EMBARGO, SE COLOCA EN 0 PARA NO ARRUINAR LA INSTRUCCIÓN DE LA LÍNEA 132 -PARA EL FUNCIONAMIENTO DE PULL UPS-
    MOVWF   OPTION_REG
       
    CONFIGURACION_INTERRUPCION:
    BANKSEL TRISA
    BSF	    PIE1, TMR1IE; HABILITA INTERRUPCION DEL TIMER1
    BSF	    PIE1, TMR2IE; HABILITA COMPARACION ENTRE PR2 Y TIMER2
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    
    MOVLW   .196	; PARA TMR2 FUNCIONAR CON 50ms
    MOVWF   PR2
    
    BANKSEL PORTA
    BSF	    INTCON, GIE ; HABILITA LAS INTERRUPCIONES
    BCF	    INTCON, T0IF; PARA ASEGURARSE DE QUE NO TENGA OVERFLOW AL INICIO
    BCF	    PIR1, TMR1IF
    BCF	    PIR1, TMR2IF

    BANKSEL PORTA  ; REGRESO AL BANCO 0
    CLRF    PORTC
    CLRF    PORTA
    CLRF    PORTB 
    CLRF    PORTD
    CLRF    PORTE
  ;****************SE DECLARAN LOS VALORES INICIALES DE LAS VARIABLES *********  
    CLRF    SEGUNDOS 
    CLRF    DECENAS 
    CLRF    UNIDADES 
    CLRF    CONT3
    CLRF    CONT4
    CLRF    CONT6
    CLRF    CONT7
    CLRF    CONT8
    MOVLW   .1
    MOVWF   CONT8
    CLRF    CONT9
    CLRF    CONT10
    CLRF    CONT11
    CLRF    CONT12
    CLRF    CONT13
    CLRF    NIBBLE_H
    CLRF    NIBBLE_L
    CLRF    INDICADOR 
    CLRF    HORAS1
    CLRF    HORAS2
    CLRF    DIAS2
    CLRF    DIAS1 
    MOVLW   .1
    MOVWF   DIAS1
    CLRF    MESES2
    CLRF    MESES1 
    MOVLW   .1
    MOVWF   MESES1 
    CLRF    ESPECIAL 
    CLRF    ESTADO 
    CLRF    DISPLAY0
    CLRF    DISPLAY1
    CLRF    DISPLAY2
    CLRF    DISPLAY3
    CLRF    PUSH_BOTTON
    CLRF    CONTIMERS
    CLRF    CONTIMERM
    CLRF    TIMER1
    MOVLW   .1
    MOVWF   TIMER1
    CLRF    TIMER2
    CLRF    TIMER3
    CLRF    TIMER4
    CLRF    ALARMA 
    MOVLW   .60
    MOVWF   ALARMA 
    CLRF    CONT1
    RETURN 
;*******************************************************************************

  END