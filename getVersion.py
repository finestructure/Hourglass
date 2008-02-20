#! /usr/bin/env python

from Foundation import *

plistFile = 'build/Release/PdbX.app/Contents/Info.plist'
key = 'CFBundleShortVersionString'

d = NSMutableDictionary.dictionaryWithContentsOfFile_( plistFile )

print d[key]
