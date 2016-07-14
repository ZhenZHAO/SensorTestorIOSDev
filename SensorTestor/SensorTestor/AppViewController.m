/*
 Copyright (c) 2013 OpenSourceRF.com.  All right reserved.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <QuartzCore/QuartzCore.h>

#import "AppViewController.h"
#import "SPView.h"

@implementation AppViewController
double resistorNewReader = 0;
bool   isChangeShow = false;

@synthesize rfduino;

+ (void)load
{
    // customUUID = @"c97433f0-be8f-4dc8-b6f0-5343e6100eb4";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIButton *backButton = [UIButton buttonWithType:101];  // left-pointing shape
        [backButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(disconnect:) forControlEvents:UIControlEventTouchUpInside];
        backButton.frame = CGRectMake(0, 0, 100.0, 40.0);
        
//        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//        [[self navigationItem] setLeftBarButtonItem:backItem];
//        
//        [[self navigationItem] setTitle:@"RFduino Temp"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    [rfduino setDelegate:self];
    
    UIColor *start = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.15];
    UIColor *stop = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.45];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self.view bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)start.CGColor, (id)stop.CGColor, nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    isChangeShow = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)disconnect:(id)sender
{
    NSLog(@"disconnect pressed");

    [rfduino disconnect];
}

- (void)didReceive:(NSData *)data
{
    NSLog(@"RecievedRX");
    
    float reader = dataFloat(data);
    float referenceResistor = 10.0f;
    float referenceVol = 3.3f;
    float volReader = referenceVol * reader / (referenceResistor+reader);
    
    NSLog(@"c=%.2f, f=%.2f", reader, volReader);
    
    NSString* string1 = [NSString stringWithFormat:@"%.2f kΩ", reader];
    NSString* string2 = [NSString stringWithFormat:@"%.2f  V", volReader];
    
    [label1 setText:string1];
    [label2 setText:string2];
    
    resistorNewReader = reader;
    
}

- (IBAction)onShowMode:(id)sender {
    if (isChangeShow) {
        //self.showButton.titleLabel.text = @"Change";
        [self.showButton setTitle:@"Time" forState:UIControlStateNormal];
         isChangeShow = false;
    }else{
        //self.showButton.titleLabel.text = @"Time";
        [self.showButton setTitle:@"Change" forState:UIControlStateNormal];
        isChangeShow = true;
    }

}
@end
