#ifndef REGISTERLISTBUILDER_H
#define REGISTERLISTBUILDER_H

#include <QObject>
#include <QStringList>

class RegisterListBuilder : public QObject
{
    Q_OBJECT
public:
    explicit RegisterListBuilder(QObject *parent = 0);

signals:
    void done(bool success, QStringList list);
    bool getRegister(quint8 reg);
public slots:
    void reg (bool success, quint8 reg, quint32 value);
    bool start();
    void reset();
protected:
    int m_Retries;
    int m_Reg;
    QStringList m_List;
    void query();

};

#endif // REGISTERLISTBUILDER_H
