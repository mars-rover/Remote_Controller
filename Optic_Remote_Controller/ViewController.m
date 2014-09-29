//
//  ViewController.m
//  Optic_Remote_Controller
//
//  Created by Andrey Karaban on 11/08/14.
//  Copyright (c) 2014 AkA. All rights reserved.
//

#import "ViewController.h"
#import "PDCustomersTableController.h"

@interface ViewController ()

@property (nonatomic) Reachability *wifiReachability;

@property (nonatomic, weak)  PDCustomersTableController *popView;
@end

@implementation ViewController
{
    GCDAsyncSocket *currentSocket ;
}

@synthesize connectButton;
@synthesize disconnectButton;
@synthesize controllButtonsView;
@synthesize labelConnection;
#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
	[self.wifiReachability startNotifier];
    
    NetworkStatus netStatus = [_wifiReachability currentReachabilityStatus];
    if(netStatus == NotReachable)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This feature requires a Wi-Fi connection. Please turn ON wi-fi in your settings!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
      
     }
   
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_ipad.png"]]];
    [self setDelegate:self];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(testNotify:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //Device type
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        NSString *deviceType = [[UIDevice currentDevice]model];
        NSLog(@"DEVICE ---> %@", deviceType);

        
    } else {
        
        
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)testNotify:(NSNotification *)notification
{
    NSLog(@"HELOO");
    [self startBrowsing];
}

- (void)dealloc
{
    if (_delegate)
    {
        _delegate = nil;
    }
    
    if (_socket)
    {
        [_socket setDelegate:nil delegateQueue:NULL];
        _socket = nil;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


#pragma mark - btnActions
- (IBAction)connect:(id)sender
{
    [self popOverInicialization];
}

- (void)dismissPopover
{
    [self.popController dismissPopoverAnimated:YES];
}


- (IBAction)disconnect:(id)sender
{
    [self.socket disconnect];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [self destroyRemoteView];
    [self.services removeAllObjects];
    [self startBrowsing];
    self.socket = nil;
    [self.socket  setDelegate:nil];
}

#pragma mark - Browsing_for_services
- (void)startBrowsing
{
    if (self.services)
    {
        [self.services removeAllObjects];
    } else
    {
        self.services = [[NSMutableArray alloc] init];
    }
    
    // Initialize Service Browser
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    
    // Configure Service Browser
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:@"_TEST_VISION_ACEP._tcp." inDomain:@"local."];
    NSLog(@"Scanning for services started");

}

#pragma mark - CustomMethods_Create/Destroy_ControllView
- (void)createRemoteView
{
    connectButton.hidden = YES;
    labelConnection.hidden = YES;
    controllButtonsView.hidden = NO;
    [controllButtonsView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_pattern.png"]]];
    [self dismissPopover];
}

- (void)destroyRemoteView
{
    connectButton.hidden = NO;
    labelConnection.hidden = NO;
    controllButtonsView.hidden = YES;
}


#pragma mark - GCDAsyncSocketDelegateMethods
- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"Service was found __%@\n",service.name);
    //  Update Services
    [self.services addObject:service];
    NSLog(@"SERVICES ARRAY- - - %@",self.services);
    
    
    if(!moreComing)
        {
           [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
             NSLog(@"ARRAY --- >%@", self.services);
            if (self.socket != nil)
            {
                NSLog(@"SOCKET HERE - ->%@", self.socket);
                int rw_index = 0;
                NSNetService *service = [self.services objectAtIndex:rw_index];
                NSLog(@"POLUCHILI \n");
                
                // Resolve Service
                [service setDelegate:self];
                [service resolveWithTimeout:-1];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connection Reestablished!" message:@"Remote device is connected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
           
        }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"Browser has deleted service-----%@\n", service.name);
    
    // Update Services
    [self.services removeObject:service];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser
{
    NSLog(@"Browser stoped searching- - - - %@\n", _serviceBrowser);
    [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didNotSearch:(NSDictionary *)userInfo
{
    NSLog(@"Browser did NOT search-> %@\n", _serviceBrowser);
    [self stopBrowsing];
}


- (void)stopBrowsing
{
    if (self.serviceBrowser)
    {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        [self setServiceBrowser:nil];
    }
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict
{
    [service setDelegate:nil];
    NSLog(@"OSHIBKA!!!!!!!!");
}


- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    // Connect With Service
    NSLog(@"START TO CONNECT");
    if ([self connectWithService:service])
    {
        [self.services addObject:service];
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    } else {
        NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
    }
}

- (BOOL)connectWithService:(NSNetService *)service
{
    NSLog(@"CONNECTING IN PROGRESS \n");
    BOOL _isConnected = NO;
    
    // Copy Service Addresses
    NSMutableArray *addresses = [[service addresses] mutableCopy];
    
    if (!self.socket || ![self.socket isConnected]) {
        // Initialize Socket
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // Connect
        while (!_isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            
            NSError *error = nil;
            if ([self.socket  connectToAddress:address error:&error])
            {
                _isConnected = YES;
                
            } else if (error) {
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
            }
        }
        
    } else {
        _isConnected = [self.socket isConnected];
    }
    
    return _isConnected;
}



- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    
    // Stop Browsing
    currentSocket = socket;
    NSLog(@"S O C K E T - %@", self.socket);
    [self stopBrowsing];
    [socket readDataToLength:sizeof(uint64_t) withTimeout:-1.0 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error
{
    NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
    if (error != NULL)
    {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"iPad Disconnected!" message:@"Press \"Disconnect\"button to start search again.\n Or wait untill it reconnects" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    }
    NSLog(@"SERVICE HERE  _ _ ---___- %@", self.service);
    NSLog(@" SOCKET is NIL???? -  ->%@", self.socket);
    [self startBrowsing];
}

#pragma mark - PopOver/ActionSheet_Inicialization
- (void)popOverInicialization
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
         UIActionSheet *act = [[UIActionSheet alloc]initWithTitle:@"Available Devices" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        
        for (NSNetService *service in self.services)
        {
            NSString *nameService = [service name];
            [act addButtonWithTitle:nameService];
        }
        
        [act showInView:self.view];
        NSLog(@" MASSIV TUT _-_%@", self.services);
    }else
    {
        NSArray *nextArray = [[NSArray alloc] initWithArray:self.services];
        NSLog(@"NEXT ARRAY = %@", nextArray);
        
        PDCustomersTableController *popView = [[PDCustomersTableController alloc] initWithCustomersArray:nextArray];   //self.services];
        
        NSLog(@"INSTANCE OF PDCUSTOMER - %@\n", popView);
        NSLog(@" A R R A Y INSIDE - >%@\n",nextArray);
        [popView.tableView reloadData];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:popView];
        
        
        CGRect size = CGRectMake(self.view.bounds.size.width/2 - 150.0, self.view.bounds.size.height/2 - 100.0, 300.0, 400.0);
        
        popView.delegate = self;
        
        self.popController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
        [self.popController presentPopoverFromRect:size inView:self.view permittedArrowDirections:nil animated:YES];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 0)
    {
        NSNetService *service = [self.services objectAtIndex:buttonIndex-1];
        NSLog(@"Button was pressed");
        NSLog(@"BUTTON INDEX %i", buttonIndex);
        // Resolve Service
        [service setDelegate:self];
        [service resolveWithTimeout:-1];
        //   // actionSheet.hidden = YES;
        [self createRemoteView];
    }
    
}

#pragma mark - SEND PACKETS METHOD
- (void)sendPackets:(Packets *)packet
{
    // Encode Packet Data
    NSMutableData *packetData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:packetData];
    [archiver encodeObject:packet forKey:@"packet"];
    [archiver finishEncoding];
    
    // Initialize Buffer
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    // Fill Buffer
    uint64_t headerLength = [packetData length];
    [buffer appendBytes:&headerLength length:sizeof(uint64_t)];
    [buffer appendBytes:[packetData bytes] length:[packetData length]];
    
    // Write Buffer
    [self.socket writeData:buffer withTimeout:-1.0 tag:0];
}

#pragma mark - SEND_MESSAGE_TO_SERVER
- (IBAction)sendMyMessage:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSString *indexButton = [NSString stringWithFormat:@"%ld", (long)btn.tag];
    NSString *msg = indexButton;
    Packets *packet = [[Packets alloc]initWithData:msg type:0 action:0];
    [self sendPackets: packet];
    NSLog(@"PACKET------->>>> %@\n", packet.data);
 }


#pragma mark - PDCustomersTableController

- (void)PopoverDidSelectRowAtIndex:(NSInteger)index
{
    NSNetService *service = [self.services objectAtIndex:index];
    NSLog(@"Button was pressed");
    [self.popView.tableView reloadData];
   
    // Resolve Service
    [service setDelegate:self];
    [service resolveWithTimeout:-1];
    [self createRemoteView];
}

@end
