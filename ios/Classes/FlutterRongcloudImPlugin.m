#import "FlutterRongcloudImPlugin.h"
#import "RongCloudModel.h"
#import "RongCloudConstant.h"
#import "RongCloudHandler.h"
#import "RongCloudHybridAdapter.h"

RongCloudHybridAdapter *_rongCloudAdapter;


@implementation FlutterRongcloudImPlugin

- (void)dealloc
{
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_rongcloud_im"
            binaryMessenger:[registrar messenger]];
    FlutterRongcloudImPlugin* instance = [[FlutterRongcloudImPlugin alloc] initWithRegistrar:registrar];
    [_rongCloudAdapter setMethodChannel:channel];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        _rongCloudAdapter = [[RongCloudHybridAdapter alloc] initRongModule];
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"disableLocalNotification" isEqualToString:call.method]) {
        [_rongCloudAdapter disableLocalNotification:result];
    }else if ([@"init" isEqualToString:call.method]) {
        [_rongCloudAdapter init:call.arguments[@"appKey"] result:result];
    }else if ([@"connect" isEqualToString:call.method]) {
        [_rongCloudAdapter connectWithToken:call.arguments[@"token"] result:result];
    }else if ([@"setUserInfo" isEqualToString:call.method]) {
        [_rongCloudAdapter setUserInfo:call.arguments[@"id"] name:call.arguments[@"name"] avatar:call.arguments[@"avatar"] level:call.arguments[@"level"] result:result];
    }else if ([@"logout" isEqualToString:call.method]) {
        [_rongCloudAdapter logout:result];
    }else if ([@"disconnect" isEqualToString:call.method]) {
        [_rongCloudAdapter disconnect:0 result:result];
    }else if ([@"getConversationList" isEqualToString:call.method]) {
        [_rongCloudAdapter getConversationList:result];
    }else if ([@"setOnReceiveMessageListener" isEqualToString:call.method]) {
        [_rongCloudAdapter setOnReceiveMessageListener:result];
    }else if ([@"getGroupConversationList" isEqualToString:call.method]) {
        [_rongCloudAdapter getConversationList:result];
    }else if ([@"getConversation" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        [_rongCloudAdapter getConversation:type targetId:targetId result:result];
    }else if ([@"removeConversation" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        [_rongCloudAdapter removeConversation:type targetId:targetId result:result];
    }else if ([@"setConversationToTop" isEqualToString:call.method]) {
        NSString * type = call.arguments[@"conversationType"];
        NSString * targetId = call.arguments[@"targetId"];
        NSNumber *isTop = call.arguments[@"isTop"];
        [_rongCloudAdapter setConversationToTop:type targetId:targetId isTop:isTop result:result];
    }else if ([@"getTotalUnreadCount" isEqualToString:call.method]) {
        [_rongCloudAdapter getTotalUnreadCount:result];
    }else if ([@"getUnreadCount" isEqualToString:call.method]) {
        NSString * type = call.arguments[@"conversationType"];
        NSString * targetId = call.arguments[@"targetId"];
        [_rongCloudAdapter getUnreadCount:type targetId:targetId result:result];
    }else if ([@"getUnreadCountByConversationTypes" isEqualToString:call.method]) {
        NSArray *array = call.arguments[@"conversationTypes"];
        [_rongCloudAdapter getUnreadCountByConversationTypes:array result:result];
    }else if ([@"getLatestMessages" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSNumber *count = call.arguments[@"count"];
        [_rongCloudAdapter getLatestMessages:type targetId:targetId count:count result:result];
    }else if ([@"getHistoryMessages" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSNumber *oldestMessageId = call.arguments[@"oldestMessageId"];
        NSNumber *count = call.arguments[@"count"];
        [_rongCloudAdapter getHistoryMessages:type targetId:targetId count:count oldestMessageId:oldestMessageId result:result];
    }else if ([@"getHistoryMessagesByObjectName" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *objectName = call.arguments[@"objectName"];
        NSNumber *oldestMessageId = call.arguments[@"oldestMessageId"];
        NSNumber *count = call.arguments[@"count"];
        [_rongCloudAdapter getHistoryMessagesByObjectName:type targetId:targetId count:count oldestMessageId:oldestMessageId objectName:objectName result:result];
    }else if ([@"deleteMessages" isEqualToString:call.method]) {
        NSArray *array = call.arguments[@"messageIds"];
        [_rongCloudAdapter deleteMessages:array result:result];
    }else if ([@"clearMessages" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        [_rongCloudAdapter clearMessages:type targetId:targetId result:result];
    }else if ([@"clearMessagesUnreadStatus" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        [_rongCloudAdapter clearMessagesUnreadStatus:type withTargetId:targetId result:result];
    }else if ([@"setMessageExtra" isEqualToString:call.method]) {
        NSNumber *messageId = call.arguments[@"messageId"];
        NSString *value = call.arguments[@"value"];
        [_rongCloudAdapter setMessageExtra:messageId withValue:value result:result];
    }else if ([@"setMessageReceivedStatus" isEqualToString:call.method]) {
        NSNumber *messageId = call.arguments[@"messageId"];
        NSString *receivedStatus = call.arguments[@"receivedStatus"];
        [_rongCloudAdapter setMessageSentStatus:messageId sentStatus:receivedStatus result:result];
    }else if ([@"getTextMessageDraft" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        [_rongCloudAdapter getTextMessageDraft:type withTargetId:targetId result:result];
    }else if ([@"saveTextMessageDraft" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *content = call.arguments[@"content"];
        [_rongCloudAdapter saveTextMessageDraft:type withTargetId:targetId withContent:content result:result];
    }else if ([@"clearTextMessageDraft" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        [_rongCloudAdapter clearTextMessageDraft:type withTargetId:targetId result:result];
    }else if ([@"createDiscussion" isEqualToString:call.method]) {
        NSString *name = call.arguments[@"name"];
        NSArray *userIds = call.arguments[@"userIdList"];
        [_rongCloudAdapter createDiscussion:name withUserIdList:userIds result:result];
    }else if ([@"getDiscussion" isEqualToString:call.method]) {
        NSString *discussionId = call.arguments[@"discussionId"];
        [_rongCloudAdapter getDiscussion:discussionId result:result];
    }else if ([@"setDiscussionName" isEqualToString:call.method]) {
        NSString *name = call.arguments[@"name"];
        NSString *discussionId = call.arguments[@"discussionId"];
        [_rongCloudAdapter setDiscussionName:discussionId withName:name result:result];
    }else if ([@"addMemberToDiscussion" isEqualToString:call.method]) {
        NSString *discussionId = call.arguments[@"discussionId"];
        NSArray *userIdList = call.arguments[@"userIdList"];
        [_rongCloudAdapter addMemberToDiscussion:discussionId withUserIdList:userIdList result:result];
    }else if ([@"removeMemberFromDiscussion" isEqualToString:call.method]) {
        NSString *discussionId = call.arguments[@"discussionId"];
        NSString *userId = call.arguments[@"userId"];
        [_rongCloudAdapter removeMemberFromDiscussion:discussionId withUserId:userId result:result];
    }else if ([@"quitDiscussion" isEqualToString:call.method]) {
        NSString *discussionId = call.arguments[@"discussionId"];
        [_rongCloudAdapter quitDiscussion:discussionId result:result];
    }else if ([@"sendTextMessage" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *content = call.arguments[@"text"];
        NSString *extra = call.arguments[@"extra"];
        [_rongCloudAdapter sendTextMessage:type targetId:targetId content:content extra:extra result:result];
    }else if ([@"sendImageMessage" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *imagePath = call.arguments[@"imagePath"];
        NSString *extra = call.arguments[@"extra"];
        [_rongCloudAdapter sendImageMessage:type targetId:targetId imagePath:imagePath extra:extra result:result];
    }else if ([@"sendVoiceMessage" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *voicePath = call.arguments[@"voicePath"];
        NSNumber *duration = call.arguments[@"duration"];
        NSString *extra = call.arguments[@"extra"];
        [_rongCloudAdapter sendVoiceMessage:type targetId:targetId voicePath:voicePath duration:duration extra:extra result:result];
    }else if ([@"sendRichContentMessage" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *title = call.arguments[@"title"];
        NSString *content = call.arguments[@"description"];
        NSString *imageUrl = call.arguments[@"imageUrl"];
        NSString *extra = call.arguments[@"extra"];
        [_rongCloudAdapter sendRichContentMessage:type targetId:targetId title:title content:content imageUrl:imageUrl extra:extra result:result];
    }else if ([@"sendLocationMessage" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSNumber *lat = call.arguments[@"latitude"];
        NSNumber *lng = call.arguments[@"longitude"];
        NSString *poi = call.arguments[@"poi"];
        NSString *imagePath = call.arguments[@"imagePath"];
        NSString *extra = call.arguments[@"extra" ];
        [_rongCloudAdapter sendLocationMessage:type targetId:targetId imagePath:imagePath latitude:lat longitude:lng locationName:poi extra:extra result:result];
    }else if ([@"sendCommandNotificationMessage" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *name = call.arguments[@"name"];
        NSString *data = call.arguments[@"data"];
        [_rongCloudAdapter sendCommandNotificationMessage:type targetId:targetId name:name data:data result:result];
    }else if ([@"sendCommandMessage" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *name = call.arguments[@"name"];
        NSString *data = call.arguments[@"data"];
        [_rongCloudAdapter sendCommandMessage:type targetId:targetId name:name data:data result:result];
    }else if ([@"getConversationNotificationStatus" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        [_rongCloudAdapter getConversationNotificationStatus:type targetId:targetId result:result];
    }else if ([@"setConversationNotificationStatus" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSString *notificationStatus = call.arguments[@"notificationStatus"];
        [_rongCloudAdapter setConversationNotificationStatus:type targetId:targetId conversationnotificationStatus:notificationStatus result:result];
    }else if ([@"setDiscussionInviteStatus" isEqualToString:call.method]) {
        NSString *discussionId = call.arguments[@"discussionId"];
        NSString *status = call.arguments[@"inviteStatus"];
        [_rongCloudAdapter setDiscussionInviteStatus:discussionId withInviteStatus:status result:result];
    }else if ([@"syncGroup" isEqualToString:call.method]) {
        NSArray *groups = call.arguments[@"groups"];
        [_rongCloudAdapter syncGroup:groups result:result];
    }else if ([@"joinGroup" isEqualToString:call.method]) {
        NSString *groupId = call.arguments[@"groupId"];
        NSString *groupName = call.arguments[@"groupName"];
        [_rongCloudAdapter joinGroup:groupId withGroupName:groupName result:result];
    }else if ([@"quitGroup" isEqualToString:call.method]) {
        NSString *groupId = call.arguments[@"groupId"];
        [_rongCloudAdapter quitGroup:groupId result:result];
    }else if([@"setConnectionStatusListener" isEqualToString:call.method]) {
        [_rongCloudAdapter setConnectionStatusListener:result];
    }else if ([@"joinChatRoom" isEqualToString:call.method]) {
        NSString *chatRoomId = call.arguments[@"chatRoomId"];
        NSNumber *defMessageCount = call.arguments[@"defMessageCount"];
        [_rongCloudAdapter joinChatRoom:chatRoomId messageCount:defMessageCount result:result];
    }else if ([@"quitChatRoom" isEqualToString:call.method]) {
        NSString *chatRoomId = call.arguments[@"chatRoomId"];
        [_rongCloudAdapter quitChatRoom:chatRoomId result:result];
    }else if ([@"clearConversations" isEqualToString:call.method]) {
        NSArray *conversationTypes = call.arguments[@"conversationTypes"];
        [_rongCloudAdapter clearConversations:conversationTypes result:result];
    }else if ([@"getConnectionStatus" isEqualToString:call.method]) {
        [_rongCloudAdapter getConnectionStatus:result];
    }else if ([@"getRemoteHistoryMessages" isEqualToString:call.method]) {
        NSString *type = call.arguments[@"conversationType"];
        NSString *targetId = call.arguments[@"targetId"];
        NSNumber *dateTime = call.arguments[@"dateTime"];
        NSNumber *count = call.arguments[@"count"];
        [_rongCloudAdapter getRemoteHistoryMessages:type targetId:targetId recordTime:dateTime count:count result:result];
    }else if ([@"setMessageSentStatus" isEqualToString:call.method]) {
        NSString *state = call.arguments[@"sentStatus"];
        NSNumber *id = call.arguments[@"messageId"];
        [_rongCloudAdapter setMessageSentStatus:id sentStatus:state result:result];
    }else if ([@"getCurrentUserId" isEqualToString:call.method]) {
        [_rongCloudAdapter getCurrentUserId:result];
    }else if ([@"getDeltaTime" isEqualToString:call.method]) {
        [_rongCloudAdapter getDeltaTime:result];
    }else if ([@"addToBlacklist" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"userId"];
        [_rongCloudAdapter addToBlacklist:id result:result];
    }else if ([@"removeFromBlacklist" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"userId"];
        [_rongCloudAdapter removeFromBlacklist:id result:result];
    }else if ([@"getBlacklistStatus" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"userId"];
        [_rongCloudAdapter getBlacklistStatus:id result:result];
    }else if ([@"getBlacklist" isEqualToString:call.method]) {
        [_rongCloudAdapter getBlacklist:result];
    }else if ([@"setNotificationQuietHours" isEqualToString:call.method]) {
        NSString *startTime = call.arguments[@"startTime"];
        NSNumber *spanMinutes = call.arguments[@"spanMinutes"];
        [_rongCloudAdapter setNotificationQuietHours:startTime spanMins:spanMinutes result:result];
    }else if ([@"removeNotificationQuietHours" isEqualToString:call.method]) {
        [_rongCloudAdapter removeNotificationQuietHours:result];
    }else if ([@"getNotificationQuietHours" isEqualToString:call.method]) {
        [_rongCloudAdapter getNotificationQuietHours:result];
    }else if ([@"startCustomService" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"kefuId"];
        NSString *nickname = call.arguments[@"nickname"];
        [_rongCloudAdapter startCustomerService:id userName:nickname result:result];
    }else if ([@"switchToHumanMode" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"kefuId"];
        [_rongCloudAdapter switchToHumanMode:id result:result];
    }else if ([@"selectCustomServiceGroup" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"kefuId"];
        NSString *groupId = call.arguments[@"groupId"];
        [_rongCloudAdapter selectCustomerServiceGroup:id withGroupId:groupId result:result];
    }else if ([@"evaluateRobotCustomerService" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"kefuId"];
        NSString *knowledgeId = call.arguments[@"knowledgeId"];
        NSNumber *isRobotResolved = call.arguments[@"isRobotResolved"];
        [_rongCloudAdapter evaluateCustomerService:id knownledgeId:knowledgeId robotValue:isRobotResolved suggest:@"" result:result];
    }else if ([@"evaluateHumanCustomerService" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"kefuId"];
        NSNumber *source = call.arguments[@"source"];
        NSString *suggest = call.arguments[@"suggest"];
        NSString *dialogId = call.arguments[@"dialogId"];
        [_rongCloudAdapter evaluateCustomerService:id dialogId:dialogId humanValue:[source intValue] suggest:suggest result:result];
    }else if ([@"stopCustomService" isEqualToString:call.method]) {
        NSString *id = call.arguments[@"kefuId"];
        [_rongCloudAdapter stopCustomerService:id result:result];
    }else {
        result(FlutterMethodNotImplemented);
    }
}

@end
