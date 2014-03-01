//
//  glimbeaconAppDelegate.h
//  glimworm_ibeacon
//
//  Created by Jonathan Carter on 22/12/2013.
//  Copyright (c) 2013 Jonathan Carter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#import "BTDeviceModel.h"
#import "AccountModel.h"

struct myuuid{
    int b1;
    int b2;
    int b3;
    int b4;
    int b5;
    int b6;
    int b7;
};

@interface glimbeaconAppDelegate : NSObject <NSApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate>


@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSToolbar *toolbar;
@property (assign) IBOutlet NSPanel *panel;
@property (unsafe_unretained) IBOutlet NSPanel *settingspanel;
@property (unsafe_unretained) IBOutlet NSPanel *selectpanel;
@property (unsafe_unretained) IBOutlet NSPanel *workingpanel;
@property (weak) IBOutlet NSView *v_details;

- (IBAction)buttonbot:(id)sender;
@property (weak) IBOutlet NSTextField *statusbox;
@property (weak) IBOutlet NSTextField *ibuuid;
@property (weak) IBOutlet NSTextField *ibmajor;
@property (weak) IBOutlet NSTextField *ibminor;


@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;

@property  (nonatomic, strong) NSMutableArray *cvitems;
@property  (nonatomic, strong) NSMutableArray *ItemArray;
@property  (nonatomic, strong) NSMutableArray *AccountArray;
@property  (nonatomic, strong) NSMutableArray *AccountBeacons;
@property (weak) IBOutlet NSLevelIndicator *p_batterylevel;
@property (weak) IBOutlet NSTextField *p_batterlevel_txt;
@property (weak) IBOutlet NSTextField *p_firmware;

@property (weak) IBOutlet NSTextField *p_name;
@property (weak) IBOutlet NSTextField *p_name_ml;
@property (weak) IBOutlet NSTextField *p_log;
@property (weak) IBOutlet NSTextField *p_major;
@property (weak) IBOutlet NSTextField *p_minor;
@property (weak) IBOutlet NSTextField *p_maj;
@property (weak) IBOutlet NSTextField *p_min;
@property (weak) IBOutlet NSTextField *p_uuid;
@property (weak) IBOutlet NSButton *p_adv_100;
@property (weak) IBOutlet NSButton *p_adv_1280a;
@property (weak) IBOutlet NSButton *p5m;
@property (weak) IBOutlet NSButton *p50m;
@property (weak) IBOutlet NSButton *p100m;

- (IBAction)buttonstop:(id)sender;
- (IBAction)button_connect:(id)sender;
- (IBAction)button_favourite:(id)sender;
- (IBAction)p_close:(id)sender;
- (IBAction)p_read:(id)sender;
- (IBAction)p_set:(id)sender;
- (IBAction)p_help:(id)sender;
- (IBAction)toolbar_setup:(id)sender;
- (IBAction)s_close:(id)sender;
- (IBAction)p_select:(id)sender;
- (IBAction)sel_close:(id)sender;
- (IBAction)sel_item:(id)sender;
- (IBAction)p_version:(id)sender;
- (IBAction)p_adv_get:(id)sender;
- (IBAction)p_adv_100:(id)sender;
- (IBAction)p_adv_1280:(id)sender;
- (IBAction)p_battery:(id)sender;
- (IBAction)p5m:(id)sender;
- (IBAction)p50m:(id)sender;
- (IBAction)p100m:(id)sender;

@end
