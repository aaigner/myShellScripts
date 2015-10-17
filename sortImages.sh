#! /bin/bash
##########################################################################
# Shellscript:	sort images according their creation date
# Author     :	Andreas Aigner <andreas.aigner@dcs-computing.com>
# Date       :	2015-10-17
# Category   :	Admin Utilities
# Version    :  0.1 15/10/17
##########################################################################
# Description
#    Creates subdirectories and moves the images to the correct directory
#    according to their creation date
##########################################################################
# Disclaimer
#    This script is a copy/paste work from several scripts available
#    online
##########################################################################

PN=`basename "$0"` # Program name
BASEDIR=`dirname "$0"`
VER='0.1'

Usage () {
    echo >&2 "$PN - sort images according their creation date, $VER
usage: $PN [-n] DESTINATION FILES
 or :  $PN [-n] DESTINATION SOURCE
    -n: do nothing ... not implemented at the moment
    -t: file extension in case of a source directory
    -h: show this help

    DESTINATION: destination directory
    FILES: list of image files
    SOURCE: source directory (optional)

Example:
    $PN $HOME/sorted *.JPG"
    exit 1
}

# message functions
Msg () { echo >&2 "$PN: $*"; }
Fatal () { Msg "$@"; exit 1; }

# copy function
copyImage () {
  echo "Processing $1 file..."

  # Obtain the creation date from the EXIF tag
  f_date=`exiftool "$1" -CreateDate -d $DEST_DIR_PATTERN | cut -d ':' -f 2 | sed -e 's/^[ \t]*//;s/[ \t]*$//'`;

  # Construct and create the destination directory
  f_dest_dir=$DEST_DIR/$f_date
  if $action_flag; then
    if [ ! -d $f_dest_dir ]; then
      echo "Creating directory $f_dest_dir"
      mkdir $f_dest_dir
    fi 
    mv "$1" "$f_dest_dir"
    echo "Moved $1 to $f_dest_dir"
  fi
}

#defaults
action_flag=true
extension="jpg"

while getopts hnt: opt
do
  case "$opt" in
    n)  action_flag=false;;
    t)  extension=$OPTARG;;
    h)  Usage;;
    \?) Usage;;
  esac
done
shift `expr $OPTIND - 1`

[ $# -lt 2 ] && Msg "Wrong number of arguments" && Usage # check for path

# The destination directory
DEST_DIR=$1
shift 1
if [ ! -d $DEST_DIR ]; then
  echo "Directory $DEST_DIR not found!"
  exit
fi

# The date pattern for the destination dir (see strftime)
DEST_DIR_PATTERN="%Y.%m.%d"

if [ -d $1 ]; then
  echo "Source directory found - not implemented at the moment"
  SOURCE_DIR=$1
  #find "$SOURCE_DIR" -iname "*.$extension" -type f | while read f
  for f in `ls $SOURCE_DIR/*.$extension`
  do
    copyImage $f
  done
else
  for f in $@
  do
    copyImage $f
  done
fi
