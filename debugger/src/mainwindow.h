#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

#include "c74debugport.h"
#include "registerlistbuilder.h"
#include "memoryviewbuilder.h"
#include "QLed.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
    QMenu * m_ConnectionMenu;
    QList<QAction*> m_Connections;
    C74DebugPort m_DebugPort;
    RegisterListBuilder m_RegListBuilder;
    MemoryViewBuilder m_MemoryViewBuilder;
    QLed * m_CPURunningLed;

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void on_actionExit_triggered();

    void on_actionHalt_triggered();

    void on_actionContinue_triggered();

    void on_actionStep_triggered();

    void on_actionRefresh_Registers_triggered();

    void on_refreshMemory_clicked();

    void on_actionReset_triggered();

    void on_writeMemButton_clicked();

protected slots:
    void on_actionRescan_comports_triggered();
    void onConnectionSelected();
    void onHalted();
    void onRunning();
    void onStatus(bool success, bool running, quint32 cpuId);
    void onRegDone(bool success, QStringList list);
    void onMemoryGetDone(bool success, QStringList items);
    void onStep(bool success);
    void refreshView();

private:
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
