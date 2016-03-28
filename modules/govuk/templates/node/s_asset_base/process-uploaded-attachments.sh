#!/bin/bash

set -e

INCOMING_DIR=$1
CLEAN_DIR=$2
INFECTED_DIR=$3

set -u

usage() {
  echo "USAGE: $0 <incoming_directory> <clean_directory> <infected_directory>"
  echo
  echo "Processes attachments in <incoming_directory> by:"
  echo "  - Running a virus scan on each attachment"
  echo "  - If the file is clean, moving it to a directory of clean files"
  echo "  - Copying it to one or more other machines"
  echo
  exit 1
}

if [ $# -lt 3 ]; then
 usage
fi

ASSET_SLAVE_NODES=$(/usr/local/bin/govuk_node_list -c asset_slave)

cd "$INCOMING_DIR"

while IFS= read -r -d '' FILE
  do
    logger -t process_uploaded_attachment "Processing uploaded file $FILE"
    # This parameter substition strips "$INCOMING_DIR/" from the beginning of $FILE.
    FILE_PATH=${FILE#$INCOMING_DIR/}
    if /usr/local/bin/virus-scan-file.sh "$FILE"; then
      rsync --relative "$FILE_PATH" "$CLEAN_DIR"
      for NODE in $ASSET_SLAVE_NODES; do
        if rsync -e "ssh -q" --quiet --timeout=10 --relative "$FILE_PATH" $NODE:$CLEAN_DIR; then
          logger -t process_uploaded_attachment "File $FILE copied to $NODE"
        else
          logger -t process_uploaded_attachment "File $FILE failed to copy to $NODE"
        fi
      done
      rm "$FILE"
    else
      rsync --remove-source-files --relative "$FILE_PATH" "$INFECTED_DIR"
    fi
done < <(find "$INCOMING_DIR" -type f -print0)

CODE=0
OUTPUT="Last run status processing $INCOMING_DIR"

# Send a passive check to check the freshness threshold
printf "<%= @ipaddress %>\tProcess attachments last run\t$CODE\t$OUTPUT\n" | /usr/sbin/send_nsca -H alert.cluster >/dev/null

# Clean up empty directories in `incoming` which have not been modified recently.
find "$INCOMING_DIR" -mindepth 1 -type d -mmin +10 -empty -delete
