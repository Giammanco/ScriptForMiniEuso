#! /bin/bash

help(){
        echo "use: UntarUtility to have the data in the courrent directory"
        echo "use: UntarUtility DirName to put the data in DirName"
        echo "use: UntarUtility state to mantain the media/usb0 directory"
        echo "use: UntarUtility help for this help"
        exit
}

narg=$#
now=$(date +%s)

case $narg in

    1)
    dir=$1


    ;;

    0)
        dir=$(pwd)

    ;;

    *)
        help

    ;;

esac


case $dir in

    help)

        help
    ;;

    state)

        for a in `ls -1 *.tar.gz`; do tar -zxvf $a; done

        exit
    ;;

    *)

      echo "creating tmp_$now"
      echo "unzipping into tmp_$now"
      mkdir "tmp_$now"
      for a in `ls -1 *.tar.gz`; do tar -C "tmp_$now" -zxvf $a; done
      if [ ! -d "$dir" ]; then
        echo "creating $dir"
        mkdir $dir
      fi
     echo "mooving files"
     (mv -v "tmp_$now/media/usb0/"* "$dir/")
     echo "remooving tmp_$now"
     rm -r "tmp_$now"
    ;;
esac
