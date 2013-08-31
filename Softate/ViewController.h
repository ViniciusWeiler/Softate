//
//  ViewController.h
//  Softate
//
//  Created by Vinicius Weiler on 8/14/13.
//  Copyright (c) 2013 Gabriel Borges Fernandes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meterview.h"

@interface ViewController : UIViewController <NSStreamDelegate, UITextFieldDelegate> {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSMutableData *incomingData;
}

@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UITextField *entradaIP;
@property (weak, nonatomic) IBOutlet UIButton *pegaIP;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *statusClient;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet meterView *meterView;

@end
