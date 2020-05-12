#!/bin/bash

# ****************************************************************************
#
#							clamscan_delta.sh
#
#
# ****************************************************************************
# clamscan_delta.sh - Scans the paths named in SCAN_PATHS for changed files
# Version 1.20 2013-03-13
# Purpose: Scan for malware and send an e-mail alert if detected
# Author: IT_Architect http://forum.directadmin.com
# Requirements: ?NIX computer, bash shell, and ClamAV
#
# Source URL: https://forum.directadmin.com/threads/
#             how-to-use-clamav-to-monitor-a-nix-server-for-malware.45896
#
# ****************************************************************************
#							User Settings
# ****************************************************************************
### Scan Type Name: Prints in log, and forms base for log tmp file names.
SCAN_TYPE="daily"

### E-mail settings
EMAIL_SUBJECT="VIRUS DETECTED ON `hostname`!!!"
EMAIL_TO="mark@cuchulainn"
EMAIL_FROM="no-reply@cuchulainn"
LOG_TAIL_SIZE=50; # Number of lines from tail of scan log to email in alerts 

### Log File Path
LOG_DIR="/home/mark/.log/clamav"

# Rotates log at size stated, but maintains only one previous.  If you use the
# quarantine capabilities, the log file is the only source of information that
# contains where the files in the quarantine came from.
MAX_LOG_SIZE_KB=1024

# Character string used to separate scan instances in log file. 
LOG_SEPARATOR="printf '*%.0s' {1..78};echo;"

# Directory for scratch files - default="$LOG_DIR/tmp"
SCRATCH_DIR="$LOG_DIR/tmp"

# Path to clamscan - default="/usr/local/bin/clamscan"
CLAMSCAN_PATH="/usr/bin/clamscan"

### Scan Parameters
# Check only files that have changed in the last X minutes
# Set to match scan frequency plus a minute or more.
# Example: If you scan every hour, LOOK_BACK_MINUTES=61
LOOK_BACK_MINUTES=1441

# Valid quarantine path required for SCAN_ACTIONs --copy or --move
# Will creseate if not present default="$LOG_DIR/quarantine"
QUARANTINE_DIR="$LOG_DIR/quarantine"

# Scan Action: Default "" = no action.  Other actions are:
# "--remove=yes" or "--move=$QUARANTINE_DIR" or "--copy=$QUARANTINE_DIR"
SCAN_ACTION=""

# Scan Paths
# Ensure QUARANTINE_DIR is not in path if SCAN_ACTION is --copy or --move
# Cannot specify directories with spaces in name but will scan them in path
SCAN_PATHS=( \
/home/*/domains/*/private_html \
/home/*/domains/*/public_html \
/home/*/domains/*/private_ftp \
/home/*/domains/*/public_ftp \
/home/*/Maildir \
/home/*/imap/*/*/Maildir \
/var/tmp \
/tmp \
)

# ****************************************************************************
# 					MAKE NO CHANGES BELOW THIS LINE
# ****************************************************************************
# ****************************************************************************
# 								Functions
# ****************************************************************************
# ******************
#Function find_files
# ******************
find_files () {

# Load files to be scanned to file
  for (( i = 0 ; i < ${#SCAN_PATHS[@]} ; i++ )) do
    eval find ${SCAN_PATHS[$i]} -type f -mmin -$LOOK_BACK_MINUTES >> $FILES_UNSORTED
    eval find ${SCAN_PATHS[$i]} -type f -cmin -$LOOK_BACK_MINUTES >> $FILES_UNSORTED
  done
  cat $FILES_UNSORTED | sort -u > $FILES_SORTED

}

# ******************
#Function check_scan
# ******************
check_scan () {
 
    # Check the last set of results. If there are any "Infected" counts that
    # aren't zero, e-mail an alert.
    if [ `tail -n 12 ${LOG}  | grep Infected | grep -v 0 | wc -l` != 0 ]
    then
        echo "To: ${EMAIL_TO}" >>  ${EMAIL_MESSAGE}
        echo "From: ${EMAIL_FROM}" >>  ${EMAIL_MESSAGE}
        echo "Subject: ${EMAIL_SUBJECT}" >>  ${EMAIL_MESSAGE}
        echo "Importance: High" >> ${EMAIL_MESSAGE}
        echo "X-Priority: 1" >> ${EMAIL_MESSAGE}
        echo "*** SEE ${LOG} FOR MALWARE DETAILS ***" >> ${EMAIL_MESSAGE}
        echo "*** Last $LOG_TAIL_SIZE lines from log file ***" >> ${EMAIL_MESSAGE}
        echo >> ${EMAIL_MESSAGE}
		echo "`tail -n $LOG_TAIL_SIZE ${LOG}`" >> ${EMAIL_MESSAGE}
        eval sendmail -t < ${EMAIL_MESSAGE}
    fi
}

# ******************
#Function initialize
# ******************
initialize () {

# *** Sanity checks
# Make LOG directory specified if necessary
if [[ ! -z $LOG_DIR ]]; then  # if not unset or empty
  if [ ! -d "$LOG_DIR" ]; then
    mkdir -p ${LOG_DIR}
    if [ ! -d "$LOG_DIR" ]; then
      echo "Fatal Error: LOG_DIR path $LOG_DIR invalid or could not be created"
      exit
    fi
  fi
else
  echo "Fatal Error: LOG_DIR path not set"
  exit
fi

# Check for SCRATCH_DIR directory and make if necessary
if [[ ! -z $SCRATCH_DIR ]]; then  # if not unset or empty
  if [ ! -d "$SCRATCH_DIR" ]; then
    mkdir -p ${SCRATCH_DIR}
    if [ ! -d "$SCRATCH_DIR" ]; then
      echo "Fatal Error: SCRATCH_DIR path $SCRATCH_DIR invalid or could not be created"
      exit
    fi
  fi
else
  echo "Fatal Error: SCRATCH_DIR path not set"
  exit
fi

# Make QUARANTINE_DIR specified if necessary
if [[ -z $QUARANTINE_DIR ]] && \
[[ $SCAN_ACTION == "--copy=$QUARANTINE_DIR" || \
$SCAN_ACTION = "--move=$QUARANTINE_DIR" ]]; then
  echo "Fatal Error: QUARANTINE_DIR not set as required by SCAN_ACTION"
  exit
else  # QUARANTINE_DIR not empty or not required by SCAN_ACTION
  if [[ $SCAN_ACTION == "--copy=$QUARANTINE_DIR" || \
  $SCAN_ACTION = "--move=$QUARANTINE_DIR" ]]; then  # If you need the path
    if [ ! -d "$QUARANTINE_DIR" ]; then
      mkdir -p ${QUARANTINE_DIR}
      if [ ! -d "$QUARANTINE_DIR" ]; then
        echo "Fatal Error: QUARANTINE_DIR $QUARANTINE_DIR invalid or could not be created"
        exit;
      fi
    fi
  fi
  # QUARANTINE_DIR not required
fi

### Initialize files.
  FILE_PREFIX=$(echo $SCAN_TYPE | sed -e 's/ /_/g')
  LOG="$LOG_DIR/$FILE_PREFIX""_scan.log"
  FILES_UNSORTED="$SCRATCH_DIR/$FILE_PREFIX""_unsorted.tmp"
  FILES_SORTED="$SCRATCH_DIR/$FILE_PREFIX""_sorted.tmp"
  EMAIL_MESSAGE="$SCRATCH_DIR/$FILE_PREFIX""_email.tmp"
  cat /dev/null > $FILES_UNSORTED
  cat /dev/null > $FILES_SORTED
  cat /dev/null > $EMAIL_MESSAGE

# *** Rotate log if necessary (Maintains only one previous revision)
if [ -f "$LOG" ]; then
  LOG_SIZE_KB=`du -k $LOG | cut -f1`
  if [[ "${LOG_SIZE_KB:-0}" -ge "${MAX_LOG_SIZE_KB:-0}" ]]
  then
    mv $LOG ${LOG}.old
  fi
fi
}

# ****************************************************************************
# 									Main
# ****************************************************************************
START_TIME="$(date +%s)"

# *** Initialize - Sanity checks, file setup, file maintenance
initialize

# *** Write header
eval $LOG_SEPARATOR >> $LOG
echo Start Time: Date $(date) >> $LOG
echo Scan Type: $SCAN_TYPE >> $LOG

# *** Find files and scan.
find_files
$CLAMSCAN_PATH --quiet --infected --log=${LOG} ${SCAN_ACTION} --file-list=${FILES_SORTED}

# *** Write trailer to log
echo Finish Time: Date $(date) >> $LOG
ET="$(($(date +%s)-START_TIME))"
printf "Elapsed Time: %d hrs %02d mins %02d secs\n" "$((ET/3600%24))" "$((ET/60%60))" "$((ET%60))" >> $LOG
eval $LOG_SEPARATOR >> $LOG

# *** Check log for malware detectiions and Send e-mail alert if found
check_scan
