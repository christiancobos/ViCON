#ifndef VICON_H
#define VICON_H

#include <QMainWindow>

#include <QGraphicsView>
#include <QGraphicsScene>
#include <QGraphicsPixmapItem>
#include <QImage>
#include <QPixmap>
#include <QTimer>

#include <opencv2/opencv.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include "FTD2XX.H"

QT_BEGIN_NAMESPACE
namespace Ui {
class ViCON;
}
QT_END_NAMESPACE

class ViCON : public QMainWindow
{
    Q_OBJECT

public:
    explicit ViCON(QWidget *parent = 0);
    ~ViCON();

private slots:

    void updateFrame();

    void on_inicioVideo_toggled(bool checked);

private:
    Ui::ViCON *ui;

    // Gestión del dispositivo FTDI
    FT_HANDLE ftHandle;
    FT_STATUS ftStatus;

    // Representación de vídeo en pantalla.
    QTimer* videoTimer;
    cv::VideoCapture cap;
    QGraphicsScene* scene;

    // Clasificador de caras.
    cv::CascadeClassifier faceCascade;

    // Flags de control
    bool videoEnable;
};
#endif // VICON_H
