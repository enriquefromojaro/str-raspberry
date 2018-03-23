#include <stdio.h>    // Used for printf() statements
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdint.h>
#include <wiringPi.h> // Include WiringPi library!

#include <time.h>

// #define TRUE 1
// #define FALSE 0

int Inicializar_dispositivos ();

int analogRead(int pin);
int Leer_Todos_Los_Sensores (int valores[]);

int Poner_Led_Rojo (int Valor_led);
int Poner_Led_Verde (int Valor_led);

int Leer_Pulsador ();

int Sensor_infrarrojos ();

int activa_trigger (int Valor_trig);

int lee_echo ();

int Mover_Servo (int posicion);

int Cerrar_Dispositivos ();

