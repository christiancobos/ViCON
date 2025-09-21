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
#include <opencv2/face.hpp>
#include <fstream>
#include <map>
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

    void mostrarImagenSinVideo();

    void on_inicio_clicked(void);

    void on_reconocimiento_toggled(bool checked);

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

    // Algoritmo de reconocimiento de caras.
    cv::Ptr<cv::face::LBPHFaceRecognizer> faceRecognizer;
    std::map<int, std::string> labelToName;

    // Flags de control
    bool videoEnable;
    bool reconocimientoEnable;
};
#endif // VICON_H
