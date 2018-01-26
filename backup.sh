#!/usr/bin/env bash

# Single backup using rsync+ssh

# m h  dom mon dow   command
# 00 04 * * * /home/euikook/bin/backup.sh -h sunrise -e ssh /home/repos /home/backup/101/home/repos
# 00 05 * * * /home/euikook/bin/backup.sh -h sunrise -e ssh /home/www /home/backup/101/home/www
# 00 06 * * * /home/euikook/bin/backup.sh -h sunrise -e ssh /home/git /home/backup/101/home/git

# USER VARIABLES
DAYS=7						# The number of days after which old backups will be deleted

# PATH VARIABLES
SH=/bin/sh					# Location of the bash bin in the production server!!!!

CP=/bin/cp;					# Location of the cp bin
FIND=/usr/bin/find;				# Location of the find bin
ECHO=/bin/echo;					# Location of the echo bin
MK=/bin/mkdir;					# Location of the mk bin
SSH=/usr/bin/ssh;				# Location of the ssh bin
DATE=/bin/date;					# Location of the date bin
RM=/bin/rm;					# Location of the rm bin
GREP=/bin/grep;					# Location of the grep bin
MYSQL=/usr/bin/mysql;				# Location of the mysql bin
MYSQLDUMP=/usr/bin/mysqldump;			# Location of the mysql_dump bin
RSYNC=/usr/bin/rsync;				# Location of the rsync bin
TOUCH=/bin/touch;				# Location of the touch bin



##                                                      ##
##      --       DO NOT EDIT BELOW THIS HERE     --     ##
##                                                      ##

while [ $# -gt 0 ]
do
	case "$1" in 
		-h) RM_HOST=$2; 
		    shift;;
		-e) RM_OPTS=$2;
		    shift;;
		-*) echo >&2 "usage $0 [-h HOST] [-e SSH_OPTION] <SRC DIR> <DST DIR>"
		    exit 1;;
		 *) break;; # terminate while loop 
	esac
	shift;
done


SRC_DIR=$1
DST_DIR=$2

if [ "RM_HOST" = "" ]; then
	$RM_OPTS=""
else
	BKUP_SRC="-e \"$RM_OPTS\" $RM_HOST:$SRC_DIR"
fi

BKUP_DST="$DST_DIR"

if [ ! -d "$BKUP_DST" ]; then
	echo "No such file or directory '$BKUP_DST'"
	exit 1;
fi

NOW=`$DATE '+%Y-%m-%d'`

#LIST="$( $FIND $DST_DIR -maxdepth 1 -type d | sort )"

#for FILE in  $LIST
#do
#	LAST=$FILE
#done

CURRENT=$BKUP_DST

BKUP_NAME=`basename "$BKUP_DST"`

BKUP_LOG="$BKUP_DST/../Log/$BKUP_NAME-$NOW.log"

echo $BKUP_NAME $DST_DIR $CURRENT $BKUP_LOG

#if [ $LAST != $DST_DIR ] && [ ! -d $CURRENT ]; then
#	$CP -al $LAST $CURRENT
#fi

# RUN RSYNC INTO CURRENT
#--exclude-from="$EXCLUDES"		\
date > "$BKUP_LOG"
echo "$RSYNC -apvz --delete --delete-excluded $BKUP_SRC $CURRENT"
$RSYNC							\
		-apvz --delete --delete-excluded	\
		$BKUP_SRC/				\
		"$CURRENT" 2>&1 >> "$BKUP_LOG" ;

# UPDATE THE MTIME TO REFELCT THE SNAPSHOT TIME
$TOUCH "$CURRENT"

exit 0
