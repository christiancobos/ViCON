#include "vicon.h"
#include "ui_vicon.h"

ViCON::ViCON(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::ViCON)
{
    ui->setupUi(this);
    setWindowTitle(tr("ViCON: Interfaz de Control y representación de vídeo")); // Título de la ventana

    // Configuración de la conexión FT245
    ftStatus = FT_Open(0, &ftHandle);
    if (ftStatus != FT_OK)
    {
        qDebug() << "Error al abrir el dispositivo FTDI.";
    }

    // Configuración de escena para representación de vídeo.
    scene = new QGraphicsScene(this);
    ui->graphicsView->setScene(scene);

    // Apertura de fuente de imagen:
    //cap.open("video.mp4"); // Opción de fuente de vídeo.
    cap.open(0); //Opción para webcam

    // Configuración de timer:
    videoTimer = new QTimer(this);
    connect(videoTimer, &QTimer::timeout, this, &ViCON::updateFrame);

    // Inicializador del clasificador facial.
    if (!faceCascade.load("haarcascade_frontalface_default.xml")) {
        qDebug() << "No se pudo cargar el clasificador de rostros.";
    }

    // Configuración de variables globales.
    videoEnable = false;
}

ViCON::~ViCON()
{
    delete ui;
}

void ViCON::updateFrame()
{
    cv::Mat frame;
    cap >> frame;
    if (!frame.empty()) {
        cv::cvtColor(frame, frame, cv::COLOR_BGR2RGB);

        std::vector<cv::Rect> faces;
        cv::Mat gray;

        cv::cvtColor(frame, gray, cv::COLOR_BGR2GRAY);
        cv::flip(frame, frame, 1); // Espejo horizontal de la imagen.

        cv::equalizeHist(gray, gray);  // Mejora contraste
        faceCascade.detectMultiScale(gray, faces, 1.1, 4, 0, cv::Size(30, 30));

        for (const auto& face : faces)
        {
            cv::rectangle(frame, face, cv::Scalar(0, 255, 0), 2);
        }

        QImage qimg(frame.data, frame.cols, frame.rows, frame.step, QImage::Format_RGB888);
        scene->clear();
        scene->addPixmap(QPixmap::fromImage(qimg));
        scene->setSceneRect(qimg.rect());
        ui->graphicsView->fitInView(scene->sceneRect(), Qt::KeepAspectRatio);
    } else {
        videoTimer->stop();  // fin del video
        ui->inicioVideo->setChecked(false);
    }
}

void ViCON::on_inicioVideo_toggled(bool checked)
{
    videoEnable = checked;

    if (checked) {
        videoTimer->start(33);  // aprox 30 fps
    } else {
        videoTimer->stop();
    }
}
