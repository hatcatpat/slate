#!/bin/sh

touch_check(){
	if [ -e "$1" ]; then
		echo "error: file exists $1"
	else
		touch "$1"
	fi
}

write_check() {
	if [ -e "$1" ]; then
		echo "error: file exists $1"
	else
		echo "$2" > "$1"
	fi
}

makefile() {
	write_check "makefile" \
"all: $NAME

$NAME: $NAME.*
	gcc -o $NAME $NAME.c -Wall

run: all
	./$NAME

clean:
	rm $NAME"
}

c_file() {
	if [ "$1" -gt 0 ]; then
		write_check "$NAME.c" "#include \"$NAME.h\""
	else
		touch_check "$NAME.c"
	fi

	echo \
"int main(int argc, char *argv[]) {
	 return 0;
}" >> "$NAME.c" 
}

safe_rm() {	
	if [ -e "$1" ]; then
		cp --backup=t "$1" "/tmp/$1"
		rm "$1"
	fi
}

C=

NAME=$1
shift

while [ $# -gt 0 ]
do
	arg=$1
	shift
	case $arg in
		-h|--help)
			echo 'usage: ./cproj.sh NAME -c'
			echo '-c, --noheader :: just make a .c file (no .h)'
			echo '-n, --new :: safely deletes .c, .h and makefile, storing backups in /tmp/'
			echo '--delete :: deletes .c, .h and makefile'
			echo '-h, --help :: shows this screen'
			;;
		-c|--noheader)
			C=1
			;;
		-n|--new)
			safe_rm "$NAME.c"
			safe_rm "$NAME.h"
			safe_rm "makefile"
			;;
		--delete)
			rm "$NAME.c"
			rm "$NAME.h"
			rm "makefile"
			exit
			;;
		*)
			echo "unknown flag, $arg"
			;;
	esac
done

makefile

if [ -z "$C" ]; then
	touch_check "$NAME.h"
	c_file 1
else
	c_file 0
fi


