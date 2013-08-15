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

@synthesize inputStream;
@synthesize outputStream;
@synthesize entradaIP;
@synthesize timeSlider;

- (void)viewDidLoad
{
    [self initNetworkCommunication];
    [entradaIP setDelegate:self];
    [self.timeSlider setValue:0.0 animated:YES];
    [self.timeSlider setHidden:NO];
    self.meterView.maxNumber = 1;
    self.meterView.arcLength = M_PI;
	
	self.meterView.value = 0.0;
	self.meterView.textLabel.text = @"Volts";
	self.meterView.minNumber = 0.0;
	self.meterView.maxNumber = 220.0;
	self.meterView.textLabel.font = [UIFont fontWithName:@"Cochin-BoldItalic" size:15.0];
	self.meterView.textLabel.textColor = [UIColor blackColor];
	self.meterView.needle.tintColor = [UIColor blackColor];
	self.meterView.needle.width = 0.5;
	self.meterView.value = 0.0;
    messages = [[NSMutableArray alloc] init];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [entradaIP resignFirstResponder];
    return YES;
}

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"169.254.153.190", 5002, &readStream, &writeStream);
    inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}
- (IBAction)didChangeSlider:(UISlider *)sender {
    self.meterView.value = (self.timeSlider.value * 220);
    NSLog(@"%f",self.timeSlider.value);
    NSLog(@"%f",self.meterView.value);
    [entradaIP setText:[NSString stringWithFormat:@"%d",(int)((self.timeSlider.value * 50)+5)]];
    
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
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
                            NSLog(@"server said: %@", output);
                            
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

- (IBAction)didPress:(UIButton *)sender {
    NSString *response  = [NSString stringWithFormat:@"iam:%@", entradaIP.text];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

@end
