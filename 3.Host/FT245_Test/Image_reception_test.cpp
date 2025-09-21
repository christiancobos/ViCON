#include <iostream>
#include <vector>
#include <windows.h>
#include "FTD2XX.H"
#include <opencv2/opencv.hpp>

#include <fstream>
#include <iomanip>
#include <sstream>

#define FRAME_WIDTH 640
#define FRAME_HEIGHT 480
#define BYTES_PER_PIXEL 2
#define FRAME_SIZE (FRAME_WIDTH * FRAME_HEIGHT * BYTES_PER_PIXEL)

bool sendRequest(FT_HANDLE ftHandle) {
    BYTE controlByte = 0xA5;
    DWORD bytesWritten;
    FT_STATUS ftStatus = FT_Write(ftHandle, &controlByte, 1, &bytesWritten);
    return (ftStatus == FT_OK && bytesWritten == 1);
}

bool receiveFrameLineByLine(FT_HANDLE ftHandle, std::vector<BYTE>& buffer) {
    constexpr size_t LINE_SIZE = FRAME_WIDTH * BYTES_PER_PIXEL;
    constexpr size_t LINE_TOTAL = LINE_SIZE + 1; // +2 bytes a descartar

    DWORD bytesRead;
    FT_STATUS ftStatus;

    buffer.clear();
    buffer.reserve(FRAME_SIZE);

    for (size_t line = 0; line < FRAME_HEIGHT; ++line) {
        std::vector<BYTE> fullLineBuffer(LINE_TOTAL ); // espacio para línea completa

        ftStatus = FT_Read(ftHandle, fullLineBuffer.data(), LINE_TOTAL, &bytesRead);
        if (ftStatus != FT_OK || bytesRead != LINE_TOTAL) {
            std::cerr << "Error leyendo línea " << line
                      << ": esperados " << LINE_TOTAL
                      << " bytes, recibidos " << bytesRead << "\n";
            return false;
        }

        // Descartar los dos primeros bytes (posibles códigos de sincronización)
        buffer.insert(buffer.end(), fullLineBuffer.begin(), fullLineBuffer.end() -1 );
    }

    return true;
}

cv::Mat convertYUV422toBGR(const std::vector<BYTE>& yuv) 
{
    // Crear imagen fuente desde el buffer crudo (UYVY → 2 bytes por píxel)
    cv::Mat yuv422(FRAME_HEIGHT, FRAME_WIDTH, CV_8UC2, const_cast<BYTE*>(yuv.data()));

    // Convertir automáticamente con OpenCV
    cv::Mat bgrImage;
    cv::cvtColor(yuv422, bgrImage, cv::COLOR_YUV2BGR_Y422);

    return bgrImage;
}


cv::Mat convertYUV422toGrayscale(const std::vector<BYTE>& yuv) {
    cv::Mat grayImage(FRAME_HEIGHT, FRAME_WIDTH, CV_8UC1);

    for (int row = 0; row < FRAME_HEIGHT; row++) {
        for (int col = 0; col < FRAME_WIDTH; col += 2) {
            int i = (row * FRAME_WIDTH + col) * 2;
            if (i + 3 >= yuv.size()) continue; // Seguridad ante overflows

            uint8_t y0 = yuv[i + 1];
            uint8_t y1 = yuv[i + 3];

            grayImage.at<uint8_t>(row, col)     = y0;
            grayImage.at<uint8_t>(row, col + 1) = y1;
        }
    }

    return grayImage;
}

int main() {
    FT_HANDLE ftHandle;
    FT_STATUS ftStatus;

    ftStatus = FT_OpenEx((PVOID)"UM232H-B", FT_OPEN_BY_DESCRIPTION, &ftHandle);
    if (ftStatus != FT_OK) {
        std::cerr << "No se pudo abrir el dispositivo FTDI.\n";
        return -1;
    }

    if (!sendRequest(ftHandle)) {
        std::cerr << "Error enviando byte de control.\n";
        FT_Close(ftHandle);
        return -1;
    }

    std::cout << "Solicitud enviada. Esperando frame...\n";

    std::vector<BYTE> yuvBuffer;
    if (!receiveFrameLineByLine(ftHandle, yuvBuffer)) {
        std::cerr << "Error recibiendo datos de imagen.\n";
        FT_Close(ftHandle);
        return -1;
    }

    // Mostrar en gris
    cv::Mat frame = convertYUV422toBGR(yuvBuffer);
    cv::imshow("Imagen desde FPGA", frame);
    cv::waitKey(0);

    std::cout << "Dimensiones de la imagen: "
              << frame.cols << " x " << frame.rows << " (ancho x alto)\n";

    FT_Close(ftHandle);
    return 0;
}
