#include "statusledspanel.h"
#include "ui_statusledspanel.h"
#include "../../include/isa_defs.h"

StatusLedsPanel::StatusLedsPanel(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::StatusLedsPanel)
{
    ui->setupUi(this);


    m_StatusLeds.resize(5);
    int i = 0;
    foreach(QObject *widget, ui->frame->children())
    {
        QLed * led = qobject_cast<QLed*>(widget);
        if (led)
        {
            m_StatusLeds[i] = led;
            switch ( i )
            {
            case Z_FLAG_POS:
                led->setC('Z');
                break;
            case V_FLAG_POS:
                led->setC('V');
                break;
            case C_FLAG_POS:
                led->setC('C');
                break;
            case N_FLAG_POS:
                led->setC('N');
                break;
            case I_FLAG_POS:
                led->setC('I');
                break;
            }
            i++;
        }
    }

}


StatusLedsPanel::~StatusLedsPanel()
{
    delete ui;
}

void StatusLedsPanel::setStatus(bool success, quint32 value)
{
    if ( success )
    {
        m_StatusLeds[Z_FLAG_POS]->setPower( ( value & ( 1 << Z_FLAG_POS )) != 0 );
        m_StatusLeds[V_FLAG_POS]->setPower( ( value & ( 1 << V_FLAG_POS )) != 0 );
        m_StatusLeds[C_FLAG_POS]->setPower( ( value & ( 1 << C_FLAG_POS )) != 0 );
        m_StatusLeds[N_FLAG_POS]->setPower( ( value & ( 1 << N_FLAG_POS )) != 0 );
        m_StatusLeds[I_FLAG_POS]->setPower( ( value & ( 1 << I_FLAG_POS )) != 0 );
    }
    else
    {
        for (int i=0;i<5;i++)
        {
            m_StatusLeds[Z_FLAG_POS]->setPower( false );
        }
    }
}
