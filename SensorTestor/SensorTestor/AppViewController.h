/*
 Copyright (c) 2013 OpenSourceRF.com.  All right reserved.
*/

#import <UIKit/UIKit.h>
#import "RFduino.h"
#import "UIViewPassValueDelegate.h"

@interface AppViewController : UIViewController<RFduinoDelegate>
{
    __weak IBOutlet UILabel *label1;
    __weak IBOutlet UILabel *label2;
}

@property(strong, nonatomic) RFduino *rfduino;
- (IBAction)onShowMode:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *showButton;

@end
