#ifndef QLED_H
#define QLED_H

#include <QWidget>
#include <QPainter>

class QLed : public QWidget{
    Q_OBJECT
    Q_PROPERTY(bool power READ power WRITE setPower NOTIFY powerChanged)
    Q_PROPERTY(QChar c READ c WRITE setC NOTIFY cChanged)
    QLed(const QLed&)=delete;
    QLed& operator=(const QLed&)=delete;
public:
    explicit QLed(QWidget* parent=0)
        :QWidget(parent)
        , m_power(false)
        , m_C('Z')
        , m_BackgroundColorOn(Qt::red)
        , m_BackgroundColorOff(Qt::gray)
    {}
    bool power() const
    {
        return m_power;
    }
    QChar c() const
    {
        return m_C;
    }

public slots:
    void setPower(bool power)
    {
        if(power!=m_power){
            m_power = power;
            emit powerChanged();
            update();
        }
    }
    void setC(QChar c)
    {
        if(c!=m_C){
            m_C = c;
            emit cChanged();
            update();
        }
    }
    void setBackgroundColor(QColor backgroundColorOn, QColor backgroundColorOff) {
        m_BackgroundColorOn = backgroundColorOn;
        m_BackgroundColorOff = backgroundColorOff;
        update();
    }

signals:
    void powerChanged();
    void cChanged();
protected:
    virtual void paintEvent(QPaintEvent *event) {

        Q_UNUSED(event)
        QRectF r = rect();
        if ( r.width() > r.height() )
        {
            int w = r.width();
            r.setHeight(r.height()-1);
            r.setWidth(r.height());
            r.moveLeft(w/2.0 - r.height()/2);
        }
        else
        {
            int h = r.height();
            r.setHeight(r.width());
            r.moveTop(h/2.0 - r.width()/2.0);
        }

        QPainter ledPainter(this);
        ledPainter.setPen(Qt::black);
        if(m_power)
            ledPainter.setBrush(m_BackgroundColorOn);
        else
            ledPainter.setBrush(m_BackgroundColorOff);
        ledPainter.drawEllipse(r);
        QString c;
        c.append(m_C);
        ledPainter.drawText(r,Qt::AlignCenter, c);
    }
private:
    bool m_power;
    QChar m_C;
    QColor m_BackgroundColorOn;
    QColor m_BackgroundColorOff;
};

#endif // QLED_H
