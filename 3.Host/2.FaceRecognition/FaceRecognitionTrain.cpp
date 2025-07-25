#include <opencv2/opencv.hpp>
#include <opencv2/face.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/objdetect.hpp>
#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <filesystem>

namespace fs = std::filesystem;
using namespace cv;
using namespace cv::face;
using namespace std;

int main() {
    const string dataset_path = "dataset/";
    const string cascade_path = "./haarcascade_frontalface_default.xml";

    CascadeClassifier faceCascade;
    if (!faceCascade.load(cascade_path)) {
        cerr << "No se pudo cargar el clasificador Haar: " << cascade_path << endl;
        return -1;
    }

    vector<Mat> images;
    vector<int> labels;
    map<int, string> labelToName;
    map<string, int> nameToLabel;

    int currentLabel = 0;

    for (const auto& person_dir : fs::directory_iterator(dataset_path)) {
        if (!person_dir.is_directory()) continue;
        string name = person_dir.path().filename().string();

        labelToName[currentLabel] = name;
        nameToLabel[name] = currentLabel;

        for (const auto& image_file : fs::directory_iterator(person_dir)) {
            Mat imgGray = imread(image_file.path().string(), IMREAD_GRAYSCALE);
            if (imgGray.empty()) {
                cerr << "Imagen no válida: " << image_file.path() << endl;
                continue;
            }

            vector<Rect> faces;
            faceCascade.detectMultiScale(imgGray, faces, 1.1, 4, 0, Size(100, 100));

            if (faces.empty()) {
                cerr << "No se detectó ninguna cara en: " << image_file.path() << endl;
                continue;
            }

            // Asegura que el recorte esté dentro de límites
            Rect face = faces[0] & Rect(0, 0, imgGray.cols, imgGray.rows);
            Mat faceROI = imgGray(face);

            resize(faceROI, faceROI, Size(200, 200));
            images.push_back(faceROI);
            labels.push_back(currentLabel);

            // Mostrar para depuración (opcional)
            //imshow("Face", faceROI);
            //waitKey(50);
        }

        currentLabel++;
    }

    if (images.empty()) {
        cerr << "No se encontraron imágenes válidas con caras detectadas." << endl;
        return -1;
    }

    Ptr<LBPHFaceRecognizer> model = LBPHFaceRecognizer::create();
    model->train(images, labels);
    model->save("modelo_lbph.xml");
    cout << "Modelo entrenado y guardado como modelo_lbph.xml" << endl;

    ofstream labelFile("labels.txt");
    if (!labelFile.is_open()) {
        cerr << "No se pudo crear el archivo labels.txt" << endl;
        return -1;
    }

    for (const auto& [label, name] : labelToName) {
        labelFile << label << " " << name << "\n";
    }

    labelFile.close();
    cout << "Etiquetas guardadas en labels.txt" << endl;

    return 0;
}