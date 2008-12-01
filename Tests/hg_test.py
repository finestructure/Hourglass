from appscript import *
import time

sysevents = app('System Events')

def click_menu(menuitem, subitem):
    menubar = hg.menu_bars[1]
    menubar.menus[menuitem].menu_items[subitem].click()

def close_all_windows():
    for w in hg.windows():
        click_menu('File', 'Close')

def select_customer_group(window):
    split_group = window.splitter_groups[1]
    scroll_area = split_group.scroll_areas[1]
    table = scroll_area.tables[1]
    row = table.rows[5]
    text_field = row.text_fields[1]
    assert text_field.value() == "Customers"
    row.selected.set(True)


if __name__ == '__main__':
    hg = sysevents.processes['Hourglass']
    app('Hourglass').activate()

    close_all_windows()
    assert len(hg.windows()) == 0

    click_menu('File', 'New Document')

    doc_window = hg.windows['Untitled']

    # add a new customer
    select_customer_group(doc_window)
    split_group = doc_window.splitter_groups[1]
    button = split_group.buttons[1].click()

    # this is the code when talked about
    ref = hg.windows['Untitled'].splitter_groups[1] \
              .scroll_areas[3].tables[1].rows[1].text_fields[1]
    
    s = '<string>'
    ref.value.set(s)
    t = ref.value()
    print (s, t, s == t)
