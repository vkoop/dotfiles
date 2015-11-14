#!/usr/bin/env bash

echo 'Starting setup';
shopt -s globstar;

case "$(uname -s)" in
	Darwin)
		echo 'Mac OS X'
		READLINK_BIN="greadlink"
		;;

	Linux)
		READLINK_BIN="readlink"
		;;
	*)
		echo "Not supported OS - will exit now!"
		exit 0;
esac

REALPATH=$($READLINK_BIN -f "$PWD");

LINKABLES=$(ls -d $REALPATH/**/*.symlink); #-d --> shows only directories instead of contents
SKIPALL=false;
OVERWRITEALL=false;
BACKUPALL=false;

for LINK in $LINKABLES
do
	echo "Found file to link: $LINK"
	FILENAME=$(basename $LINK .symlink) #TODO ordner muss noch entfernt werden 
	TARGET="$HOME/.$FILENAME"
	BACKUP=false
	OVERWRITE=false

	echo "target: $TARGET"

	if [ -a $TARGET ];
	then
		echo "file already exists: $TARGET";
		if [ $SKIPALL = false ] && [ $OVERWRITEALL = false ] && [ $BACKUPALL = false ]; 
		then
			#show dialog
			select selection in "skip" "skip all" "overwrite" "overwrite all" "backup" "backup all" ; 
			do
				case $selection in
					"skip" ) continue 2;;
					"skip all" ) SKIPALL=true; break 2;;
					"overwrite" ) OVERWRITE=true; break;;
					"overwrite all" ) OVERWRITEALL=true; break;;
					"backup" ) BACKUP=true; break;;
					"backup all" ) BACKUPALL=true; break;;	
				esac
			done
		fi
	fi

	if $BACKUP || $BACKUPALL ;  then
		echo "trying to create backup $TARGET.backup";
		mv "$TARGET" "$TARGET.backup";
	fi

	if $OVERWRITE  || $OVERWRITEALL ; then
		if [ -f $TARGET ]; then
			echo "overwriting $TARGET";
			rm $TARGET;
		else
			echo "overwriting $TARGET";
			rm -R $TARGET;
		fi
	fi	
	echo "Creating symlink from: $LINK to $TARGET";
	ln -s $LINK $TARGET #perhaps have to get realpath of LINK
done
