from carro import * #import mi archivo creado con el designer
from PyQt5 import QtWidgets
from PyQt5.QtGui import QPainter, QPen, QPixmap, QColor
import serialcarro as sc #importo mi archivo con las funciones que reciben, mapean y mandan datos
import threading
import serial
import time
import sys
class dibujo (QtWidgets.QMainWindow, Ui_mainWindow):
    def __init__ (self):
        super().__init__()
        self.setupUi(self)
        ubicaciones=threading.Thread(daemon=True,target=cronometro) #hago un hilo para llamar a mi funcion grafica para realacionar mi interfaz con los datos seriales
        ubicaciones.start()
        self.pushButton.clicked.connect(self.boton0)
        self.pushButton_2.clicked.connect(self.boton1)
        self.pushButton_3.clicked.connect(self.boton2)
        self.pushButton_4.clicked.connect(self.boton4)
        self.pushButton_5.clicked.connect(self.boton5)
        self.pushButton_6.clicked.connect(self.boton3)
        self.pushButton_7.clicked.connect(self.iniciar_cronometro)
        self.pushButton_8.clicked.connect(self.reset)
        self.label_1.setText(sc.reloj())
        self.update()
    def boton0(self):
        sc.iniciar_carrera()
        print(sc.iniciar_carrera())
    def boton1(self):
        sc.terminar_carrera()
        print(sc.terminar_carrera())
    def boton2(self):
        sc.cerrar_puerta()
        print(sc.cerrar_puerta())
    def boton3(self):
        sc.abrir_puerta()
        print(sc.abrir_puerta())
    def boton4(self):
        sc.encender_luces()
        print(sc.encender_luces())
    def boton5(self):
        sc.aumentar_contador()
        print(sc.aumentar_contador())
    def iniciar_cronometro(self):
        sc.habilitar_cronometro()
    def reset(self):
        sc.limpiar_cronometro()
    def count(self):
        self.label_1.setText(sc.reloj())
    def actualizar(self):
        self.update()

def cronometro ():
    global dibujomain
    while(1):
        sc.reloj()
        dibujomain.count()
        dibujomain.actualizar()

aplication = QtWidgets.QApplication([])
dibujomain=dibujo()
dibujomain.show()
aplication.exec_()
