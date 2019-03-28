//
//  RongCloudModule.h
//  UZApp
//
//  Created by xugang on 14/12/17.
//  Copyright (c) 2014年 APICloud. All rights reserved.
//
#import <Flutter/Flutter.h>
#import <RongIMLib/RongIMLib.h>

#ifdef RC_SUPPORT_IMKIT
#import <RongIMKit/RongIMKit.h>
#endif

@protocol RongCloud2HybridDelegation <NSObject>
- (void)sendResult:(NSDictionary *)resultDict error:(NSDictionary *)errorDict result:(FlutterResult)result doDelete:(BOOL)doDelete;
- (NSString *)getAbsolutePath:(NSString *)relativePath;
@end


@interface RongCloudHybridAdapter : NSObject <
#ifdef RC_SUPPORT_IMKIT
RCIMReceiveMessageDelegate, RCIMConnectionStatusDelegate, RCIMUserInfoDataSource
#else
RCIMClientReceiveMessageDelegate,RCConnectionStatusChangeDelegate
#endif
>
- (instancetype)initRongModule;

- (void)setMethodChannel:(FlutterMethodChannel *)flutterMethodChannel;
- (void)init:(NSString *)appKey result:(FlutterResult)result;
- (void)setUserInfo:(NSString *)userId name:(NSString *)name avatar:(NSString *)avatar level:(NSString *)level  result:(FlutterResult)result;
- (void)connectWithToken:(NSString *)token result:(FlutterResult)result;
- (void)disconnect:(NSNumber *)isReceivePush result:(FlutterResult)result;
- (void)setConnectionStatusListener:(FlutterResult)result;
- (void)sendTextMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId content:(NSString *)textContent extra:(NSString *)extra  result:(FlutterResult)result;
- (void)sendImageMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId imagePath:(NSString *)imagePath extra:(NSString *)extra result:(FlutterResult)result;
- (void)sendVoiceMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId voicePath:(NSString *)voicePath duration:(NSNumber *)duration extra:(NSString *)extra result:(FlutterResult)result;
- (void)sendLocationMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId imagePath:(NSString *)imagePath latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude locationName:(NSString *)locationName extra:(NSString *)extra result:(FlutterResult)result;
- (void)sendRichContentMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId title:(NSString *)title content:(NSString *)content imageUrl:(NSString *)imageUrl extra:(NSString *)extra result:(FlutterResult)result;
- (void)sendCommandNotificationMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId name:(NSString *)name data:(NSString *)data  result:(FlutterResult)result;
-(void)sendCommandMessage:(NSString *)conversationTypeString targetId:(NSString *)targetId name:(NSString *)name data:(NSString *)data  result:(FlutterResult)result;
- (void)setOnReceiveMessageListener:(FlutterResult)result;
- (void)getConversationList: (FlutterResult)result;
- (void)getConversation:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result;
- (void)removeConversation:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result;
- (void)clearConversations:(NSArray *)conversationTypes result:(FlutterResult)result;
- (void)setConversationToTop:(NSString *)conversationTypeString targetId:(NSString *)targetId isTop:(NSNumber *)isTop result:(FlutterResult)result;
- (void)getConversationNotificationStatus:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result;
- (void)setConversationNotificationStatus:(NSString *)conversationTypeString targetId:(NSString *)targetId conversationnotificationStatus:(NSString *)conversationnotificationStatus result:(FlutterResult)result;
- (void)getLatestMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count result:(FlutterResult)result;
- (void)getHistoryMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count oldestMessageId:(NSNumber *)oldestMessageId result:(FlutterResult)result;
- (void)getHistoryMessagesByObjectName:(NSString *)conversationTypeString targetId:(NSString *)targetId count:(NSNumber *)count oldestMessageId:(NSNumber *)oldestMessageId objectName:(NSString *)objectName result:(FlutterResult)result;

- (void) deleteMessages:(NSArray *)messageIds result:(FlutterResult)result;
- (void) clearMessages:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result;
- (void) getTotalUnreadCount:(FlutterResult)result;
- (void) getUnreadCount:(NSString *)conversationTypeString targetId:(NSString *)targetId result:(FlutterResult)result;
-(void)getUnreadCountByConversationTypes:(NSArray *)conversationTypes result:(FlutterResult)result;
-(void)setMessageReceivedStatus:(NSNumber *)messageId withReceivedStatus:(NSString *)receivedStatus result:(FlutterResult)result;

- (void) clearMessagesUnreadStatus: (NSString*)conversationTypeString withTargetId:(NSString *)targetId result:(FlutterResult)result;
-(void) setMessageExtra : (NSNumber *)messageId withValue:(NSString *)value result:(FlutterResult)result;
-(void) getTextMessageDraft :(NSString*)conversationTypeString withTargetId:(NSString *)targetId result:(FlutterResult)result;
-(void) saveTextMessageDraft:(NSString *)conversationTypeString withTargetId:(NSString *)targetId withContent:(NSString *)content result:(FlutterResult)result;
-(void)clearTextMessageDraft:(NSString *)conversationTypeString  withTargetId:(NSString *)targetId result:(FlutterResult)result;
- (void) createDiscussion:(NSString *)name withUserIdList:(NSArray *)userIdList result:(FlutterResult)result;
-(void)getDiscussion:(NSString *)discussionId result:(FlutterResult)result;
-(void)setDiscussionName:(NSString *)discussionId withName:(NSString *)name result:(FlutterResult)result;
- (void) addMemberToDiscussion:(NSString *)discussionId withUserIdList:(NSArray *)userIdList result:(FlutterResult)result;
- (void) removeMemberFromDiscussion:(NSString *)discussionId  withUserId:(NSString *)userId result:(FlutterResult)result;
- (void) quitDiscussion:(NSString *)discussionId result:(FlutterResult)result;
- (void) setDiscussionInviteStatus:(NSString *)discussionId withInviteStatus:(NSString *)inviteStatus result:(FlutterResult)result;
- (void) syncGroup:(NSArray *)groups result:(FlutterResult)result;
- (void) joinGroup:(NSString *)groupId withGroupName:(NSString *)groupName result:(FlutterResult)result;

- (void) quitGroup:(NSString *)groupId
    result:(FlutterResult)result;

- (void)joinChatRoom:(NSString *)chatRoomId
        messageCount:(NSNumber *)defMessageCount
      result:(FlutterResult)result;

- (void)quitChatRoom:(NSString *)chatRoomId
      result:(FlutterResult)result;

- (void)getConnectionStatus:(FlutterResult)result;

- (void)logout:(FlutterResult)result;

- (void)getDeltaTime:(FlutterResult)result;

- (void)getRemoteHistoryMessages:(NSString *)conversationTypeString
                        targetId:(NSString *)targetId
                      recordTime:(NSNumber *)dateTime
                           count:(NSNumber *)count
                  result:(FlutterResult)result;

- (void)setMessageSentStatus:(NSNumber *)messageId
                  sentStatus:(NSString *)statusString
              result:(FlutterResult)result;

- (void)getCurrentUserId:(FlutterResult)result;

- (void)addToBlacklist:(NSString *)userId
        result:(FlutterResult)result;

- (void)removeFromBlacklist:(NSString *)userId
             result:(FlutterResult)result;

- (void)getBlacklistStatus:(NSString *)userId
            result:(FlutterResult)result;

- (void)getBlacklist:(FlutterResult)result;

- (void)setNotificationQuietHours:(NSString *)startTime
                         spanMins:(NSNumber *)spanMinutes
                   result:(FlutterResult)result;

- (void)removeNotificationQuietHours:(FlutterResult)result;

- (void)getNotificationQuietHours:(FlutterResult)result;

- (void)disableLocalNotification:(FlutterResult)result;


- (void)startCustomerService:(NSString *)kefuId userName:(NSString *)userName result:(FlutterResult)result;

- (void)stopCustomerService:(NSString *)kefuId result:(FlutterResult)result;

- (void)selectCustomerServiceGroup:(NSString *)kefuId withGroupId:(NSString *)groupId result:(FlutterResult)result;
- (void)switchToHumanMode:(NSString *)kefuId result:(FlutterResult)result;

- (void)evaluateCustomerService:(NSString *)kefuId knownledgeId:(NSString *)knownledgeId robotValue:(BOOL)isRobotResolved suggest:(NSString *)suggest result:(FlutterResult)result;

- (void)evaluateCustomerService:(NSString *)kefuId dialogId:(NSString *)dialogId humanValue:(int)value suggest:(NSString *)suggest result:(FlutterResult)result;

#ifdef RC_SUPPORT_IMKIT
- (void)startNativeSingleCall:(NSString *)calleeId mediaType:(int)mediaType result:(FlutterResult)result;
- (void)startNativeMultiCall:(NSString *)conversationTypeString targetId:(NSString *)targetId userIdList:(NSArray *)userIdList mediaType:(int)mediaType result:(FlutterResult)result;

- (void)startNativeCustomerService:(NSString *)kefuId withUserName:(NSString *)userName withCallbackId:cbId;
- (void)refreshUserInfo:(RCUserInfo *)userInfo;
- (void)setUserInfoProvider:(id)userInfoProviderId;
#endif
@end
