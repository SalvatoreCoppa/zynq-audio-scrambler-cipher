#include "scrambler.h"

void scrambler(data_t *y, data_t x, seed_t seed, bool load_seed) {
    // Direttive HLS per creare i registri AXI-Lite
    #pragma HLS INTERFACE mode=s_axilite bundle=scrambler_io port=return
    #pragma HLS INTERFACE mode=s_axilite bundle=scrambler_io port=x
    #pragma HLS INTERFACE mode=s_axilite bundle=scrambler_io port=y
    #pragma HLS INTERFACE mode=s_axilite bundle=scrambler_io port=seed
    #pragma HLS INTERFACE mode=s_axilite bundle=scrambler_io port=load_seed

    // Lo stato interno deve essere 'static' per conservare il valore tra le chiamate
    // Inizializzato a un valore non zero (l'LFSR si blocca se è 0)
    static seed_t lfsr_state = 0xACE1;

    // Se il processore ARM ci dice di caricare un nuovo seed, resettiamo l'LFSR
    if (load_seed) {
        if (seed == 0) {
            lfsr_state = 0xACE1; // Protezione: il seed non può mai essere 0
        } else {
            lfsr_state = seed;
        }
    }

    // 1. Calcolo del prossimo numero pseudo-casuale (Galois LFSR a 16 bit)
    unsigned short lsb = lfsr_state & 1; // Prende il bit meno significativo
    lfsr_state >>= 1;                    // Shift a destra
    if (lsb) {
        lfsr_state ^= 0xB400;            // Operazione XOR con il polinomio (Tap 16, 14, 13, 11)
    }

    // 2. Crittografia/Decrittografia: XOR tra il campione audio e il numero casuale
    *y = x ^ (data_t)lfsr_state;
}
