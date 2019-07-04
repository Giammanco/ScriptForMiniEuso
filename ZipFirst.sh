#!/bin/bash

DIR_b=/media/usb0       #Directory for data file to be stored and for mecontrol staff
IS_DAY=is_day.txt       #File where mecontrol write 1 when is day, 0 when is nigth
FERTIG=FERTIG
FERTIG_PART=FERTIG1

NFILES=11               #number files to zip ina single time two times

SLEEP_TIME=10 #600       #The script controls every SLEEP_TIME if is day or night



###############################################################################

function ZIP_CORE

        {

        echo 'Zipping a data package'
        startziptime=$(date +%s)

        #find all file *.dat in usb 0 take the fisrt NFILES names and write them
        #into a list.
		find $DIR_b -maxdepth 1 -type f -name '*.dat'| head -$((2*NFILES))  >  $DIR_b/toTarGzALL.txt

        if test ! -f "$FERTIG_PART"; then

            sed -n "1,$((NFILES))p"  $DIR_b/toTarGzALL.txt > $DIR_b/toTarGz.txt

            echo 'primo'

        else

            sed -n "$((NFILES+1)),$((2*NFILES))p" $DIR_b/toTarGzALL.txt > $DIR_b/toTarGz.txt

            echo 'secondo'

        fi



        # if the list has (should be equal NFILES elements then it starts zipping
        # operation.
        nin=$(wc -l < $DIR_b/toTarGz.txt)

        if ((nin >=NFILES)); then

            find $DIR_b -maxdepth 2 -type f -name '*.log' >>  $DIR_b/toTarGz.txt
           	#take time to generate a filename
		    now4name=$(date +"%Y_%m_%d__%H_%M_%S")

		    echo "Writing $DIR_b/$now4name.tar.gz"

		    tar -czf "$DIR_b/$now4name.tar.gz" -T "$DIR_b/toTarGz.txt"

            #write a file to prevent new zip operation

            if test ! -f "$FERTIG_PART"; then
               echo "this is a flag to prevent new zipping operation" >$FERTIG_PART
               endziptime=$(date +%s)
               echo "time spent to zip [s] :" $((endziptime-startziptime))
               return
            else
               echo "this is a flag to prevent new zipping operation" >$FERTIG

               endziptime=$(date +%s)
               echo "time spent to zip [s] :" $((endziptime-startziptime))
               exit 0
            fi
       else

            echo 'Not enought packages waiting for the next check...'
            return

        fi

    }

################################################
    echo 'ZipFirst started'

    #inizializing ZipDemon
    IS_DAY=$DIR_b/$IS_DAY
    FERTIG=$DIR_b/$FERTIG
    FERTIG_PART=$DIR_b/$FERTIG_PART




    #if FERTIG doesn't exist the operation can be done
    #if it esxist it means that files have been already zipped
    if test ! -f "$FERTIG"; then


        #if is_day.txt doen't exist it generates the file

        if test ! -f "$IS_DAY" ; then

            echo "1">$IS_DAY
        fi

        #main infinite loop
        while((1)); do

            #when flag is 1 it means that is local day, when 2 is local night
            read flag<$IS_DAY

            if ((flag==1)); then

              ZIP_CORE

            fi


            sleep $SLEEP_TIME

        done

    else

        echo "Already done"

    fi
