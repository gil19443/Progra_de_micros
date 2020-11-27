;*******************************************************************************                                                                       *
;    Filename:		    Proyecto_3.0.asm                              *
;    Date:                  08/09/2020                                         *
;    File Version:          v.1                                                *
;    Author:                Carlos Gil                      *
;    Company:               UVG                                                *
;    Description:           carro seguidor de luz                                                                                                            *
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
    SERVO	RES	1
    CAMBIO	RES	1
    PARTEALTA	RES	1
    PARTEBAJA	RES	1
    ACCION	RES	1
    CHECK	RES	1
    LUCES	RES	1
    PUSH_BUTTON	RES	1
    ENTER	RES	1
    DECENAS	RES	1
    MINUTOS	RES	1
    MINUTOS2	RES	1   
    EEPROM	RES	1
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
    BTFSC   PIR1, RCIF
    CALL    INTERRUPCION_RECIBIR
    BTFSC   PIR1, TMR2IF
    CALL    INTERRUPCION_TMR2
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS 
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE
;TOGGLE DE TIMER0 PARA RUTINA MANUAL DE SERVO, SE CAMBIAN LAS  VARIABLES QUE SE GUARDAN EN EL TIMER Y ASI SE GENERAN LOS ANCHOS DE PULSO DESEADOS
INTERRUPCION_TMRO:
    BTFSC  SERVO, 0
    GOTO   APAGAR_19.3MS
ENCENDER_0.7MS:
    MOVFW   PARTEALTA    
    MOVWF   TMR0
    BSF	    PORTA, 1
    BSF	    SERVO, 0
    BCF	    INTCON, T0IF 
    RETURN 
    
APAGAR_19.3MS:
    MOVFW   PARTEBAJA    
    MOVWF   TMR0
    BCF	    PORTA, 1
    BCF	    SERVO, 0
    BCF	    INTCON, T0IF 
    RETURN 
;TOGGLE PARA RECIBIR DATOS, SE RECIBE UN NUMERO ENTRE 0-9 Y UN ENTER PARA VERIFICACION    
INTERRUPCION_RECIBIR:
    BTFSC   CHECK, 4
    GOTO    RECIBIR_ENTER
RECIBIR_DATO:
    MOVFW   RCREG
    MOVWF   ACCION
    BSF	    CHECK, 4
    RETURN
RECIBIR_ENTER:
    MOVFW   RCREG
    MOVWF   ENTER
    BSF	    CHECK, 5 ;BIT QUE SIRVE PARA VERIFICAR QUE SE REALIZARON 2 LECTURAS 
    BCF	    CHECK, 4
    RETURN 
;INTERRUPCION DEL TIMER 1 CADA MEDIO SEGUNDO PARA EL CRONOMETRO 
INTERRUPCION_TMR1:
    MOVLW   0x0B
    MOVWF   TMR1H
    MOVLW   0xDC
    MOVLW   TMR1L 
    CALL    SELECCION ;SUBRUTINA QUE SELECCIONA LA FUNCION QUE SE DEBE EJECUTAR ACORDE CON EL COMANDO QUE SE ENVIA DE LA COMPU 
    BCF	    PIR1, TMR1IF
    BTFSS   CHECK, 1
    GOTO    $+4
    CALL    CEROGRADOS 
    BCF	    CHECK, 7
    BCF	    CHECK, 1 ;LINEAS QUE SE ENCARGAN DE REVISAR QUE EL CONTADOR CONTADOR DE VUELTAS LLEGO AL MAXIMO PARA CERRAR EL SERVO 
    INCF    CONT2 ;CONTADOR QUE HACE QUE SE LLAME A LA RUTINA DE CRONOMETRO CADA 2 INTERRUPCIONES (1SEG)
    MOVLW   .2
    SUBWF   CONT2, W
    BTFSS   STATUS, Z
    GOTO    $+3
    CALL    CONTADOR ;RUTINA QUE INCREMENTA VARIABLES DE CRONOMETRO 
    CLRF    CONT2
    RETURN 
INTERRUPCION_TMR2:
    BCF	    PIR1, TMR2IF
    CALL    ANTIRREBOTE ;ANTIRREBOTE DEL SENSOR INFRARROJO 
    BTFSC   PIR1, TXIF
    CALL    INTERRUPCION_TX ;SUBRUTINA QUE MANDA LOS VALORES DEL CRONOMETRO COMO 00,00/N
    RETURN
;*******************************************************************************
; TABLAS
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
    BTFSC   CHECK, 0
    CALL    ENCENDER_LUCES ;RUTINA QUE ENCIENDE LAS LUCES DEL SEMAFORO 
    BTFSC   EEPROM, 0
    CALL    ESCRITURA_EEPROM ;RUTINA DE ESCRITURA 
    BTFSC   EEPROM, 1
    CALL    LECTURA_EEPROM ;RUTINA DE LECTURA 
    GOTO    LOOP

;******************RUTINAS AUXILIARES*******************************************
 NOVENTAGRADOS: ;VALORES PARA EL TIMER0 QUE HACEN QUE EL SERVO SE MUEVA 90 GRADOS 
    MOVLW   .250
    MOVWF   PARTEALTA
    MOVLW   .184
    MOVWF   PARTEBAJA  
    RETURN 
CEROGRADOS: ;VALORES PARA EL TIMER0 QUE HACEN QUE EL SERVO SE MUEVA 0 GRADOS 
    MOVLW   .254
    MOVWF   PARTEALTA
    MOVLW   .180
    MOVWF   PARTEBAJA
    RETURN 
;RUTINA QUE SELECCIONA LO QUE SE VA A EJECUTAR, ACORDE CON LO QUE SE RECIBE DE LA COMPUTADORA 
SELECCION:
    BTFSC   CHECK, 5
    GOTO    $+2 ;SE REVISA QUE SI SE HAYAN HECHO 2 LECTURAS 
    RETURN 
    BCF	    CHECK, 5
    MOVLW   .10
    SUBWF   ENTER, W
    BTFSS   STATUS, Z 
    GOTO    CORREGIR ;SE REVISA QUE LA SEGUNA RECEPCION HAYA SIDO UN ENTER, SI ES CORRECTO PROCEDE, SINO LIMPIA LAS VARIABLES 
    MOVLW   .48
    SUBWF   ACCION, W  ;SE CONVIERTE A BINARIO LA VARIABLE QUE SE RECIBE 
    MOVWF   ACCION 
    MOVLW   .0
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    INICIAR_CARRERA
    MOVLW   .1
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO   TERMINAR_CARRERA
    MOVLW   .2
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO   CEROGRADOS
    MOVLW   .3
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    NOVENTAGRADOS
    MOVLW   .4
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    ACTIVAR_LUCES 
    MOVLW   .5
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    INCREMENTAR_CONTADOR
    MOVLW   .6
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    HABILITAR_CONTADOR
    MOVLW   .7
    SUBWF   ACCION, W
    BTFSC   STATUS, Z 
    GOTO    RESETEAR_CONTADOR
    RETURN  ;ACORDE CON CADA VALOR RECIBIDO EJECUTA UNA SUBRUTINA Y DE LO CONTRARIO, NO EJECUTA 
HABILITAR_CONTADOR:
    BSF	    CHECK, 7 ;INICIA EL CONTADOR DEL TIMER 
    RETURN 
RESETEAR_CONTADOR:
    BCF	    CHECK, 7 ;BLOQUEA EL CONTADOR HASTA QUE SE INICIE Y SE LIMPIAN LAS VARIABLES 
    CLRF    UNIDADES 
    CLRF    DECENAS
    CLRF    MINUTOS 
    CLRF    MINUTOS2
    RETURN 
CORREGIR:
    CLRF    ACCION
    CLRF    ENTER
    RETURN 
ACTIVAR_LUCES:
    BSF	    CHECK, 0 ;BIT QUE ACTIVA QUE SE EJECUTEN LAS LUCES EN EL MAIN LOOP 
    RETURN 
DELAY_SMALL: ;DELAY UTILIZADO PARA LA RUTINA DE LUCES 
    MOVLW	.255 
    MOVWF	CONT1
    DECFSZ	CONT1, 1
    GOTO	$-1
    RETURN
ENCENDER_LUCES: ;RUTINA QUE ENCIENDE LAS LUCES 
    BSF	    PORTD, RD5
    CALL    DELAY_BIG
    BSF	    PORTD, RD6
    CALL    DELAY_BIG
    BCF	    PORTD, RD6
    BCF	    PORTD, RD5
    CALL    DELAY_BIG
    BSF	    PORTD, RD7
    CALL    DELAY_BIG
    BCF	    PORTD, RD7
    BCF	    CHECK, 0 ;SE LIMPIA LA BANDERA PARA QUE LA RUTINA SOLO SUCEDA CADA VEZ QUE ESTA SE LLAME 
    RETURN 
INCREMENTAR_CONTADOR: ;RUTINA QUE INCREMENTA EL CONTADOR DE LAS CARRERAS
    BTFSS   CHECK, 2 ;SE REVISA LA BANDERA, PARA QUE AL LLEGAR AL TOPE, ESTE NO SE REINICIE SOLO 
    RETURN 
    MOVLW   .4
    SUBWF   LUCES, W
    BTFSC   STATUS,Z
    GOTO    QUINTA_CARRERA
    MOVLW   .3
    SUBWF   LUCES, W
    BTFSC   STATUS,Z
    GOTO    CUARTA_CARRERA
    MOVLW   .2
    SUBWF   LUCES, W
    BTFSC   STATUS,Z
    GOTO    TERCERA_CARRERA
    MOVLW   .1
    SUBWF   LUCES, W
    BTFSC   STATUS,Z
    GOTO    SEGUNDA_CARRERA
PRIMERA_CARRERA:
    MOVLW   .1
    MOVWF   PORTB
    INCF    LUCES
    RETURN 
SEGUNDA_CARRERA:
    MOVLW   .3
    MOVWF   PORTB
    INCF    LUCES
    RETURN 
TERCERA_CARRERA:
    MOVLW   .7
    MOVWF   PORTB
    INCF    LUCES
    RETURN 
CUARTA_CARRERA:
    MOVLW   .15
    MOVWF   PORTB
    INCF    LUCES
    RETURN 
QUINTA_CARRERA:
    MOVLW   .31
    MOVWF   PORTB
    CLRF    LUCES
    BSF	    CHECK, 1
    BCF	    CHECK, 2 ;AL LLEGAR AL FINAL SE BLOQUEA LA BANDERA INICIAL Y SE ACTIVA LA BANDERA PARA CERRAR EL SERVO 
    RETURN 
INICIAR_CARRERA: ;AL INICIAR LA CARRERA SE LLAMA LAS RUTINAS DE LAS LUCES 
    BSF	    CHECK, 7 ;SE LIMPIA LAS VARIABLES QUE CUENTAN LAS CARRERAS Y EL PUERTO DONDE SE VE EL CONTEO 
    CLRF    LUCES
    CLRF    PORTB
    BSF	    CHECK, 2 ;HABILITA LA BANDERA PARA CONTAR LAS CARRERAS 
    BSF	    CHECK, 0 ;HABILITA LOS LEDS 
    CLRF    UNIDADES
    CLRF    DECENAS
    CLRF    MINUTOS 
    CLRF    MINUTOS2
    CALL    NOVENTAGRADOS ;ABRE EL SERVO 
    RETURN 
TERMINAR_CARRERA:
    BCF	    CHECK, 7 ;LIMPIA EL CRONOMETRO Y LO BLOQUEA 
    BSF	    EEPROM, 0 ;HABILITA LA ESCRITURA LE EEPROM 
    CALL    CEROGRADOS ;CIERRA EL SERVO 
    BCF	    CHECK, 2 ;BLOQUE EL CONTEO HASTA QUE SE HABILITE, AL INICIAR LA CARRERA 
    RETURN
    
DELAY_BIG: ;RUTINA QUE DELAY PARA LAS LUCES 
    MOVLW   .255
    MOVWF   CONT2
CONFIG1:
    CALL    DELAY_SMALL
    DECFSZ  CONT2, F
    GOTO    CONFIG1
    RETURN
INTERRUPCION_TX: ;RUTINA DEL TX QUE ALTERNA PARA MANDAR LOS VALRORES DEL CRONOMETRO DE LA FORMA VALOR VALOR , VALOR VALOR /N
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
    MOVFW   MINUTOS2
    CALL    TABLA_ASCII
    MOVWF   TXREG
    INCF    CONT7
    RETURN
MANDAR_NHX:
    MOVFW   MINUTOS
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
    MOVFW   UNIDADES
    CALL    TABLA_ASCII
    MOVWF   TXREG
    INCF    CONT7
    RETURN 
MANDAR_NLY:
    MOVFW   DECENAS
    CALL    TABLA_ASCII
    MOVWF   TXREG
    INCF    CONT7
    RETURN
ESPACIO:
    MOVLW   .10
    MOVWF   TXREG
    CLRF    CONT7
    RETURN 
;RUTINA QUE INCREMENTA VARIABLES PARA EL CRONOMETRO   
CONTADOR:
    BTFSS   CHECK, 7
    RETURN 
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
    INCF    MINUTOS
    MOVLW   .10
    SUBWF   MINUTOS, W
    BTFSS   STATUS, Z
    RETURN 
    CLRF    MINUTOS 
    INCF    MINUTOS2
    MOVLW   .10
    SUBWF   MINUTOS2, W
    BTFSS   STATUS, Z 
    RETURN 
    CLRF    MINUTOS2
    RETURN
;RUTINA DE LA LECTURA DE LA EEPROM 
LECTURA_EEPROM:
    BCF	    EEPROM, 1
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
    MOVWF   PORTB
    BSF	    INTCON, GIE
    RETURN
;RUTINA DE ESCRITURA DE LA EEPROM 
ESCRITURA_EEPROM:
    BCF	    EEPROM, 0
    BANKSEL EEADR
    MOVLW   0x00	; Mover la dirección a W
    MOVWF   EEADR      ; Escribir la dirección
    BANKSEL PORTA
    MOVFW   PORTB      ; Mover los datos a W
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
;antirebote********************************************************************    
ANTIRREBOTE:
    BTFSC   PUSH_BUTTON, 0
    GOTO    DEBOUNCE 
    BTFSC   PORTA, 0
    RETURN 
    BSF	    PUSH_BUTTON, 0
    RETURN 
DEBOUNCE:
    BTFSC   PUSH_BUTTON, 0
    CALL    ACCION_ANTIRREBOTE 
    RETURN
ACCION_ANTIRREBOTE:
    BTFSS   PORTA, 0
    RETURN
    BCF	    PUSH_BUTTON, 0
    CALL    INCREMENTAR_CONTADOR
    RETURN
;****************************CONFIGURACION**************************************
SETUP:
    BANKSEL PORTA  ; BANCO 0
    CLRF    PORTA  ; BORRA EL PUERTO 
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
    CLRF    ANSEL
    BANKSEL TRISA   ; BANCO 1
    CLRF    TRISA 
    BSF	    TRISA, 0
    CLRF    TRISB
    CLRF    TRISC  
    CLRF    TRISD
    CLRF    TRISE
    ;BSF	    PIE1, TXIE
    BSF	    PIE1, RCIE
    CONFIGURACION_TIMER0:
    CLRWDT		; CONFIGURACIÓN PARA EL FUNCIONAMIENTO DEL TIMER0
    MOVLW   b'11010111'	
    MOVWF   OPTION_REG
    CONFIGURACION_INTERRUPCION:
    BANKSEL TRISA
    BSF	    PIE1, TMR1IE; HABILITA INTERRUPCION DEL TIMER1
    BSF	    PIE1, TMR2IE; HABILITA COMPARACION ENTRE PR2 Y TIMER2
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    MOVLW   .20	; PARA TMR2 FUNCIONAR CON 5ms
    MOVWF   PR2
    
     
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
    CLRF    CAMBIO 
    CLRF    SERVO
    CLRF    PARTEALTA
    CLRF    PARTEBAJA
    CLRF    ACCION 
    CLRF    CHECK
    CLRF    LUCES
    CLRF    PUSH_BUTTON 
    CLRF    ENTER
    CLRF    UNIDADES 
    CLRF    DECENAS 
    CLRF    MINUTOS 
    CLRF    MINUTOS2
    CLRF    EEPROM 
    BSF	    EEPROM, 1
    RETURN 
;*******************************************************************************

  END