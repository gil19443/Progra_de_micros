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
def reloj():
    try:
        ser.flushInput()
        time.sleep(.1)
        ser.readline()
        variable = ser.readline()
        code = variable.decode("utf8")
        datos = code[0]
        datos1 = code[1]
        datos2 = code[3]
        datos3 = code[4]
    except:
        datos = '80'
        datos1 = '80'
        datos2 = '80'
        datos3 = '80'

    x1 = int(datos,16)
    y1 = int(datos1,16)
    x2 = int(datos2,16)
    y2 = int(datos3,16)
    finalx1 = str(x1)
    finaly1 = str(y1)
    finalx2 = str(x2)
    finaly2 = str(y2)
    final = finalx1+ finaly1+":"+finalx2+finaly2
    return final
def datos():
    x = conversiones()[0] #llamo a mis valore x y y de la funcion anterior para mapealos de 0 a 99
    y = conversiones()[1]
    x1 = math.floor(5*int(x)/13) #uso math.floor para aproximar las operaciones a numeros enreros
    y1 = math.floor(5*int(y)/13)
    fin = [x1,y1]
    return fin #devuelvo una lista con las componentes en entero mapeadas
def iniciar_carrera (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    ser.flushOutput()
    sendx = "0"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        ser.write(bytes.fromhex('0A'))
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
def terminar_carrera (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    ser.flushOutput()
    sendx = "1"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        ser.write(bytes.fromhex('0A'))
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
def cerrar_puerta (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    ser.flushOutput()
    sendx = "2"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        ser.write(bytes.fromhex('0A'))
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
def abrir_puerta (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    ser.flushOutput()
    sendx = "3"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        ser.write(bytes.fromhex('0A'))
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
def encender_luces (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    ser.flushOutput()
    sendx = "4"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        ser.write(bytes.fromhex('0A'))
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
def aumentar_contador (): # funcion que envia datos al PIC, tiene como parametros lo que va a enviars
    ser.flushOutput()
    sendx = "5"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        ser.write(bytes.fromhex('0A'))
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
def habilitar_cronometro():
    ser.flushOutput()
    sendx = "6"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        ser.write(bytes.fromhex('0A'))
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
def limpiar_cronometro():
    ser.flushOutput()
    sendx = "7"
    try:
        sendx2 = ord(sendx)
        sendx1final = hex(sendx2)[2:] #convierto los valres en acsii a hex
        ser.write(bytes.fromhex(sendx1final)) #envio el primer digito de x
        ser.write(bytes.fromhex('0A'))
        regreso = bytes.fromhex(sendx1final)
        return regreso
    except:
        pass
        return
