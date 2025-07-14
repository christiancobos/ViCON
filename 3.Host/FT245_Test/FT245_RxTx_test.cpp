#include <windows.h>
#include <iostream>
#include "./Includes/FTD2XX.h"  // Incluye la librería D2XX de FTDI

using namespace std;

int main(void)
{
FT_HANDLE ftHandle;
    FT_STATUS ftStatus;
    DWORD bytesWritten, bytesRead;
    UCHAR txByte = 7;  // Byte para enviar (empezando en 0)
    //UCHAR rxByte = 0;  // Byte recibido
    const DWORD BUFFER_SIZE = 4096; // Tamaño del buffer de lectura
    unsigned char buffer[BUFFER_SIZE];
    bool communicationOK = true;

    // Abrir el dispositivo FT245 utilizando la librería D2XX
    ftStatus = FT_Open(0, &ftHandle);  // Abrir el primer dispositivo encontrado
    if (ftStatus != FT_OK) {
        std::cerr << "Error al abrir el dispositivo FT245" << std::endl;
        return 1;
    }

    // Bucle infinito para enviar y recibir datos
    while (communicationOK) {
        // Enviar el byte actual a la FPGA
        ftStatus = FT_Write(ftHandle, &txByte, 1, &bytesWritten);
        if (ftStatus != FT_OK || bytesWritten != 1) {
            cerr << "Error al enviar el byte: " << (int)txByte << endl;
            communicationOK = false;
            break;
        }

        printf ("Enviado byte: %x\n", (int)txByte);

        Sleep(10);  // Esperar 10 ms para permitir que la FPGA procese el byte

        // Leer el byte de vuelta desde la FPGA
        ftStatus = FT_Read(ftHandle, &buffer, 2, &bytesRead);

        // Verificar si el byte recibido es el mismo que se envió
        if (ftStatus != FT_OK || bytesRead != 2) {
            cerr << "Error al recibir el byte" << endl;
            communicationOK = false;
            break;
        }
        if (buffer[0] != txByte) {
            cerr << "Byte recibido no coincide con el enviado. Enviado: "
                      << (int)txByte << ", Recibido: " << (int)buffer[0] << endl;
            //communicationOK = false;
            //break;
        }


        // Esperamos 1 segundo antes de volver a mandar
        Sleep(1000);  // Esperar 1 segundo (1000 ms)

        // Incrementar el byte a enviar y manejar el desbordamiento
        txByte = (txByte + 1) % 256;  // Reiniciar a 0 cuando llega a 256
    }

    // Cerrar el dispositivo FT245
    FT_Close(ftHandle);
    return 0;
}
