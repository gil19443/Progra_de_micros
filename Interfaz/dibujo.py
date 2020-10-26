from pantalla import * #import mi archivo creado con el designer
from PyQt5 import QtWidgets
from PyQt5.QtGui import QPainter, QPen, QPixmap, QColor
import SERIAL as sr #importo mi archivo con las funciones que reciben, mapean y mandan datos
import threading
import serial
import time
import sys
x=0
y=0
class dibujo (QtWidgets.QMainWindow, Ui_MainWindow):
    def __init__ (self):
        super().__init__()
        self.setupUi(self)
        self.mapa = QPixmap(700,700) #selecciono mi area de dibujo de 700x700
        self.mapa.fill(QColor('#ffffff'))
        self.label.setPixmap(self.mapa)
        self.painter = QPainter(self.label.pixmap())
        pen = QPen()
        pen.setWidth(4) #selecciono el ancho de pincel
        pen.setColor(QColor('Blue')) #selecciono el color de im pincel
        self.painter.setRenderHint(QPainter.Antialiasing)
        self.painter.setPen(pen)
        ubicaciones=threading.Thread(daemon=True,target=grafica) #hago un hilo para llamar a mi funcion grafica para realacionar mi interfaz con los datos seriales
        ubicaciones.start()
        self.limpiar.clicked.connect(self.clicked) #llamo a mi funcion clicked cuando presiono el boton limpiar

    def clicked(self): #funcion limpiar que borra todo de mi interfaz
        self.painter.eraseRect(0,0,700,700)

    def paint (self,x1,y1): #funcino que hace que si dibujo fuera de pantalla, ingrese al otro lado
        global x,y
        try: #no utilizo valores minimos como 0 ya que por la forma en la que envio los datos, necesito que sean de dos digitos
            self.painter.drawLine(x, y, x+x1 , y+y1)
            self.update()
            x=x1+x
            if x >= 700:
                x=10
            elif x<10:
                x= 700
            y=y1+y
            if y >= 700:
                y=10
            elif y<10:
                y= 700
        except:
            print('No se puede pintar en esa área de la pantalla ')
#funcion que dibuja con cierta velocidad acorde con el valor del potenciometro que lee mis arichos
def grafica ():
    global dibujomain
    while 1:
        par1 = sr.datos() #importo mi funcion que lee datos, para utilizar los valores en lo que voy a graficar
        x1 = par1[0]
        y1 = par1[1]
        try:
            Vx=0
            Vy=0
            if x1 >=50:
                Vx=1*(x1-50)
            elif x1 <=40:
                Vx=-1*(40-x1)

            if y1 >=50:
                    Vy=1*(y1-50)
            elif y1 <=40:
                    Vy=-1*(40-y1)
            dibujomain.paint(Vx,Vy) #dibujo los diferenciales de modo que entre mayor sea mi valor, dibujare con mas velocidad
            sr.envio(99*x//700,99*y//700) #llamo a mi funcion que envia datos para que se muestre la ubicacion en la que dibujo, mapeada de 0 a 100
            print ("El punto graficado es =",x1,y1)
        except:
            print ("No se puede dibujar nada")
aplication = QtWidgets.QApplication([])
dibujomain=dibujo()
dibujomain.show()
aplication.exec_()