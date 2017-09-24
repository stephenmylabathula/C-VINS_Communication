//
//  ViewController.m
//  CrossPlatformCommunicator
//
//  Created by MARS Lab on 7/14/17.
//  Copyright © 2017 MARS Lab. All rights reserved.
//

#import "ViewController.h"
#import "GatewayFinder.h"


@interface ViewController ()
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    gatewayIp = [NSString stringWithFormat: @"%s", routerIP()];
    port = 12345;
    _connectedLabel.text = @"Disconnected";
    dataToSend = [[NSMutableArray alloc] init];
    for(int i = 0; i < 200; i++){
        [dataToSend addObject:[NSNumber numberWithFloat:(float)random()]];
    }
}

/*
 * EventHandler For Send Button Click
 */
- (IBAction)sendMessage:(id)sender {
    if([_switchFloat isOn]){
        NSData *json = [NSJSONSerialization dataWithJSONObject:dataToSend options:nil error:nil];
        //NSData *data = [[NSData alloc] initWithBytes:(__bridge const void * _Nullable)(dataToSend) length:sizeof(NSNumber)*200];
        //[NSJSONSerialization js]
        for(int i = 0; i < [json length]; i += 1024){
            NSRange range;
            range.location = i;
            range.length = MIN(1024, [json length] - i);
            [outputStream write:[[json subdataWithRange:range] bytes] maxLength:[json length]];
        }
        
    } else {
        NSString *response  = [NSString stringWithFormat:@"%@\n", _dataToSendText.text];
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
    }
}

/*
 * Displays Server Message - Called By handleEvent()
 */
- (void) messageReceived:(NSString *)message {
    _dataReceivedTextView.text = message;
}

/*
 * EventHandler For Stream Event
 */
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %lu", (unsigned long)streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            _connectedLabel.text = @"Connected";
            break;
        case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                uint8_t buffer[1024];   //uint8_t is 1 byte
                NSInteger len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        if([_switchFloat isOn]){
                            [incomingData appendBytes:buffer length:len];   // add data to incomingData
                            NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:incomingData options:nil error:nil];
                            if (jsonData != nil){
                                //[incomingData setLength:0]; // clear incomingData
                                //[self messageReceived:[NSString stringWithFormat:@"Floats Received: %lu", (unsigned long)[jsonData count]]];
                                float f = [[jsonData objectAtIndex:0] floatValue];
                                [self messageReceived:[NSString stringWithFormat:@"Floats Received: %f", f]];
                                //Do stuff with data
                            }
                        } else {
                            NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                            if (nil != output) {
                                //NSLog(@"server said: %@", @(sum));
                                [self messageReceived:output];
                            }
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream has space available now");
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"%@",[theStream streamError].localizedDescription);
            break;
            
        case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            _connectedLabel.text = @"Disconnected";
            NSLog(@"close stream");
            break;
        default:
            NSLog(@"Unknown event");
    }
    
}

- (IBAction)connectToServer:(id)sender {
    NSLog(@"Setting up connection to %@ : %i", gatewayIp, port);
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef) gatewayIp, port, &readStream, &writeStream);
    
    incomingData = [[NSMutableData alloc] init];    //Initialize incomingData
    [self open];
}

- (IBAction)disconnect:(id)sender {
    [self close];
    exit(0);
}

- (void)open {
    
    NSLog(@"Opening streams.");
    
    outputStream = (__bridge NSOutputStream *)writeStream;
    inputStream = (__bridge NSInputStream *)readStream;
    
    [outputStream setDelegate:self];
    [inputStream setDelegate:self];
    
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [outputStream open];
    [inputStream open];
    
    [_btnConnect setEnabled:false];
    _connectedLabel.text = @"Connected";
}

- (void)close {
    NSLog(@"Closing streams.");
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    inputStream = nil;
    outputStream = nil;
    _connectedLabel.text = @"Disconnected";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
