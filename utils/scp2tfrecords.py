# -*- coding: utf-8 -*-
"""
@author: goat
"""
import logging
import argparse

import tensorflow as tf

class KeywordAlignment(object):
    def __init__(self):
        self.alignment_dict =  {}

    def read(self, alignment_file):
        with open(alignment_file, "r") as file:
            for line in file:
                line_array = line.rstrip().split()
                key = line_array[0]
                alignment = numpy.asarray([ int(x) for x in line_array[1:] ], numpy.int32)
                if key not in self.alignment_dict.keys():
                    self.alignment_dict[name] = alignment
                else :
                    logging.warning("duplicate alignments key " + key + "\n")

    def has_key(self, key):
        return self.alignment_dict.has_key(key)

    def get(self, key):
        return self.alignment_dict[key]

def main():



if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('--nnet_input_scp', type=str, help='nnet input scp')
    parser.add_argument('--tfrecords_scp', type=str, help='tfrecords scp')
    parser.add_argument('--tfrecords_dir', type=str, help='tfrecords dir')

    args = parser.parse_args()
    tf.app.run(main=main, argv=[sys.argv[0]])

