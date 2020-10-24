from random import *
from tkinter import *
import SERIAL as sr
import math

def crea_linea(event):
 # par1 = sr.conversiones()
 # x1= math.floor(float(par1[1]))
 # y1= math.floor(float(par1[3]))
 # par2 = sr.conversiones()
 # x2= math.floor(float(par2[1]))
 # y2= math.floor(float(par2[3]))
    par1 = sr.envio()
    x1 = par1[0]
    y1 = par1[1]
    par2 = sr.envio()
    x2 = par2[0]
    y2 = par2[1]
    print("x1=",x1,"y1=",y1,"x2=",x2,"y2=",y2)
    canvas.create_line(x1,y1,x2,y2,fill="black",width=20)
def borra_linea(event):
  canvas.delete('all')

ventana = Tk()
ventana.title("CREA LINEAS")
canvas = Canvas(ventana,width=800,height=500,background='white')
canvas.bind('<Motion>',crea_linea)
canvas.bind('<Visibility>',crea_linea)
canvas.grid(row=0,column=0)
canvas.bind('<Button-3>',borra_linea)
canvas.mainloop()
