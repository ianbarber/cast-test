//
//  ViewController.h
//  TestyTest
//
//  Created by Ian Barber on 30/07/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>

@interface ViewController : UIViewController <
GCKDeviceFilterListener,
GCKDeviceScannerListener,
GCKDeviceManagerDelegate,
GCKLoggerDelegate,
GCKMediaControlChannelDelegate>
- (IBAction)didDisableSubs:(id)sender;
- (IBAction)didStopMovie:(id)sender;
- (IBAction)didStartMovie:(id)sender;

@end
