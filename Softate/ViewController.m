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
@synthesize keepTurnedOn;
@synthesize timeToShutDown;
@synthesize timeToSoftlyShutDown;
@synthesize timeToStayOn;

NSString *charValue;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [entradaIP setDelegate:self];
    [timeToShutDown setDelegate:self];
    [keepTurnedOn setDelegate:self];
    [self.timeSlider setValue:0.0 animated:YES]; //MAYBE CHANGE
    [self.timeSlider setHidden:NO];
    [self.timeToSoftlyShutDown setValue:0.0 animated:YES]; //MAYBE CHANGE
    [self.timeToSoftlyShutDown setHidden:NO];
    [self.timeToStayOn setValue:0.0 animated:YES]; //MAYBE CHANGE
    [self.timeToStayOn setHidden:NO];
    self.meterView.arcLength =  M_PI;
	self.meterView.value = 0.0;
	self.meterView.textLabel.text = @"Sobre corrente (%)";
	self.meterView.minNumber = 0.0;
	self.meterView.maxNumber = 200.0;
	self.meterView.textLabel.font = [UIFont fontWithName:@"Cochin-BoldItalic" size:13.0];
	self.meterView.textLabel.textColor = [UIColor blackColor];
    CGFloat r=0,g=122,b=255;
	self.meterView.needle.tintColor = [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:1];
	self.meterView.needle.width = 1.0;
	self.meterView.value = 0.0;
    [self initNetworkCommunication];
    incomingData = [[NSMutableData alloc] init];
    if(UIAccessibilityIsVoiceOverRunning()) {
        NSString *irineu = [NSString stringWithFormat:@"Der Motor wird in %@ Sekunden eingeschalted werden, bleibt völlig eingeschalted %@ Sekunded lang und wird langsam schalten in %@ Sekunden.",self.entradaIP.text,self.keepTurnedOn.text, self.timeToShutDown.text];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,irineu);
    }
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
    [keepTurnedOn resignFirstResponder];
    [timeToShutDown resignFirstResponder];
    return YES;
}

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"10.244.5.47", 5002, &readStream, &writeStream);
    inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (IBAction)didChangeSlider:(UISlider *)sender {
    [entradaIP setText:[NSString stringWithFormat:@"Starts in: %d s",(char)((self.timeSlider.value * 50)+5)]];
}
- (IBAction)didPressEmergency:(UIButton *)sender {
    NSString *response = [NSString stringWithFormat:@"%c",(char)56];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    NSLog(@"%@",response);
}
- (IBAction)didChangeSliderToStayOn:(UISlider *)sender {
    [keepTurnedOn setText:[NSString stringWithFormat:@"On max for: %d s",(unsigned char)(self.timeToStayOn.value * 26)+1]];
}
- (IBAction)didChangeSliderToSoftlyShutDown:(UISlider *)sender {
    [timeToShutDown setText:[NSString stringWithFormat:@"Shut down in: %d s",(char)(self.timeToSoftlyShutDown.value * 35)+5]];
}
- (IBAction)willTryConnection:(UIButton *)sender {
    [self initNetworkCommunication];
}

- (IBAction)didPress:(UIButton *)sender {
    NSString *response;//  = [NSString stringWithFormat:@"%c",(char)self.entradaIP.text];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];

        response  = [NSString stringWithFormat:@"%c",(char)((self.timeSlider.value * 50)+5)];
        data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        char debug1 = [response characterAtIndex:0];
        NSLog(@"%c",debug1);
    
        //[keepTurnedOn setText:[NSString stringWithFormat:@"%d",(char)((self.timeToStayOn.value * 14)+1)]];
        response  = [NSString stringWithFormat:@"%c",(char)(((self.timeToStayOn.value * 26)+1)+100)];
        data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        //NSLog(@"%@",response);
        debug1 = [response characterAtIndex:0];
        NSLog(@"%c",debug1);
    
        //[timeToShutDown setText:[NSString stringWithFormat:@"%d",(char)((self.timeSlider.value * 7)+3)]];
        response  = [NSString stringWithFormat:@"%c",(char)(((self.timeToSoftlyShutDown.value * 35)+5)+60)];
        data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        //NSLog(@"%@",response);
        debug1 = [response characterAtIndex:0];
        NSLog(@"%c",debug1);
    
    if(UIAccessibilityIsVoiceOverRunning()) {
        NSString *irineu = [NSString stringWithFormat:@"Der Motor wird in %@ Sekunden eingeschalted werden, bleibt völlig eingeschalted %@ Sekunded lang und wird langsam schalten in %@ Sekunden.",self.entradaIP.text,self.keepTurnedOn.text, self.timeToShutDown.text];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification,irineu);
    }
    
    NSString *start1  = [NSString stringWithFormat:@"%c",(char)57];
    NSData *start = [[NSData alloc] initWithData:[start1 dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[start bytes] maxLength:[start length]];
    //NSLog(@"%@",start1);
    debug1 = [start1 characterAtIndex:0];
    NSLog(@"%c",debug1);
}

- (void) messageReceived:(NSString *)message {
    self.meterView.value = (((unsigned char) (message) * 200) / 190);
    if(self.meterView.value > 190) {
        NSString *response = [NSString stringWithFormat:@"%c",(char)56];
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
    }
}
 
@end
