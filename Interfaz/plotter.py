import matplotlib.pyplot as plt
import matplotlib.widgets as button
import numpy as np
import SERIAL as sr
# use ggplot style for more sophisticated visuals
plt.style.use('ggplot')
# the function below is for updating both x and y values (great for updating dates on the x-axis)
def live_plotter_xy(x_vec,y1_data,line1,identifier='',pause_time=1):
    if line1==[]:
        plt.ion()
        fig = plt.figure(figsize=(13,6))
        ax = fig.add_subplot(111)
        fig, ay = plt.subplots()
        line1, = ax.plot(x_vec,y1_data,'r-o',alpha=0.8)
        plt.title('Proyecto 2 - Etch a sketch'.format(identifier))
        axnext = plt.axes([0.1, 0.1, 0.1, 0.1])
        btn1 = button(ay = axnext, label= 'Next', color = 'red', hovercolor ='tomato')
        plt.show()
    line1.set_data(x_vec,y1_data)
    plt.xlim(0,100)
    plt.ylim(0,100)
    par1 = sr.envio()
    x1 = par1[0]
    y1 = par1[1]
    plt.ylabel(y1)
    plt.xlabel(x1)
    plt.pause(pause_time)
    return line1

    def next(self, event):
        y1_data = np.zeros(5)
        x_vect = np.zeros(5)
        plt.draw()


        bnext.on_clicked(callback.next)
