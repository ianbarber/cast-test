//
//  ViewController.m
//  TestyTest
//
//  Created by Ian Barber on 30/07/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    GCKDeviceScanner *_deviceScanner;
    GCKDeviceFilter *_deviceFilter;
    GCKDeviceManager *_deviceManager;
    GCKMediaControlChannel *_mediaControlChannel;
    BOOL _subs;
    NSInteger _pendingStyleChange;
}

@end

@implementation
ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _deviceScanner = [[GCKDeviceScanner alloc] init];
    _subs = NO;
    
    [[GCKLogger sharedInstance] setDelegate:self];
    
    GCKFilterCriteria *filterCriteria = [[GCKFilterCriteria alloc] init];
    filterCriteria = [GCKFilterCriteria criteriaForAvailableApplicationWithID:@"4F8B3483"];
    
    _deviceFilter = [[GCKDeviceFilter alloc] initWithDeviceScanner:_deviceScanner criteria:filterCriteria];
    [_deviceFilter addDeviceFilterListener:self];
    
    [_deviceScanner addListener:self];
    [_deviceScanner startScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GCKDeviceFilterListener
- (void)deviceDidComeOnline:(GCKDevice *)device forDeviceFilter:(GCKDeviceFilter *)deviceFilter {
    NSLog(@"device found!!!");
  if ([device.friendlyName isEqualToString:@"Matty Boo's Chromecast"]) {
    GCKDevice *selectedDevice = device;
    
    _deviceManager = [[GCKDeviceManager alloc]  initWithDevice:selectedDevice
                                            clientPackageName:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    
    _deviceManager.delegate = self;
    [_deviceManager connect];
  }
}

- (void)deviceDidGoOffline:(GCKDevice *)device forDeviceFilter:(GCKDeviceFilter *)deviceFilter {
    NSLog(@"device disappeared!!!");
}

#pragma mark - GCKDeviceManagerDelegate
- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    NSLog(@"connected!!");
    
    [_deviceManager launchApplication:@"4F8B3483"];
}


- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication {
    NSLog(@"App Launched");
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    [metadata setString:@"Big Buck Bunny" forKey:kGCKMetadataKeyTitle];
    
    NSURL *imUrl = [NSURL URLWithString:@"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg"];
    [metadata addImage:[[GCKImage alloc] initWithURL:imUrl width:100 height:100]];
    
    
    GCKMediaTrack *track = [[GCKMediaTrack alloc] initWithIdentifier:1 contentIdentifier:@"https://google-developers.appspot.com/web/fundamentals/resources/samples/media/video/chrome-subtitles-en.vtt" contentType:@"text/vtt" type:GCKMediaTrackTypeText textSubtype:GCKMediaTextTrackSubtypeSubtitles name:@"English Subs" languageCode:@"en-GB" customData:nil];
    
    NSURL *url = [NSURL URLWithString:@"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"];
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:[url absoluteString]
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:@"video/mp4"
                                          metadata:metadata
                                    streamDuration:0
                                       mediaTracks:@[track]
                                    textTrackStyle:[GCKMediaTextTrackStyle createDefault]
                                        customData:nil];
    
    _mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    _mediaControlChannel.delegate = self;
    [_deviceManager addChannel:_mediaControlChannel];
    
    [_mediaControlChannel loadMedia:mediaInformation autoplay:NO playPosition:0];
}

#pragma mark - GCKMediaControlChannelDelegate
- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel didCompleteLoadWithSessionID:(NSInteger)sessionID {
    NSLog(@"Loaded media");
    //[mediaControlChannel setActiveTrackIDs:@[@1]];
   // [mediaControlChannel play];
}

- (void) mediaControlChannelDidUpdateStatus:(GCKMediaControlChannel *)mediaControlChannel {
    NSLog(@"Updated status");
}

- (void)mediaControlChannel:(GCKMediaControlChannel *)mediaControlChannel requestDidCompleteWithID:(NSInteger)requestID {
  if (requestID == _pendingStyleChange) {
    NSLog(@"Style update completed");
  } else {
    NSLog(@"Other request completed");
  }
}

- (void) mediaControlChannelDidUpdateMetadata:(GCKMediaControlChannel *)mediaControlChannel {
    NSLog(@"Updated metadata");
}

#pragma mark - GCKLoggerDelete

- (void) logFromFunction:(const char *)function message:(NSString *)message {
   // NSLog(@"Cast: %@", message);
}

- (IBAction)didDisableSubs:(id)sender {
    if (_subs) {
        [_mediaControlChannel setActiveTrackIDs:@[]];
        _subs = false;
    } else {
        [_mediaControlChannel setActiveTrackIDs:@[@1]];
        _subs = true;
    }
}

- (IBAction)didStopMovie:(id)sender {
    [_mediaControlChannel stop];
}

- (IBAction)didStartMovie:(id)sender {
       [_mediaControlChannel play];
}

- (IBAction)didChangeSubStyle:(id)sender {
  GCKMediaTextTrackStyle *style = [GCKMediaTextTrackStyle createDefault];
  [style setForegroundColor:[[GCKColor alloc] initWithCSSString:@"#FF000080"]];
  NSInteger requestId =  [_mediaControlChannel setTextTrackStyle:style];
  _pendingStyleChange = requestId;
}

- (IBAction)didTapDisconnect:(id)sender {
  if ([_deviceManager isConnected]) {
    [_deviceManager disconnect];
  } else {
    [_deviceManager connect];
  }
}
@end
