//
//  RongCloudModule.m
//  UZApp
//
//  Created by xugang on 14/12/17.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//

#import "RongCloudHybridAdapter.h"
#import "RongCloudModel.h"
#import "RongCloudConstant.h"
#import "RongCloudApplicationHandler.h"
#import <objc/runtime.h>

#ifdef RC_SUPPORT_IMKIT
#import <RongIMKit/RongIMKit.h>
#import <RongCallKit/RongCallKit.h>
#import "RCDCustomerServiceViewController.h"
#endif

#define BAD_PARAMETER_CODE @"-10002"
#define BAD_PARAMETER_MSG @"Argument Exception"

#define NOT_INIT_CODE @"-10000"
#define NOT_INIT_MSG @"Not Init"

#define NOT_CONNECT_CODE @"-10001"
#define NOT_CONNECT_MSG @"Not Connected"

#define UNKNOWN_CODE @"-10003"
#define UNKNOWN_MSG @"Unknown"

static BOOL isInited = NO;
static BOOL isConnected = NO;

@interface RongCloudHybridAdapter ()

//@property (nonatomic, strong) id connectionCallbackId;
//@property (nonatomic,strong) id receiveMessageCbId;
#ifdef RC_SUPPORT_IMKIT
@property (nonatomic, strong) id refreshUserInfoCallbackId;
#endif
@property (nonatomic, assign)BOOL disableLocalNotification;

@property (nonatomic, assign)FlutterMethodChannel* _channel;
@property (nonatomic, strong)RCUserInfo* userInfo;
@end


@implementation RongCloudHybridAdapter

- (instancetype)initRongModule {
    self = [super init];
    if (self) {
        self.disableLocalNotification = NO;
    }
    return self;
}

- (void)setMethodChannel:(FlutterMethodChannel *)flutterMethodChannel {
    self._channel = flutterMethodChannel;
}

/**
 * initialize & connection
 */
-(void)init:(NSString *)appKey result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![appKey isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode: BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:appKey]);
        
        return;
    }
    
#ifdef RC_SUPPORT_IMKIT
  [[RCIM sharedRCIM] initWithAppKey:appKey];
  [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
#else
  [[RCIMClient sharedRCIMClient] initWithAppKey:appKey];
#endif
    isInited = YES;
    result(SUCCESS);
}

-(void)setUserInfo:(NSString *)userId name:(NSString *)name avatar:(NSString *)avatar level:(NSString *)level  result:(FlutterResult)result
{
    self.userInfo = [RCUserInfo new];
    self.userInfo.userId= userId;
    self.userInfo.extra = level;
    self.userInfo.name = name;
    self.userInfo.portraitUri = avatar;
    result(@"");
}

-(void)connectWithToken:(NSString *)token result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    
    if (NO == isInited) {
        result([FlutterError errorWithCode:NOT_INIT_CODE message:NOT_INIT_MSG details:NOT_INIT_MSG]);
        return;
    }

    
    if (![token isKindOfClass:[NSString class]]) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:token]);
        return;
    }

    void (^successBlock)(NSString *userId) = ^(NSString *userId){
        NSLog(@"%s", __FUNCTION__);
        isConnected           = YES;
        NSDictionary *_result = @{@"status": SUCCESS, @"result": @{@"userId":userId}};
        result(_result);
    };
    
    void (^errorBlock)(RCConnectErrorCode status) = ^(RCConnectErrorCode status) {
        NSLog(@"%s, errorCode> %ld", __FUNCTION__, (long)status);
        
        isConnected           = YES;
        result([FlutterError errorWithCode:[@(status) stringValue] message:ERROR details:ERROR]);
    };
    
    void (^tokenIncorrectBlock)(void) = ^{
        NSLog(@"%s, errorCode> %d", __FUNCTION__, 31004);
        
        isConnected           = YES;
        result([FlutterError errorWithCode:@"31004" message:ERROR details:ERROR]);
    };
    
#ifdef RC_SUPPORT_IMKIT
    [[RCIM sharedRCIM] connectWithToken:token success:successBlock error:errorBlock tokenIncorrect:tokenIncorrectBlock];
#else
    [[RCIMClient sharedRCIMClient] connectWithToken:token success:successBlock error:errorBlock tokenIncorrect:tokenIncorrectBlock];
#endif
}


- (BOOL)checkIsInitOrConnect:(FlutterResult)result
{
    BOOL isContinue = YES;
    if (result) {
        if (NO == isInited) {
            isContinue            = NO;
            
            result([FlutterError errorWithCode:NOT_INIT_CODE message:NOT_INIT_MSG details:ERROR]);
        }else if (NO == isConnected) {
            isContinue            = NO;
            
            result([FlutterError errorWithCode:NOT_CONNECT_CODE message:NOT_CONNECT_MSG details:ERROR]);
        }
    }
    return isContinue;
}

- (BOOL)checkIsInit:(FlutterResult)result
{
    BOOL isContinue = YES;
    if (result) {
        if (NO == isInited) {
            isContinue            = NO;
            
            result([FlutterError errorWithCode:NOT_INIT_CODE message:NOT_INIT_MSG details:ERROR]);
        }
    }
    return isContinue;
}

- (void)disconnect:(NSNumber *)isReceivePush result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (NO == isInited) {
        result([FlutterError errorWithCode:NOT_INIT_CODE message:NOT_INIT_MSG details:ERROR]);
        return;
    }
    
    if (![isReceivePush isKindOfClass:[NSNumber class]]) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
  
  BOOL receivePush = YES;
    if (isReceivePush) {
        if (1 != isReceivePush.integerValue) {
          receivePush = NO;
        }
    }
  
#ifdef RC_SUPPORT_IMKIT
  [[RCIM sharedRCIM] disconnect:receivePush];
#else
  [[RCIMClient sharedRCIMClient] disconnect:receivePush];
#endif
  
    isConnected           = NO;
    result(SUCCESS);

}

- (void)setConnectionStatusListener:(FlutterResult) result
{
//    NSLog(@"%s", __FUNCTION__);
//    self.connectionCallbackId = connectionCallbackId;

#ifdef RC_SUPPORT_IMKIT
  [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
#else
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
#endif
    result(SUCCESS);
}

#ifdef RC_SUPPORT_IMKIT
- (void)refreshUserInfo:(RCUserInfo *)userInfo {
  [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userInfo.userId];
}

- (void)setUserInfoProvider:(id)userInfoProviderId {
  self.refreshUserInfoCallbackId = userInfoProviderId;
  [RCIM sharedRCIM].userInfoDataSource = self;
}

- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.refreshUserInfoCallbackId) {
      NSDictionary *_result = @{@"result":@{@"userId":userId}};
      [self.commandDelegate sendResult:_result error:nil withCallbackId:self.refreshUserInfoCallbackId doDelete:NO];
    }
  });
}

#endif

#ifdef RC_SUPPORT_IMKIT
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status;
#else
- (void)onConnectionStatusChanged:(RCConnectionStatus)status
#endif
{
    if (self._channel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *_result = @{@"result":@{@"connectionStatus":[RongCloudModel RCTransferConnectionStatus:status]}};
            [self._channel invokeMethod:@"onConnectStatus" arguments:_result];
        });
    }
}

- (void)_sendMessage:(RCConversationType)conversationType withTargetId:(NSString *)targetId withContent:(RCMessageContent *)messageContent withPushContent:(NSString *)pushContent result:(FlutterResult)result
{

  __weak __typeof(self)weakSelf = self;
#ifdef RC_SUPPORT_IMKIT
  RCMessage *rcMessage = [[RCIM sharedRCIM] sendMessage:conversationType
#else
  RCMessage *rcMessage = [[RCIMClient sharedRCIMClient]sendMessage:conversationType
#endif
                                                        targetId:targetId
                                                         content:messageContent
                                                     pushContent:pushContent
                                                        pushData:nil
                                                         success:^(long messageId) {
                                                           NSLog(@"success");
                                                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                             NSLog(@"%s", __FUNCTION__);
                                                             NSLog(@"callback success");
                                                             NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                             
                                                             [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                             
                                                             [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isSuccess"];
                                                             
                                                             NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"message":@{@"messageId":@(messageId)}}};
                                                               [weakSelf._channel invokeMethod:@"onMessageSendSuccess" arguments:_result];
                                                           });
                                                         }
                                                           error:^(RCErrorCode nErrorCode, long messageId) {
                                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                               NSLog(@"%s", __FUNCTION__);
                                                               NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                               
                                                               [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                               
                                                               [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                                                               
                                                               NSDictionary *_result = @{@"status":ERROR, @"result":@{@"message": @{@"messageId":@(messageId)}}};
                                                               [weakSelf._channel invokeMethod:@"onMessageSendError" arguments:_result];
                                                             });
                                                           }];
                          NSLog(@"perpare");
                          NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:rcMessage];
                          NSDictionary *_result = @{@"status":PREPARE, @"result": @{@"message":_message}};
                          result(_result);
                          
}

/**
 * message send & receive
 */
- (void)sendTextMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId content:(NSString *)textContent extra:(NSString *)extra  result:(FlutterResult)result
{
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    NSLog(@"%s", __FUNCTION__);

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![textContent isKindOfClass:[NSString class]] ||
        ![extra isKindOfClass:[NSString class]]
        ) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:nil]);
        
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    RCTextMessage *rcTextMessage         = [RCTextMessage messageWithContent:textContent];
    rcTextMessage.extra                  = extra;
    rcTextMessage.senderUserInfo = self.userInfo;
    
    [self _sendMessage:_conversationType withTargetId:targetId withContent:rcTextMessage withPushContent:nil result:result];

}

- (void)sendImageMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId imagePath:(NSString *)imagePath extra:(NSString *)extra  result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
  
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![imagePath isKindOfClass:[NSString class]] ||
        ![extra isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:nil]);
        return;
    }
    
//    NSLog(@"_truePath > %@", _truePath);
    
    NSData *imageData   = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imagePath]];
    UIImage* image      = [UIImage imageWithData:imageData];
    
    if (![image isKindOfClass:[UIImage class]]) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:@"imagePath"]);
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    RCImageMessage *imageMessage         = [RCImageMessage messageWithImage:image];
    imageMessage.extra                   = extra;
    imageMessage.thumbnailImage          = [UIImage imageWithData:[RongCloudModel compressedImageAndScalingSize:image targetSize:CGSizeMake(360.0f, 360.0f) percent:0.4f]];
    imageMessage.senderUserInfo = self.userInfo;

    
    __weak __typeof(self)weakSelf = self;
#ifdef RC_SUPPORT_IMKIT
  RCMessage *rcMessage = [[RCIM sharedRCIM] sendImageMessage:_conversationType
#else
//                          升级说明：如果您之前使用了此接口，可以直接替换为sendMediaMessage:targetId:content:pushContent:pushData:progress:success:error:cancel:接口，行为和实现完全一致。
  RCMessage *rcMessage = [[RCIMClient sharedRCIMClient] sendMediaMessage:_conversationType
#endif
                                                                targetId:targetId
                                                                content:imageMessage
                                                                pushContent:nil
                                                                pushData:nil
                                                                progress:^(int progress, long messageId) {
                                                                  if (0 == progress) {
                                                                    NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(0)}};
                                                                    
                                                                      [weakSelf._channel invokeMethod:@"onSendImageMessageProgress" arguments:_result];
                                                                  }else if (50 == progress)
                                                                  {
                                                                    NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(50)}};
                                                                    
                                                                      [weakSelf._channel invokeMethod:@"onSendImageMessageProgress" arguments:_result];

                                                                  }else if (100 == progress)
                                                                  {
                                                                    NSDictionary *_result = @{@"status":PROGRESS, @"result": @{@"message":@{@"messageId":@(messageId)}, @"progress":@(100)}};
                                                                    
                                                                      [weakSelf._channel invokeMethod:@"onSendImageMessageProgress" arguments:_result];

                                                                  }
                                                                }
                                                                success:^(long messageId) {
                                                                  NSLog(@"%s", __FUNCTION__);
                                                                  
                                                                  NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                  
                                                                  [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                  
                                                                  [dic setObject:[NSNumber numberWithBool:YES] forKey:@"isSuccess"];
                                                                  
                                                                  
                                                                  NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"message":@{@"messageId":@(messageId)}}};
                                                                    [weakSelf._channel invokeMethod:@"onMessageSendSuccess" arguments:_result];
;
                                                                }
                                                                error:^(RCErrorCode errorCode, long messageId) {
                                                                  NSLog(@"%s", __FUNCTION__);
                                                                  NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                                  
                                                                  [dic setObject:[NSNumber numberWithLong:messageId] forKey:@"messageId"];
                                                                  
                                                                  [dic setObject:[NSNumber numberWithBool:NO] forKey:@"isSuccess"];
                                                                  
                                                                  NSDictionary *_result = @{@"status":ERROR, @"result":@{@"message": @{@"messageId":@(messageId)}}};
                                                                    [weakSelf._channel invokeMethod:@"onMessageSendError" arguments:_result];
;
                                                                  
                                                                }
                                                                  cancel:^(long messageId) {
                                                                      NSLog(@"%s", __FUNCTION__);
                                                                  }];
    
    NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:rcMessage];
    NSDictionary *_result = @{@"status":PREPARE, @"result": @{@"message":_message}};

    result(_result);
}

- (void)sendVoiceMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId voicePath:(NSString *)voicePath duration:(NSNumber *)duration extra:(NSString *)extra  result:(FlutterResult)result

{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![voicePath isKindOfClass:[NSString class]] ||
        ![duration isKindOfClass:[NSNumber class]]||
        ![extra isKindOfClass:[NSString class]]
        ) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
//    NSString *_truePath = [self.commandDelegate getAbsolutePath:voicePath];
//    NSLog(@"_truePath > %@", _truePath);
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
//    NSBundle *myBundle = [NSBundle mainBundle];
//    NSString *testArm = [myBundle pathForResource:@"testVoice" ofType:@"amr"];

    NSData *amrData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:voicePath]];

    if (amrData == nil) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:@"voicePath"]);
        return;
    }
    NSData *wavData ;
    if (amrData.length > 6 && ((unsigned char*)amrData.bytes)[0] == 0x23 && ((unsigned char*)amrData.bytes)[1] == 0x21 && ((unsigned char*)amrData.bytes)[2] == 0x41 && ((unsigned char*)amrData.bytes)[3] == 0x4d && ((unsigned char*)amrData.bytes)[4] == 0x52) {
        //amr first 6 byte are 0x23 0x21 0x41 0x4d 0x52 0X0A(#!AMR.)
        wavData                = [[RCAMRDataConverter sharedAMRDataConverter]decodeAMRToWAVE:amrData];
    } else {
        wavData = amrData;
    }

    RCVoiceMessage *rcVoiceMessage = [RCVoiceMessage messageWithAudio:wavData duration:duration.intValue];
    rcVoiceMessage.extra           = extra;
    [self _sendMessage:_conversationType withTargetId:targetId withContent:rcVoiceMessage withPushContent:nil result:result];
}

- (void)sendLocationMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId imagePath:(NSString *)imagePath latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude locationName:(NSString *)locationName extra:(NSString *)extra result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![latitude isKindOfClass:[NSNumber class]] ||
        ![longitude isKindOfClass:[NSNumber class]] ||
        ![locationName isKindOfClass:[NSString class]] ||
        ![imagePath isKindOfClass:[NSString class]]||
        ![extra isKindOfClass:[NSString class]]
        ) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
//    NSString *_truePath = [self.commandDelegate getAbsolutePath:imagePath];
//    NSLog(@"_truePath > %@", _truePath);
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    CLLocationCoordinate2D location;
    location.latitude                    = (CLLocationDegrees)[latitude doubleValue];
    location.longitude                   = (CLLocationDegrees)[longitude doubleValue];
    
    NSData *thumbnailData                = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:imagePath]];
    
    UIImage *thumbnailImage              = [UIImage imageWithData:thumbnailData];
    
    RCLocationMessage *locationMessage = [RCLocationMessage messageWithLocationImage:thumbnailImage location:location locationName:locationName];
    locationMessage.extra              = extra;
    [self _sendMessage:_conversationType withTargetId:targetId withContent:locationMessage withPushContent:nil result:result];
}

- (void)sendRichContentMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId title:(NSString *)title content:(NSString *)content imageUrl:(NSString *)imageUrl extra:(NSString *)extra  result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![title isKindOfClass:[NSString class]] ||
        ![content isKindOfClass:[NSString class]] ||
        ![imageUrl isKindOfClass:[NSString class]] ||
        ![extra isKindOfClass:[NSString class]]
        ) {

        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    if (nil == extra) {
        extra = @"";
    }
    RCRichContentMessage  * rcRichMessage = [RCRichContentMessage messageWithTitle:title
                                                                            digest:content
                                                                          imageURL:imageUrl
                                                                             extra:extra];
    
    [self _sendMessage:_conversationType withTargetId:targetId withContent:rcRichMessage withPushContent:nil result:result];

}
-(void)sendCommandNotificationMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId name:(NSString *)name data:(NSString *)data result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![name isKindOfClass:[NSString class]] ||
        ![data isKindOfClass:[NSString class]]
        ) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    RCCommandNotificationMessage *msg    = [RCCommandNotificationMessage notificationWithName:name data:data];
    [self _sendMessage:_conversationType withTargetId:targetId withContent:msg withPushContent:nil result:result];
}

-(void)sendCommandMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId name:(NSString *)name data:(NSString *)data result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![name isKindOfClass:[NSString class]] ||
        ![data isKindOfClass:[NSString class]]
        ) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    RCCommandMessage *msg    = [RCCommandMessage messageWithName:name data:data];
    [self _sendMessage:_conversationType withTargetId:targetId withContent:msg withPushContent:nil result:result];
}

- (void)setOnReceiveMessageListener:(FlutterResult)result
{
//    NSLog(@"%s", __FUNCTION__);
//    self.receiveMessageCbId = receiveMessageCbId;

#ifdef RC_SUPPORT_IMKIT
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
#else
    [[RCIMClient sharedRCIMClient]setReceiveMessageDelegate:self object:nil];
#endif
    result(@"");
}

#ifdef RC_SUPPORT_IMKIT
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)nLeft;
#else
- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object
#endif
{
    NSLog(@"%s, isMainThread > %d", __FUNCTION__, [NSThread isMainThread]);
    
//    if (self.receiveMessageCbId) {
    NSDictionary *_message = [RongCloudModel RCGenerateMessageModel:message];
    NSDictionary *_result = @{@"result": @{@"message":_message, @"left":@(nLeft)}};
        
    [self._channel invokeMethod:@"onMessageReceived" arguments:_result];
//    }
    
    /**
     *  Add Local Notification Event
     */
    if (!self.disableLocalNotification) {
        NSNumber *nAppbackgroundMode = [[NSUserDefaults standardUserDefaults]objectForKey:kAppBackgroundMode];
        BOOL _bAppBackgroundMode = [nAppbackgroundMode boolValue];
        if (YES == _bAppBackgroundMode && 0 == nLeft) {
            //post local notification
            [[RCIMClient sharedRCIMClient]getConversationNotificationStatus:message.conversationType targetId:message.targetId success:^(RCConversationNotificationStatus nStatus) {
                if (NOTIFY == nStatus) {
                    NSString *_notificationMessae = @"您收到了一条新消息";
                    
                    [RongCloudModel postLocalNotification:_notificationMessae];
                    
                }
            } error:^(RCErrorCode status) {
                NSLog(@"notification error code= %d",(int)status);
            }];
        }
    }
}

/**
 * conversation
 */
- (void)getConversationList:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    NSArray *typeList                       = [[NSArray alloc]initWithObjects:[NSNumber numberWithInt:ConversationType_PRIVATE],
                                               [NSNumber numberWithInt:ConversationType_DISCUSSION],
                                               [NSNumber numberWithInt:ConversationType_GROUP],
                                               [NSNumber numberWithInt:ConversationType_SYSTEM],nil];
    
    NSArray *_conversationList              = [[RCIMClient sharedRCIMClient]getConversationList:typeList];
    
    NSMutableArray * _conversationListModel = nil;
    _conversationListModel                  = [RongCloudModel RCGenerateConversationListModel:_conversationList];
    
    NSDictionary *_result                   = @{@"status":SUCCESS, @"result": _conversationListModel};
    result(_result);
}

- (void)getConversation:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    RCConversation *_rcConversion        = [[RCIMClient sharedRCIMClient]getConversation:_conversationType targetId:targetId];
    NSDictionary *_ret                   = nil;
    _ret                                 = [RongCloudModel RCGenerateConversationModel:_rcConversion];
    
    if (!_ret) {
        _ret = [NSDictionary new];
    }
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _ret};
    result(_result);
}

- (void)removeConversation:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    BOOL isRemoved = [[RCIMClient sharedRCIMClient] removeConversation:_conversationType targetId:targetId];
    if(isRemoved)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        result(_result);
    }
}

- (void)clearConversations:(NSArray *)conversationTypes result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    if (![conversationTypes isKindOfClass:[NSArray class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_MSG message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    if (nil != conversationTypes && [conversationTypes count] > 0) {
        
        NSUInteger _count      = [conversationTypes count];
        NSMutableArray *argums = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i< _count; i++) {
            RCConversationType _type = [RongCloudModel RCTransferConversationType:[conversationTypes objectAtIndex:i]];
            [argums addObject:@(_type)];
        }
        
        BOOL __ret =[[RCIMClient sharedRCIMClient]clearConversations:argums];
        
        if(__ret)
        {
            NSDictionary *_result = @{@"status":SUCCESS};
            result(_result);
        }else{
            NSDictionary *_result = @{@"status":ERROR};
            result(_result);
        }
    }
}

- (void)setConversationToTop:(NSString *)conversationTypeString targetId:(NSString *)targetId isTop:(NSNumber *)isTop result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![isTop isKindOfClass:[NSNumber class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_CODE details:ERROR]);
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL isSetted = [[RCIMClient sharedRCIMClient] setConversationToTop:_conversationType targetId:targetId isTop:[isTop boolValue]];
    if(isSetted)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    }else{
        NSDictionary *_result = @{@"status":ERROR};
        result(_result);
    }
}

/**
 * conversation notification
 */
- (void)getConversationNotificationStatus:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
//    __weak __typeof(&*self) blockSelf = self;
    [[RCIMClient sharedRCIMClient]getConversationNotificationStatus:_conversationType targetId:targetId success:^(RCConversationNotificationStatus nStatus) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"code": @(nStatus), @"notificationStatus": nStatus?@"NOTIFY":@"DO_NOT_DISTURB"}};
        result(_result);
    } error:^(RCErrorCode status) {
        NSLog(@"notification error code= %d",(int)status);
//        NSDictionary *_result = @{@"status":ERROR};
//        NSDictionary *_err = @{@"code": @(status), @"msg": @""};
        result([FlutterError errorWithCode:[@(status) stringValue] message:@"" details:ERROR]);
    }];
}
- (void)setConversationNotificationStatus:(NSString *)conversationTypeString targetId:(NSString *)targetId conversationnotificationStatus:(NSString *)conversationnotificationStatus result:(FlutterResult)result

{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![conversationnotificationStatus isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL _isBlocked = NO;
    if ([conversationnotificationStatus isEqualToString:@"DO_NOT_DISTURB"]) {
        _isBlocked = YES;
    }
//    __weak __typeof(&*self) blockSelf = self;
    [[RCIMClient sharedRCIMClient]setConversationNotificationStatus:_conversationType targetId:targetId isBlocked:_isBlocked success:^(RCConversationNotificationStatus nStatus) {
        
        NSDictionary *_result = @{@"status":SUCCESS, @"result":@{@"code": @(nStatus), @"notificationStatus": nStatus?@"NOTIFY":@"DO_NOT_DISTURB"}};
        result(_result);
    } error:^(RCErrorCode status) {
//        NSDictionary *_result   =   @{@"status":ERROR};
//        NSDictionary *_err      =   @{@"code": @(status), @"status": @""};
        
        result([FlutterError errorWithCode:[@(status) stringValue] message:@"" details:ERROR]);
    }];
}

/**
 * read message & delete
 */
- (void)getLatestMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![count isKindOfClass:[NSNumber class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    RCConversationType _conversationType     = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSArray *_latestMessages                 = [[RCIMClient sharedRCIMClient]getLatestMessages:_conversationType targetId:targetId count:[count intValue]];
    NSMutableArray * _latestMessageListModel = nil;
    
    _latestMessageListModel                  = [RongCloudModel RCGenerateMessageListModel:_latestMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _latestMessageListModel};
    result(_result);
}

- (void)getHistoryMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count oldestMessageId:(NSNumber *)oldestMessageId result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![count isKindOfClass:[NSNumber class]] ||
        ![oldestMessageId isKindOfClass:[NSNumber class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    RCConversationType _conversationType      = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSArray *_historyMessages                 = [[RCIMClient sharedRCIMClient] getHistoryMessages:_conversationType targetId:targetId oldestMessageId:[oldestMessageId longValue] count:[count intValue]];
    NSMutableArray * _historyMessageListModel = nil;
    
    _historyMessageListModel                  = [RongCloudModel RCGenerateMessageListModel:_historyMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _historyMessageListModel};
    result(_result);
}
- (void)getHistoryMessagesByObjectName:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count oldestMessageId:(NSNumber *)oldestMessageId objectName:(NSString *)objectName result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![count isKindOfClass:[NSNumber class]] ||
        ![oldestMessageId isKindOfClass:[NSNumber class]] ||
        ![objectName isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCConversationType _conversationType      = [RongCloudModel RCTransferConversationType:conversationTypeString];
    
    NSArray *_historyMessages = [[RCIMClient sharedRCIMClient] getHistoryMessages:_conversationType targetId:targetId objectName:objectName oldestMessageId:[oldestMessageId longValue] count:[count intValue]];
    NSMutableArray * _historyMessageListModel = nil;
    
    _historyMessageListModel = [RongCloudModel RCGenerateMessageListModel:_historyMessages];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": _historyMessageListModel};
    result(_result);
}
- (void) deleteMessages:(NSArray *)messageIds result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![messageIds isKindOfClass:[NSArray class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    BOOL isDeleted = [[RCIMClient sharedRCIMClient]deleteMessages:messageIds];
    if(isDeleted)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    }else{
        result([FlutterError errorWithCode:ERROR message:ERROR details:ERROR]);
    }
}
- (void) clearMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL isCleared = [[RCIMClient sharedRCIMClient]clearMessages:_conversationType targetId:targetId];
    if(isCleared)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    }else{
//        NSDictionary *_result = @{@"status":ERROR};
        result([FlutterError errorWithCode:ERROR message:ERROR details:ERROR]);
    }
}

/**
 * unread message count
 */
- (void) getTotalUnreadCount: (FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);

    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    int totalUnReadCount = (int)[[RCIMClient sharedRCIMClient]getTotalUnreadCount];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(totalUnReadCount)};
    result(_result);
}

- (void) getUnreadCount:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
        
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSInteger unReadCount = [[RCIMClient sharedRCIMClient]getUnreadCount:_conversationType targetId:targetId];
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(unReadCount)};
    result(_result);
}
-(void)getUnreadCountByConversationTypes:(NSArray *)conversationTypes result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    if (![conversationTypes isKindOfClass:[NSArray class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    NSMutableArray * _conversationTypes = [NSMutableArray new];
    for(int i=0; i< [conversationTypes count]; i++)
    {
        RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypes[i]];
        [_conversationTypes addObject:@(_conversationType)];
    }
    
    NSInteger _unread_count = [[RCIMClient sharedRCIMClient]getUnreadCount:_conversationTypes];
    
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(_unread_count)};
    result(_result);
}

-(void)setMessageReceivedStatus:(NSNumber *)messageId
             withReceivedStatus:(NSString *)receivedStatus
                  result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![messageId isKindOfClass:[NSNumber class]] ||
        ![receivedStatus isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    BOOL __ret = [[RCIMClient sharedRCIMClient]setMessageReceivedStatus:messageId.intValue
                                                         receivedStatus:[RongCloudModel RCTransferReceivedStatusFromString:receivedStatus]];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    }else{
        result([FlutterError errorWithCode:ERROR message:ERROR details:ERROR]);
    }
}

- (void) clearMessagesUnreadStatus: (NSString*)conversationTypeString
                      withTargetId:(NSString *)targetId
                    result:(FlutterResult)result

{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL __ret = [[RCIMClient sharedRCIMClient]clearMessagesUnreadStatus:_conversationType targetId:targetId];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    }else{
        result([FlutterError errorWithCode:ERROR message:ERROR details:ERROR]);
    }
    
}
-(void) setMessageExtra : (NSNumber *)messageId
               withValue:(NSString *)value
          result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![messageId isKindOfClass:[NSNumber class]] ||
        ![value isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    BOOL __ret = [[RCIMClient sharedRCIMClient]setMessageExtra:messageId.longValue value:value];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    }else{
        result([FlutterError errorWithCode:ERROR message:ERROR details:ERROR]);
    }
}

/**
 * message draft
 */
-(void) getTextMessageDraft :(NSString*)conversationTypeString
                withTargetId:(NSString *)targetId
              result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
   
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    RCConversationType conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    NSString *__draft = [[RCIMClient sharedRCIMClient]getTextMessageDraft:conversationType targetId:targetId];
    if (nil == __draft) {
        __draft = @"";
    }
    NSDictionary *_result = @{@"status":SUCCESS, @"result": __draft};
    result(_result);
    
}
-(void) saveTextMessageDraft:(NSString *)conversationTypeString
                withTargetId:(NSString *)targetId
                 withContent:(NSString *)content
              result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![content isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    RCConversationType conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
    BOOL __ret = [[RCIMClient sharedRCIMClient] saveTextMessageDraft:conversationType
                                                            targetId:targetId
                                                             content:content];
    if(__ret)
    {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    }else{
        result([FlutterError errorWithCode:ERROR message:ERROR details:ERROR]);
    }
}
-(void)clearTextMessageDraft:(NSString *)conversationTypeString
                withTargetId:(NSString *)targetId
              result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
        if (![conversationTypeString isKindOfClass:[NSString class]] ||
            ![targetId isKindOfClass:[NSString class]]
            ) {
            result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
            return;
        }
        RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
        BOOL __ret = [[RCIMClient sharedRCIMClient] clearTextMessageDraft:_conversationType targetId:targetId];
        if(__ret)
        {
            NSDictionary *_result = @{@"status":SUCCESS};
            result(_result);
        }else{
            result([FlutterError errorWithCode:ERROR message:ERROR details:ERROR]);
        }
}

/**
 * discussion
 */
- (void) createDiscussion:(NSString *)name
           withUserIdList:(NSArray *)userIdList
           result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![name isKindOfClass:[NSString class]] ||
        ![userIdList isKindOfClass:[NSArray class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient]createDiscussion:name userIdList:userIdList success:^(RCDiscussion *discussion) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result": @{@"discussionId": discussion.discussionId}};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
        
    
}

-(void)getDiscussion:(NSString *)discussionId
      result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![discussionId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    [[RCIMClient sharedRCIMClient]getDiscussion:discussionId success:^(RCDiscussion *discussion) {
        NSDictionary *_dic = [RongCloudModel RCGenerateDiscussionModel:discussion];
        NSDictionary *_result = @{@"status":SUCCESS, @"result": _dic};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

-(void)setDiscussionName:(NSString *)discussionId
                withName:(NSString *)name
          result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (result) {
        if (![discussionId isKindOfClass:[NSString class]] ||
            ![name isKindOfClass:[NSString class]]
            ) {
            result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
            return;
        }
        
        [[RCIMClient sharedRCIMClient]setDiscussionName:discussionId name:name success:^{
            NSDictionary *_result = @{@"status":SUCCESS};
            result(_result);
        } error:^(RCErrorCode status) {
            result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
        }];
    }
}

- (void) addMemberToDiscussion:(NSString *)discussionId
                withUserIdList:(NSArray *)userIdList
                result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![discussionId isKindOfClass:[NSString class]] ||
        ![userIdList isKindOfClass:[NSArray class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    [[RCIMClient sharedRCIMClient] addMemberToDiscussion:discussionId userIdList:userIdList success:^(RCDiscussion *discussion){
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}
- (void) removeMemberFromDiscussion:(NSString *)discussionId
                        withUserId:(NSString *)userId
                     result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![discussionId isKindOfClass:[NSString class]] ||
        ![userId isKindOfClass:[NSString class]]
        ) {
        
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient] removeMemberFromDiscussion:discussionId userId:userId success:^(RCDiscussion *discussion) {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}
- (void) quitDiscussion:(NSString *)discussionId
         result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![discussionId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    [[RCIMClient sharedRCIMClient] quitDiscussion:discussionId success:^(RCDiscussion *discussion) {
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}
- (void) setDiscussionInviteStatus:(NSString *)discussionId
                  withInviteStatus:(NSString *)inviteStatus
                    result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![inviteStatus isKindOfClass:[NSString class]] ||
        ![discussionId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    BOOL _isOpen = YES;
    
    if ([inviteStatus isEqualToString:@"CLOSED"]) {
        _isOpen = NO;
    }
    [[RCIMClient sharedRCIMClient]setDiscussionInviteStatus:discussionId isOpen:_isOpen success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

/**
 * group
 */
- (void) syncGroup:(NSArray *)groups
    result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
     if (![groups isKindOfClass:[NSArray class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    NSMutableArray *_groupList = [RongCloudModel RCGenerateGroupList:groups];
    
    if (nil == _groupList) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient]syncGroups:_groupList success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}
- (void) joinGroup:(NSString *)groupId
     withGroupName:(NSString *)groupName
    result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    if (![groupId isKindOfClass:[NSString class]] ||
        ![groupName isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient]joinGroup:groupId groupName:groupName success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void) quitGroup:(NSString *)groupId
    result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![groupId isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient]quitGroup:groupId success:^{
        
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

/**
 * chatRoom
 */
- (void)joinChatRoom:(NSString *)chatRoomId
        messageCount:(NSNumber *)defMessageCount
      result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![chatRoomId isKindOfClass:[NSString class]] ||
        ![defMessageCount isKindOfClass:[NSNumber class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient]joinChatRoom:chatRoomId messageCount:[defMessageCount intValue] success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)quitChatRoom:(NSString *)chatRoomId
      result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![chatRoomId isKindOfClass:[NSString class]]
        ) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient]quitChatRoom:chatRoomId success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)getConnectionStatus:(FlutterResult) result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @{@"connectionStatus":[RongCloudModel RCTransferConnectionStatus:status]}};
    result(_result);
}

- (void)logout:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
  
#ifdef RC_SUPPORT_IMKIT
  [[RCIM sharedRCIM] disconnect:NO];
#else
    [[RCIMClient sharedRCIMClient]disconnect:NO];
#endif
    isConnected = NO;
    NSDictionary *_result = @{@"status": SUCCESS};
    result(_result);
}

- (void)getRemoteHistoryMessages:(NSString *)conversationTypeString
                        targetId:(NSString *)targetId
                      recordTime:(NSNumber *)dateTime
                           count:(NSNumber *)count
                  result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }

    if (![conversationTypeString isKindOfClass:[NSString class]] ||
        ![targetId isKindOfClass:[NSString class]] ||
        ![dateTime isKindOfClass:[NSNumber class]] ||
        ![count isKindOfClass:[NSNumber class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCConversationType _conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];

    [[RCIMClient sharedRCIMClient] getRemoteHistoryMessages:_conversationType targetId:targetId recordTime:[dateTime longLongValue] count:[count intValue] success:^(NSArray *messages,BOOL isRemaining) {
        
        NSMutableArray * _historyMessageListModel = nil;
        _historyMessageListModel = [RongCloudModel RCGenerateMessageListModel:messages];
        
        NSDictionary *_result = @{@"status":SUCCESS, @"result": _historyMessageListModel};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)setMessageSentStatus:(NSNumber *)messageId
                  sentStatus:(NSString *)statusString
              result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![statusString isKindOfClass:[NSString class]] ||
        ![messageId isKindOfClass:[NSNumber class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    RCSentStatus status = [RongCloudModel RCTransferSendStatusFromString:statusString];
    BOOL isSuccess = [[RCIMClient sharedRCIMClient] setMessageSentStatus:[messageId longValue] sentStatus:status];
    if (isSuccess) {
        NSDictionary *_result = @{@"status":SUCCESS};
        
        result(_result);
    } else {
        result([FlutterError errorWithCode:UNKNOWN_CODE message:UNKNOWN_MSG details:ERROR]);    }
}
                        
- (void)getDeltaTime:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    long long time = [[RCIMClient sharedRCIMClient] getDeltaTime];
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": @(time)};
    result(_result);
}

- (void)getCurrentUserId:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    NSDictionary *_result = @{@"status":SUCCESS, @"result": [RCIMClient sharedRCIMClient].currentUserInfo.userId};
    result(_result);
}

- (void)addToBlacklist:(NSString *)userId
        result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![userId isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient] addToBlacklist:userId success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)removeFromBlacklist:(NSString *)userId
             result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![userId isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient] removeFromBlacklist:userId success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)getBlacklistStatus:(NSString *)userId
            result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![userId isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }
    
    [[RCIMClient sharedRCIMClient] getBlacklistStatus:userId success:^(int bizStatus) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result": (bizStatus? @(1) : @(0))};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)getBlacklist:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    [[RCIMClient sharedRCIMClient] getBlacklist:^(NSArray *blockUserIds) {
        NSDictionary *_result = @{@"status":SUCCESS, @"result": blockUserIds ? blockUserIds : @[]};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)setNotificationQuietHours:(NSString *)startTime
                         spanMins:(NSNumber *)spanMinutes
                   result:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    if (![startTime isKindOfClass:[NSString class]]
        || ![spanMinutes isKindOfClass:[NSNumber class]]) {
        result([FlutterError errorWithCode:BAD_PARAMETER_CODE message:BAD_PARAMETER_MSG details:ERROR]);
        return;
    }

    [[RCIMClient sharedRCIMClient] setNotificationQuietHours:startTime spanMins:[spanMinutes intValue] success:^{
        NSDictionary *_result = @{@"status":SUCCESS};
        
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)removeNotificationQuietHours:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:^{
        NSDictionary *_result = @{@"status": SUCCESS};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}

- (void)getNotificationQuietHours:(FlutterResult)result
{
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInitOrConnect:result]) {
        return;
    }
    
    [[RCIMClient sharedRCIMClient] getNotificationQuietHours:^(NSString *startTime, int spansMin) {
        NSDictionary *_result = @{@"status": SUCCESS, @"result": @{@"startTime": startTime, @"spanMinutes": @(spansMin)}};
        result(_result);
    } error:^(RCErrorCode status) {
        result([FlutterError errorWithCode:ERROR message:ERROR details:@(status)]);
    }];
}
- (void)disableLocalNotification:(FlutterResult)result {
    NSLog(@"%s", __FUNCTION__);
    
    if (![self checkIsInit:result]) {
        return;
    }
    
    self.disableLocalNotification = YES;

    
    NSDictionary *_result = @{@"status": SUCCESS};
    result(_result);
}

- (NSDictionary *)dictionaryOfCustomerServiceGroupItem:(RCCustomerServiceGroupItem *)item {
    return @{@"groupId":item.groupId, @"name":item.name, @"online":@(item.online)};
}
                          
- (void)startCustomerService:(NSString *)kefuId userName:(NSString *)userName  result:(FlutterResult)result {
  RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
  csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
  csInfo.nickName = userName;
  
  __weak RongCloudHybridAdapter* weakSelf = self;
  
  [[RCIMClient sharedRCIMClient] startCustomerService:kefuId info:csInfo onSuccess:^(RCCustomerServiceConfig *config) {
    NSDictionary *_result = @{@"status":@"success"};
      [weakSelf._channel invokeMethod:@"onCustomServiceSuccess" arguments:_result];
  } onError:^(int errorCode, NSString *errMsg) {
      if (errMsg == nil)
          errMsg = @"";
      NSDictionary *_result = @{@"status":@"error", @"result": @{@"errorCode":@(errorCode), @"errorMsg":errMsg}};
      [weakSelf._channel invokeMethod:@"onCustomServiceError" arguments:_result];
  } onModeType:^(RCCSModeType mode) {
    NSDictionary *_result = @{@"status":@"modeChanged", @"result": @{@"mode":@(mode)}};
      [weakSelf._channel invokeMethod:@"onCustomServiceModeChanged" arguments:_result];
  } onPullEvaluation:^(NSString *dialogId) {
    NSDictionary *_result = @{@"status":@"pullEvaluation", @"result": @{@"dialogId":dialogId}};
      [weakSelf._channel invokeMethod:@"onCustomServicePullEvaluation" arguments:_result];
  } onSelectGroup:^(NSArray<RCCustomerServiceGroupItem *> *groupList) {
    NSMutableArray *groupItemDictList = [NSMutableArray new];
    for (RCCustomerServiceGroupItem *item in groupList) {
      [groupItemDictList addObject:[weakSelf dictionaryOfCustomerServiceGroupItem:item]];
    }
    NSDictionary *_result = @{@"status":@"selectGroup", @"result": @{@"groupList":groupItemDictList}};
    
      [weakSelf._channel invokeMethod:@"onCustomServiceSelectGroup" arguments:_result];
  } onQuit:^(NSString *quitMsg) {
    NSDictionary *_result = @{@"status":@"quit", @"result": @{@"quitMsg":quitMsg}};
      [weakSelf._channel invokeMethod:@"onCustomServiceQuit" arguments:_result];
  }];
  result(SUCCESS);
}

- (void)stopCustomerService:(NSString *)kefuId  result:(FlutterResult)result {
  [[RCIMClient sharedRCIMClient] stopCustomerService:kefuId];
  result(@"");
}

- (void)selectCustomerServiceGroup:(NSString *)kefuId withGroupId:(NSString *)groupId  result:(FlutterResult)result {
  [[RCIMClient sharedRCIMClient] selectCustomerServiceGroup:kefuId withGroupId:groupId];
  result(@"");
}

- (void)switchToHumanMode:(NSString *)kefuId  result:(FlutterResult)result {
  [[RCIMClient sharedRCIMClient] switchToHumanMode:kefuId];
  result(@"");
}

- (void)evaluateCustomerService:(NSString *)kefuId
                      knownledgeId:(NSString *)knownledgeId
                        robotValue:(BOOL)isRobotResolved
                           suggest:(NSString *)suggest
                     result:(FlutterResult)result {
  [[RCIMClient sharedRCIMClient] evaluateCustomerService:kefuId knownledgeId:knownledgeId robotValue:isRobotResolved suggest:suggest];
  result(@"");
}

- (void)evaluateCustomerService:(NSString *)kefuId
                          dialogId:(NSString *)dialogId
                        humanValue:(int)value
                           suggest:(NSString *)suggest
                     result:(FlutterResult)result {
                         // 升级说明：如果您之前使用了此接口，可以直接替换为evaluateCustomerService:dialogId:starValue:suggest:resolveStatus:tagText:extra: 接口，行为和实现完全一致。

                         [[RCIMClient sharedRCIMClient] evaluateCustomerService:kefuId dialogId:dialogId starValue:value suggest:suggest resolveStatus:1 tagText:nil extra:nil];
  result(@"");
}
                          
#ifdef RC_SUPPORT_IMKIT
- (void)startNativeSingleCall:(NSString *)calleeId mediaType:(int)mediaType result:(FlutterResult)result {
    [[RCCall sharedRCCall] startSingleCall:calleeId mediaType:(RCCallMediaType)mediaType];
}
                          
- (void)startNativeMultiCall:(NSString *)conversationTypeString targetId:(NSString *)targetId userIdList:(NSArray *)userIdList mediaType:(int)mediaType result:(FlutterResult)result {
  RCConversationType conversationType = [RongCloudModel RCTransferConversationType:conversationTypeString];
  [[RCCall sharedRCCall] startMultiCallViewController:conversationType targetId:targetId mediaType:mediaType userIdList:userIdList];
}
                          
- (void)startNativeCustomerService:(NSString *)kefuId withUserName:(NSString *)userName withCallbackId:cbId {
  RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];
  
  chatService.userName = @"客服";
  chatService.conversationType = ConversationType_CUSTOMERSERVICE;
  
  chatService.targetId = kefuId;
  
  //上传用户信息，nickname是必须要填写的
  RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
  csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
  csInfo.nickName = userName;
  
  chatService.csInfo = csInfo;
  chatService.title = chatService.userName;
  
  UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:chatService];
  
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navi animated:YES completion:nil];
}
#endif
@end
