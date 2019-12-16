#! /usr/bin/env python2
# -*- coding: utf-8 -*-

import os
import sys
import wave
import shutil

def Usage():
    print "Usage: %s src_dir dst_dir \n attention: dir input like /tmp/src_dir, dont like /tmp/src_dir/ " %(sys.argv[0],)
    sys.exit(-1)

if __name__ == '__main__':
  if len(sys.argv) != 3:
     Usage()
  wave_dir = sys.argv[1]
  wave_store_dir = sys.argv[2]
  waves_in_dir = os.listdir(wave_dir)
  base_dir=os.path.basename(wave_dir)
   
  for wave_name in waves_in_dir:
    try:
       realpath_wav = wave_dir + '/' + wave_name
       wav_id = wave.open(realpath_wav,'r')
    except wave.Error:
       print wave_name + " open error"
       continue
    frames = wav_id.getnframes()
    if frames == 0 :
       print wave_name + " is empty file"
       continue
    frame_rate = wav_id.getframerate()
    if frame_rate == 16000 :
       dst_wav = wave_store_dir + "/" + wave_name
       shutil.copyfile(realpath_wav, dst_wav)

