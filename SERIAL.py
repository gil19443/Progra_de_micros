
import serial
import time
import sys

#COMUNICACION SERIAL DE PIC CON LA CUMPU

# Configurar el puerto serial. Elejir el puerto en el que aparece en su computadora y la velocidad

# loop infinito
ser = serial.Serial(port='COM5',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
ser.flushInput()
ser.flushOutput()
while 1:
                try:
                        #esperar un tiempo para recibir datos
                        time.sleep(.3)
                        #leer dato serial
                        x1=ser.readline()
                        dato = []
                        dato.append(x1)
                        print(x1)
                        #ser.close()
                        # RECUERDEN CONECTAR EL RX del pic AL TX de la compu
                except:

                        print("puerto no conectado")


