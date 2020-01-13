#include "memoryviewbuilder.h"

MemoryViewBuilder::MemoryViewBuilder(QObject *parent) :
    QObject(parent),
    m_Start(-1)
{
}

bool MemoryViewBuilder::start(int start, int count)
{
    if ( m_Start >= 0 )
    {
        return false;
    }
    m_Start = start;
    m_Count = count;
    m_Current = m_Start;
    m_Retries = 0;
    m_Items.clear();
    query();
    return true;
}

void MemoryViewBuilder::onMemory(bool success, quint32 value)
{
    if ( success )
    {
        QString s = tr("%1 = %2").arg( QString::number(m_Current,16)).arg(QString::number(value,16));
        m_Items.append(s);
        m_Current+=4;
        query();
    }
    else
    {
        m_Retries++;
        if ( m_Retries < 10 )
        {
            query();
        }
        else
        {
            m_Start = -1;
            emit done(false, m_Items);
        }
    }
}

void MemoryViewBuilder::reset()
{
    m_Start = -1;
}

void MemoryViewBuilder::query()
{
    if ( m_Current >= (m_Start + m_Count) )
    {
        m_Start = -1;
        emit done(true, m_Items);
        return;
    }

    emit getMemory(m_Current);
}

