#!/usr/bin/env python

import glob
import string
import os
import sys

COL_HANDLE = 'Handle'
COL_TITLE = 'Title'
COL_BODY = 'Body (HTML)'
COL_PRICE = 'Variant Price'
COL_IMGURL = 'Image Src'
COL_IMGTXT = 'Image Alt Text'

header = [ COL_HANDLE,
           COL_TITLE,
           COL_BODY,
           'Vendor',
           'Type',
           'Tags',
           'Variant Inventory Tracker',
           'Variant Inventory Qty',
           'Variant Inventory Policy',
           COL_PRICE,
           'Variant Requires Shipping',
           'Variant Taxable',
           COL_IMGURL,
           COL_IMGTXT ]

SEGMENT_POSTERS = 'vintage-posters'
TYP_POSTER = 'poster'
SEGMENT_GLASS = 'art-glass'
TYP_GLASS = 'glass'

TYP_2_SEGMENT = { TYP_POSTER : SEGMENT_POSTERS,
                  TYP_GLASS : SEGMENT_GLASS }

def deterime_type(cwd):
    typ = 'unknown'
    if SEGMENT_POSTERS in cwd:
        return TYP_POSTER
    elif SEGMENT_GLASS in cwd:
        return TYP_GLASS
    else:
        print 'ERROR: Cannot determine product type. Running in {0}. Expect {1} or {2} on the path.'.format(cwd, SEGMENT_POSTERS, SEGMENT_GLASS)
        sys.exit(1)

cwd = os.getcwd() 
vendor = os.path.basename(cwd)
typ = determine_type(cwd)
tag = vendor

record = [ None,
           None,
           None,
           vendor,
           typ,
           tag,
           'shopify',
           '1',
           'deny',
           None,
           'TRUE',
           'TRUE',
           None,
           None ]

imgurl_format ='http://glass-print.com/images/{0}/{1}/{2}.jpg'

def tx_title(handle):
    segs = handle.split('-')
    tx_segs = []
    for seg in segs:
        tx_segs.append(seg[0].upper() + seg[1:])
    return string.join(tx_segs, ' ')

print string.join(header, ',')
for f in glob.glob('*.html'):
    if f == 'all.html':
        continue

    handle = f.split('.')[0]

    record[header.index(COL_HANDLE)] = handle

    print string.join(record, ',')

