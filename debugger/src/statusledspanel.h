#ifndef STATUSLEDSPANEL_H
#define STATUSLEDSPANEL_H

#include <QWidget>

#include "QLed.h"

namespace Ui {
class StatusLedsPanel;
}

class StatusLedsPanel : public QWidget
{
    Q_OBJECT

public:
    explicit StatusLedsPanel(QWidget *parent = 0);
    ~StatusLedsPanel();

public slots:
    void setStatus(bool success, quint32 value);

private:
    Ui::StatusLedsPanel *ui;

    QVector<QLed*> m_StatusLeds;
};

#endif // STATUSLEDSPANEL_H
