//
//  ViewController.h
//  CrossPlatformCommunicator
//
//  Created by MARS Lab on 7/14/17.
//  Copyright © 2017 MARS Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<NSStreamDelegate>
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    NSInputStream   *inputStream;   //socket input stream
    NSOutputStream  *outputStream;  // socket output stream
    
    NSMutableArray *dataToSend;
    
    int port;                       // port number
    NSString *gatewayIp;            // this will store the IP address of the gateway (router)
    NSMutableData *incomingData;    // this will serve as a buffer to store partially transmitted JSON
}

@property (weak, nonatomic) IBOutlet UITextField *dataToSendText;
@property (weak, nonatomic) IBOutlet UITextView *dataReceivedTextView;
@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UISwitch *switchFloat;


@end

