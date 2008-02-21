#! /usr/bin/env python

import glob
from Foundation import *

plistFile = glob.glob('build/Release/*.app/Contents/Info.plist')[0]
key = 'CFBundleShortVersionString'

d = NSMutableDictionary.dictionaryWithContentsOfFile_( plistFile )

print d[key]
