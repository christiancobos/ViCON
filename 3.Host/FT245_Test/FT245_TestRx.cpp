#include <windows.h>
#include <iostream>
#include "./Includes/FTD2XX.h"  // Incluye la librería D2XX de FTDI

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

    FT_ResetDevice(ftHandle);

    UCHAR bitMode;

    ftStatus = FT_GetBitMode(ftHandle, &bitMode);
    if (ftStatus != FT_OK) {
        std::cerr << "Error al obtener el bit mode del dispositivo" << std::endl;
        FT_Close(ftHandle);
        return 1;
    }

    // 3. Imprimir el bit mode en hexadecimal
    std::cout << "Bit mode actual: 0x" << std::hex << static_cast<int>(bitMode) << std::endl;

    // Bucle infinito para enviar y recibir datos
    while (communicationOK) {
        // Enviar el byte actual a la FPGA
        ftStatus = FT_Write(ftHandle, &txByte, 1, &bytesWritten);
        if (ftStatus != FT_OK || bytesWritten != 1) {
            std::cerr << "Error al enviar el byte: " << (int)txByte << std::endl;
            communicationOK = false;
            break;
        }

        printf ("Enviado byte: %x\n", (int)txByte);

        // Esperamos 1 segundo antes de volver a leer
        Sleep(1000);  // Esperar 1 segundo (1000 ms)

        // Incrementar el byte a enviar y manejar el desbordamiento
        txByte = (txByte + 1) % 256;  // Reiniciar a 0 cuando llega a 256
    }

    // Cerrar el dispositivo FT245
    FT_Close(ftHandle);
    return 0;
}