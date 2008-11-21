from appscript import *
import time

sysevents = app('System Events')
hg = sysevents.processes['Hourglass']

app('Hourglass').activate()

menubar = hg.menu_bars[1]
filemenu = menubar.menus['File']

def close_all_windows():
    for w in hg.windows():
        filemenu.menu_items['Close'].click()

def click_new_document():
    filemenu.menu_items['New Document'].click()

def select_customer_group(window):
    split_group = window.splitter_groups[1]
    scroll_area = split_group.scroll_areas[1]
    table = scroll_area.tables[1]
    row = table.rows[5]
    text_field = row.text_fields[1]
    assert text_field.value() == "Customers"
    row.selected.set(True)

def click_add_customer(window):
    split_group = window.splitter_groups[1]
    button = split_group.buttons[1]
    #assert button.title() == 'Add customer'
    button.click()

def customer_table(window):
    split_group = window.splitter_groups[1]
    scroll_area = split_group.scroll_areas[3]
    return scroll_area.tables[1]

def edit_customer(window, index, value):
    row = customer_table(window).rows[index]
    text_field = row.text_fields[1]
    text_field.focused.set(True)
    #text_field.value.set(value)
    #time.sleep(1)
    sysevents.keystroke(value)
    sysevents.key_code(36)
    #text_field.focused.set(False)
    #text_field.confirm()
    
    assert text_field.value() == value

if __name__ == '__main__':
    close_all_windows()
    assert len(hg.windows()) == 0
    
    click_new_document()
    
    #filemenu.menu_items['New Task'].click()
    
    win = hg.windows[1]
    assert win.title() == 'Untitled'
    
    select_customer_group(win)
    click_add_customer(win)
    
    assert len(customer_table(win).rows()) == 1
    
    edit_customer(win, 1, 'Test Customer A')
    