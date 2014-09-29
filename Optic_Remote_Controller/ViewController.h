//
//  ViewController.h
//  Optic_Remote_Controller
//
//  Created by Andrey Karaban on 11/08/14.
//  Copyright (c) 2014 AkA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "Packets.h"
#import "Reachability.h"
#import "QuartzCore/QuartzCore.h"
#import "PDCustomersTableController.h"
@protocol ViewControlDelegate <NSObject>

@required

- (void)destroyRemoteView;


@end

@interface ViewController : UIViewController <UIAlertViewDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncSocketDelegate, ViewControlDelegate, PDCustomersTableControllerDelegate, UIActionSheetDelegate>



@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;
@property (strong, nonatomic)NSNetService *service;

@property (weak, nonatomic) id <ViewControlDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *controllButtonsView;
@property (weak, nonatomic) IBOutlet UIImageView *bgViewiPhone;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UILabel *labelConnection;

@property (nonatomic, strong) UIPopoverController *popController;
@property (weak, nonatomic) IBOutlet UIImageView *smallControlBg;



- (IBAction)connect:(id)sender;
- (IBAction)disconnect:(id)sender;
- (IBAction)sendMyMessage:(id)sender;




@end
