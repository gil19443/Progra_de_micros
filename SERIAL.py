
import serial
import time
import sys

#COMUNICACION SERIAL DE PIC CON LA CUMPU

# Configurar el puerto serial. Elejir el puerto en el que aparece en su computadora y la velocidad

# loop infinito
while 1:
        ser = serial.Serial(port='COM5',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
        #borrar el buffer para iniciar en cero
        ser.flushInput()
        ser.flushOutput()
        #esperar un tiempo para recibir datos
        time.sleep(.3)
        #leer dato serial
        #x=ser.read() #readline lee hasta encontrar el enter ASCII "A"h
        #esperar un tiempo para recibir datos
        #time.sleep(.3)
        y=ser.read() #readline lee hasta encontrar el enter ASCII "A"h
        #escribir dato serial
        #ser.write(0x0A)
        #convertir a número de 8 bits e imprimir el dato recibido#x_final = ord(y)
        #y_final = ord(y)
        print(y)
        ser.close()
        # RECUERDEN CONECTAR EL RX del pic AL TX de la compu
