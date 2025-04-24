#!/bin/bash

LOGFILE="build.log"
GAME="$HOME/.steam/steam/steamapps/common/Portal 2/portal2"
STUDIOMDL="$GAME/../bin/studiomdl.exe"
VPKTOOL="$GAME/../bin/vpk.exe"
OUTPUT="./pak04_dir"

rm -rf $OUTPUT
mkdir $OUTPUT

function resize_prop {
  # compile base model (without scaling)
  echo "Compiling base model... ($1)"
  sed -i "1s/.*/\$modelname \"npcs\/monsters\/$1.mdl\"/" "$1/$1.qc"
  sed -i "2s/.*//" "$1/$1.qc"
  wine "$STUDIOMDL" -game "$GAME" -nop4 -verbose "$1/$1.qc" > $LOGFILE 2>&1
  # compile models at each scale increment
  for (( i = 2 ; i <= 35 ; i ++ )); do
    scale="$((i / 10)).$((i % 10))"
    scale_dash="$((i / 10))-$((i % 10))"
    echo "Compiling ${scale}x model... ($1)"
    sed -i "1s/.*/\$modelname \"npcs\/monsters\/$1_${scale_dash}x.mdl\"/" "$1/$1.qc"
    sed -i "2s/.*/\$scale $scale/" "$1/$1.qc"
    wine "$STUDIOMDL" -game "$GAME" -nop4 -verbose "$1/$1.qc" > $LOGFILE 2>&1
  done
}

resize_prop metal_box
resize_prop reflection_cube
resize_prop underground_weighted_cube
resize_prop monster_a_box

cp -r "$GAME/models" "$OUTPUT/models"
wine "$VPKTOOL" "$OUTPUT"
