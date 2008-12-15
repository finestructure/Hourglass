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

def select_project_group(window):
    split_group = window.splitter_groups[1]
    scroll_area = split_group.scroll_areas[1]
    table = scroll_area.tables[1]
    row = table.rows[6]
    text_field = row.text_fields[1]
    assert text_field.value() == "Projects"
    row.selected.set(True)

def click_add_customer(window):
    split_group = window.splitter_groups[1]
    button = split_group.buttons[1]
    #assert button.title() == 'Add customer'
    button.click()

def click_add_project(window):
    split_group = window.splitter_groups[1]
    button = split_group.buttons[1]
    #assert button.title() == 'Add project'
    button.click()

def customer_table(window):
    split_group = window.splitter_groups[1]
    scroll_area = split_group.scroll_areas[3]
    return scroll_area.tables[1]

def project_table(window):
    split_group = window.splitter_groups[1]
    scroll_area = split_group.scroll_areas[3]
    return scroll_area.tables[1]

def update_text_field(field, value):
    field.focused.set(True)
    sysevents.keystroke(value)
    field.confirm()
    assert field.value() == value

def add_customer(window, name):
    select_customer_group(window)
    click_add_customer(window)
    row = customer_table(window).rows.last()
    update_text_field(row.text_fields[1], name)

def add_project(window, name, customer):
    select_project_group(window)
    click_add_project(window)
    row = project_table(window).rows.last()
    update_text_field(row.text_fields[1], name)
    button = window.splitter_groups[1].pop_up_buttons[1]
    button.click()
    button.menus[1].menu_items[customer].click()
    time.sleep(1)


if __name__ == '__main__':
    close_all_windows()
    assert len(hg.windows()) == 0
    
    click_new_document()
        
    doc_window = hg.windows[1]
    assert doc_window.title() == 'Untitled'
    
    
    add_customer(doc_window, 'Customer D')
    add_customer(doc_window, 'Company 3')
    add_customer(doc_window, 'Firm X')
    assert customer_table(doc_window).rows.count() == 3

    add_project(doc_window, 'Job A', 'Company 3')
    add_project(doc_window, 'Project M', 'Firm X')
    add_project(doc_window, 'Big Contract', 'Customer D')
    add_project(doc_window, 'Internal', 'Firm X')
    add_project(doc_window, 'Proj B', 'Company 3')
    assert project_table(doc_window).rows.count() == 5
    
    #filemenu.menu_items['New Task'].click()

    