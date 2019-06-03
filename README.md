# 2019_BluetoothLamp

<img align="left" src="https://i.imgur.com/ZvV5VV3.png" width="400"/>

## About
Project of smart RGB lamp controlled by iOS app using Bluetooth Low Energy. 

In addition to the usual color change, it also offers the option of setting an alarm for a specific time and a music mode that dynamically changes the color and brightness of the lamp depending on the song frequency and amplitude.

## Software
Our project consists of both STM32 application and iOS app.

## Hardware
1. STM32F407G-DISC1,
2. 2x8 LED WS2812b ring,
3. Bluetooth module 4.0 BLE - HM-10 - 3,3V/5V.

## Tools 
1. STM32CubeMX,
2. System Workbench for STM32,
3. ST-LinkUpgrade,
4. [WS2812b STM32 HAL Library](https://github.com/lamik/WS2812B_STM32_HAL) - adjusted to our needs.

## How to run 
Plug the power adapter into a power outlet. Connect with lamp by app and turn it on.

## How to compile 
- Clone, compile project to STM32F4 Discovery.
- Connect all pins correctly:
USART6_RX - PC7
USART6_TX - PC6
SPI1_SCK - PA5
SPI1_MOSI - PA7


## Attributions 
- WS2812b communicaton inspiration : https://msalamon.pl/adresowalne-diody-ws2812b-na-stm32-cz-1/

# License
licence: MIT

## Credits
Robert Moryson
Robert Molenda
 
The project was conducted during the Microprocessor Lab course held by the Institute of Control and Information Engineering, Poznan University of Technology. Supervisor: Tomasz Mańkowski.
