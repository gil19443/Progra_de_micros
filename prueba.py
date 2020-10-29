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
while 1:
    ser.flushInput()
    parte2 = []
    verificacion = ''
    while verificacion != 44: #me aseguro que siempre agrupe los 4 datos que envio en el mismo orden
            time.sleep(.03)
            verificacion = ord(ser.read())
    for i in range(6): #leer los primeros datos que se envian del  pic x,y enter
            time.sleep(.03)
            #leer dato serial
            parte1= ser.readline()
            parte2.append(parte1)  #contruyo un sting con los cuatro datos separados por comas
    #dato = parte2.split(',') #separo los datos por comas
   # xf = dato[1]+dato[2] #x es la posicion 1 de mi string
   # yf = dato[4]+dato[5] #y es la posicion 3 de mi string
    yy = parte1.decode("utf8")
   # devuelve = [xf, yf]
    print(yy)
#def datos():
#    x = conversiones()[1] #llamo a mis valore x y y de la funcion anterior para mapealos de 0 a 99
#    y = conversiones()[2]
#    ix = int(x,16)
#    iy = int(y,16)
#    x1 = math.floor(5*int(ix)/13) #uso math.floor para aproximar las operaciones a numeros enreros
#    y1 = math.floor(5*int(iy)/13)
#    fin = [x1,y1]
#    return fin #devuelvo una lista con las componentes en entero mapeadas
#def envio (sendx,sendy): # funcion que envia datos al PIC, tiene como parametros lo que va a enviar
#    try:
#        ser.write(bytes.fromhex(str(sendx))) #por la funcion fromhex, suele dar error al tener valores de 00 como lectura, de modo que si da error se manda un 01 consntante
#    except:
#        ser.write(bytes.fromhex('01'))
#    try:
#        ser.write(bytes.fromhex(str(sendy)))
#    except:
#        ser.write(bytes.fromhex('01'))
#    return
