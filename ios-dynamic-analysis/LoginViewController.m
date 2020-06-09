//  Created by Murphy on 11/06/17.
//  Copyright © 2017 Murphy. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "Utils.h"
#import <sqlite3.h>

@implementation LoginViewController

@synthesize usernameField;
@synthesize passwordField;



- (NSString *)getPathForFilename:(NSString *)filename {
    // Get the path to the Documents directory belonging to this app.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Append the filename to get the full, absolute path.
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, filename];
    return fullPath;
}

- (void)storeCredentialsForUsername:(NSString *)username withPassword:(NSString *)password {
    // Write the credentials to a SQLite database.
    sqlite3 *credentialsDB;
    const char *path = [[self getPathForFilename:@"credentials.sqlite"] UTF8String];
    
    if (sqlite3_open(path, &credentialsDB) == SQLITE_OK) {
        sqlite3_stmt *compiledStmt;
        
        //sqlite3_exec(credentialsDB, "PRAGMA key = 'secretKey!'", NULL, NULL, NULL);
        // Create the table if it doesn't exist.
        const char *createStmt =
        "CREATE TABLE IF NOT EXISTS creds (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT);";
        
        sqlite3_exec(credentialsDB, createStmt, NULL, NULL, NULL);
        
        // Check to see if the user exists; update if yes, add if no.
        const char *queryStmt = "SELECT id FROM creds WHERE username=?";
        int userID = -1;
        
        if (sqlite3_prepare_v2(credentialsDB, queryStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                userID = sqlite3_column_int(compiledStmt, 0);
            }
            
            sqlite3_finalize(compiledStmt);
        }
        
        const char *addUpdateStmt;
        
        if (userID >= 0) {
            addUpdateStmt = "UPDATE creds SET username=?, password=? WHERE id=?";
        } else {
            addUpdateStmt = "INSERT INTO creds(username, password) VALUES(?, ?)";
        }
        
        if (sqlite3_prepare_v2(credentialsDB, addUpdateStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(compiledStmt, 2, [password UTF8String], -1, SQLITE_TRANSIENT);
            
            if (userID >= 0) sqlite3_bind_int(compiledStmt, 3, userID);
            if (sqlite3_step(compiledStmt) != SQLITE_DONE) {
                NSLog(@"Error storing credentials in SQLite database.");
            }
        }
        
        // Clean things up.
        if (compiledStmt && credentialsDB) {
            if (sqlite3_finalize(compiledStmt) != SQLITE_OK) {
                NSLog(@"Error finalizing SQLite compiled statement.");
            } else if (sqlite3_close(credentialsDB) != SQLITE_OK) {
                NSLog(@"Error closing SQLite database.");
            }
            
        } else {
            NSLog(@"Error closing SQLite database.");
        }
    }
}

- (void)doLogin {
    // Write the credentials to a SQLite database.
    NSLog(@"Begin Authentication process!");

    if ([self isUserValid]) {
        NSLog(@"Access Granted");
        [self performSegueWithIdentifier: @"startMainView" sender: self];
    } else {
        UIAlertController *alert = [UIAlertController
                                       alertControllerWithTitle:@"Login"
                                       message:@"Invalid Credentials"
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
}

- (BOOL)isUserValid {
    sqlite3 *credentialsDB;
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    const char *path = [[self getPathForFilename:@"credentials.sqlite"] UTF8String];
    BOOL is_user_valid = FALSE;
    NSString *stored_password = NULL;

    if (sqlite3_open(path, &credentialsDB) == SQLITE_OK) {
        sqlite3_stmt *compiledStmt;
        
        // Check to see if the user exists; update if yes, add if no.
        const char *queryStmt = "SELECT * FROM creds WHERE username=?";
        
        if (sqlite3_prepare_v2(credentialsDB, queryStmt, -1, &compiledStmt, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStmt, 1, [username UTF8String], -1, SQLITE_TRANSIENT);
            while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                const char * c_password = (char *) sqlite3_column_text(compiledStmt, 2);
                if (c_password) {
                    stored_password = [[NSString alloc] initWithUTF8String:c_password];
                }
            }
            sqlite3_finalize(compiledStmt);
        }
        
        // Clean things up.
        if (compiledStmt && credentialsDB) {
           if (sqlite3_close(credentialsDB) != SQLITE_OK) {
                NSLog(@"Error closing SQLite database.");
            }
        } else {
            NSLog(@"Error closing SQLite database.");
        }
        NSString *decoded_password = [Utils decryption:stored_password withKey:@"MYKEY"];
        
        if (([decoded_password length] > 0) && [decoded_password isEqualToString:password]) {
            NSLog(@"%@", [NSString stringWithFormat:@"Username %@ and password %@ are correct!", username, password]);
            is_user_valid = TRUE;
        } else {
            NSLog(@"%@", [NSString stringWithFormat:@"Username %@ and password %@ are incorrect!", stored_password, decoded_password]);
        }
    }
    return is_user_valid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *username = @"administrator";
    NSString *password = @"therightpass"; // stored password
    
    NSString *str = [Utils decryption:password withKey:@"MYKEY"];
    
    [self storeCredentialsForUsername:username withPassword:str];
}


- (IBAction)submit:(id)sender {
    [self doLogin];
}

- (IBAction)getHint:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"HINT"
                                message:@"What is the right method to hook that returns BOOL?."
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

- (void) showAlert:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Alert"
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

- (void) changeBgWithColor:(NSString *)color{
    NSLog(@"Changing background color...");
    if ([color isEqualToString:@"green"]) {
        self.view.backgroundColor = [UIColor greenColor];
    } else if ([ color isEqualToString:@"blue"]) {
        self.view.backgroundColor = [UIColor blueColor];
    } else if ([color isEqualToString:@"red"]) {
        self.view.backgroundColor = [UIColor redColor];
    } else if ([color isEqualToString:@"black"]) {
        self.view.backgroundColor = [UIColor blackColor];
    } else if ([color isEqualToString:@"white"]) {
        self.view.backgroundColor = [UIColor whiteColor];
    } else if ([color isEqualToString:@"brown"]) {
        self.view.backgroundColor = [UIColor brownColor];
    } else if ([color isEqualToString:@"purple"]) {
        self.view.backgroundColor = [UIColor purpleColor];
    }
    else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
