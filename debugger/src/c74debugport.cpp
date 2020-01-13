#include "c74debugport.h"
#include "../../include/isa_defs.h"

#include <QDebug>

#ifndef nullptr
#define nullptr 0
#endif

C74DebugPort::C74DebugPort(QObject *parent) :
    QObject(parent),
    m_Port(nullptr),    
    m_LastCommand(0)
{
    close();
    connect(&m_Timer, SIGNAL(timeout()), this, SLOT(on_timeout()));
    m_Timer.setSingleShot(true);
}

bool C74DebugPort::open(const QString &path)
{
    if ( m_Port != nullptr)
    {
        m_Port->close();
        delete m_Port;
    }

    m_Port = new QSerialPort(path);
    if (!m_Port->open(QIODevice::ReadWrite))
    {
        m_Port = nullptr;
        delete m_Port;
        return false;
    }

    m_Port->setBaudRate(115200);
    m_Port->setParity(QSerialPort::NoParity);
    m_Port->setStopBits(QSerialPort::OneStop);

    connect(m_Port, SIGNAL(readyRead()), this, SLOT(on_ready_read()));
    getStatus();

    emit connected();
    return true;
}

void C74DebugPort::close()
{
    if ( m_Port != nullptr )
    {
        m_Port->close();
        delete m_Port;
        m_Port = nullptr;
    }
}

bool C74DebugPort::getStatus()
{
    return send(DBG_STATUS);
}

bool C74DebugPort::setHalt()
{
    return send(DBG_HALT);
}

bool C74DebugPort::setContinue()
{
    return send(DBG_CONTINUE);
}

bool C74DebugPort::setStep()
{
    return send(DBG_STEP);
}

bool C74DebugPort::setReset()
{
    return send(DBG_RESET);
}

bool C74DebugPort::getRegister(quint8 reg)
{
    return send(DBG_GET_REG_0 + reg);
}

bool C74DebugPort::getCpuFlags()
{
    return send(DBG_GET_CPU_FLAGS);
}

bool C74DebugPort::getMemory(quint32 address)
{
    QByteArray data;
    data.append((char)(0xff & (address >> 24)));
    data.append((char)(0xff & (address >> 16)));
    data.append((char)(0xff & (address >> 8)));
    data.append((char)(0xff & (address >> 0)));
    return send(DBG_GET_MEM, data);
}

bool C74DebugPort::setMemory(quint32 address, quint32 value)
{
    QByteArray data;
    data.append((char)(0xff & (address >> 24)));
    data.append((char)(0xff & (address >> 16)));
    data.append((char)(0xff & (address >> 8)));
    data.append((char)(0xff & (address >> 0)));

    data.append((char)(0xff & (value >> 24)));
    data.append((char)(0xff & (value >> 16)));
    data.append((char)(0xff & (value >> 8)));
    data.append((char)(0xff & (value >> 0)));

    return send(DBG_SET_MEM, data);
}

void C74DebugPort::on_ready_read()
{
    QByteArray d = m_Port->readAll();

    // qDebug() << "RECEIVING" << d.toHex();

    for (int i=0;i<d.count();i++)
    {
        m_Data.push_back((quint8)d[i]);
    }

    while ( m_Data.count() > 0 )
    {
        quint8 cmd = m_Data.first();
        bool ack = ( cmd & 0x80 ) == 0x80;
        cmd &= 0x7f;

        if (ack)
        {

            if ( m_LastCommand ==  cmd )
            {
                m_Timer.stop();
                m_LastCommand = 0;
            }

            int popCnt = 1;

            switch ( cmd )
            {
            case DBG_RUNNING:
                emit running();
                break;

            case DBG_HALTED:
                emit halted();
                break;


            case DBG_HALT:
                emit halt(true);
                break;

            case DBG_CONTINUE:
                emit cont(true);
                break;

            case DBG_RESET:
                emit reset(true);
                break;

            case DBG_STEP:
                emit step(true);
                break;

            case DBG_SET_MEM:
                emit memorySet(true);
                break;

            case DBG_STATUS:

                if (m_Data.count() < 5 )
                {
                    return;
                }
                {
                    quint8 id1 = m_Data[1] & 0x7f;
                    bool isRunning = ( m_Data[1] & 0x80 ) == 0x00;
                    emit status( true, isRunning, ( id1 << 24) | ( m_Data[2] << 16) | ( m_Data[3] << 8) | ( m_Data[4] << 0));
                }
                popCnt = 5;
                break;

            case DBG_GET_REG_0:
            case DBG_GET_REG_1:
            case DBG_GET_REG_2:
            case DBG_GET_REG_3:
            case DBG_GET_REG_4:
            case DBG_GET_REG_5:
            case DBG_GET_REG_6:
            case DBG_GET_REG_7:
            case DBG_GET_REG_8:
            case DBG_GET_REG_9:
            case DBG_GET_REG_10:
            case DBG_GET_REG_11:
            case DBG_GET_REG_12:
            case DBG_GET_REG_13:
            case DBG_GET_REG_14:
            case DBG_GET_REG_15:

                if (m_Data.count() < 5 )
                {
                    return;
                }
                emit reg(true, cmd - DBG_GET_REG_0, ( m_Data[1] << 24) | ( m_Data[2] << 16) | ( m_Data[3] << 8) | ( m_Data[4] << 0) );
                popCnt = 5;
                break;

            case DBG_GET_CPU_FLAGS:
                if (m_Data.count() < 5 )
                {
                    return;
                }
                emit cpuFlags( true, ( m_Data[1] << 24) | ( m_Data[2] << 16) | ( m_Data[3] << 8) | ( m_Data[4] << 0) );
                popCnt = 5;
                break;

            case DBG_GET_MEM:
                if (m_Data.count() < 5 )
                {
                    return;
                }
                emit memoryGet( true, ( m_Data[1] << 24) | ( m_Data[2] << 16) | ( m_Data[3] << 8) | ( m_Data[4] << 0) );
                popCnt = 5;
                break;

            default:
                qDebug() << "Unknown response " << (quint8)m_Data.at(0);
                m_Data.clear();
            }

            // qDebug() << "Processed command: " << QString::number(m_Data.first(), 16);

            for (int i=0;i<popCnt;i++)
            {
                m_Data.pop_front();
            }
        }
        else
        {
            failed(cmd);
            m_Data.pop_front();
        }
    }

    checkQueue();
}

void C74DebugPort::on_timeout()
{    
    failed(m_LastCommand);
    m_LastCommand = 0;
}


bool C74DebugPort::send(quint8 cmd, QByteArray data, int timeout)
{
    if (m_Port == nullptr )
    {
        return false;
    }

    if ( m_LastCommand != 0 )
    {
        Command c = {cmd, data,timeout};
        m_CommandQueue.push_back( c );
        return true;
    }

    QByteArray ba;
    ba.append((char)cmd);
    ba.append(data);

    // qDebug() << "SENDING" << ba.toHex();

    m_Port->write(ba);
    m_LastCommand = cmd;
    m_Timer.start(timeout);

    return true;
}

void C74DebugPort::failed(quint8 cmd)
{
    switch(cmd)
    {
    case DBG_HALT:
        emit halt(false);
        break;

    case DBG_CONTINUE:
        emit cont(false);
        break;

    case DBG_RESET:
        emit reset(false);
        break;

    case DBG_STEP:
        emit step(false);
        break;

    case DBG_STATUS:
        emit status(false, false, 0);
        break;

    case DBG_SET_MEM:
        emit status(false, false, 0);
        break;


    case DBG_GET_REG_0:
    case DBG_GET_REG_1:
    case DBG_GET_REG_2:
    case DBG_GET_REG_3:
    case DBG_GET_REG_4:
    case DBG_GET_REG_5:
    case DBG_GET_REG_6:
    case DBG_GET_REG_7:
    case DBG_GET_REG_8:
    case DBG_GET_REG_9:
    case DBG_GET_REG_10:
    case DBG_GET_REG_11:
    case DBG_GET_REG_12:
    case DBG_GET_REG_13:
    case DBG_GET_REG_14:
    case DBG_GET_REG_15:
        emit reg(false, 0, 0);
        break;

    case DBG_GET_CPU_FLAGS:
        emit cpuFlags( false, 0 );
        break;

    case DBG_GET_MEM:
        emit memorySet(false);
        break;
    default:
        qDebug() << "C74DebugPort::failed / unknown command " << cmd;

    }
}

void C74DebugPort::checkQueue()
{
    if ( m_CommandQueue.count()==0)
    {
        return;
    }

    if ( m_LastCommand > 0 )
    {
        return;
    }

    Command c = m_CommandQueue.first();
    m_CommandQueue.pop_front();
    send(c.cmd, c.data, c.timeout);
}


