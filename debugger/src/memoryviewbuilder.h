#ifndef MEMORYVIEWBUILDER_H
#define MEMORYVIEWBUILDER_H

#include <QObject>
#include <QStringList>

class MemoryViewBuilder : public QObject
{
    Q_OBJECT
public:
    explicit MemoryViewBuilder(QObject *parent = 0);

signals:
    void done(bool success, QStringList items);
    bool getMemory(quint32 address);
public slots:
    bool start(int start, int count);
    void onMemory(bool success, quint32 value);
    void reset();

private:
    int m_Start;
    int m_Count;
    int m_Current;
    int m_Retries;
    QStringList m_Items;
    void query();
};

#endif // MEMORYVIEWBUILDER_H
