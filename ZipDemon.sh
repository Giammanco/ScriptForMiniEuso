#!/bin/bash

DIR_b=/media/usb0        #Directory for data file to be stored and for mecontrol staff
IS_DAY=is_day.txt        #File where mecontrol write 1 when is day, 0 when is nigth
DELAY=864                #determine how much data seconds are  zipped together
                         #864 are 14.4 minutes, it is almost 0.8 GB data

SECURE_DT=225           #If are left less than  SECURE_DT to the next night
                        # the script sleeps
SLEEP_TIME=1 #600          #The script controls every SLEEP_TIME if is day or night

T=2700                      #2700s , 45 min is the time long of a night

###############################################################################

function ZIP_CORE

        {

        echo 'Zipping a data package'
        startziptime=$(date +%s)
        #write time in readable way for -newermt option
		start_date=$(date -d @$start_time  +"%m/%d/%Y  %H:%M:%S")
		end_date=$(date -d @$end_time  +"%m/%d/%Y  %H:%M:%S")
#echo $start_time  $end_time $((end_time-start_time))

        #find all file creted betweem the specified data excluding  *.tar.*
        #extension
		find $DIR_b -maxdepth 3 -newermt "$start_date"  ! -newermt "$end_date"  -not \( -name '*.tar.*' -or -name 'toTarGz.txt' -or -type d \) ! -path $DIR_b  >  $DIR_b/toTarGz.txt


       	#take time to generate a filename
		now4name=$(date +"%Y_%m_%d__%H_%M_%S") ####################
        sleep 1s ################################################
		echo "$now4name"

        if ( [ -s "$DIR_b/toTarGz.txt" ]); then
		    tar -czf "$DIR_b/$now4name.tar.gz" -T "$DIR_b/toTarGz.txt"
		fi

        #determine the new start and end time for the file to be stored
		start_time=$((end_time+1))
		end_time=$((start_time+DELAY))
#echo $start_time  $end_time $((end_time-start_time))

        #Calculate how long take the tar gz
        endziptime=$(date +%s)
        totalziptime=$((endziptime-startziptime))
        totalziptime=$((totalziptime/60))
        echo 'time to zip [min] ' $totalziptime


        #check if it is day. If it is an indeterminate state (3), it will check
        #until to have an answer: 0 night, 1 day
        flag=3
        while((flag==3)); do
            read flag<$IS_DAY
            sleep 3
        done

        #calculate how much time is left to the next night
        #time for the next night is start_day_time+90 minutes (5400 seconds)
        #start_day_time=$(stat -c %Y $IS_DAY) #non rileggere
        now=$(date +%s)
        dt=$((start_day_time+T-now))


#echo $start_time  $end_time $((end_time-start_time))
    return
    }

################################################
    echo 'ZipDemon started'

    #inizializing ZipDemon
    IS_DAY=$DIR_b/$IS_DAY

    #if is_day.txt doen't exist it generates the file
    #in such a way that the time stamp of the new file will be read
    #and no zip operation will be perfomed: fstart=0

    start_time=$(date +%s)
    start_day_time=$start_time
    fstart=0


     if test ! -f "$IS_DAY"; then

        echo '1'>$IS_DAY
        flag_old=2

     else
        flag_old=1
     fi



    #when flag2 is 1 all data related to the last night are been zipped
    flag2=0


#main infinite loop
while((1)); do
#echo $flag2

    #when flag is 1 it means that is local day, when 0 is local night
    read flag<$IS_DAY

    #Since every time that mecontrol starts, it writes in is_day.txt, and the time
    #stamp of the file is used to set the temporal interval of data to be zipped
    #it is necessary to check flag_old, in such a way that the time stamp is saved only
    #if the status is really changed.
    if (((flag==1) && (flag_old==2)))

    #When mecontrol says that it is day  and before was night the start_day_time is saved,
    #when mecontrol says that it is night and before was day start_time is saved.
    #One supposes that all data to be conpressed are between
    #strat_time and start_day_time this interval should be the last night
    then
        start_day_time=$(stat -c %Y $IS_DAY)
        flag_old=1
        #echo 'flag '$flag
        #echo 'flag2 '$flag2
        #echo 'start day'$start_day_time
        #echo 'start time'$start_time

     elif (((flag==2) && (flag_old==1))); then
        start_time=$(stat -c %Y $IS_DAY)
        flag2=0
        flag_old=2
        fstart=1
        #echo 'flag '$flag
        #echo 'flag2 '$flag2
        #echo 'start day'$start_day_time
        #echo 'start time'$start_time
        #echo 'notte'
    fi

    #end time for the first data  to be zipped together
    end_time=$((start_time+DELAY))
    #echo 'end time '$end_time

    #calculate how much time is left before the next night
    now=$(date +%s)
    dt=$((start_day_time+T-now))

    #echo 'dt '$dt
    #The data created after start_day_time are day immages, we don't zip them!
    #if it is night flag==2 : we zip only during the day
    #if SECURE_DT is left to the next night we don't zip not even
    while (( (end_time  <=  start_day_time) && \
            (flag==1) && (dt> SECURE_DT) && (flag2==0) && (fstart==1))); do

        ZIP_CORE
#echo '**' $start_time  $end_time $((end_time-start_time))
    done


    #The following lines zip the last data of the night
    if(((end_time > start_day_time) && (flag==1) && \
        (dt> SECURE_DT) && (flag2==0) && (fstart==1)))

        then
        flag2=1
        end_time=$start_day_time

        ZIP_CORE
#echo '++' $start_time  $end_time $((end_time-start_time))
     fi


    sleep $SLEEP_TIME



done
