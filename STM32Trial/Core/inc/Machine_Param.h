#ifndef MACHINE_CONFIG_H
#define MACHINE_CONFIG_H

/*
 * Berisi pendefinisian threshold / batasan untuk masing-masing komponen.
 * Batasan digunakan untuk mendeskripsikan batasan atas / batas maksimum
 * alat dapat dikategorikan sebagai idle.
 * Jika alat beroperasi di atas threshold, maka dianggap bekerja
 *
 * Dimohon untuk tidak mengubah semua parameter yang ada kecuali nilai dari
 * fix variabelnya.
 *
 * Dilarang keras untuk mengganti nama dan convention variable
 * karena parameter digunakan untuk code lain, terima kasih.
 */

#define RPM_WORK_THRESH 1100
/* ((iN CASE SWING R DAN SWING L BEDA))
 * #define SWINGL_PRESS_THRESH
 * #define SWINGR_PRESS_THRESH
 */
#define SWING_PRESS_THRESH 10


//Fix Param untuk Boom Down dan Boom Up (In case Beda)
#define BOOMD_PRESS_THRESH 10
#define BOOMUP_PRESS_THRESH 10

/*
 * Jika Boom down dan Boom Up sama, gunakan
 * #define BOOM_PRESS_THRESH
 */

#define ARMDIG_PRESS_THRESH 10
#define BUCKETDUMP_PRESS_THRESH 10

#define TRAVEL_PRESS_THRESH 10

#endif
