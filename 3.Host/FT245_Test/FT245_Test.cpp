#include <windows.h>
#include <iostream>
#include "./Includes/FTD2XX.h"  // Incluye la librería D2XX de FTDI

#define FT_BITMODE_SYNC_FIFO 0x40

int main(void)
{
    FT_HANDLE ftHandle;
    FT_STATUS ftStatus;
    DWORD bytesWritten, bytesRead;
    UCHAR txByte = 0;  // Byte para enviar (empezando en 0)
    UCHAR rxByte = 0;  // Byte recibido
    bool communicationOK = true;

    // Abrir el dispositivo FT245 utilizando la librería D2XX
    ftStatus = FT_Open(0, &ftHandle);  // Abrir el primer dispositivo encontrado
    if (ftStatus != FT_OK) {
        std::cerr << "Error al abrir el dispositivo FT245" << std::endl;
        return 1;
    }

    // Configurar el FT245 para comunicación síncrona
    FT_SetBitMode(ftHandle, 0xFF, FT_BITMODE_SYNC_FIFO);

    // Bucle infinito para enviar y recibir datos
    while (communicationOK) {
        // Enviar el byte actual a la FPGA
        ftStatus = FT_Write(ftHandle, &txByte, 1, &bytesWritten);
        if (ftStatus != FT_OK || bytesWritten != 1) {
            std::cerr << "Error al enviar el byte: " << (int)txByte << std::endl;
            communicationOK = false;
            break;
        }

        // Esperar a recibir el byte desde la FPGA
        ftStatus = FT_Read(ftHandle, &rxByte, 1, &bytesRead);
        if (ftStatus != FT_OK || bytesRead != 1) {
            std::cerr << "Error al recibir el byte" << std::endl;
            communicationOK = false;
            break;
        }

        // Verificar que el byte recibido es igual al enviado
        if (rxByte == txByte) {
            std::cout << "Éxito: enviado = " << (int)txByte << ", recibido = " << (int)rxByte << std::endl;
        } else {
            std::cerr << "Error: enviado = " << (int)txByte << ", recibido = " << (int)rxByte << std::endl;
            communicationOK = false;
            break;
        }

        // Incrementar el byte a enviar y manejar el desbordamiento
        txByte = (txByte + 1) % 256;  // Reiniciar a 0 cuando llega a 256
    }

    // Cerrar el dispositivo FT245
    FT_Close(ftHandle);
    return 0;
}