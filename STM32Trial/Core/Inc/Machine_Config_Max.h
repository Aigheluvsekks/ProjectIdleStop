#ifndef MACHINE_CONFIG_MAX_H
#define MACHINE_CONFIG_MAX_H

/*
 * Mendefinisikan batas operasional normal untuk masing-masing parameter
 * yang ditinjau. Masing-masing parameter diukur dengan satuan standar yang sesuai
 * dan ada pada Shop Manual Exca
 *
 * Nama Variabel tidak boleh diganti, value dari parameter boleh diganti
 *
 * Variabel digunakan untuk mendeteksi apakah data hasil
 */

/* Replace these numbers with the actual values from your Shop Manual */
#define RPM_MAX 4000
#define RPM_MIN 0

#define SWING_PRESS_MAX 350
#define SWING_PRESS_MIN 0

#define BOOMD_PRESS_MAX 350
#define BOOMD_PRESS_MIN 0

#define BOOMUP_PRESS_MAX 350
#define BOOMUP_PRESS_MIN 0

#define ARMDIG_PRESS_MAX 350
#define ARMDIG_PRESS_MIN 0

#define BUCKETDUMP_PRESS_MAX 350
#define BUCKETDUMP_PRESS_MIN 0

#define TRAVEL_PRESS_MAX 350
#define TRAVEL_PRESS_MIN 0

#endif
