from scapy.all import *

import time

server_ip = '0.0.0.0'

protocols = {1:'ICMP', 6:'TCP', 17:'UDP'}

options = {66:'Acid Resistance +5',67:'Acid Resistance +10',68:'Acid Resistance +15',
          78:'Attack Speed +5',79:'Attack Speed +10',80:'Attack Speed +15',
          81:'Attack Speed +20',82:'Attack Speed +25',
          183:'All Attributes +1',184:'All Attributes +2',185:'All Attributes +3',
          72:'Blood Resistance +5',73:'Blood Resistance +10',74:'Blood Resistance +15',
          83:'Critical Hit +2',84:'Critical Hit +4',85:'Critical Hit +6',
          86:'Critical Hit +8',87:'Critical Hit +10',
          69:'Curse Resistance +5',70:'Curse Resistance +10',71:'Curse Resistance +15',
          48:'Damage +1',49:'Damage +2',50:'Damage +3',51:'Damage +4',52:'Damage +5',
          43:'Defense +1',44:'Defense +2',45:'Defense +3',46:'Defense +4',47:'Defense +5',
          6:'DEX +1',7:'DEX +2',8:'DEX +3',9:'DEX +4',10:'DEX +5',
          58:'Durability +20%',59:'Durability +40%',60:'Durability +60%',61:'Durability +80%',62:'Durability +100%',
          16:'HP +3',17:'HP +6',18:'HP +9',19:'HP +12',20:'HP +15',
          174:'HP Regen +1',33:'HP Regen +3',34:'HP Regen +5',
          26:'HP Steal +1',27:'HP Steal +2',28:'HP Steal +3',
          11:'INT +1',12:'INT +2',13:'INT +3',14:'INT +4',15:'INT +5',
          175:'LUCK +1',176:'LUCK +2',177:'LUCK +3',
          21:'MP +5',22:'MP +10',23:'MP +15',24:'MP +20',25:'MP +25',
          35:'MP Regen +1',36:'MP Regen +3',37:'MP Regen +5',
          29:'MP Steal +1',30:'MP Steal +2',31:'MP Steal +3',
          63:'Poison Resistance +5',64:'Poison Resistance +10',65:'Poison Resistance +15',
          53:'Protection +1',54:'Protection +2',55:'Protection +3',56:'Protection +4',57:'Protection +5',
          178:'All Resistance +1',179:'All Resistance +3',180:'All Resistance +5',181:'All Resistance +7',182:'All Resistance +9',
          1:'STR +1',2:'STR +2',3:'STR +3',4:'STR +4',5:'STR +5',
          38:'To Hit +1',39:'To Hit +2',40:'To Hit +3',41:'To Hit +4',42:'To Hit +5',
          75:'Vision +1',76:'Vision +2',77:'Vision +3',
          None:''
          }
		  
def print_drop_item_info(Class_ID = None, Item_ID = None, Option_ID = None, Option_ID2 = None):
    return options[Option_ID] + ' ' + options[Option_ID2]
	

#IFACES.show()


def my_callback(packet):
    global protocols
    
    data = bytes(packet[0].payload).hex()
    data = data[80:]
    length = 2
    data = [data[0 + i:length + i] for i in range(0, len(data), length)]


    try:
        src_ip = packet[0][1].src
        protocol = protocols[packet[0][1].proto]
        data_len = len(data)

        if server_ip == src_ip and protocol == 'TCP':
            
            try:
                
                option_id = None
                option_id2 = None
                
                
                if (data_len >= 34):
                
                
                    now = time
                    current_time = now.strftime('%Y-%m-%d %H:%M:%S')
                    
                    option_list = []
                
                    p = re.compile('02[0-9a-z]{4}000004000000')
                    results = p.findall(''.join(data))
                    
                    for result in results:
                        
                        option1, option2 = '', ''
                        
                        if result[:2] == '02':
                            option1 = options[int(result[2:4], 16)]
                            option2 = options[int(result[4:6], 16)]
                            
                            
                            if option1 != '' and option2 != '':
                                option_list.append(current_time + ': ' + option1 + ' ' +option2)
                                 
                                data = ''.join(data)
                                data = data.replace(result, '')
                            
                                length = 2
                                data = [data[0 + i:length + i] for i in range(0, len(data), length)]
                    

                
                    p = re.compile('01[0-9a-z]{2}000004000000')
                    results = p.findall(''.join(data))

                    for result in results:

                        option1 = ''

                        if result[:2] == '01':
                            option1 = options[int(result[2:4], 16)]
                            if option1 != '':
                                option_list.append(current_time + ': ' + option1)
                        
                      
                    if len(option_list) > 0:
                        print()
                        for option_ in option_list:
                            print(option_)
                            
                    #print(''.join(data), data_len)
                    

                
                """
                if (data_len == 34 and data[15] == '01'):
                    option_id = int(data[16], 16)
                    

                elif (data_len ==35 and data[15] == '02'):
                    option_id = int(data[16], 16)
                    option_id2 = int(data[17], 16)

                if option_id != None or option_id2 != None:
                    Class_ID = int(data[12], 16)
                    Item_ID = int(data[13], 16)
                    arg1 = int(data[14], 16)
                    
                    arg_0 = int(data[6], 16)
                    arg_1 = int(data[7], 16)
                    arg_2 = int(data[8], 16)
                    arg_3 = int(data[9], 16)
                    arg_4 = int(data[10], 16)
                    arg_5 = int(data[11], 16)
                    arg_6 = int(data[12], 16)
                    arg_7 = int(data[13], 16)
                    arg_8 = int(data[14], 16)
                                
                        
                    #option_name = print_drop_item_info(Option_ID=option_id,Option_ID2=option_id2)
                    #print( arg_0, arg_1, arg_2, arg_3, arg_4, arg_5, arg_6, arg_7, arg_8, option_name)
                    
                    
                    
                    #print(Class_ID, Item_ID, arg1, option_name)
                
                if data_len >= 33:
                    #print(' '.join(data), data_len)
                    print(''.join(data), data_len)
                    #print(src_ip, data, len(data))
                    
                """
                
            except Exception as e:
                #print(e)
                pass

    except:
        pass

iface = "Realtek PCIe GbE Family Controller"

sniff(iface=iface, prn=my_callback)