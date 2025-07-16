#include <windows.h>
#include <iostream>
#include <chrono>
#include "./Includes/ftd2xx.h"  // Incluye la librería D2XX de FTDI

using namespace std;

int main() {
    FT_HANDLE ftHandle;
    FT_STATUS ftStatus;
    DWORD bytesRead;
    const DWORD BUFFER_SIZE = 4096; // Tamaño del buffer de lectura
    unsigned char buffer[BUFFER_SIZE];

    // Abrir el primer dispositivo FTDI
    ftStatus = FT_Open(0, &ftHandle);
    if (ftStatus != FT_OK) {
        cerr << "Error abriendo el dispositivo FTDI: " << ftStatus << endl;
        return 1;
    }

    cout << "Comenzando prueba de throughput...\n";

    unsigned char expectedValue = 0;
    size_t totalBytes = 0;
    size_t errors = 0;
    bool started = false;
    auto start = chrono::high_resolution_clock::now();
    const double duration_sec = 15.0; // duración de la prueba

    while (true) {
        auto now = chrono::high_resolution_clock::now();

        // Si ya hemos empezado a contar tiempo, verifica si debemos terminar
        if (started) {
            double elapsed = chrono::duration<double>(now - start).count();
            if (elapsed >= duration_sec) break;
        }

        ftStatus = FT_Read(ftHandle, buffer, BUFFER_SIZE, &bytesRead);
        if (ftStatus != FT_OK) {
            cerr << "Error de lectura: " << ftStatus << std::endl;
            break;
        }

        if (bytesRead > 0 && !started) {
            start = chrono::high_resolution_clock::now(); // inicio real
            started = true;
            cout << "Primer dato recibido. Iniciando medición...\n";
        }

        for (DWORD i = 0; i < bytesRead; ++i) {
            if (buffer[i] != expectedValue) {
                cerr << "Dato incorrecto. Esperado: " << (int)expectedValue
                          << ", recibido: " << (int)buffer[i] << endl;
                errors++;
                expectedValue = buffer[i]; // resync
            }
            expectedValue++;
            expectedValue = (expectedValue == 256) ? 0 : expectedValue; // wrap around
        }

        totalBytes += bytesRead;
    }

    double throughput = (double)totalBytes / duration_sec;
    cout << "\n--- Resultados ---\n";
    cout << "Total de bytes recibidos: " << totalBytes << endl;
    cout << "Errores de sincronización: " << errors << endl;
    cout << "Throughput: " << throughput << " B/s (" << (throughput/ 1e6) << " MB/s)" << endl;

    FT_Close(ftHandle);
    return 0;
}
