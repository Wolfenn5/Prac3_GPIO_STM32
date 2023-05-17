
# Practica  'Lab5' Configuracion de puertos GPIO


# Funcionamiento de la implementacion

En esta practica se modifico el archivo blink.s para que ahora enciendan diez LED conectados a los puertos GPIO del µC (blue pill stm32f103c8t6). 

Los LED muestran el valor binario de una variable. Si se
oprime un push button A, entonces se incrementa el valor
de la variable en una unidad. Si se oprime un push button B,
entonces el valor de la variable se decrementa. Si se
oprimen los dos botones, entonces el valor de la variable se reinicia a 0.


# Calidad de la implementación

Debido a que el archivo blink.s no sigue convenciones de compilacion se utilizo marcos de funcion y el correcto respaldo de argumentos 

# Documentación

-Funcionamiento del Proyecto: Encendido de 10 LED con un valor binario de 0 a 10 con 2 botones push button para incremento y decremento, al pulsar ambos botones el valor de la variable se reinicia a 0.

-Compilacion del software: En una distribucion de linux basada en ubuntu se procedio  a instalar los siguientes paquetes con el comando "sudo apt install gcc-arm-none-eabi stlink-tools
libusb-1.0-0-dev" :


    gcc-arm-none-eabi. Este es el compilador cruzado que permite generar código máquina para microcontroladores.

    stlink-tools. Este paquete contiene las utilizadas que permiten grabar un microcontrolador STM32 mediante el dispositivo ST-Link V2.

    libusb-1.0-0-dev. Este paquete contiene los controladores que permiten detectar la conexión con el ST-Link V2.

Posteriormente se establecieron alias para no emplear comandos verbosos(utilizando visual studio) de la siguiente manera:

    cd $HOME. Esta instruccion cambia el directorio a HOME donde se localiza bash

    code .bashrc. Esta instruccion abre el bash para establecer los alias


Alias a establecer:

    alias arm-gcc=arm-none-eabi-gcc

    alias arm-as=arm-none-eabi-as

    alias arm-objdump=arm-none-eabi-objdump

    alias arm-objcopy=arm-none-eabi-objcopy



Una vez establecidos los alias se utilizaron los siguientes comandos:

    lsusb. Sirve para verificar si reconoce el µC

    st-flash read dummy.bin 0 0xFFFF. Sirve para comprobar si puede leerse

    arm-as archivo.s -o archivo.o. Sirve para ensamblar el archivo.s (ensamble) y convertirlo a un archivo.o (objeto) 

    arm-objcopy -O binary archivo.o archivo.bin. Sirve para convertir el archivo.o (objeto) a un archivo.bin (binario)

    st-flash write ‘archivo.bin’  0x8000000. Sirve para escribir el archivio.bin (binario) al µC
Marco de funcion delay 

    desperdicio 28
    desperdico 24
    j 20
    i 16
    desperdiciado 12
    ms 8
    lr 4
    r7 0

Marco de funcion reset
    desperdiciado 12
    val 8
    lr 4
    r7 0

Diagrama de la placa
![Logo](https://i.ibb.co/HFBQ2h1/Diagrama-STM32.png[/img][/url])

