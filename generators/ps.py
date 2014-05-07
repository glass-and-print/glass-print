#!/usr/bin/env python

import glob
import string
import os
import sys
import bs4
import re

all_digits = re.compile('\d+')
dim = re.compile('^\d+.*\s+x\s+.*\d+.*$')

imgurl_format = 'http://glass-print.com/images/{0}/{1}/{2}'
imgpath_format = '../../images/{0}/{1}/{2}.*'

def path_to_image(typ, vendor, handle):
    return os.path.basename(glob.glob(imgpath_format.format(typ, vendor, handle))[0])

def quote(val):
    return '"' + val + '"'

def parse(fn):
    ft = None
    with open(fn, 'r') as f:
        ft = bs4.BeautifulSoup(f)
    return ft

def normalize(tag):
    import unicodedata
    return unicodedata.normalize('NFKD', tag.text).encode('ascii','ignore').strip()

def title(parent):
    title = parent.find('td', id='piece-title')
    if title:
        title = normalize(title)
    return title

def price(parent):
    price = parent.select(".product-price")
    if price and len(price) > 0:
        price = price[0]['value']
        if all_digits.match(price):
            return price
    return None

def body(parent):
    result = ""
    for desc_tag in t.find_all('td', colspan='2'):
        desc = normalize(desc_tag)
        if desc:
            if dim.match(desc):
                desc = desc.replace('"', ' in')
            else:
                desc = desc.replace('"', '')
            result = result + desc + " <br />"
    return result

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

COL_HANDLE_IDX = header.index(COL_HANDLE)
COL_TITLE_IDX = header.index(COL_TITLE)
COL_BODY_IDX = header.index(COL_BODY)
COL_PRICE_IDX = header.index(COL_PRICE)
COL_IMGURL_IDX = header.index(COL_IMGURL)
COL_IMGTXT_IDX = header.index(COL_IMGTXT)

SEGMENT_POSTERS = 'vintage-posters'
TYP_POSTER = 'poster'
SEGMENT_GLASS = 'art-glass'
TYP_GLASS = 'glass'

TYP_2_SEGMENT = { TYP_POSTER : SEGMENT_POSTERS,
                  TYP_GLASS : SEGMENT_GLASS }

def determine_type(cwd):
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

print ','.join(header)
for f in glob.glob('*.html'):
    if f == 'all.html' or f == 'index.html':
        continue
    handle = f.split('.')[0]
    t = parse(f).find('table', id='piece-description')
    if t:
        pric = price(t)
        titl = title(t)
        bod = body(t)
        if pric and titl and bod:
            record[COL_HANDLE_IDX] = quote(handle)
            record[COL_TITLE_IDX] = quote(titl)
            record[COL_BODY_IDX] = quote(bod)
            record[COL_PRICE_IDX] = quote(pric)
            ts = TYP_2_SEGMENT[typ]
            record[COL_IMGURL_IDX] = quote(imgurl_format.format(ts,
                                                                vendor,
                                                                path_to_image(ts, vendor, handle)))
            record[COL_IMGTXT_IDX] = quote(titl)
            print ','.join(record)

