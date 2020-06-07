//
//  LoginViewController.h
//  testingDataProtectionclasses
//
//  Created by Murphy on 11/06/17.
//  Copyright © 2017 Murphy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)submit:(id)sender;
- (IBAction)getHint:(UIButton *)sender;

- (void)doLogin;
- (void)storeCredentialsForUsername:(NSString *)username withPassword:(NSString *)password;
- (NSString *)getPathForFilename:(NSString *)filename;
- (BOOL)isUserValid;

@end
