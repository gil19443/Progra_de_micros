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
def iniciar_carrera (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    sendx = "0"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
def terminar_carrera (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    sendx = "1"
    try:
        sendx2 = ord(sendx)[2:]
        sendx1final = hex(sendx2) #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
    except:
        pass
    return
def cerrar_puerta (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    sendx = "2"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
    except:
        pass
    return
def abrir_puerta (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    sendx = "3"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
    except:
        pass
    return
def encender_luces (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    sendx = "4"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2) #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final))[2:] #envio el primer digito de x
    except:
        pass
    return
def aumentar_contador (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    sendx = "5"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
    except:
        pass
    return
