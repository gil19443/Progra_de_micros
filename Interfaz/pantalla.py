# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'pantalla.ui'
#
# Created by: PyQt5 UI code generator 5.15.1
#
# WARNING: Any manual changes made to this file will be lost when pyuic5 is
# run again.  Do not edit this file unless you know what you are doing.


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):

    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(850, 800)
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.label = QtWidgets.QLabel(self.centralwidget)
        self.label.setGeometry(QtCore.QRect(0, 0, 800, 800))
        font = QtGui.QFont()
        font.setPointSize(24)
        self.label.setFont(font)
        self.label.setText("25656656")
        self.label.setObjectName("label")
        self.limpiar = QtWidgets.QPushButton(self.centralwidget)
        self.limpiar.setGeometry(QtCore.QRect(740, 10, 93, 28))
        self.limpiar.setObjectName("limpiar")
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 855, 26))
        self.menubar.setObjectName("menubar")
        self.menuArchivo = QtWidgets.QMenu(self.menubar)
        self.menuArchivo.setObjectName("menuArchivo")
        self.menuClear = QtWidgets.QMenu(self.menubar)
        self.menuClear.setObjectName("menuClear")
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtWidgets.QStatusBar(MainWindow)
        self.statusbar.setObjectName("statusbar")
        MainWindow.setStatusBar(self.statusbar)
        self.actionGuardar = QtWidgets.QAction(MainWindow)
        self.actionGuardar.setObjectName("actionGuardar")
        self.actionBorrar = QtWidgets.QAction(MainWindow)
        self.actionBorrar.setObjectName("actionBorrar")
        self.menuArchivo.addSeparator()
        self.menuArchivo.addAction(self.actionGuardar)
        self.menuArchivo.addAction(self.actionBorrar)
        self.menubar.addAction(self.menuArchivo.menuAction())
        self.menubar.addAction(self.menuClear.menuAction())
        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)


    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.limpiar.setText(_translate("MainWindow", "Limpiar "))
        self.menuArchivo.setTitle(_translate("MainWindow", "Archivo"))
        self.menuClear.setTitle(_translate("MainWindow", "Clear "))
        self.actionGuardar.setText(_translate("MainWindow", "Guardar "))
        self.actionGuardar.setShortcut(_translate("MainWindow", "Ctrl+S"))
        self.actionBorrar.setText(_translate("MainWindow", "Copiar "))
        self.actionBorrar.setShortcut(_translate("MainWindow", "Ctrl+C"))


if __name__ == "__main__":
    import sys
    app = QtWidgets.QApplication(sys.argv)
    MainWindow = QtWidgets.QMainWindow()
    ui = Ui_MainWindow()
    ui.setupUi(MainWindow)
    MainWindow.show()
    sys.exit(app.exec_())
