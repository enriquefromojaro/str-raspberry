C:: 
	gcc -c dispositivos.c; 
	gcc -c ejemplo1.c; 
	gcc -o ejemplo1 ejemplo1.o dispositivos.o -lrt -lwiringPi

ADA::
	gcc -c dispositivos.c
	gnatmake -c control1.adb
	gnatbind control1.ali
	gnatlink control1.ali dispositivos.o -lwiringPi -lrt
	
clean::
	rm *.o ejemplo1 control1

all:: C ADA
