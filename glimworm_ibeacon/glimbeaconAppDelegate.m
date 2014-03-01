//
//  glimbeaconAppDelegate.m
//  glimworm_ibeacon
//
//  Created by Jonathan Carter on 22/12/2013.
//  Copyright (c) 2013 Jonathan Carter. All rights reserved.
//

#import "glimbeaconAppDelegate.h"
#import <IOBluetooth/IOBluetooth.h>


@implementation glimbeaconAppDelegate
@synthesize statusbox;
@synthesize manager;
@synthesize cvitems;
@synthesize ItemArray;
@synthesize AccountArray;
@synthesize panel;
@synthesize p_name;
@synthesize p_name_ml;
@synthesize p_log;
@synthesize p_major;
@synthesize p_minor;
@synthesize p_uuid;
@synthesize p_maj;
@synthesize p_min;
@synthesize settingspanel;
@synthesize AccountBeacons;
@synthesize workingpanel;
@synthesize selectpanel;
@synthesize p_batterylevel;
@synthesize p_batterlevel_txt;
@synthesize p_firmware;
@synthesize p_adv_1280a;
@synthesize p_adv_100;
@synthesize v_details;
@synthesize p50m;
@synthesize p5m;
@synthesize p100m;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    manager = [[CBCentralManager alloc] initWithDelegate:self
                                                       queue:nil];
    
}

static NSString *const kServiceUUID = @"5B2EABB7-93CB-4C6A-94D4-C6CF2F331ED5";
static NSString *const kCharacteristicUUID = @"D589A9D6-C7EE-44FC-8F0E-46DD631EC940";

BTDeviceModel* currentPeripheral = Nil;
CBCharacteristic *_currentChar = Nil;
NSString *currentcommand = @"";
NSString *currentfirmware = @"";



- (void)startScan {
    NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES};
//    CBUUID *serviceUUID = [CBUUID UUIDWithString:kServiceUUID];
    [self.manager scanForPeripheralsWithServices:nil options:options];
    [statusbox setStringValue:@"scanning"];
    
}


- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {

    NSLog(@" servicesDISCOVERED ( %@ )", [aPeripheral name]);
    for (CBService *service in aPeripheral.services) {
        NSLog(@"Discovered service s: %@", service);
        NSLog(@"Discovered service u: %@", service.UUID);

        /* connect to serial bluetooth */
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
        {
            [aPeripheral discoverCharacteristics:nil forService:service];
        }
    }
}


- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE0"]])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            /* Set notification on heart rate measurement */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
            {
                NSLog(@"Found a serial connectionCharacteristic, properties %@", aChar.UUID);
                
                [p_name_ml setStringValue:@"Found a serial connectionCharacteristic, enquiring about name"];

                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
                
//                NSString *val = @"AT+NAME? ";
//                NSData* payload = [val dataUsingEncoding:NSUTF8StringEncoding];
//                [aPeripheral writeValue:payload forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
                
                _currentChar = aChar;
                _peripheral = aPeripheral;
                
                [self working];
                [self performSelector:@selector(q_readall) withObject:self afterDelay:3.0];
//                [self q_readall];
                
                
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"-- didWriteValueForCharacteristic");
    /* Updated value for heart rate measurement received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
    {
        if( (characteristic.value)  || !error )
        {
            /* Update UI with heart rate data */
            NSLog(@"wrote characteristic val: %@ , %@", characteristic.value, characteristic.UUID);
            [p_log setStringValue: [[NSString alloc] initWithFormat:@"written : %@", characteristic.value] ];
        }
    }
    
}

/*
 this is the one that gets called
*/

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"-- didUpdateValueForCharacteristic");

    /* Updated value for heart rate measurement received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
    {
        if( (characteristic.value)  || !error )
        {
            /* Update UI with heart rate data */
            NSLog(@"updated characteristic val: %@ , %@", characteristic.value, characteristic.UUID);
            
            NSString *str=[[NSString alloc] initWithBytes:characteristic.value.bytes length:characteristic.value.length encoding:NSUTF8StringEncoding];
            NSLog(@"retval %@", str);
            
            NSString *logmessage = [[NSString alloc] initWithFormat:@"'%@' : '%@'", currentcommand, str];

            [p_log setStringValue: logmessage ];
            
            NSLog(@"currentcommand %@", currentcommand);
            NSLog(@"currentcommand:retval %@", str);
            
            if ([currentcommand isEqualToString:@"AT+VERS?"]) {

                NSArray *array = [str componentsSeparatedByString:@" "];
                [p_firmware setStringValue:array[1]];
                currentfirmware = [[NSString alloc] initWithFormat:@"%@", array[1]];
                
                if ([currentfirmware isEqualToString:@"V517"]) {
                    // dvert 0 = 100 , 1 = 1280
                    
                } else if ([currentfirmware isEqualToString:@"V518"]) {
                    
                } else if ([currentfirmware isEqualToString:@"V519"]) {

                } else if ([currentfirmware isEqualToString:@"V520"]) {
                
                } else if ([currentfirmware isEqualToString:@"V521"]) {
                
                } else if ([currentfirmware isEqualToString:@"V522"]) {
                
                }
                
            }
            
            if ([currentcommand isEqualToString:@"AT+POWE?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                NSLog(@"array %@",array[1]);
                int val = [array[1] intValue];
                if (val == 0) {
                    p5m.state = 0;
                    p50m.state = 0;
                    p100m.state = 0;
                }
                if (val == 1) {
                    p5m.state = 1;
                    p50m.state = 0;
                    p100m.state = 0;
                }
                if (val == 2) {
                    p5m.state = 0;
                    p50m.state = 1;
                    p100m.state = 0;
                }
                if (val == 3) {
                    p5m.state = 0;
                    p50m.state = 0;
                    p100m.state = 1;
                }
            }
            
            if ([currentcommand isEqualToString:@"AT+ADVI?"]) {
                NSArray *array = [str componentsSeparatedByString:@":"];
                
                NSLog(@"array %@",array[1]);
                int val = [array[1] intValue];
                
                if (val == 0) {
                    p_adv_100.state = 1;
                    p_adv_1280a.state = 0;
                    
                } else if (val == 1) {
                    p_adv_100.state = 0;
                    p_adv_1280a.state = 1;
                } else {

                }

            }

            
            
            if ([currentcommand isEqualToString:@"AT+BATT?"]) {
                
                NSLog(@"currentcommand MATCHED");
                
                NSArray *array = [str componentsSeparatedByString:@":"];

                double dv = [array[1] doubleValue];
                NSLog(@"array %@",array[1]);
                NSLog(@"array intvalue %ld",(long)[array[1] integerValue]);
                NSLog(@"array intvalue %d",[array[1] intValue]);
                NSLog(@"array intvalue %f",dv);
                
                [p_batterylevel setDoubleValue:dv];
                [p_batterlevel_txt setDoubleValue:dv];
                
                [p_log setStringValue: @"Battery level" ];
            }

            
            
            [self q_next];
            
        }
    }
}


/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@" connectED ( %@ )", [aPeripheral name]);
    
    [self stopScan];
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    
//    self.connected = @"Connected";
//    [connectButton setTitle:@"Disconnect"];
//    [indicatorButton setHidden:TRUE];
//    [progressIndicator setHidden:TRUE];
//    [progressIndicator stopAnimation:self];
}
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@" DISconnectED ( %@ )", [aPeripheral name]);
    [self startScan];
}

- (NSString *) uuidToString:(CFUUIDRef)UUID {
    NSString *retval = CFBridgingRelease(CFUUIDCreateString(NULL, UUID));
    return retval;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *value = [[NSString alloc] initWithFormat:@"disc %@ %@ %@", peripheral.name, RSSI, peripheral.UUID];
    NSString *_uuid = [[NSString alloc] initWithFormat:@"%@", peripheral.UUID];
//    NSString *_name = [[NSString alloc] initWithFormat:@"%@", peripheral.name];
    NSString *_name = [[NSString alloc] initWithFormat:@"%@", peripheral.UUID];

    NSString *u = [self uuidToString:peripheral.UUID];

    NSLog(@"CFSTRINGREF u %@",u);
    NSLog(@"CFSTRINGREF U %@",_uuid);
    
    @try {
    
    
    [statusbox setStringValue:value];
    
    if (_name == NULL) _name = @"";

    for (int i=0; i < [ItemArray count]; i++) {
        BTDeviceModel *m = [ItemArray objectAtIndex:i];

        NSLog(@"CFSTRINGREF MNAME %@",m.name);
        
        if ([m.name isEqualTo: (_name)] || [m.name isEqualToString: (_name)])
        {
            m.RSSI = RSSI;

            for (CBService* service in peripheral.services)
            {
                NSString *__uuid = [[NSString alloc] initWithFormat:@"LS : %@", service.UUID];
                NSLog(@"%@",__uuid);
            }

            
            for (id key in [advertisementData allKeys]){
                id obj = [advertisementData objectForKey: key];
                
                //NSLog(@"key : %@  value : %@",key,obj);
                
                NSString *_key = [[NSString alloc] initWithFormat:@"%@", key];
                
                if ([_key isEqualToString:@"kCBAdvDataManufacturerData"]) {
                    NSString *ss2 = [NSString stringWithFormat:@"%@",obj];
                    //NSLog(@"ss2 : %@",ss2);
                    NSString *ib_uuid = [NSString stringWithFormat:@"%@-%@-%@-%@-%@%@",
                                         [ss2 substringWithRange:NSMakeRange(10, 8)],
                                         [ss2 substringWithRange:NSMakeRange(19, 4)],
                                         [ss2 substringWithRange:NSMakeRange(23, 4)],
                                         [ss2 substringWithRange:NSMakeRange(28, 4)],
                                         [ss2 substringWithRange:NSMakeRange(32, 4)],
                                         [ss2 substringWithRange:NSMakeRange(37, 8)]
                                         ];
                    NSString *ib_major = [NSString stringWithFormat:@"%@%@",
                                          [ss2 substringWithRange:NSMakeRange(46, 2)],
                                          [ss2 substringWithRange:NSMakeRange(48, 2)]];
                    
                    NSString *ib_minor = [NSString stringWithFormat:@"%@%@",
                                          [ss2 substringWithRange:NSMakeRange(50, 2)],
                                          [ss2 substringWithRange:NSMakeRange(52, 2)]];
                    
                    m.ib_uuid = ib_uuid;
                    m.ib_major = ib_major;
                    m.ib_minor = ib_minor;
                    [self findItemInAccountArray:m];
                    
                }
            }
            
            return;
        }
    }
    
    [peripheral discoverServices:Nil];

    BTDeviceModel * pm = [[BTDeviceModel alloc] init];
    pm.name = _name;
    pm.UUID = _uuid;
    pm.RSSI = RSSI;
    pm.peripheral = peripheral;
    pm.ib_uuid = @"";
    pm.ib_major = @"";
    pm.ib_minor = @"";
    
    
    NSLog(@"%@",value);
    NSLog(@"%@", [advertisementData description]);
    NSLog(@"1000 %@",value);
    NSLog(@"2000 %@", [advertisementData description]);
    
        
    for (id key in [advertisementData allKeys]){
        id obj = [advertisementData objectForKey: key];

        NSLog(@"key : %@  value : %@",key,obj);
        
        NSString *_key = [[NSString alloc] initWithFormat:@"%@", key];
        

        if ([_key isEqualToString:@"kCBAdvDataManufacturerData"]) {
            NSString *ss2 = [NSString stringWithFormat:@"%@",obj];
            NSString *ib_uuid = [NSString stringWithFormat:@"%@-%@-%@-%@-%@%@",
                                                    [ss2 substringWithRange:NSMakeRange(10, 8)],
                                                    [ss2 substringWithRange:NSMakeRange(19, 4)],
                                                    [ss2 substringWithRange:NSMakeRange(23, 4)],
                                                    [ss2 substringWithRange:NSMakeRange(28, 4)],
                                                    [ss2 substringWithRange:NSMakeRange(32, 4)],
                                                    [ss2 substringWithRange:NSMakeRange(37, 8)]
                                 ];
            NSString *ib_major = [NSString stringWithFormat:@"%@",
                                 [ss2 substringWithRange:NSMakeRange(46, 4)]];

            NSString *ib_minor = [NSString stringWithFormat:@"%@",
                                  [ss2 substringWithRange:NSMakeRange(50, 4)]];

            NSLog(@"AdvDataArray: IBUUID : %@ ",ib_uuid);
            NSLog(@"AdvDataArray: IBMAJOR : %@ ",ib_major);
            NSLog(@"AdvDataArray: IBINOR : %@ ",ib_minor);
            pm.ib_uuid = ib_uuid;
            pm.ib_major = ib_major;
            pm.ib_minor = ib_minor;

            
        }
    }
    
    [self insertObject:pm inItemArrayAtIndex:0];
    [self findItemInAccountArray:pm];
        
        
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    @finally {
        NSLog(@"finally");
    }
    
}

- (void)stopScan {
    [self.manager stopScan];
}

-(void)insertObject:(BTDeviceModel *)p incvitemsAtIndex:(NSUInteger)index {
    [cvitems insertObject:p atIndex:index];
}

-(void)removeObjectFromcvitemsAtIndex:(NSUInteger)index {
    [cvitems removeObjectAtIndex:index];
}

-(void)setcvitems:(NSMutableArray *)a {
    cvitems = a;
}

-(NSArray*)cvitems {
    return cvitems;
}

-(void)insertObject:(BTDeviceModel *)p inItemArrayAtIndex:(NSUInteger)index {
    [ItemArray insertObject:p atIndex:index];
}

-(void)removeObjectFromItemArrayAtIndex:(NSUInteger)index {
    [ItemArray removeObjectAtIndex:index];
}

-(void)setItemArray:(NSMutableArray *)a {
    ItemArray = a;
}

-(NSArray*)itemArray {
    return ItemArray;
}

/* account array */

-(void)insertObject:(AccountModel *)p inAccountArrayAtIndex:(NSUInteger)index {
    [AccountArray insertObject:p atIndex:index];
}

-(void)removeObjectFromAccountArrayAtIndex:(NSUInteger)index {
    [AccountArray removeObjectAtIndex:index];
}

-(void)setAccountArray:(NSMutableArray *)a {
    AccountArray = a;
}

-(NSArray*)accountArray {
    return AccountArray;
}


/* account beacons */

-(void)insertObject:(BTDeviceModel *)p inAccountBeaconsAtIndex:(NSUInteger)index {
    [AccountBeacons insertObject:p atIndex:index];
}

-(void)removeObjectFromAccountBeaconsAtIndex:(NSUInteger)index {
    [AccountBeacons removeObjectAtIndex:index];
}

-(void)setAccountBeacons:(NSMutableArray *)a {
    AccountBeacons = a;
}

-(NSArray*)accountBeacons {
    return AccountBeacons;
}



-(void)awakeFromNib {
    
    BTDeviceModel * pm = [[BTDeviceModel alloc] init];
    pm.name = @"Na";
    pm.UUID = @"UU";
    pm.RSSI = 0;
    
    BTDeviceModel * pm1 = [[BTDeviceModel alloc] init];
    pm1.name = @"Na1";
    pm1.UUID = @"UU1";
    pm1.RSSI = 0;
    //NSMutableArray * tempArray = [NSMutableArray arrayWithObjects:pm, pm1, nil];

    NSMutableArray * tempArray = [NSMutableArray arrayWithObjects:nil];
    [self setItemArray:tempArray];
    
    AccountModel * ac1 = [[AccountModel alloc] init];
    ac1.name = @"default";
    ac1.type = @"cloud";
    ac1.url = @"";
    ac1.username = @"";
    ac1.password = @"";

    AccountModel * ac2 = [[AccountModel alloc] init];
    ac2.name = @"custom";
    ac2.type = @"cloud";
    ac2.url = @"";
    ac2.username = @"";
    ac2.password = @"";
    
    NSMutableArray * tempAccountArray = [NSMutableArray arrayWithObjects:ac1,ac2,nil];
    [self setAccountArray:tempAccountArray];
    

    [statusbox setStringValue:@"awoke"];
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [statusbox setStringValue:@"state update"];

    if (central.state == CBCentralManagerStatePoweredOn) {
        [statusbox setStringValue:@"state update powered on"];

        
        
        
//        [self startScan];
        
//        [self.deviceTextField setStringValue:@"..."];
//        [self.orientationTextField setStringValue:@""];
    }
    else if (central.state == CBCentralManagerStatePoweredOff) {
        [statusbox setStringValue:@"state update powered off"];
        NSAlert *alert = [NSAlert alertWithMessageText:@"Bluetooth is currently powered off." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
        [alert runModal];
    }
    else if (central.state == CBCentralManagerStateUnauthorized) {
        [statusbox setStringValue:@"state update powered unauthorized"];
        NSAlert *alert = [NSAlert alertWithMessageText:@"The app is not authorized to use Bluetooth Low Energy." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
        [alert runModal];
    }
    else if (central.state == CBCentralManagerStateUnsupported) {
        [statusbox setStringValue:@"state update powered unsupported"];
        NSAlert *alert = [NSAlert alertWithMessageText:@"The platform/hardware doesn't support Bluetooth Low Energy." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
        [alert runModal];
    }
    
    
    
}
- (IBAction)buttonbot:(id)sender {
    [statusbox setStringValue:@"test"];
    [self startScan];
    
//    NSString * ret = [self getDataFrom:@"http://jon651.glimworm.com/ibeacon/api.php?action=beacons&verb="];
//    NSLog(ret);
    
    [self readItemsFromAccountArray];
    
    
}
- (BTDeviceModel *) findItemInAccountBeaconArray:(NSString *)BEACONID{
    for (BTDeviceModel * btitem in AccountBeacons) {
        if ([BEACONID isEqualToString:btitem.ID ]) {
            return btitem;
        }
    }
    return Nil;
}

- (void) findItemInAccountArray:(BTDeviceModel *)BEACON{
    //NSLog(@"BEACON U:%@ MA:%@ MI:%@ NA:%@",BEACON.ib_uuid, BEACON.ib_major, BEACON.ib_minor, BEACON.name);
    for (BTDeviceModel * btitem in AccountBeacons) {
        //NSLog(@"BTITEM U:%@ MA:%@ MI:%@ NA:%@",btitem.ib_uuid, btitem.ib_major, btitem.ib_minor, btitem.name);
        if ([BEACON.ib_uuid isEqualToString:btitem.ib_uuid ] &&
            [BEACON.ib_major isEqualToString:btitem.ib_major ] &&
            [BEACON.ib_minor isEqualToString:btitem.ib_minor ]) {
            BEACON.found = @"y";
        }
    }
}

- (void) readItemsFromAccountArray {
    // REF FOR JSON
    // http://stackoverflow.com/questions/19881924/parse-json-string-and-array-with-nsjsonserialization-issue
    
    NSURL * url=[NSURL URLWithString:@"http://jon651.glimworm.com/ibeacon/api.php?action=beacons&verb="];   // pass your URL  Here.
    NSData * data=[NSData dataWithContentsOfURL:url];
    NSError * error;
    NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    NSLog(@"%@",json);
    
    //    NSLog(@"Jsondic: %@", [json objectForKey:@"data"]);
    
    NSArray * dataa = json[@"data"][@"items"];
    
    NSMutableArray * tempArray = [NSMutableArray arrayWithObjects:nil];
    
    [self setAccountBeacons:tempArray];
    
    for (NSMutableDictionary * item in dataa) {
        BTDeviceModel * pm = [[BTDeviceModel alloc] init];
        pm.name = item[@"name"];
        pm.UUID = item[@"uuid"];
        pm.ib_uuid = item[@"ib_uuid"];
        pm.ib_major = item[@"ib_major"];
        pm.ib_minor = item[@"ib_minor"];
        pm.ID = item[@"id"];
        [self insertObject:pm inAccountBeaconsAtIndex:0];
//        [AccountBeacons addObject:pm];
    }
    NSLog(@"%@",AccountBeacons);

}


- (IBAction)toolbar_setup:(id)sender {
    [[NSApplication sharedApplication] beginSheet:settingspanel
                                   modalForWindow:self.window
                                    modalDelegate:self
                                   didEndSelector:Nil
                                      contextInfo:nil];
    
    
}

- (IBAction)s_close:(id)sender {
    [NSApp endSheet:settingspanel];
    [settingspanel orderOut:self];

}



- (IBAction)p_select:(id)sender {
    [[NSApplication sharedApplication] beginSheet:selectpanel
                                   modalForWindow:panel
                                    modalDelegate:self
                                   didEndSelector:Nil   //@selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
    
    
}

- (IBAction)sel_close:(id)sender {
    [NSApp endSheet:selectpanel];
    [selectpanel orderOut:self];
    
}

- (IBAction)sel_item:(id)sender {

    BTDeviceModel * btm = [self findItemInAccountBeaconArray:[sender alternateTitle]];
    if (btm != Nil) {
        [p_major setStringValue:btm.ib_major];
        [p_minor setStringValue:btm.ib_minor];
        [p_uuid setStringValue:btm.ib_uuid];
        [p_name setStringValue:btm.name];
    }
}

- (IBAction)p_version:(id)sender {

    NSData *data = [_VERSION dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    currentcommand = [[NSString alloc] initWithFormat:@"%@",str];
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];


}

- (IBAction)p_adv_get:(id)sender {
    
    NSData *data = [_ADV_GET dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    currentcommand = @"AT+ADVI?";
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];

}

- (IBAction)p_adv_100:(id)sender {
    NSData *data = [_ADV_100 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    currentcommand = @"AT+ADVI?";
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
}

- (IBAction)p_adv_1280:(id)sender {
    NSData *data = [_ADV_1280 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    currentcommand = @"AT+ADVI?";
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
}

- (IBAction)p_battery:(id)sender {
    NSData *data = [_BATT dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    currentcommand = @"AT+BATT?";
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];

}

- (IBAction)p5m:(id)sender {
    NSData *data = [@"AT+POWE1" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    currentcommand = @"AT+POWE?";
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
}

- (IBAction)p50m:(id)sender {
    NSData *data = [@"AT+POWE2" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    currentcommand = @"AT+POWE?";
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
}

- (IBAction)p100m:(id)sender {
    NSData *data = [@"AT+POWE3" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    currentcommand = @"AT+POWE?";
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
}

- (IBAction)w_cancel:(id)sender {
    [self done];
}

- (IBAction)buttonstop:(id)sender {
    [self stopScan];
}

- (IBAction)button_connect:(id)sender {

    NSLog([[NSString alloc] initWithFormat:@" connect ( %@ )", [sender alternateTitle] ]);
    NSString *_name = [[NSString alloc] initWithFormat:@"%@", [sender alternateTitle]];

    currentPeripheral = Nil;
    for (BTDeviceModel* m in ItemArray) {
        if ( [m.name isEqualTo: (_name)] || [m.name isEqualToString: (_name)]) {
            currentPeripheral = m;
        }
    }
    
    if (currentPeripheral != Nil) {
        [p_name setStringValue: currentPeripheral.name];
        
        unsigned int ibmajor;
        NSScanner* scanner = [NSScanner scannerWithString:currentPeripheral.ib_major];
        [scanner scanHexInt:&ibmajor];
        NSString *ibmajor_str = [[NSString alloc] initWithFormat:@"%u", ibmajor];

        unsigned int ibminor;
        scanner = [NSScanner scannerWithString:currentPeripheral.ib_minor];
        [scanner scanHexInt:&ibminor];
        NSString *ibminor_str = [[NSString alloc] initWithFormat:@"%u", ibminor];

        
        
        [p_major setStringValue: ibmajor_str];
        [p_minor setStringValue: ibminor_str];
        [p_uuid setStringValue: currentPeripheral.ib_uuid];
        [p_maj setStringValue: currentPeripheral.ib_major];
        [p_min setStringValue: currentPeripheral.ib_minor];
        [p_name_ml setStringValue:@""];
        [p_log setStringValue:@""];
        [p_batterylevel setDoubleValue:0.0];
        [p_batterlevel_txt setStringValue:@""];
        [p_firmware setStringValue:@""];
        p_adv_1280a.state = 0;
        p_adv_100.state = 0;
        p5m.state = 0;
        p50m.state = 0;
        p100m.state = 0;
        
        currentcommand = @"";
        currentfirmware = @"";
        
        
        [self.manager connectPeripheral:currentPeripheral.peripheral options:nil];

    }
    

    [[NSApplication sharedApplication] beginSheet:panel
                                   modalForWindow:self.window
                                    modalDelegate:self
                                   didEndSelector:Nil   //@selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
    
    [self working];
    
}

- (IBAction)button_favourite:(id)sender {
    NSLog([[NSString alloc] initWithFormat:@" favourite ( %@ )", [sender alternateTitle] ]);
    NSString *_name = [[NSString alloc] initWithFormat:@"%@", [sender alternateTitle]];
    
    currentPeripheral = Nil;
    for (BTDeviceModel* m in ItemArray) {
        if ( [m.name isEqualTo: (_name)] || [m.name isEqualToString: (_name)]) {
            currentPeripheral = m;
        }
    }
    
    if (currentPeripheral != Nil) {

        NSString *_url = [[NSString alloc] initWithFormat:@"http://jon651.glimworm.com/ibeacon/api.php?action=beacons&verb=insert&name=newitem&ib_uuid=%@&&ib_major=%@&ib_minor=%@", [currentPeripheral ib_uuid], [currentPeripheral ib_major], [currentPeripheral ib_minor]];
        
        NSLog(@"%@",_url);

        NSURL * url=[NSURL URLWithString:_url] ;
        NSData * data=[NSData dataWithContentsOfURL:url];
        NSError * error;

        NSLog(@"data: %@",data);
        NSLog(@"error: %@",error);
        
        NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
        NSLog(@"%@",json);
    } else {
        NSLog(@"Name %@ not found",_name);
    }

}

- (IBAction)p_close:(id)sender {
    
    if (currentPeripheral != Nil) {

        if(currentPeripheral.peripheral && ([currentPeripheral.peripheral isConnected]))
        {
            /* Disconnect if it's already connected */
            if (_currentChar != Nil) {
                [currentPeripheral.peripheral setNotifyValue:NO forCharacteristic:_currentChar];
            }
            [self.manager cancelPeripheralConnection:currentPeripheral.peripheral];
        }
    }
    _currentChar = Nil;
    currentPeripheral = Nil;
    
    [NSApp endSheet:panel];
    [panel orderOut:self];
    
}

const char HELP[] = "\x41\x54\x2B\x48\x45\x4C\x50\x3F";     // AT+HELP?
const NSString *_HELP = @"AT+HELP?";
const NSString *_VERSION = @"AT+VERS?";

const NSString *_ADV_GET = @"AT+ADVI?";
const NSString *_ADV_100 = @"AT+ADVI0";
const NSString *_ADV_1280 = @"AT+ADVI1";

const NSString *_BATT = @"AT+BATT?";

const char NAME[] = "\x41\x54\x2B\x4E\x41\x4D\x45\x3F";     //   AT+NAME?
const char GET[] = "\x41\x54\x2B\x4D\x41\x52\x4A\x3F";     // AT+MARJ?
const char SET[] = "\x41\x54\x2B\x4D\x41\x52\x4A\x30\x78\x30\x31\x30\x32";     // AT+MARJ0x0102

//const char CMD[] = "\x41\x54\x2B\x4E\x41\x4D\x45\x3F";     //   AT+NAME?
//const char CMD[] = "\x41\x54\x2B\x48\x45\x4C\x50\x3F";     // AT+HELP?
const char CMD[] = "\x41\x54\x2B\x4D\x41\x52\x4A\x3F";     // AT+MARJ?

- (IBAction)p_read:(id)sender {

    [self working];
    [self q_readall];

}

- (void)q_readall {


    NSString *get1 = [[NSString alloc] initWithFormat:@"AT+VERS?"];
    NSString *get2 = [[NSString alloc] initWithFormat:@"AT+BATT?"];
    NSString *get3 = [[NSString alloc] initWithFormat:@"AT+ADVI?"];
    NSString *get4 = [[NSString alloc] initWithFormat:@"AT+POWE?"]; // 0 1 2 3 2 = std
    NSString *get5 = [[NSString alloc] initWithFormat:@"AT+TYPE?"]; // 2 PIN
//    NSString *get6 = [[NSString alloc] initWithFormat:@"AT+MEAS?"]; // Value
    
    Queue = [NSMutableArray arrayWithObjects:get1,get2,get3,get4,get5,nil];

    [self q_next];
}

- (void)working {
    
    [[NSApplication sharedApplication] beginSheet:workingpanel
                                   modalForWindow:panel
                                    modalDelegate:self
                                   didEndSelector:Nil
                                      contextInfo:nil];
}

- (void)done {
    [NSApp endSheet:workingpanel];
    [workingpanel orderOut:self];
}




//  THE QUEUE
//
//  process the next item in the queue
//
//
//

NSMutableArray *Queue;

- (void)q_next {
    
    // than you to https://github.com/mattjgalloway/MJGFoundation/blob/master/Source/Model/MJGStack.m for the queue code
    
    NSLog(@"Q_NEXT");
    NSLog(@"Q_NEXT CNT %lu ",(unsigned long)Queue.count);

    if (Queue.count > 0) {
        
        NSString *q_str = [Queue objectAtIndex:0];
        [Queue removeObjectAtIndex:(0)];
        NSLog(@"Q_NEXT STR %@", q_str);
        
        
        /* skip this if the versions are too old */
        /* v517
            1. Add AT+IBEA command (Open close iBeacon)
            2. Add AT+MARJ command (Query/Set iBeacon marjor)
            3. Add AT+MINO command (Query/Set iBeacon minor)
         */
        
        if ([currentfirmware isEqualToString:@"V517"] && [currentcommand isEqualToString:@"AT+MEAS?"]) [self q_next];
        if ([currentfirmware isEqualToString:@"V518"] && [currentcommand isEqualToString:@"AT+MEAS?"]) [self q_next];
        if ([currentfirmware isEqualToString:@"V519"] && [currentcommand isEqualToString:@"AT+MEAS?"]) [self q_next];

        if ([currentfirmware isEqualToString:@"V517"] && [currentcommand isEqualToString:@"AT+MEAS?"]) [self q_next];
        if ([currentfirmware isEqualToString:@"V518"] && [currentcommand isEqualToString:@"AT+MEAS?"]) [self q_next];
        if ([currentfirmware isEqualToString:@"V519"] && [currentcommand isEqualToString:@"AT+MEAS?"]) [self q_next];
        if ([currentfirmware isEqualToString:@"V520"] && [currentcommand isEqualToString:@"AT+MEAS?"]) [self q_next];
        

        currentcommand = [[NSString alloc] initWithFormat:@"%@", q_str];
        
        NSData *data = [q_str dataUsingEncoding:NSUTF8StringEncoding];
        NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
        [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];
    } else {
        currentcommand = @"";
        [self done];
    }
    
}
- (IBAction)p_set:(id)sender {

    // thanks for the formaating of the hex to http://stackoverflow.com/questions/5473896/objective-c-converting-an-integer-to-a-hex-value
    
    
    NSString *ibmajor_str_val = [[NSString alloc] initWithFormat:@"%04X", [p_major intValue]];
    NSString *ibminor_str_val = [[NSString alloc] initWithFormat:@"%04X", [p_minor intValue]];
    
    NSString *ibmajor_str = [[NSString alloc] initWithFormat:@"AT+MARJ0x%@%@",
                             [ibmajor_str_val substringWithRange:NSMakeRange(0,2)],
                             [ibmajor_str_val substringWithRange:NSMakeRange(2,2)]];
    

    NSString *ibminor_str = [[NSString alloc] initWithFormat:@"AT+MINO0x%@%@",
                             [ibminor_str_val substringWithRange:NSMakeRange(0,2)],
                             [ibminor_str_val substringWithRange:NSMakeRange(2,2)]];
    
    NSString *name_str = [[NSString alloc] initWithFormat:@"AT+NAME%@", [p_name stringValue]];

    
    Queue = [NSMutableArray arrayWithObjects:ibmajor_str,ibminor_str,name_str,nil];
    
    [self q_next];

    /*
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:ibmajor_str];
    [alert addButtonWithTitle:ibminor_str];
    [alert setMessageText:str];
    [alert setInformativeText:str];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
     */
    
//    size_t length = (sizeof SET) - 1; //string literals have implicit trailing '\0'
//    NSData *data = [NSData dataWithBytes:SET length:length];
//    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
//    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
//    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];

}



//- (BOOL)p_n

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string




- (IBAction)p_help:(id)sender {

    NSData *data = [_HELP dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str=[[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
    [p_log setStringValue: [[NSString alloc] initWithFormat:@"awaiting response for : %@ ...", str] ];
    [currentPeripheral.peripheral writeValue:data forCharacteristic:_currentChar type:CBCharacteristicWriteWithResponse];

}


- (NSString *) getDataFrom:(NSString *)url{
    // ref from http://stackoverflow.com/questions/9404104/simple-objective-c-get-request
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}



@end
