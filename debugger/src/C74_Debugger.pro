#-------------------------------------------------
#
# Project created by QtCreator 2020-01-11T14:48:11
#
#-------------------------------------------------

QT       += core gui serialport

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

#QMAKE_CXXFLAGS += -std=c++11
CONFIG += c++11

TARGET = C74_Debugger
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    c74debugport.cpp \
    registerlistbuilder.cpp \
    memoryviewbuilder.cpp \
    statusledspanel.cpp

HEADERS  += mainwindow.h \
    c74debugport.h \
    registerlistbuilder.h \
    memoryviewbuilder.h \
    QLed.h \
    statusledspanel.h

FORMS    += mainwindow.ui \
    statusledspanel.ui

RESOURCES += \
    res.qrc
