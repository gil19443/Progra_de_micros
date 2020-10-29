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
    try:
        ser.flushInput()
        time.sleep(.1)
        ser.readline()
        variable = ser.readline()
        code = variable.decode("utf8")
        datos = code[0]+code[1]
        datos1 = code[3]+code[4]
    except:
        datos = '80'
        datos1 = '80'
    x = int(datos,16)
    y = int(datos1,16)
    final = [x,y]
    return final
def datos():
    x = conversiones()[0] #llamo a mis valore x y y de la funcion anterior para mapealos de 0 a 99
    y = conversiones()[1]
    x1 = math.floor(5*int(x)/13) #uso math.floor para aproximar las operaciones a numeros enreros
    y1 = math.floor(5*int(y)/13)
    fin = [x1,y1]
    return fin #devuelvo una lista con las componentes en entero mapeadas
def envio (sendx1,sendy1): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    sendx = str(sendx1)
    sendy = str(sendy1)
    try:
        sendx2 = ord(sendx[0])
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
    except:
        ser.write(bytes.fromhex(hex(ord('0'))[2:])) #si la funcion da error, escribo un 0

    try:
        sendx3 = ord(sendx[1])
        sendx2final = hex(sendx3)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx2final)) #envio el segundo digito de x
        ser.write(bytes.fromhex('2C')) #envia una coma en hexadecimal
    except:
        ser.write(bytes.fromhex(hex(ord('0'))[2:])) #si la funcion da error, escribo un 0
    try:
        sendy2 = ord(sendy[0])
        sendy1final = hex(sendy2)[2:] #convierto los valres en acsii a hex acsii
        ser.write(bytes.fromhex(sendy1final))  #envio el primer digito de y
    except:
        ser.write(bytes.fromhex(hex(ord('0'))[2:]))  #si la funcion da error, escribo un 0
    try:#decimal ord(str(sendx))
        sendy3 = ord(sendy[1])
        sendy2final = hex(sendy3)[2:] #convierto los valres en acsii a hex acsii
        ser.write(bytes.fromhex(sendy2final))  #envio el segundo digito de y
        ser.write(bytes.fromhex('0A')) # envio un enter en hexadecimal
    except:
        ser.write(bytes.fromhex(hex(ord('0'))[2:])) #si la funcion da error, escribo un 0

    return
