#!/bin/sh
startdir=$1
pkgname=$2

if [ -z "$startdir" ] || [ -z "$pkgname" ]; then
	echo "ERROR: missing argument!"
	echo "Please call devicepkg_default_build() with \$startdir and \$pkgname as arguments."
	exit 1
fi

srcdir="$startdir/src"

if [ ! -f "$srcdir/deviceinfo" ]; then
	echo "NOTE: $0 is intended to be used inside of the build() function"
	echo "of a device package's APKBUILD only."
	echo "ERROR: deviceinfo file missing!"
	exit 1
fi

# shellcheck disable=SC1090,SC1091
. "$srcdir/deviceinfo"

echo_libinput_calibration()
{
	# shellcheck disable=SC2154
	if [ $# -eq 6 ] && [ ! -z "$deviceinfo_screen_width" ] && [ ! -z "$deviceinfo_screen_height" ]
	then
		# shellcheck disable=SC2154
		x_offset=$(dc "$3" "$deviceinfo_screen_width" / p)
		# shellcheck disable=SC2154
		y_offset=$(dc "$6" "$deviceinfo_screen_height" / p)
		if [ ! -z "$x_offset" ] && [ ! -z "$y_offset" ]
		then
			echo "ENV{LIBINPUT_CALIBRATION_MATRIX}=\"$1 $2 $x_offset $4 $5 $y_offset\", \\"
		fi
	fi
}

# shellcheck disable=SC2154
if [ ! -z "$deviceinfo_dev_touchscreen" ]; then
	# Create touchscreen udev rule
	{
		echo "SUBSYSTEM==\"input\", ENV{DEVNAME}==\"$deviceinfo_dev_touchscreen\", \\"
		# shellcheck disable=SC2154
		if [ ! -z "$deviceinfo_dev_touchscreen_calibration" ]; then
			echo "ENV{WL_CALIBRATION}=\"$deviceinfo_dev_touchscreen_calibration\", \\"
			# shellcheck disable=SC2086
			echo_libinput_calibration $deviceinfo_dev_touchscreen_calibration
		fi
		echo "ENV{ID_INPUT}=\"1\", ENV{ID_INPUT_TOUCHSCREEN}=\"1\""
	} > "$srcdir/90-$pkgname.rules"
fi
