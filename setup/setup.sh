#!/usr/bin/env bash

echo 'Starting setup';

# mac os setup
# brew install bash
# brew install coreutils
# brew install starship
# link .config/starship.toml


# enable globstar and extglob to allow recursive globbing and extended pattern matching
shopt -s globstar;
shopt -s extglob;

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

LINKABLES=$(ls -d "$REALPATH"/**/*.symlink "$REALPATH"/**/link__*); 
SKIPALL=false;
OVERWRITEALL=false;
BACKUPALL=false;

for LINK in $LINKABLES
do
	echo "Found file to link: $LINK"
	
	# Handle both .symlink and link__ files
	if [[ $LINK == *".symlink" ]]; then
		FILENAME=$(basename "$LINK" .symlink)
		TARGET="$HOME/.$FILENAME"
	else
		# Extract the filename part after link__
		FILENAME=$(basename "$LINK")
		FILENAME=${FILENAME#link__}
		
		# Handle subdirectory creation using @@@ separator
		if [[ $FILENAME == *"@@@"* ]]; then
			# Split the path into parts using @@@
			IFS="@@@" read -ra PARTS <<< "$FILENAME"
			
			# Build the target path
			TARGET="$HOME"
			for ((i=0; i<${#PARTS[@]}-1; i++)); do
				TARGET="$TARGET/${PARTS[i]}"
			done
			# Add the final filename
			TARGET="$TARGET/${PARTS[-1]}"
			
			# Create directory if it doesn't exist
			mkdir -p "$(dirname "$TARGET")"
		else
			TARGET="$HOME/$FILENAME"
		fi
	fi

	echo "target: $TARGET"

	if [ -a "$TARGET" ]; then
		echo "file already exists: $TARGET";
		if [ $SKIPALL = false ] && [ $OVERWRITEALL = false ] && [ $BACKUPALL = false ]; then
			select selection in "skip" "skip all" "overwrite" "overwrite all" "backup" "backup all" ; do
				case $selection in
					"skip" ) continue 2;;
					"skip all" ) SKIPALL=true; break;;
					"overwrite" ) OVERWRITE=true; break;;
					"overwrite all" ) OVERWRITEALL=true; break;;
					"backup" ) BACKUP=true; break;;
					"backup all" ) BACKUPALL=true; break;;	
				esac
			done
		fi
	fi

	if $BACKUP || $BACKUPALL; then
		echo "trying to create backup $TARGET.backup";
		mv "$TARGET" "$TARGET.backup";
	fi

	if $OVERWRITE || $OVERWRITEALL; then
		if [ -f "$TARGET" ]; then
			echo "overwriting $TARGET";
			rm "$TARGET";
		else
			echo "overwriting $TARGET";
			rm -R "$TARGET";
		fi
	fi	
	echo "Creating symlink from: $LINK to $TARGET";
	ln -s "$LINK" "$TARGET"
done
