#include "registerlistbuilder.h"

RegisterListBuilder::RegisterListBuilder(QObject *parent) :
    QObject(parent),
    m_Reg(-1)
{
}

void RegisterListBuilder::reg(bool success, quint8 reg, quint32 value)
{
    if ( !success)
    {
        if ( m_Retries < 10 )
        {
            m_Retries++;
            query();
        }
        else
        {
            m_Reg = -1;
            emit done(false, m_List);
        }
    }
    m_List.append( tr("R%1 = %2").arg(reg).arg(QString::number(value,16)));
    m_Reg++;
    query();
}

bool RegisterListBuilder::start()
{
    if ( m_Reg >= 0 )
    {
        return false;
    }
    m_Reg = 0;
    m_Retries = 0;
    m_List.clear();
    query();
    return true;
}

void RegisterListBuilder::reset()
{
    m_Reg = -1;
}

void RegisterListBuilder::query()
{
    if ( m_Reg < 16 )
    {
        emit getRegister(m_Reg);
    }
    else
    {
        m_Reg = -1;
        emit done(true, m_List);
    }
}
