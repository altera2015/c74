#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "../../include/isa_defs.h"

#include <QtSerialPort/QSerialPort>
#include <QtSerialPort/QSerialPortInfo>
#include <QDebug>

#ifndef nullptr
#define nullptr 0
#endif

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    m_ConnectionMenu(nullptr),    
    ui(new Ui::MainWindow)

{
    ui->setupUi(this);

    on_actionRescan_comports_triggered();

    connect(&m_DebugPort, SIGNAL(halted()), this, SLOT(onHalted()));
    connect(&m_DebugPort, SIGNAL(running()), this, SLOT(onRunning()));
    connect(&m_DebugPort, SIGNAL(status(bool,bool,quint32)), this, SLOT(onStatus(bool, bool, quint32)));
    connect(&m_DebugPort, SIGNAL(step(bool)), this, SLOT(onStep(bool)));

    connect(&m_RegListBuilder, SIGNAL(getRegister(quint8)), &m_DebugPort, SLOT(getRegister(quint8)));
    connect(&m_DebugPort, SIGNAL(reg(bool,quint8,quint32)), &m_RegListBuilder, SLOT(reg(bool,quint8,quint32)));
    connect(&m_RegListBuilder, SIGNAL(done(bool,QStringList)), this, SLOT(onRegDone(bool,QStringList)));

    connect(&m_MemoryViewBuilder, SIGNAL(getMemory(quint32)), &m_DebugPort, SLOT(getMemory(quint32)));
    connect(&m_DebugPort, SIGNAL(memoryGet(bool,quint32)), &m_MemoryViewBuilder, SLOT(onMemory(bool,quint32)));
    connect(&m_MemoryViewBuilder, SIGNAL(done(bool,QStringList)), this, SLOT(onMemoryGetDone(bool,QStringList)));

    connect(&m_DebugPort, SIGNAL(connected()), &m_RegListBuilder, SLOT(reset()));
    connect(&m_DebugPort, SIGNAL(connected()), &m_MemoryViewBuilder, SLOT(reset()));

    connect(&m_DebugPort, SIGNAL(cpuFlags(bool,quint32)), ui->statusLedsPanel, SLOT(setStatus(bool,quint32)));

    m_CPURunningLed = new QLed(ui->statusBar);
    m_CPURunningLed->setMinimumWidth(16);
    m_CPURunningLed->setC(' ');
    ui->statusBar->addPermanentWidget(m_CPURunningLed);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_actionRescan_comports_triggered()
{
    QList<QSerialPortInfo> infos = QSerialPortInfo::availablePorts();

    if (m_ConnectionMenu!=nullptr)
    {
        m_ConnectionMenu->deleteLater();
    }

    qDebug() << "Rescan...";

    m_ConnectionMenu = ui->menuBar->addMenu("Connection");
    QAction * rescan = m_ConnectionMenu->addAction("Rescan");
    connect(rescan, SIGNAL(triggered()), this, SLOT(on_actionRescan_comports_triggered()));
    m_ConnectionMenu->addSeparator();

    qDebug() << "Listing...";

    for (int i=0;i<infos.count();i++)
    {
        const QSerialPortInfo & info = infos[i];

        /* QString s = QObject::tr("Port: ") + info.portName() + "\n"
                    + QObject::tr("Location: ") + info.systemLocation() + "\n"
                    + QObject::tr("Description: ") + info.description() + "\n"
                    + QObject::tr("Manufacturer: ") + info.manufacturer() + "\n"
                    + QObject::tr("Serial number: ") + info.serialNumber() + "\n"
                    + QObject::tr("Vendor Identifier: ") + (info.hasVendorIdentifier() ? QString::number(info.vendorIdentifier(), 16) : QString()) + "\n"
                    + QObject::tr("Product Identifier: ") + (info.hasProductIdentifier() ? QString::number(info.productIdentifier(), 16) : QString()) + "\n";*/

        QAction * a = m_ConnectionMenu->addAction(info.portName());
        a->setCheckable(true);
        m_Connections.append(a);
        a->setData(info.systemLocation());
        connect(a, SIGNAL(triggered()), this, SLOT(onConnectionSelected()));
        qDebug() << info.portName() << info.systemLocation();
    }
}

void MainWindow::onConnectionSelected()
{
    QObject* obj = sender();
    QAction * a = qobject_cast<QAction *>(obj);
    if ( a == nullptr )
    {
        qDebug() << "MainWindow::on_connection_selected / unexpected signal sender, expected a QAction";
        return;
    }

    foreach( QAction * a, m_Connections)
    {
        a->setChecked(false);
    }

    a->setChecked(true);
    QString portname = a->data().toString();    
    if ( m_DebugPort.open(portname) )
    {
        m_CPURunningLed->setBackgroundColor(Qt::green, Qt::yellow);
    }
    else
    {
        ui->statusBar->showMessage(tr("Failed to open comport, check if another task is using the port."));
    }
}

void MainWindow::onHalted()
{
    ui->statusBar->showMessage("CPU Halted");
    m_CPURunningLed->setPower(false);
    refreshView();
}

void MainWindow::onRunning()
{
    ui->statusBar->showMessage("CPU Running");
    m_CPURunningLed->setPower(true);
}

void MainWindow::onStatus(bool success, bool running, quint32 cpuId)
{
    if (success)
    {
        m_CPURunningLed->setPower(running);
        if (running)
        {
            ui->statusBar->showMessage( tr("CPU %1 Running").arg(QString::number(cpuId, 16)));
        }
        else
        {
            ui->statusBar->showMessage( tr("CPU %1 Halted").arg(QString::number(cpuId, 16)));
            refreshView();
        }
    }
    else
    {
        ui->statusBar->showMessage( tr("Unable to connect to CPU Debugger."));
    }
}

void MainWindow::onRegDone(bool success, QStringList list)
{
    if ( success )
    {
        ui->listWidget->clear();
        ui->listWidget->addItems(list);
    }
    else
    {
        ui->statusBar->showMessage( tr("Failed to retrieve register values."));
    }
}

void MainWindow::onMemoryGetDone(bool success, QStringList items)
{
    if ( success )
    {
        ui->textEdit->setText( items.join("\n"));
    }
    else
    {
        ui->textEdit->setText( tr("Failed to get memory"));
    }
}

void MainWindow::onStep(bool success)
{
    if ( success )
    {
        ui->statusBar->showMessage( tr("CPU Stepped."));
        refreshView();
    }
    else
    {
        ui->statusBar->showMessage( tr("CPU Step failed."));
    }
}

void MainWindow::refreshView()
{
    m_RegListBuilder.start();
    m_MemoryViewBuilder.start(ui->memoryBaseAddress->value(), ui->memoryCount->value());
    m_DebugPort.getCpuFlags();
}


void MainWindow::on_actionExit_triggered()
{
    close();
}

void MainWindow::on_actionHalt_triggered()
{
    m_DebugPort.setHalt();
}

void MainWindow::on_actionContinue_triggered()
{
    m_DebugPort.setContinue();
}

void MainWindow::on_actionStep_triggered()
{
    m_DebugPort.setStep();
}

void MainWindow::on_actionRefresh_Registers_triggered()
{
    m_RegListBuilder.start();
}

void MainWindow::on_refreshMemory_clicked()
{
    m_MemoryViewBuilder.start(ui->memoryBaseAddress->value(), ui->memoryCount->value());
}

void MainWindow::on_actionReset_triggered()
{
    m_DebugPort.setReset();
}

void MainWindow::on_writeMemButton_clicked()
{
    bool ok;
    quint32 v = ui->valueToWrite->text().toULong(&ok, 16);
    m_DebugPort.setMemory(ui->addressToWrite->value(), v);
}
