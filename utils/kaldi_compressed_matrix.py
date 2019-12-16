# -*- coding: utf-8 -*-
"""
@author: goat
"""
import numpy 
import os
import struct


class GlobalHeader(object):
    def __init__(self):
        self.format = None #int32
        self.min_value = None #float
        self.range = None #float
        self.num_rows = None #int32
        self.num_cols = None #int32


class PerColHeader(object):
    def __init__(self):
        self.percentile_0 = None #uint16
        self.percentile_25 = None
        self.percentile_75 = None
        self.percentile_100 = None


def uint16_to_float(global_header, value) :
    return (global_header.min_value + global_header.range * 1.52590218966964e-05 * value)


def char_to_float(p0, p25, p75, p100, value) :
    if (value <= 64) :
        return p0 + (p25 - p0) * value * (1/64.0)
    elif (value <= 192) :
        return p25 + (p75 - p25) * (value - 64) * (1/128.0)
    else :
        return p75 + (p100 - p75) * (value - 192) * (1/63.0)


class CompressMatrix(object):
    def __init__(self):
        self.global_header = GlobalHeader()
        self.pre_col_headers = []
        self.data = None
        self.numpy_data = None
    
    def read(self, file_obj, pos):
        file_obj.seek(pos, 0)
        file_obj.read(5)  # eat header BCM and two blanks
        self.global_header.format = 1
        data = struct.unpack(2*'f', file_obj.read(4*2))
        self.global_header.min_value = data[0]
        self.global_header.range = data[1]
        data = struct.unpack(2*'i', file_obj.read(4*2))
        self.global_header.num_rows = data[0]
        self.global_header.num_cols = data[1]
        rows = data[0]
        cols = data[1]
        data = numpy.frombuffer(file_obj.read(2*4*cols),numpy.uint16).reshape(cols,4)
        
        for c in xrange(cols):
            per_col_header = PerColHeader()
            per_col_header.percentile_0 = data[c, 0] 
            per_col_header.percentile_25 = data[c, 1] 
            per_col_header.percentile_75 = data[c, 2]
            per_col_header.percentile_100 = data[c, 3] 
            self.per_col_headers.append(per_col_header)
        
        data = numpy.frombuffer(file_obj.read(cols*rows), numpy.uint8).reshape(cols, rows)
        self.numpy_data = numpy.empty([rows, cols], dtype = float, order = 'C')
        
        for c in xrange(cols) :
            p0 = uint16_to_float(self.global_header, self.per_col_headers[c].percentile_0)
            p25 = uint16_to_float(self.global_header, self.per_col_headers[c].percentile_25)
            p75 = uint16_to_float(self.global_header, self.per_col_headers[c].percentile_75)
            p100 = uint16_to_float(self.global_header, self.per_col_headers[c].percentile_100)
            for r in xrange(rows) :
                val = char_to_float(p0, p25, p75, p100, data[c, r])
                self.numpy_data[r, c] = val  # transpose
        
    def numpy(self):
        return self.numpy_data
