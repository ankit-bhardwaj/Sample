//
//  AppDelegate.m
//  Crunn
//
//  Created by Ashish Maheshwari on 5/11/14.
//  Copyright (c) 2014 Erixir Inc Limited. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuVC.h"
#import "HomeVC.h"
#import "RecentFeedVC.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "WelcomeVC.h"
#import "GSAsynImageView.h"
#import "UserDocument.h"
#import "TaskListVC.h"
#import "ShowAttachmentVC.h"
#import "ImageMapVC.h"
#import <Crashlytics/Crashlytics.h>
#import <UXCam/UXCam.h> 
#import <DBChooser/DBChooser.h>
#import "TaskDocument.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize window;



-(BOOL)registerNetworkURL:(NSString*)string forObserver:(NSObject*)observer
{
    if([self.networkQueue objectForKey:string])
    {
        NSMutableArray *arr = [self.networkQueue objectForKey:string];
        [arr addObject:observer];
        return YES;
    }
    else
    {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:observer];
        [self.networkQueue setObject:arr forKey:string];
        return NO;
    }
}

-(void)weekenNetworkURL:(NSString*)string
{
    if([self.networkQueue objectForKey:string])
    {
        NSMutableArray *arr = [self.networkQueue objectForKey:string];
        for (int indx = 0; indx < arr.count; indx++)
        {
            GSAsynImageView *observer = (GSAsynImageView *) [arr objectAtIndex:indx];
            if([observer respondsToSelector:@selector(networkOperationDone)])
            {
                [observer performSelector:@selector(networkOperationDone) withObject:nil];
            }
        }
        [self.networkQueue removeObjectForKey:string];
    }
}


-(void)LoadMainView
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"userLoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UserDocument sharedInstance] enablePushNotification:[[NSUserDefaults standardUserDefaults] boolForKey:@"PushEnabled"]];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LocationEnabled"])
        [LocationService start];
    
    [[TaskDocument sharedInstance] getProjectList];
    
    UIViewController * leftSideDrawerViewController = [[MenuVC alloc] initWithNibName:@"MenuVC" bundle:nil];
    
    UIViewController * centerViewController = nil;
    if(1)
    {
        centerViewController = [[HomeVC alloc] initWithNibName:@"HomeVC" bundle:nil];
    }
    else
    {
        centerViewController = [[TaskListVC alloc] initWithNibName:@"TaskListVC" bundle:nil];
    }
    
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:centerViewController];
    [navigationController setRestorationIdentifier:@"HomeVC"];
    
        UINavigationController * leftSideNavController = [[UINavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
		[leftSideNavController setRestorationIdentifier:@"MenuVC"];
        self.drawerController = [[MMDrawerController alloc]
                                 initWithCenterViewController:navigationController
                                 leftDrawerViewController:leftSideDrawerViewController
                                 rightDrawerViewController:nil];
        [self.drawerController setShowsShadow:YES];
    
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumRightDrawerWidth:280.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    [self.drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeFull];
    [[MMExampleDrawerVisualStateManager sharedManager] setLeftDrawerAnimationType:MMDrawerAnimationTypeSwingingDoor];
    [[MMExampleDrawerVisualStateManager sharedManager] setRightDrawerAnimationType:MMDrawerAnimationTypeSwingingDoor];
    
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
        UIColor * tintColor = [UIColor colorWithRed:29.0/255.0
                                              green:173.0/255.0
                                               blue:234.0/255.0
                                              alpha:1.0];
        [self.window setTintColor:tintColor];
    
    [self.window setRootViewController:self.drawerController];

    [self.window makeKeyAndVisible];
}

-(void)loadLoginView
{
    LoginVC *vc = [[LoginVC alloc]initWithNibName:@"LoginVC" bundle:nil];
    self.navigationController = [[UINavigationController alloc]initWithRootViewController:vc];
    self.navigationController.navigationBarHidden = YES;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crashlytics startWithAPIKey:@"a5cb6786dd6a120071f983e2f5d276c3c95f5a09"];
    //[UXCam startApplicationWithKey: @"e0935eb98662e58"];
    
#if GRAPPLE
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"production"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.statusBarStyle = UIStatusBarStyleLightContent;
    self.networkQueue = [[NSMutableDictionary alloc] init];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    else
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"userLoggedIn"])
    {
        WelcomeVC *vc = [[WelcomeVC alloc]initWithNibName:@"WelcomeVC" bundle:nil];
        self.navigationController = [[UINavigationController alloc]initWithRootViewController:vc];
        self.navigationController.navigationBarHidden = YES;
        self.window.rootViewController = self.navigationController;
        [self.window makeKeyAndVisible];
    }
    else
    {
        [[UserDocument sharedInstance] getUserProfile];
        [self LoadMainView];
    
    }
    if(launchOptions && launchOptions.count)
    {
        NSDictionary* aps = [launchOptions objectForKey:@"aps"];
        NSString* message = [aps objectForKey:@"alert"];
        if(NSSTRING_HAS_DATA(message))
        {
            self.notificationCounter += 1;
            //[UIApplication sharedApplication].applicationIconBadgeNumber = self.notificationCounter;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteNotificationArrived" object:launchOptions];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAttachment:) name:@"ShowAttachment" object:nil];

   
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[UXCam stopApplicationAndUploadData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"LocationEnabled"])
    {
        [LocationService start];
    }
    else
    {
        [LocationService stop];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *device = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    if(NSSTRING_HAS_DATA(device))
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PushEnabled"];
        [[NSUserDefaults standardUserDefaults] setObject:device forKey:@"authToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary* aps = [userInfo objectForKey:@"aps"];
    NSString* message = [aps objectForKey:@"alert"];
    if(NSSTRING_HAS_DATA(message))
    {
        self.notificationCounter += 1;
        //[UIApplication sharedApplication].applicationIconBadgeNumber = self.notificationCounter;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoteNotificationArrived" object:userInfo];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the
        // completion block
        return YES;
    }
    return NO;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Crunn" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Crunn.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSString *)randomNumberGenerator
{
    char *characters="abcdef0123456789";
    int length=strlen(characters);
    char randomString[38];
    int i;
    for(i=0;i<36;i++)
    {
        if(i == 8 || i == 13 || i == 18 || i == 23)
            randomString[i]='-';
        else
            randomString[i] = characters[arc4random()%length];
    }
    randomString[i]='\0';
    NSString *returnString = [[NSString alloc] initWithCString:randomString encoding:NSUTF8StringEncoding];
    return returnString;
	
}

- (void)registerUserForPush
{
    
}

-(void)showAttachment:(NSNotification*)note
{
    Attachment* att = [note object];
    if([att.ExternalVendorType integerValue] == 0 && ([att.ContentType isEqualToString:@"image/jpeg"] || [att.ContentType isEqualToString:@"image/png"]))
    {
        ImageMapVC* savc = [[ImageMapVC alloc] initWithNibName:@"ImageMapView" bundle:nil];
        savc.attachment = att;
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:savc];
        [self.window.rootViewController presentViewController:navVC animated:YES completion:nil];
        
    }
    else
    {
        ShowAttachmentVC* savc = [[ShowAttachmentVC alloc] initWithNibName:@"ShowAttachmentVC" bundle:nil];
        if([att.ExternalVendorType integerValue] > 0)
            [savc setUrl:att.FileUrl];
        else
            savc.attachment = att;
        UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:savc];
        //navVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.window.rootViewController presentViewController:navVC animated:YES completion:nil];
        
    }
}

static NSOperationQueue* opQueue = nil;

+ (NSOperationQueue*) sharedOpQueue
{
	if ( opQueue == nil )
	{
		opQueue = [[NSOperationQueue alloc] init];
		[opQueue setMaxConcurrentOperationCount:4];
        
	}
	return opQueue;
}



UIAlertView* noNetworAlert = nil;
- (void) startShowingNoNetworkAlert
{
	if (!noNetworAlert)
	{
        noNetworAlert = [[UIAlertView alloc] initWithTitle:@"Grapple" message:@"No Internet connection found. Please check and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noNetworAlert show];
	}
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	noNetworAlert = nil;
}


static int sShowNetworkActivityIndicatorCounter = 0;

+ (void) startShowingNetworkActivity
{
	if (++sShowNetworkActivityIndicatorCounter == 1)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}


+ (void) stopShowingNetworkActivity
{
	if (--sShowNetworkActivityIndicatorCounter == 0)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

@end
