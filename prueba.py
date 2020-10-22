import serial
import time
import sys

#COMUNICACION SERIAL DE PIC CON LA CUMPU

# Configurar el puerto serial. Elejir el puerto en el que aparece en su computadora y la velocidad

# loop infinito
dato = serial.Serial(port='COM5',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
dato.flushInput()
dato.flushOutput()
#def conversiones():
while 1:
        dato.flushInput()
                            #esperar un tiempo para recibir datos
        time.sleep(.3)
        dato.readline()
        variable = dato.readline()
        print(variable)
