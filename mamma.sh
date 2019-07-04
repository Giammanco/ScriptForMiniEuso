#!/bin/bash
#
#FIRMWARE UPDATE ZYNQ
#


USB0=/media/usb0
USB1=/media/usb1
INTERNAL=/tftpboot
file1=lwip_proj.elf
file2=design_1_wrapper.bit
ardu_file=analog_sensor6.ino
input2=/home/analog_sensor6
#directory da cui far partire arduino
ardu=/home/arduino-1.8.7/arduino


#The funtion takes the boot files in usb0 then in usb1 and finally know that are
# in the internal storage
pick_file(){

    DAC=$1
    tmp1=$USB0/$DAC
    tmp2=$USB1/$DAC
    tmp3=$INTERNAL/$DAC

    if test -f "$tmp1"; then
	flag=1
        final=$tmp1
        echo $DAC' in USB0'

    elif test -f "$tmp2"; then

	flag=2
        final=$tmp2
        echo $DAC' in USB1'


    else
         echo $DAC" should be in INTERNAL storage device"
	flag=0
        final=$tmp3

    fi


}

ardu_write(){
        sudo usermod -a -G dialout $user
        sudo chmod a+rw /dev/ttyACM0
        $ardu --board arduino:avr:mega:cpu=atmega2560 --upload $1 --port /dev/ttyACM0
}


echo " "
echo "searching $file1"
pick_file $file1
echo " "

if ((flag!=0)); then

    echo "coping $final into $INTERNAL"
    cp $final $tmp3
fi
echo " "

echo "searching $file2"
pick_file $file2
echo " "
if ((flag!=0)); then

    echo "coping $final into $INTERNAL"
    cp $final $tmp3
fi
echo " "


flag=0

while((flag !=2)); do
     echo "Waiting for zynq..."
    ping  192.168.7.10 -w 1 && flag=2

done
echo "  "


echo "Now zynq is rebooting (25 sec)"
echo "reboot" | nc 192.168.7.10 23 -q 1
echo " "




#ARDUINO


user=$(whoami)


#ìl do-while scorre prima le due porte usb, finché non trova lo sketch
#ogni volta che non lo trova aumenta il contatore j, che se uguale a 2 fa caricare la versione messa sul SSD
echo " "
echo "Searching $ardu_file"
pick_file $ardu_file

if((flag==0)); then
  final=$input2/$ardu_file
fi
echo " "
echo "Uploading $final into arduino"
 ardu_write $final

echo " "

echo "Send trigger Mask"
echo " "
./SetNoTriggerMask

echo "Trigger Mask Completed"

echo "Send DAC10 Matrix"

./SetMatrixDac10


echo "DAC10 Mask Completed"

echo "Start  Mecontrol script"

./BP_Control.sh
