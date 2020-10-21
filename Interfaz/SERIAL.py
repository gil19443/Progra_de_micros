import serial
import time
import sys
import math
#COMUNICACION SERIAL DE PIC CON LA CUMPU
# Configurar el puerto serial. Elejir el puerto en el que aparece en su computadora y la velocidad
ser = serial.Serial(port='COM5',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
ser.flushInput()
ser.flushOutput()
#funcion que vuelve el dato que lee el puerto serial
def conversiones():
    parte2 = ''
    verificacion = ''
    while verificacion != 10: #me aseguro que los datos que voy a ordenar siempre sean leidos en el orden que los envio
            time.sleep(.3)
            varificacion = ord(ser.read())
    for i in range(4): #leer los primeros datos que se envian del  pic x,y enter
            time.sleep(.3)
            #leer dato serial
            parte1= ord(ser.read())
            parte2 += ',' + str(x1)  #contruyo un sting con los cuatro datos separados por comas
    dato = parte2.split(',') #separo los datos por comas
    xf = dato[1] #x es la posicion 1 de mi string
    yf = dato[3] #y es la posicion 3 de mi string
    print(dato)
    return dato
def envio():
    x = conversiones()[1]
    y = conversiones()[3]
    x1 = math.floor(5*int(x)/13)
    y1 = math.floor(5*int(y)/13)
    ser.write(str(x1).encode('utf-8'))
    ser.write(str(y1).encode('utf-8'))
    fin = [str(x1).encode('utf-8'), str(y1).encode('utf-8')]
    return fin
