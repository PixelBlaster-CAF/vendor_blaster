#!/usr/bin/env bash
# PixelBlaster build helper script

# red = errors, cyan = warnings, green = confirmations, blue = informational
# plain for generic text, bold for titles, reset flag at each end of line
# plain blue should not be used for readability reasons - use plain cyan instead
CLR_RST=$(tput sgr0)                        ## reset flag
CLR_RED=$CLR_RST$(tput setaf 1)             #  red, plain
CLR_GRN=$CLR_RST$(tput setaf 2)             #  green, plain
CLR_BLU=$CLR_RST$(tput setaf 4)             #  blue, plain
CLR_CYA=$CLR_RST$(tput setaf 6)             #  cyan, plain
CLR_BLD=$(tput bold)                        ## bold flag
CLR_BLD_RED=$CLR_RST$CLR_BLD$(tput setaf 1) #  red, bold
CLR_BLD_GRN=$CLR_RST$CLR_BLD$(tput setaf 2) #  green, bold
CLR_BLD_BLU=$CLR_RST$CLR_BLD$(tput setaf 4) #  blue, bold
CLR_BLD_CYA=$CLR_RST$CLR_BLD$(tput setaf 6) #  cyan, bold

# Set defaults
BUILD_TYPE="userdebug"

function checkExit () {
    if [ $? -ne 0 ]; then
        EXIT_CODE=$?
        echo "${CLR_BLD_RED}Build failed!${CLR_RST}"
        echo -e ""
        exit $EXIT_CODE
    fi
}

# Output usage help
function showHelpAndExit {
        echo -e "${CLR_BLD_BLU}Usage: $0 <device> [options]${CLR_RST}"
        echo -e ""
        echo -e "${CLR_BLD_BLU}Options:${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -h, --help            Display this help message${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -c, --clean           Wipe the tree before building${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -i, --installclean    Dirty build - Use 'installclean'${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -r, --repo-sync       Sync before building${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -v, --variant         Build Type - Can be Gapps or Vanilla${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -t, --build-type      Specify build type${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -o, --official        Build official build${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -j, --jobs            Specify jobs/threads to use${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -m, --module          Build a specific module${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -s, --sign-keys       Specify path to sign key mappings${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -p, --pwfile          Specify path to sign key password file${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -b, --backup-unsigned Store a copy of unsignied package along with signed${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -d, --delta           Generate a delta ota from the specified target_files zip${CLR_RST}"
        echo -e "${CLR_BLD_BLU}  -z, --imgzip          Generate fastboot flashable image zip from signed target_files${CLR_RST}"
        exit 1
}

# Setup getopt.
long_opts="help,clean,installclean,repo-sync,variant:,build-type:,jobs:,module:,sign-keys:,pwfile:,backup-unsigned,delta:,imgzip,official"
getopt_cmd=$(getopt -o hcirv:t:j:m:s:p:bd:zo --long "$long_opts" \
            -n $(basename $0) -- "$@") || \
            { echo -e "${CLR_BLD_RED}\nError: Getopt failed. Extra args\n${CLR_RST}"; showHelpAndExit; exit 1;}

eval set -- "$getopt_cmd"

while true; do
    case "$1" in
        -h|--help|h|help) showHelpAndExit;;
        -c|--clean|c|clean) FLAG_CLEAN_BUILD=y;;
        -i|--installclean|i|installclean) FLAG_INSTALLCLEAN_BUILD=y;;
        -r|--repo-sync|r|repo-sync) FLAG_SYNC=y;;
        -v|--variant|v|variant) BUILD_GAPPS="$2"; shift;;
        -t|--build-type|t|build-type) BUILD_TYPE="$2"; shift;;
        -j|--jobs|j|jobs) JOBS="$2"; shift;;
        -m|--module|m|module) MODULE="$2"; shift;;
        -s|--sign-keys|s|sign-keys) KEY_MAPPINGS="$2"; shift;;
        -p|--pwfile|p|pwfile) PWFILE="$2"; shift;;
        -b|--backup-unsigned|b|backup-unsigned) FLAG_BACKUP_UNSIGNED=y;;
        -d|--delta|d|delta) DELTA_TARGET_FILES="$2"; shift;;
        -z|--imgzip|img|imgzip) FLAG_IMG_ZIP=y;;
        -o|--official|o|official) OFFICIAL=y; shift;;
        --) shift; break;;
    esac
    shift
done

# Mandatory argument
if [ $# -eq 0 ]; then
    echo -e "${CLR_BLD_RED}Error: No device specified${CLR_RST}"
    showHelpAndExit
fi
export DEVICE="$1"; shift

# Make sure we are running on 64-bit before carrying on with anything
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ "$ARCH" != "64" ]; then
        echo -e "${CLR_BLD_RED}error: unsupported arch (expected: 64, found: $ARCH)${CLR_RST}"
        exit 1
fi

# Set up paths
cd $(dirname $0)
DIR_ROOT=$(pwd)

# Make sure everything looks sane so far
if [ ! -d "$DIR_ROOT/vendor/blaster" ]; then
        echo -e "${CLR_BLD_RED}error: insane root directory ($DIR_ROOT)${CLR_RST}"
        exit 1
fi

# Setup Build variant if specified
if [ $BUILD_GAPPS ]; then
    BUILD_GAPPS=`echo $BUILD_GAPPS |  tr "[:upper:]" "[:lower:]"`
    if [ "${BUILD_GAPPS}" = "gapps" ]; then
        export BUILD_GAPPS=GAPPS
    elif [ "${BUILD_GAPPS}" = "vanilla" ]; then
        export BUILD_GAPPS=VANILLA
    else
        echo -e "${CLR_BLD_RED} Unknown Build variant - use vanilla or gapps${CLR_RST}"
        exit 1
    fi
fi

# Setup Official Build if specified
if [ $OFFICIAL ]; then
    OFFICIAL=`echo $OFFICIAL |  tr "[:upper:]" "[:lower:]"`
    if [ "${OFFICIAL}" = "y" ]; then
        export BLASTER_BUILD_TYPE=OFFICIAL
    else
        export BLASTER_BUILD_TYPE=UNOFFICIAL
        exit 1
    fi
fi

# Initializationizing!
echo -e "${CLR_BLD_BLU}Setting up the environment${CLR_RST}"
echo -e ""
. build/envsetup.sh
echo -e ""

# Use the thread count specified by user
CMD=""
if [ $JOBS ]; then
  CMD+="-j$JOBS"
fi

# Pick the default thread count (allow overrides from the environment)
if [ -z "$JOBS" ]; then
        if [ "$(uname -s)" = 'Darwin' ]; then
                JOBS=$(sysctl -n machdep.cpu.core_count)
        else
                JOBS=$(cat /proc/cpuinfo | grep '^processor' | wc -l)
        fi
fi

# Grab the build version
BLASTER_DISPLAY_VERSION="$(cat $DIR_ROOT/vendor/blaster/target/product/version.mk | grep 'BLASTER_BUILD_VERSION := *' | sed 's/.*= //')"

# Prep for a clean build, if requested so
if [ "$FLAG_CLEAN_BUILD" = 'y' ]; then
        echo -e "${CLR_BLD_BLU}Cleaning output files left from old builds${CLR_RST}"
        echo -e ""
        m clobber "$CMD"
fi

# Prep for a installclean build, if requested so
if [ "$FLAG_INSTALLCLEAN_BUILD" = 'y' ]; then
        echo -e "${CLR_BLD_BLU}Cleaning compiled image files left from old builds${CLR_RST}"
        echo -e ""
        m installclean "$CMD"
fi

# Sync up, if asked to
if [ "$FLAG_SYNC" = 'y' ]; then
        echo -e "${CLR_BLD_BLU}Downloading the latest source files${CLR_RST}"
        echo -e ""
        repo sync -j"$JOBS" -c --no-clone-bundle --current-branch --no-tags
fi

# Check the starting time (of the real build process)
TIME_START=$(date +%s.%N)

# Friendly logging to tell the user everything is working fine is always nice
echo -e "${CLR_BLD_GRN}Building PixelBlaster $BLASTER_DISPLAY_VERSION for $DEVICE${CLR_RST}"
echo -e "${CLR_GRN}Start time: $(date)${CLR_RST}"
echo -e ""

# Lunch-time!
echo -e "${CLR_BLD_BLU}Lunching $DEVICE${CLR_RST} ${CLR_CYA}(Including dependencies sync)${CLR_RST}"
echo -e ""
BLASTER_VERSION=$(lunch "blaster_$DEVICE-$BUILD_TYPE" | grep 'BLASTER_VERSION=*' | sed 's/.*=//')
lunch "blaster_$DEVICE-$BUILD_TYPE"
echo -e ""

# Build away!
echo -e "${CLR_BLD_BLU}Starting compilation${CLR_RST}"
echo -e ""

# If we aren't in Jenkins, use the engineering tag
if [ -z "${BUILD_NUMBER}" ]; then
    export FILE_NAME_TAG=eng.$USER
else
    export FILE_NAME_TAG=$BUILD_NUMBER
fi

# Build a specific module
if [ "${MODULE}" ]; then
    m $MODULE "$CMD"
    checkExit

# Build signed rom package if specified
elif [ "${KEY_MAPPINGS}" ]; then
    # Set sign key password file if specified
    if [ "${PWFILE}" ]; then
        export ANDROID_PW_FILE=$PWFILE
    fi

    # Make package for distribution
    m dist "$CMD"

    checkExit

    echo -e "${CLR_BLD_BLU}Signing target files apks${CLR_RST}"
    sign_target_files_apks -o -d $KEY_MAPPINGS \
        out/dist/blaster_$DEVICE-target_files-$FILE_NAME_TAG.zip \
        PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD-signed-target_files-$FILE_NAME_TAG.zip

    checkExit

    echo -e "${CLR_BLD_BLU}Generating signed install package${CLR_RST}"
    ota_from_target_files -k $KEY_MAPPINGS/releasekey \
        --block ${INCREMENTAL} \
        PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD-signed-target_files-$FILE_NAME_TAG.zip \
        PixelPixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD-$BLASTER_BUILD.zip

    checkExit

    if [ "$DELTA_TARGET_FILES" ]; then
        # die if base target doesn't exist
        if [ ! -f "$DELTA_TARGET_FILES" ]; then
                echo -e "${CLR_BLD_RED}Delta error: base target files don't exist ($DELTA_TARGET_FILES)${CLR_RST}"
                exit 1
        fi
        ota_from_target_files -k $KEY_MAPPINGS/releasekey \
            --block --incremental_from $DELTA_TARGET_FILES \
            PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD-signed-target_files-$FILE_NAME_TAG.zip \
            PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD-delta.zip
        checkExit
    fi

    if [ "$FLAG_IMG_ZIP" = 'y' ]; then
        echo -e "${CLR_BLD_BLU}Generating signed fastboot package${CLR_RST}"
        img_from_target_files \
            PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD-signed-target_files-$FILE_NAME_TAG.zip \
            PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD-signed-image.zip
        checkExit
    fi
# Build rom package
elif [ "$FLAG_IMG_ZIP" = 'y' ]; then
    m otatools target-files-package "$CMD"

    checkExit

    echo -e "${CLR_BLD_BLU}Generating install package${CLR_RST}"
    ota_from_target_files \
        "$OUT"/obj/PACKAGING/target_files_intermediates/blaster_$DEVICE-target_files-$FILE_NAME_TAG.zip \
        PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD.zip

    checkExit

    echo -e "${CLR_BLD_BLU}Generating fastboot package${CLR_RST}"
    img_from_target_files \
        "$OUT"/obj/PACKAGING/target_files_intermediates/blaster_$DEVICE-target_files-$FILE_NAME_TAG.zip \
        PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD-image.zip

    checkExit

else
    m otapackage "$CMD"

    checkExit

    cp -f $OUT/blaster_$DEVICE-ota-$FILE_NAME_TAG.zip $OUT/PixelBlaster-CAF-$BLASTER_DISPLAY_VERSION-$BLASTER_BUILD_TYPE-$BUILD_GAPPS-$BLASTER_BUILD.zip
fi
echo -e ""

# Check the finishing time
TIME_END=$(date +%s.%N)

# Log those times at the end as a fun fact of the day
echo -e "${CLR_BLD_GRN}Total time elapsed:${CLR_RST} ${CLR_GRN}$(echo "($TIME_END - $TIME_START) / 60" | bc) minutes ($(echo "$TIME_END - $TIME_START" | bc) seconds)${CLR_RST}"
echo -e ""

exit 0
