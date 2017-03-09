import sys

import os

#list product support sensors

#choice sensor
sn = []
sn_path = ''
sn_items = []

def remove_sensor_items():
    #first copy items.itm to items.itm.tmp
    tg_itm = os.getcwd() + sys.argv[1] + 'items.itm'
    tmp_itm = os.getcwd() + sys.argv[1] + 'items.itm.tmp'
    os.system("cp -f " + tg_itm + ' ' +  tmp_itm)
    #print "tg_itm = " + tg_itm
    #print "file = " + file
    os.system("sed -i /\#ddk.items.start/,/#ddk.items.end/d" + ' ' + tmp_itm)

def remove_exist_config(name):
    tmp = os.getcwd() + sys.argv[1] + 'system/root/'
    target = tmp + '.ispddk'
    for (dir, subdir, file_name) in os.walk(target):
        for file_elem in file_name:
            #print file_elem
            name_list = file_elem.split('-')
            if (name_list[0] == name):
                os.system("rm -f " + target + '/' + file_elem)
            #print name_list[0]

def do_copy_sensor_items(file):
    fp = open(file, 'r')
    for line in fp.readlines():
        sn_items.append(line)
def add_to_main_item():
    tg_itm = os.getcwd() + sys.argv[1] + 'items.itm.tmp'
    tmp = []
    end = ''
    fp = open(tg_itm, 'r')
    tmp = fp.readlines()
    #print tmp
    end = tmp[len(tmp) - 1]
    tmp.remove(tmp[len(tmp)-1])
    fp.close()
    fp = open(tg_itm, 'w')

    sn_items.insert(0, "#ddk.items.start\n")
    sn_items.append("#ddk.items.end\n")
    sn_items.append(end)
    tmp.extend(sn_items)
    fp.writelines(tmp)
    fp.close()

def check_items_exist(path):
    i = 0
    file_list = []
    for(dir, subdir, file_name) in os.walk(path):
        for file_elem in file_name:
            file_list.append(file_elem)
    for el in file_list:
        if (os.path.splitext(el)[1] != ".itm"):
            i=i+1
        else:
            break
    if(i == len(file_list)):
        print "no items file ,please add, exit!"
        return 0
    else:
        #print "there is a item file"
        return 1

def do_copy_configure(path, index):
    tmp = os.getcwd() + sys.argv[1] + 'system/root/'
    target = tmp + '.ispddk'
    #print "target = " + target

    if (not os.path.exists(target)):
        os.system("mkdir " + target)
    #else:

    src = path + '/' + sn[index]
    print "src = " +src
    if (0 == check_items_exist(src)):
        exit(1)

    for (dir, subdir, file_name) in os.walk(src):
        for file_elem in file_name:
            if (os.path.splitext(file_elem)[1] != ".itm"):
               print file_elem
               os.system("cp -f "  + src + '/' + file_elem + ' ' +  target )
            elif (os.path.splitext(file_elem)[1] == ".itm"):
                do_copy_sensor_items(src + '/' + file_elem)

def list_menu(path):
    i = 0
    print "Please select sensor configure:"
    sn_list = os.listdir(path)
    if (0 == len(sn_list)):
        print "Error, the product directory have no sensor, please add!"
        return
    for itm in sn_list:
        print "  " + itm + ":"
        if (os.path.isdir(path + '/' + itm)):
            ldir = os.listdir(path + '/' + itm)
            for elem in ldir:
                sn.append(elem)
                print "     %d   :%s" %(i, elem)
                i +=1
            print "     %c   :%s" %('x', "none " + itm)
            #wait ui input the number and copy the configure file to fixed directory.
            input = raw_input("your select:")
            if (input == 'x'):
                del sn[0:]
                i = 0
                remove_exist_config(itm)
                continue
            else:
                do_copy_configure(path + '/' + itm, int(input))
            del sn[0:]
        i = 0

    #print tdict
def list_used_sensor(path):
    #print "path = " + path
    print "The current product default used sensor list:"
    #print '\033[1;31;40m'
    f = open(path, 'r')
    for line in f.readlines():
        item = line.split(' ')
        if (item[0] == "sensor0.name" or item[0] == "sensor1.name"):
            item_name = item[0].split('.')
            print '  ' + item_name[0] + ': ' + item[1]
   # print '\033[0m'

if __name__ == "__main__":   
    sn_path = os.getcwd() + sys.argv[1] + "isp"
    #print sn_path
    list_menu(sn_path)
    remove_sensor_items()
    add_to_main_item()
    prod_list=(sys.argv[1]).split('/')
    #print prod_list
    print "select sensor configure successfully to " + prod_list[-2] 

