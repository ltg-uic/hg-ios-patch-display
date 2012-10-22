//
//  AppDelegate.h
//  xmppTemplate
//
//  Created by Anthony Perritano on 9/14/12.
//  Copyright (c) 2012 Learning Technologies Group. All rights reserved.
//
//


#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "XMPPRoom.h"
#import "XMPPBaseNewMessageDelegate.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPBaseOnlineDelegate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,XMPPRoomStorage> {
    
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoom *xmppRoom;

    NSString *password;
    NSMutableDictionary *lastMessageDict;
    
    
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	BOOL isXmppConnected;
    id <XMPPBaseNewMessageDelegate> __weak xmppBaseNewMessageDelegate;
    id <XMPPBaseOnlineDelegate>     __weak xmppBaseOnlineDelegate;
    
    #define ROOM_JID        @"fg-pilot-oct12@conference.ltg.evl.uic.edu"
    #define XMPP_HOSTNAME   @"ltg.evl.uic.edu"
    #define XMPP_JID        @"fg-patch-5@ltg.evl.uic.edu"
    
    #define kXMPPmyJID      @"kXMPPmyJID"
    #define kXMPPmyPassword @"kXMPPmyPassword"

}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, readonly) XMPPRoom *xmppRoom;

@property (nonatomic, weak) id <XMPPBaseNewMessageDelegate> xmppBaseNewMessageDelegate;
@property (nonatomic, weak) id <XMPPBaseOnlineDelegate>     xmppBaseOnlineDelegate;


- (BOOL)connect;
- (void)disconnect;

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

@end
