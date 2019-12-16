#! /usr/bin/env python2
# file1 - file2 ,the file sorted first.

import sys
import os

def Usage():
  print "usage:%s file1 file2 > result" %(sys.argv[0],)
  exit()


if __name__ == '__main__':
    if len(sys.argv) != 3 :
        Usage()
    file1 = open(sys.argv[1], 'r')
    file1_lines = file1.readlines()
    file2 = open(sys.argv[2], 'r')
    file2_lines = file2.readlines()
    file1.close()
    file2.close()

    for line in file1_lines:
        if line not in file2_lines:
            print line,
        else:
            file2_lines.remove(line);

