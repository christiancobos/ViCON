#include "vicon.h"
#include "ui_vicon.h"

ViCON::ViCON(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::ViCON)
{
    ui->setupUi(this);
    setWindowTitle(tr("ViCON: Interfaz de Control y representación de vídeo")); // Título de la ventana

    // Configuración de escena para representación de vídeo.
    scene = new QGraphicsScene(this);
    ui->graphicsView->setScene(scene);

    // Mostrar imagen estática
    QTimer::singleShot(0, this, [this]() {
        mostrarImagenSinVideo();
    });

    // Inicializar estado del botón de inicio.
    ui->inicio->setStyleSheet(
        "QPushButton {"
        " background-color: #e0e0e0;"
        " color: black;"
        " border: 2px solid #aaaaaa;"
        " border-radius: 5px;"
        " padding: 6px;"
        " font-weight: normal;"
        " }"
        );

    // Configuración de timer:
    videoTimer = new QTimer(this);
    connect(videoTimer, &QTimer::timeout, this, &ViCON::updateFrame);

    // Configuración de variables globales.
    videoEnable          = false;
    reconocimientoEnable = false;
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
        cv::flip(frame, frame, 1); // Espejo horizontal de la imagen.

        std::vector<cv::Rect> faces;
        cv::Mat gray;

        cv::cvtColor(frame, gray, cv::COLOR_BGR2GRAY);

        cv::equalizeHist(gray, gray);  // Mejora contraste
        faceCascade.detectMultiScale(gray, faces, 1.1, 4, 0, cv::Size(30, 30));

        if (reconocimientoEnable && faceRecognizer)
        {
            for (const auto& face : faces)
            {
                cv::Mat faceROI = gray(face);  // recorta la cara del frame en gris
                cv::Mat resizedFace;
                cv::resize(faceROI, resizedFace, cv::Size(200, 200));  // normaliza tamaño

                int predictedLabel = -1;
                double confidence = 0.0;

                faceRecognizer->predict(resizedFace, predictedLabel, confidence);

                std::string labelName = "Desconocido";
                if (labelToName.find(predictedLabel) != labelToName.end() && confidence < 70.0)
                {
                    labelName = labelToName[predictedLabel];
                }

                // Dibujar nombre encima del rectángulo
                cv::rectangle(frame, face, cv::Scalar(0, 255, 0), 2);
                cv::putText(frame, labelName, cv::Point(face.x, face.y - 10),
                            cv::FONT_HERSHEY_SIMPLEX, 0.8, cv::Scalar(0, 255, 0), 2);
            }
        }
        else
        {
            // Solo dibujar rectángulo si no está activo el reconocimiento
            for (const auto& face : faces)
            {
                cv::rectangle(frame, face, cv::Scalar(0, 255, 0), 2);
            }
        }

        QImage qimg(frame.data, frame.cols, frame.rows, frame.step, QImage::Format_RGB888);
        scene->clear();
        scene->addPixmap(QPixmap::fromImage(qimg));
        scene->setSceneRect(qimg.rect());
        ui->graphicsView->fitInView(scene->sceneRect(), Qt::KeepAspectRatio);
    } else {
        videoTimer->stop();  // fin del video
        ui->inicio->click();
    }
}

void ViCON::mostrarImagenSinVideo()
{
    // 1. Crear imagen negra base
    int width = 640;
    int height = 480;
    cv::Mat noVideoImg(height, width, CV_8UC3, cv::Scalar(0, 0, 0));

    // 2. Texto
    std::string mensaje = "No video available";
    int fontFace = cv::FONT_HERSHEY_SIMPLEX;
    double fontScale = 2.0;
    int thickness = 3;

    // 3. Centrado del texto
    int baseline = 0;
    cv::Size textSize = cv::getTextSize(mensaje, fontFace, fontScale, thickness, &baseline);
    cv::Point textOrg((width - textSize.width) / 2, (height + textSize.height) / 2);
    cv::putText(noVideoImg, mensaje, textOrg, fontFace, fontScale, cv::Scalar(0, 0, 255), thickness);

    // 4. Convertir a QImage y luego a QPixmap
    QImage qimg(noVideoImg.data, noVideoImg.cols, noVideoImg.rows, noVideoImg.step, QImage::Format_RGB888);
    QPixmap pixmap = QPixmap::fromImage(qimg.rgbSwapped());

    // 5. Añadir a escena y escalar con fitInView
    scene->clear();
    QGraphicsPixmapItem* item = scene->addPixmap(pixmap);
    item->setTransformationMode(Qt::SmoothTransformation);
    scene->setSceneRect(pixmap.rect());

    // 6. Ajuste de vista manteniendo aspecto
    ui->graphicsView->fitInView(item, Qt::KeepAspectRatio);
}

void ViCON::on_inicio_clicked(void)
{
    if (!videoEnable)
    {
        // Configuración de la conexión FT245
        ftStatus = FT_Open(0, &ftHandle);
        if (ftStatus != FT_OK)
        {
            qDebug() << "Error al abrir el dispositivo FTDI.";
            ui->estado->setStyleSheet("color: red;");
            ui->estado->setText("No se encuentra dispositivo FTDI!");
            return;
        }
        ui->estado->setStyleSheet("color: green;");
        ui->estado->setText("Conexión iniciada");

        // TODO: Adaptaciones para usar imágen del FT245
        // Apertura de fuente de imagen:
        //cap.open("video.mp4"); // Opción de fuente de vídeo.
        cap.open(0); //Opción para webcam

        // Inicializador del clasificador facial.
        if (!faceCascade.load("haarcascade_frontalface_default.xml")) {
            qDebug() << "No se pudo cargar el clasificador de rostros.";
            ui->estado->setStyleSheet("color: red;");
            ui->estado->setText("Error con el clasificador!");
            return;
        }
        ui->estado->setStyleSheet("color: green;");
        ui->estado->setText("Algoritmo reconocimiento cargado");

        // Cargar modelo de reconocimiento facial
        faceRecognizer = cv::face::LBPHFaceRecognizer::create();
        try {
            faceRecognizer->read("modelo_lbph.xml");
        } catch (...) {
            qDebug() << "No se pudo cargar el modelo de reconocimiento.";
            ui->estado->setStyleSheet("color: red;");
            ui->estado->setText("Error cargando modelo LBPH.");
            return;
        }
        ui->estado->setStyleSheet("color: green;");
        ui->estado->setText("Reconocimiento de caras cargado");

        // Cargar labels.txt
        std::ifstream file("labels.txt");
        if (!file.is_open()) {
            qDebug() << "No se pudo abrir labels.txt";
            ui->estado->setStyleSheet("color: red;");
            ui->estado->setText("Error cargando etiquetas.");
            return;
        }
        ui->estado->setStyleSheet("color: green;");
        ui->estado->setText("Etiquetas cargadas");

        int label;
        std::string name;
        while (file >> label >> name) {
            labelToName[label] = name;
        }

        videoTimer->start(33);  // aprox 30 fps
        ui->inicio->setStyleSheet(
            "QPushButton {"
            " background-color: #28a745;"
            " color: white;"
            " border: 2px solid #1e7e34;"
            " border-radius: 5px;"
            " padding: 6px;"
            " font-weight: bold;"
            " }"
            );

        ui->estado->setStyleSheet("color: green;");
        ui->estado->setText("Detección iniciada!");
    }
    else
    {
        videoTimer->stop();

        // Reemplazamos clasificador por uno vacío.
        faceCascade = cv::CascadeClassifier();

        // Cerramos la fuente de imagen.
        cap.release();

        // Mostrar imagen estática
        mostrarImagenSinVideo();

        // Configuración de la conexión FT245
        ftStatus = FT_Close(ftHandle);
        if (ftStatus != FT_OK)
        {
            qDebug() << "Error al cerrar el dispositivo FTDI.";
            ui->estado->setStyleSheet("color: red;");
            ui->estado->setText("Error al cerrar el dispositivo FTDI!");
            return;
        }
        ui->estado->setStyleSheet("color: black;");
        ui->estado->setText("Pendiente de inicio");

        ui->inicio->setStyleSheet(
            "QPushButton {"
            " background-color: #e0e0e0;"
            " color: black;"
            " border: 2px solid #aaaaaa;"
            " border-radius: 5px;"
            " padding: 6px;"
            " font-weight: normal;"
            " }"
            );
    }

    videoEnable = !videoEnable;

    return;
}

void ViCON::on_reconocimiento_toggled(bool checked)
{
    if (!reconocimientoEnable)
    {
        // Cargar modelo de reconocimiento facial
        faceRecognizer = cv::face::LBPHFaceRecognizer::create();
        try {
            faceRecognizer->read("modelo_lbph.xml");
        } catch (...) {
            qDebug() << "No se pudo cargar el modelo de reconocimiento.";
            ui->estado->setStyleSheet("color: red;");
            ui->estado->setText("Error cargando modelo LBPH.");
            return;
        }
        ui->estado->setStyleSheet("color: green;");
        ui->estado->setText("Reconocimiento de caras cargado");
    }
    else
    {
        // Liberamos el algoritmo de reconocimiento y vaciamos el mapa de etiquetas.
        faceRecognizer.release();                       // Libera el recognizer
        labelToName.clear();                            // Vacía el mapa de etiquetas

        ui->estado->setStyleSheet("color: black;");
        ui->estado->setText("Algoritmo reconocimiento liberado");
    }

    reconocimientoEnable = checked;
}
