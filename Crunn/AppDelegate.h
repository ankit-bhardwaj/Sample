//
//  AppDelegate.h
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

#import "LoginVC.h"
#import "MMDrawerController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic,strong) MMDrawerController * drawerController;
@property (nonatomic, retain) NSMutableDictionary *networkQueue;
@property (nonatomic, assign) int notificationCounter;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)registerUserForPush;
-(void)DoFacebookLogin;
-(void)weekenNetworkURL:(NSString*)string;
-(BOOL)registerNetworkURL:(NSString*)string forObserver:(NSObject*)observer;
-(void)LoadMainView;
-(void)loadLoginView;

+ (NSOperationQueue*) sharedOpQueue;
+ (void) startShowingNetworkActivity;
+ (void) stopShowingNetworkActivity;
-(NSString *)randomNumberGenerator;
- (void) startShowingNoNetworkAlert;
@end
