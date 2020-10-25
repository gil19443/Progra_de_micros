from plotter import live_plotter_xy
from plotter import *
import numpy as np
import SERIAL as sr
import matplotlib.widgets as button
import matplotlib.pyplot as plt
size = 2
reset = np.zeros(size)
x_vec = np.linspace(0,1,size+1)[0:-1]
y_vec = np.linspace(0,1,size+1)[0:-1]
line1 = []
while 1:
    par1 = sr.envio()
    x1 = par1[0]
    y1 = par1[1]
    y_vec[-1] = y1
    x_vec[-1] = x1
    line1 = live_plotter_xy(x_vec,y_vec,line1)
    y_vec = np.append(y_vec[1:],0.0)
    x_vec = np.append(y_vec[1:],0.0)
    print("coordenada x =",x1,"coordenada y =",y1)
