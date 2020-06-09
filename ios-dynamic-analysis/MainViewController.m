//  Created by Murphy on 20/03/16.
//  Copyright © 2016 Murphy. All rights reserved.
//

#import "MainViewController.h"
#import "Utils.h"


@interface MainViewController ()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation MainViewController: UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)JailbreakButtonTapped2:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:@"/bin/bash"]) {
        [self showAlert:@"Device is Jailbroken :("];
    } else if ([fileManager fileExistsAtPath:@"/bin/ls"]) {
        [self showAlert:@"Device is Jailbroken :("];
    } else {
        [self showAlert:@"Device is not Jailbroken. Yay!"];
    }
}

- (IBAction)JailbreakButtonTapped1:(id)sender {
    if ([Utils isJailbroken]) {
        [self showAlert:@"Device is Jailbroken :("];
    } else {
        [self showAlert:@"Device is not Jailbroken. Yay!"];
    }
}

- (void) showAlert:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Jailbreak Detection"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
