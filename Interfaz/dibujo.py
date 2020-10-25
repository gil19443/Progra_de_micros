from pantalla import *
from PyQt5 import QtWidgets
from PyQt5.QtGui import QPainter, QPen, QPixmap, QColor
import SERIAL as sr
import threading
import serial
import time
import sys
x1= 0
y1= 0
x=0
y=0
class dibujo (QtWidgets.QMainWindow, Ui_MainWindow):
    def __init__ (self):
        super().__init__()
        self.setupUi(self)
        self.mapa = QPixmap(700,700)
        self.mapa.fill(QColor('#ffffff'))
        self.label.setPixmap(self.mapa)
        self.painter = QPainter(self.label.pixmap())
        pen = QPen()
        pen.setWidth(4)
        pen.setColor(QColor('Blue'))
        self.painter.setRenderHint(QPainter.Antialiasing)
        self.painter.setPen(pen)
        cordenada=threading.Thread(daemon=True,target=hilo_cordenadas)
        cordenada.start()
        self.limpiar.clicked.connect(self.clicked)

    def clicked(self):
        self.painter.eraseRect(0,0,700,700)
        
    def paint (self,x1,y1):
        global x,y
        try:
            self.painter.drawLine(x, y, x+x1 , y+y1)
            self.update()
            x=x1+x
            if x >= 700:
                x=0
            elif x<0:
                x= 700
            y=y1+y
            if y >= 700:
                y=0
            elif y<0:
                y= 700
        except:
            print('No se puede pintar en la pantalla')

def hilo_cordenadas ():
    global x1,y1,ventanamain
    while 1:
        par1 = sr.envio()
        x1 = par1[0]
        y1 = par1[1]
        try:
            dx=0
            dy=0
            if x1 >=29:
                dx=1*(x1-29)
            elif x1 <=23:
                dx=-1*(23-x1)

            if y1 >=29:
                    dy=1*(y1-29)
            elif y1 <=23:
                    dy=-1*(23-y1)
            ventanamain.paint(dx,dy)
            print (x1,"x")
            print (y1,"y")
        except:
            print ("S")
aplication = QtWidgets.QApplication([])
ventanamain=dibujo()
ventanamain.show()
aplication.exec_()
