from appscript import *
import time

sysevents = app('System Events')
hg = sysevents.processes['Hourglass']

ref = hg.windows['Untitled'].splitter_groups[1] \
          .scroll_areas[3].tables[1].rows[1].text_fields[1]

s = '<string>'
ref.value.set(s)
t = ref.value()
print (s, t, s == t)
