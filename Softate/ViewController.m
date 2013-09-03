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

NSString *charValue;

- (void)viewDidLoad
{
    [entradaIP setDelegate:self];
    [timeToShutDown setDelegate:self];
    [keepTurnedOn setDelegate:self];
    [self.timeSlider setValue:0.0 animated:YES]; //MAYBE CHANGE
    [self.timeSlider setHidden:NO];
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
    CGRect rect = self.meterView.frame;
    float x=75;
    float yc=50;
    float w=0;
    float y=10;
    CGMutablePathRef path = CGPathCreateMutable();
    CGContextRef context = UIGraphicsGetCurrentContext();
    while (w<=rect.size.width) {
        CGPathMoveToPoint(path, nil, w,y/2);
        CGPathAddQuadCurveToPoint(path, nil, w+x/4, -yc,w+ x/2, y/2);
        CGPathMoveToPoint(path, nil, w+x/2,y/2);
        CGPathAddQuadCurveToPoint(path, nil, w+3*x/4, y+yc, w+x, y/2);
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathStroke);
        w+=x;
    }
    
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
    [keepTurnedOn resignFirstResponder];
    [timeToShutDown resignFirstResponder];
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
}

- (IBAction)didChangeSlider:(UISlider *)sender {
    //self.meterView.value = (self.timeSlider.value * 220);
    [entradaIP setText:[NSString stringWithFormat:@"%d",(char)((self.timeSlider.value * 50)+5)]];
    [keepTurnedOn setText:[NSString stringWithFormat:@"%d",(char)(self.timeSlider.value * 14)+1]];
    [timeToShutDown setText:[NSString stringWithFormat:@"%d",(char)(self.timeSlider.value * 7)+3]];
}
- (IBAction)didPressEmergency:(UIButton *)sender {
    NSString *response = [NSString stringWithFormat:@"%c",(char)56];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}

- (IBAction)didPress:(UIButton *)sender {
    NSString *response;//  = [NSString stringWithFormat:@"%c",(char)self.entradaIP.text];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];

        [entradaIP setText:[NSString stringWithFormat:@"%d",(char)((self.timeSlider.value * 50)+5)]];
        response  = [NSString stringWithFormat:@"%c",(char)((self.timeSlider.value * 50)+5)];
        //response  = [NSString stringWithFormat:@"%c",(char)(self.entradaIP.text)];
        data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        NSLog(@"%@",response);
    
        [keepTurnedOn setText:[NSString stringWithFormat:@"%d",(char)((self.timeSlider.value * 14)+1)]];
        response  = [NSString stringWithFormat:@"%c",(char)(((self.timeSlider.value * 14)+1)+100)];
        //response  = [NSString stringWithFormat:@"%c",(char)(self.keepTurnedOn.text)];
        data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        NSLog(@"%@",response);
    
        [timeToShutDown setText:[NSString stringWithFormat:@"%d",(char)((self.timeSlider.value * 7)+3)]];
        response  = [NSString stringWithFormat:@"%c",(char)(((self.timeSlider.value * 7)+3)+60)];
        data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        NSLog(@"%@",response);
    
    NSString *start1  = [NSString stringWithFormat:@"%c",(char)57];
    NSData *start = [[NSData alloc] initWithData:[start1 dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[start bytes] maxLength:[start length]];
    NSLog(@"%@",start1);
}

- (void) messageReceived:(NSString *)message {
    //if (![message hasPrefix:@"iPod"]) {
    //[self.statusClient setText:message];//[NSString stringWithFormat:@"%d",(unsigned char) message]];
    self.meterView.value = (((char) (message) * 200) / 255);
    //}
}
 
@end
