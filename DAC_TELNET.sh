#!/bin/bash



SL_T=0.01 #sleep time after every command sent by telnet

USB0=/media/usb0
USB1=/media/usb1
INTERNAL=/home/minieusouser
DAC7=dac7.txt
DAC10=dac10.txt
IPZYNC=192.168.7.10

#The funtion takes the conbfiguration files in usb0 then in usb1 and finally
# in the internal storage
pick_file(){

    DAC=$1
    tmp1=$USB0/$DAC
    tmp2=$USB1/$DAC
    tmp3=$INTERNAL/$DAC

    if test -f "$tmp1"; then

        final=$tmp1
        echo $DAC' in USB0'

    elif test -f "$tmp2"; then


        final=$tmp2
        echo $DAC' in USB1'

    elif test -f "$tmp3"; then

        final=$tmp3
        echo $DAC' in INTERNAL storage device'
    else

        echo 'NO $ms_str FILE FOUND'
        final=0

    fi


}

send_t(){
pick_file $DAC7
DAC7=$final


pick_file $DAC10
DAC10=$final



#read matrix for dac7
while read line; do
    IFS=' ' dac7+=(${line})
done < $DAC7


echo ${dac7[0]}
echo ${dac7[48]}
echo ${dac7[96]}
echo ${dac7[$((48*3))]}
echo ${dac7[$((48*4))]}
echo lunghezza ${#dac7[@]}
echo ${dac7[2303]}


#read matrix for dac10
while read line; do
#inserire asterischi per gli
    IFS=' ' dac10+=(${line})
done < $DAC10

echo ${dac10[0]}
echo ${dac10[48]}
echo ${dac10[96]}
echo ${dac10[$((48*3))]}
echo ${dac10[$((48*4))]}
echo lunghezza ${#dac10[@]}
echo ${dac10[2303]}

(echo open $IPZYNC

    sleep $SL_T


    for ((board=0; board <6; board++)); do

        echo "slowctrl line $board"
        sleep $SL_T


        for ((asic=0; asic<6; asic++)); do

            echo "slowctrl asic $asic"
            sleep $SL_T


            for ((pixel=0; pixel<64; pixel++)); do
            #pixel is the sequential index number of a pixel inside to  [board, asic] matrix
            #x,y are the  x, y indices for a pixel inside to [board, asic] matrix
            #X,Y are the coordinate of a pixel inside to the general big matrix
            #index is the index of a pixel inside to the general big matrix

                x=$((pixel/8))
                y=$((pixel-x*8))
                X=$((board*8+x))
                Y=$((asic*8+y))
                index=$((X*48+Y))

               echo "slowctrl pixel $pixel"
               sleep $SL_T


                echo "slowctrl dac7 ${dac7[$index]}"
                sleep $SL_T


                echo "slowctrl dac10 ${dac10[$index]}"
                sleep $SL_T


                #echo $board, $asic, $pixel ,$x, $y,$X,$Y, $index, ${dac7[$index]}, ${dac10[$index]}
              done

             echo "slowctrl apply"
             sleep $SL_T
        done
    done
)| telnet

}

send_t>/media/usb0/dac_telnet.log

echo "check dac_telnet.log"

