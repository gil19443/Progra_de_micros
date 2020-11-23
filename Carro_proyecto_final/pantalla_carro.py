from interfaz_carro import * #import mi archivo creado con el designer
from PyQt5 import QtWidgets
from PyQt5.QtGui import QPainter, QPen, QPixmap, QColor
import serial_carro as sc #importo mi archivo con las funciones que reciben, mapean y mandan datos
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
    #    ubicaciones=threading.Thread(daemon=True,target=grafica) #hago un hilo para llamar a mi funcion grafica para realacionar mi interfaz con los datos seriales
    #    ubicaciones.start()
        self.pushButton.clicked.connect(self.boton0)
        self.pushButton_2.clicked.connect(self.boton1)
        self.pushButton_3.clicked.connect(self.boton2)
        self.pushButton_4.clicked.connect(self.boton3)
        self.pushButton_5.clicked.connect(self.boton4)
        self.pushButton_6.clicked.connect(self.boton6)

    def boton0(self):
        sc.iniciar_carrera()
    def boton1(self):
        sc.terminar_carrera()
    def boton2(self):
        sc.cerrar_puerta()
    def boton3(self):
        sc.abrir_puerta()
    def boton4(self):
        sc.encender_luces()
    def boton5(self):
        sc.aumentar_contador()



aplication = QtWidgets.QApplication([])
dibujomain=dibujo()
dibujomain.show()
aplication.exec_()
