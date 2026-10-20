#ifndef SCRAMBLER_H
#define SCRAMBLER_H

#include <stdbool.h>

// I campioni audio sono a 16-bit
typedef short data_t;

// La chiave del nostro generatore pseudo-casuale è a 16-bit
typedef unsigned short seed_t;

// Prototipo della funzione
void scrambler(data_t *y, data_t x, seed_t seed, bool load_seed);

#endif
