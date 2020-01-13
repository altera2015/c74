#ifndef C74DEBUGPORT_H
#define C74DEBUGPORT_H

#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QVector>

class C74DebugPort : public QObject
{
    Q_OBJECT


public:
    explicit C74DebugPort( QObject *parent = 0);

    bool open( const QString & path );
    void close();

signals:

    void running();
    void halted();

    void halt     (bool success);
    void cont     (bool success);
    void step     (bool success);
    void reset    (bool success);

    void status   (bool success, bool running, quint32 cpuid);
    void reg      (bool success, quint8 reg, quint32 value);
    void cpuFlags (bool success, quint32 value);
    void memoryGet(bool success, quint32 value);
    void memorySet(bool success);

    void connected();

public slots:


    bool setHalt();
    bool setContinue();
    bool setStep();
    bool setReset();

    bool getStatus();
    bool getRegister(quint8 reg);
    bool getCpuFlags();
    bool getMemory(quint32 address);
    bool setMemory(quint32 address, quint32 value);

private slots:
    void on_ready_read();
    void on_timeout();

private:
    struct Command {
        quint8 cmd;
        QByteArray data;
        int timeout;
    };

    QSerialPort * m_Port;
    QTimer m_Timer;
    QVector<quint8> m_Data;
    quint8 m_LastCommand;
    QList<Command> m_CommandQueue;

    bool send( quint8 cmd, QByteArray data = QByteArray(), int timeout = 1000);
    void failed(quint8 cmd);
    void checkQueue();
};

#endif // C74DEBUGPORT_H
