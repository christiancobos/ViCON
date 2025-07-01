#include "vicon.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    qDebug() << "Starting ViCON GUI...";
    QApplication a(argc, argv);
    ViCON w;
    w.show();
    return a.exec();
}
