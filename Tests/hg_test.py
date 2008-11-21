from appscript import *
import time

sysevents = app('System Events')

hg = sysevents.processes['Hourglass']
#hg = app('Hourglass')
#hg.activate()

def close_window():
    menubar = hg.menu_bars[1]
    menubar.menus['File'].menu_items['Close'].click()

loginwindow = sysevents.processes['loginwindow']
for w in hg.windows():
    print w.title()
