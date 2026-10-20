#include <stdio.h>
#include "scrambler.h"

// Funzione aggiuntiva per testare la validità matematica dell'LFSR
int test_lfsr_period() {
    unsigned short start_seed = 0x1234;
    unsigned short current = start_seed;
    unsigned long count = 0;

    printf("\n--- VERIFICA PERIODO MASSIMO LFSR ---\n");
    do {
        // Simulazione esatta dell'hardware LFSR
        unsigned short lsb = current & 1;
        current >>= 1;
        if (lsb) {
            current ^= 0xB400; // Il nostro Polinomio
        }
        count++;
    } while (current != start_seed && count < 100000); // Limite di sicurezza

    printf("L'LFSR si e' ripetuto dopo %lu colpi di clock.\n", count);

    if (count == 65535) {
        printf("SUCCESSO! L'LFSR ha lunghezza massima (2^16 - 1).\n");
        return 0;
    } else {
        printf("FALLIMENTO. Il polinomio non e' ottimale.\n");
        return 1;
    }
}

void genera_dataset_matlab() {
    FILE *fp = fopen("lfsr_samples.txt", "w");
    if (fp == NULL) {
        printf("Errore nell'apertura del file!\n");
        return;
    }

    unsigned short current = 0x1234; // Il tuo Seed

    // Generiamo l'intero periodo massimo
    for(long i = 0; i < 65535; i++) {
        fprintf(fp, "%d\n", current); // Scrive il numero nel file e va a capo

        // Logica hardware
        unsigned short lsb = current & 1;
        current >>= 1;
        if (lsb) {
            current ^= 0xB400; // Il tuo Polinomio
        }
    }

    fclose(fp);
    printf("File 'lfsr_samples.txt' generato con successo per MATLAB!\n");
}

void genera_dataset_matlab_subopt() {
    FILE *fp = fopen("lfsr_samples_subottimale.txt", "w");
    if (fp == NULL) {
        printf("Errore nell'apertura del file!\n");
        return;
    }

    unsigned short current = 0x1234; // Stesso Seed di partenza
    unsigned short bad_poly = 0x0011; // UN POLINOMIO SCELTO A CASO

    // Generiamo sempre 65535 campioni per fare un confronto alla pari
    for(long i = 0; i < 65535; i++) {
        fprintf(fp, "%d\n", current);

        // Logica hardware LFSR
        unsigned short lsb = current & 1;
        current >>= 1;
        if (lsb) {
            current ^= bad_poly; // Usiamo il polinomio sbagliato!
        }
    }

    fclose(fp);
    printf("File 'lfsr_samples_subottimale.txt' generato con successo!\n");
}

int main() {
    data_t input_signal[10] = {0, 100, -200, 300, -400, 500, -600, 700, -800, 900};
    data_t encrypted_signal[10];
    data_t decrypted_signal[10];

    data_t out;
    int i;

    printf("--- SIMULAZIONE SCRAMBLER ---\n");

    // FASE 1: CRITTOGRAFIA (Simuliamo il Tx)
    printf("Inizializzazione TX con Seed...\n");
    scrambler(&out, 0, 0x1234, true); // Carico il seed 0x1234

    for(i=0; i<10; i++) {
        scrambler(&out, input_signal[i], 0, false);
        encrypted_signal[i] = out;
    }

    // FASE 2: DECRITTOGRAFIA (Simuliamo l'Rx)
    printf("Inizializzazione RX con stesso Seed...\n");
    scrambler(&out, 0, 0x1234, true); // Ricarico lo STESSO seed per decriptare

    for(i=0; i<10; i++) {
        scrambler(&out, encrypted_signal[i], 0, false);
        decrypted_signal[i] = out;
    }

    // VERIFICA SEGNALE
    int errors = 0;
    for(i=0; i<10; i++) {
        printf("In: %5d | Criptato: %6d | Decriptato: %5d\n",
               input_signal[i], encrypted_signal[i], decrypted_signal[i]);

        if(input_signal[i] != decrypted_signal[i]) {
            errors++;
        }
    }

    // ESECUZIONE TEST MATEMATICO LFSR
    int period_errors = test_lfsr_period();

    // GENERAZIONE DATASET PER MATLAB
        genera_dataset_matlab();

    // GENERAZIONE DATASET SUB-OTTIMALE PER MATLAB
        genera_dataset_matlab_subopt();

        // RISULTATO FINALE (HLS richiede che il main ritorni 0 per passare)
        if (errors == 0 && period_errors == 0) {
            printf("\nTEST COMPLETO SUPERATO CON SUCCESSO!\n");
            return 0;
        } else {
            printf("\nERRORE DURANTE I TEST!\n");
            return 1;
        }
}
