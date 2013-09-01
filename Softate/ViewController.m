//
//  ViewController.m
//  Softate
//
//  Created by Vinicius Weiler on 8/14/13.
//  Copyright (c) 2013 Gabriel Borges Fernandes. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@end

@implementation ViewController

@synthesize entradaIP;
@synthesize timeSlider;

- (void)viewDidLoad
{
    [entradaIP setDelegate:self];
    [self.timeSlider setValue:0.0 animated:YES]; //MAYBE CHANGE
    [self.timeSlider setHidden:NO];
    self.meterView.arcLength = M_PI;
	
	self.meterView.value = 0.0;
	self.meterView.textLabel.text = @"Volts";
	self.meterView.minNumber = 0.0;
	self.meterView.maxNumber = 220.0;
	self.meterView.textLabel.font = [UIFont fontWithName:@"Cochin-BoldItalic" size:15.0];
	self.meterView.textLabel.textColor = [UIColor blackColor];
	self.meterView.needle.tintColor = [UIColor blackColor];
	self.meterView.needle.width = 1.0;
	self.meterView.value = 0.0;
    [self initNetworkCommunication];
    incomingData = [[NSMutableData alloc] init];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
		case NSStreamEventOpenCompleted:
			break;
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                uint8_t buffer[1024];
                int len;
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        if (nil != output) {
                            [self messageReceived:output];
                        }
                    }
                }
            }
			break;
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
		case NSStreamEventEndEncountered:
			break;
		default:
			NSLog(@"Unknown event");
	}
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [entradaIP resignFirstResponder];
    return YES;
}

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.25.7", 5000, &readStream, &writeStream);
    inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    NSString *response  = [NSString stringWithFormat:@"iam:%@", @"iPod"];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

- (IBAction)didChangeSlider:(UISlider *)sender {
    self.meterView.value = (self.timeSlider.value * 220);
    [entradaIP setText:[NSString stringWithFormat:@"%d",(unsigned char)((self.timeSlider.value * 50)+5)]];
}

- (IBAction)didPress:(UIButton *)sender {
    [entradaIP setText:[NSString stringWithFormat:@"%d",(unsigned char)((self.timeSlider.value * 50)+5)]];
    NSString *response  = entradaIP.text;
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

- (void) messageReceived:(NSString *)message {
    //if (![message hasPrefix:@"iPod"]) {
    [self.statusClient setText:message];//[NSString stringWithFormat:@"%d",(unsigned char) message]];
    //}
}
 
@end
