import 'dart:async';

import 'package:flutter/services.dart';

class FlutterRongcloudIm {
  static final MethodChannel _channel =
  const MethodChannel('flutter_rongcloud_im')
    ..setMethodCallHandler(_handler);

  /*链接状态*/
  static StreamController<Map> _responseFromConnectStatusController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromConnectStatus =>
      _responseFromConnectStatusController.stream;

  //消息发送成功
  static StreamController<Map> _responseFromMessageSendSuccessController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromMessageSendSuccess =>
      _responseFromMessageSendSuccessController.stream;

  // 消息发送错误
  static StreamController<Map> _responseFromMessageSendErrorController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromMessageSendError =>
      _responseFromMessageSendErrorController.stream;

  // 消息被接受
  static StreamController<Map> _responseFromMessageReceivedController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromMessageReceived =>
      _responseFromMessageReceivedController.stream;

  // 发送图片消息的进度
  static StreamController<Map> _responseFromSendImageMessageProgressController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromSendImageMessageProgress =>
      _responseFromSendImageMessageProgressController.stream;

  // 启动客服成功
  static StreamController<Map> _responseFromCustomServiceSuccessController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromCustomServiceSuccess =>
      _responseFromCustomServiceSuccessController.stream;

  // 启动客服失败
  static StreamController<Map> _responseFromCustomServiceErrorController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromCustomServiceError =>
      _responseFromCustomServiceErrorController.stream;

  // 客服类型变化
  static StreamController<Map> _responseFromCustomServiceModeChangedController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromCustomServiceModeChanged =>
      _responseFromCustomServiceModeChangedController.stream;

  //退出客服
  static StreamController<Map> _responseFromCustomServiceQuitController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromCustomServiceQuit =>
      _responseFromCustomServiceQuitController.stream;

  // 获取评价
  static StreamController<Map>
  _responseFromCustomServicePullEvaluationController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromCustomServicePullEvaluation =>
      _responseFromCustomServicePullEvaluationController.stream;

  // 选择分组
  static StreamController<Map> _responseFromCustomServiceSelectGroupController =
  new StreamController.broadcast();

  static Stream<Map> get responseFromCustomServiceSelectGroup =>
      _responseFromCustomServiceSelectGroupController.stream;

  static Future<dynamic> _handler(MethodCall call) {
    if ('onConnectStatus' == call.method) {
      _responseFromConnectStatusController.add(call.arguments);
    } else if ('onMessageSendSuccess' == call.method) {
      _responseFromMessageSendSuccessController.add(call.arguments);
    } else if ('onMessageSendError' == call.method) {
      _responseFromMessageSendErrorController.add(call.arguments);
    } else if ('onMessageReceived' == call.method) {
      _responseFromMessageReceivedController.add(call.arguments);
    } else if ('onSendImageMessageProgress' == call.method) {
      _responseFromSendImageMessageProgressController.add(call.arguments);
    } else if ('onCustomServiceSuccess' == call.method) {
      _responseFromCustomServiceSuccessController.add(call.arguments);
    } else if ('onCustomServiceError' == call.method) {
      _responseFromCustomServiceErrorController.add(call.arguments);
    } else if ('onCustomServiceModeChanged' == call.method) {
      _responseFromCustomServiceModeChangedController.add(call.arguments);
    } else if ('onCustomServiceQuit' == call.method) {
      _responseFromCustomServiceQuitController.add(call.arguments);
    } else if ('onCustomServicePullEvaluation' == call.method) {
      _responseFromCustomServicePullEvaluationController.add(call.arguments);
    } else if ('onCustomServiceSelectGroup' == call.method) {
      _responseFromCustomServiceSelectGroupController.add(call.arguments);
    }
    return Future.value(true);
  }

  static Future init(String appKey) async {
    return await _channel.invokeMethod('init', {'appKey': appKey});
  }

  static Future disableLocalNotification() async {
    return await _channel.invokeMethod('disableLocalNotification');
  }

  static Future connect(String token) async {
    return await _channel.invokeMethod('connect', {'token': token});
  }

  static Future logout() async {
    return await _channel.invokeMethod('logout', {});
  }

  static Future disconnect() async {
    return await _channel.invokeMethod('disconnect', {});
  }

  static Future getConversationList(String conversationType) async {
    return await _channel.invokeMethod(
        'getConversationList', {'conversationType': conversationType});
  }

  static Future setOnReceiveMessageListener() async {
    return await _channel.invokeMethod('setOnReceiveMessageListener', {});
  }

  static Future getGroupConversationList() async {
    return await _channel.invokeMethod(
        'getGroupConversationList');
  }

  static Future getConversation(String conversationType,
      String targetId) async {
    return await _channel.invokeMethod('getConversation',
        {'conversationType': conversationType, 'targetId': targetId});
  }

  static Future removeConversation(String conversationType,
      String targetId) async {
    return await _channel.invokeMethod('removeConversation',
        {'conversationType': conversationType, 'targetId': targetId});
  }

  static Future setConversationToTop(String conversationType, String targetId,
      bool isTop) async {
    return await _channel.invokeMethod('setConversationToTop', {
      'conversationType': conversationType,
      'targetId': targetId,
      'isTop': isTop
    });
  }

  static Future getTotalUnreadCount() async {
    return await _channel.invokeMethod('getTotalUnreadCount', {});
  }

  static Future<int> getUnreadCount(String conversationType,
      String targetId) async {
    return await _channel.invokeMethod('getUnreadCount',
        {'conversationType': conversationType, 'targetId': targetId});
  }

  static Future getUnreadCountByConversationTypes(
      List<String> conversationTypes) async {
    return await _channel.invokeMethod('getUnreadCountByConversationTypes',
        {'conversationTypes': conversationTypes});
  }

  static Future getLatestMessages(String conversationType, String targetId,
      int count) async {
    return await _channel.invokeMethod('getLatestMessages', {
      'conversationType': conversationType,
      'targetId': targetId,
      'count': count
    });
  }

  static Future getHistoryMessages(String conversationType, String targetId,
      int count, int oldestMessageId) async {
    return await _channel.invokeMethod('getHistoryMessages', {
      'conversationType': conversationType,
      'targetId': targetId,
      'count': count,
      'oldestMessageId': oldestMessageId
    });
  }

  static Future getHistoryMessagesByObjectName(String conversationType,
      String targetId,
      int count,
      int oldestMessageId,
      String objectName) async {
    return await _channel.invokeMethod('getHistoryMessagesByObjectName', {
      'conversationType': conversationType,
      'targetId': targetId,
      'count': count,
      'oldestMessageId': oldestMessageId,
      'objectName': objectName
    });
  }

  static Future deleteMessages(List<int> messageIds) async {
    return await _channel
        .invokeMethod('deleteMessages', {'messageIds': messageIds});
  }

  static Future clearMessages(String conversationType, String targetId) async {
    return await _channel.invokeMethod('clearMessages',
        {'conversationType': conversationType, 'targetId': targetId});
  }

  static Future clearMessagesUnreadStatus(String conversationType,
      String targetId) async {
    return await _channel.invokeMethod('clearMessagesUnreadStatus',
        {'conversationType': conversationType, 'targetId': targetId});
  }

  static Future setMessageExtra(int messageId, String value) async {
    return await _channel.invokeMethod(
        'setMessageExtra', {'messageId': messageId, 'value': value});
  }

  static Future setMessageReceivedStatus(int messageId,
      String receivedStatus) async {
    return await _channel.invokeMethod('setMessageReceivedStatus',
        {'messageId': messageId, 'receivedStatus': receivedStatus});
  }

  static Future getTextMessageDraft(String conversationType,
      String targetId) async {
    return await _channel.invokeMethod('getTextMessageDraft',
        {'conversationType': conversationType, 'targetId': targetId});
  }

  static Future saveTextMessageDraft(String conversationType, String targetId,
      String content) async {
    return await _channel.invokeMethod('saveTextMessageDraft', {
      'conversationType': conversationType,
      'targetId': targetId,
      'content': content
    });
  }

  static Future clearTextMessageDraft(String conversationType,
      String targetId) async {
    return await _channel.invokeMethod('clearTextMessageDraft',
        {'conversationType': conversationType, 'targetId': targetId});
  }

  static Future createDiscussion(List<String> userIdList, String name) async {
    return await _channel.invokeMethod(
        'createDiscussion', {'userIdList': userIdList, 'name': name});
  }

  static Future getDiscussion(String discussionId) async {
    return await _channel
        .invokeMethod('getDiscussion', {'discussionId': discussionId});
  }

  static Future setDiscussionName(String discussionId, String name) async {
    return await _channel.invokeMethod(
        'setDiscussionName', {'discussionId': discussionId, 'name': name});
  }

  static Future addMemberToDiscussion(String discussionId,
      List<String> userIdList) async {
    return await _channel.invokeMethod('addMemberToDiscussion',
        {'discussionId': discussionId, 'userIdList': userIdList});
  }

  static Future removeMemberFromDiscussion(String discussionId,
      String userId) async {
    return await _channel.invokeMethod('removeMemberFromDiscussion',
        {'discussionId': discussionId, 'userId': userId});
  }

  static Future quitDiscussion(String discussionId) async {
    return await _channel
        .invokeMethod('quitDiscussion', {'discussionId': discussionId});
  }

  static Future sendTextMessage(String conversationType, String targetId,
      String content, String extra) async {
    return await _channel.invokeMethod('sendTextMessage', {
      'conversationType': conversationType,
      'targetId': targetId,
      'text': content,
      'extra': extra
    });
  }

  static Future sendImageMessage(String conversationType, String targetId,
      String imagePath, String extra) async {
    return await _channel.invokeMethod('sendImageMessage', {
      'conversationType': conversationType,
      'targetId': targetId,
      'imagePath': imagePath,
      'extra': extra
    });
  }

  static Future sendVoiceMessage(String conversationType, String targetId,
      String voicePath, int duration, String extra) async {
    return await _channel.invokeMethod('sendVoiceMessage', {
      'conversationType': conversationType,
      'targetId': targetId,
      'voicePath': voicePath,
      'duration': duration,
      'extra': extra
    });
  }

  static Future sendRichContentMessage(String conversationType, String targetId,
      String title, String description, String imageUrl, String extra) async {
    return await _channel.invokeMethod('sendRichContentMessage', {
      'conversationType': conversationType,
      'targetId': targetId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'extra': extra
    });
  }

  static Future sendLocationMessage(String conversationType,
      String targetId,
      double latitude,
      double longitude,
      String poi,
      String imagePath,
      String extra) async {
    return await _channel.invokeMethod('sendLocationMessage', {
      'conversationType': conversationType,
      'targetId': targetId,
      'latitude': latitude,
      'longitude': longitude,
      'poi': poi,
      'imagePath': imagePath,
      'extra': extra
    });
  }

  static Future sendCommandNotificationMessage(String conversationType,
      String targetId, String name, String data) async {
    return await _channel.invokeMethod('sendCommandNotificationMessage', {
      'conversationType': conversationType,
      'targetId': targetId,
      'name': name,
      'data': data
    });
  }

  static Future sendCommandMessage(String conversationType, String targetId,
      String name, String data) async {
    return await _channel.invokeMethod('sendCommandMessage', {
      'conversationType': conversationType,
      'targetId': targetId,
      'name': name,
      'data': data
    });
  }

  static Future getConversationNotificationStatus(String conversationType,
      String targetId) async {
    return await _channel.invokeMethod('getConversationNotificationStatus',
        {'conversationType': conversationType, 'targetId': targetId});
  }

  static Future setConversationNotificationStatus(String conversationType,
      String targetId, String notificationStatus) async {
    return await _channel.invokeMethod('setConversationNotificationStatus', {
      'conversationType': conversationType,
      'targetId': targetId,
      'notificationStatus': notificationStatus
    });
  }

  static Future setDiscussionInviteStatus(String discussionId,
      String inviteStatus) async {
    return await _channel.invokeMethod('setDiscussionInviteStatus',
        {'discussionId': discussionId, 'inviteStatus': inviteStatus});
  }

//  static Future syncGroup() async {
//    return await _channel.invokeMethod('syncGroup', {});
//  }
//
//  static Future joinGroup() async {
//    return await _channel.invokeMethod('joinGroup', {});
//  }
//
//  static Future quitGroup() async {
//    return await _channel.invokeMethod('quitGroup', {});
//  }

  static Future setConnectionStatusListener() async {
    return await _channel.invokeMethod('setConnectionStatusListener', {});
  }

  static Future joinChatRoom(String chatRoomId, int defMessageCount) async {
    return await _channel.invokeMethod('joinChatRoom',
        {'defMessageCount': defMessageCount, 'chatRoomId': chatRoomId});
  }

  static Future setUserInfo(String id, String name, String avatar,
      String level) async {
    return await _channel.invokeMethod('setUserInfo',
        {'id': id, 'name': name, 'avatar': avatar, 'level': level});
  }

  static Future quitChatRoom(String chatRoomId) async {
    return await _channel
        .invokeMethod('quitChatRoom', {'chatRoomId': chatRoomId});
  }

  static Future clearConversations(List<String> conversationTypes) async {
    return await _channel.invokeMethod(
        'clearConversations', {'conversationTypes': conversationTypes});
  }

  static Future getConnectionStatus() async {
    return await _channel.invokeMethod('getConnectionStatus', {});
  }

  static Future getRemoteHistoryMessages(String conversationType,
      String targetId, int dateTime, int count) async {
    return await _channel.invokeMethod('getRemoteHistoryMessages', {
      'conversationType': conversationType,
      'targetId': targetId,
      'dateTime': dateTime,
      'count': count
    });
  }

  static Future setMessageSentStatus(String sentStatus, int messageId) async {
    return await _channel.invokeMethod('setMessageSentStatus',
        {'messageId': messageId, 'sentStatus': sentStatus});
  }

  static Future getCurrentUserId() async {
    return await _channel.invokeMethod('getCurrentUserId', {});
  }

  static Future getDeltaTime() async {
    return await _channel.invokeMethod('getDeltaTime', {});
  }

  static Future addToBlacklist(String userId) async {
    return await _channel.invokeMethod('addToBlacklist', {'userId': userId});
  }

  static Future removeFromBlacklist(String userId) async {
    return await _channel
        .invokeMethod('removeFromBlacklist', {'userId': userId});
  }

  static Future getBlacklistStatus(String userId) async {
    return await _channel
        .invokeMethod('getBlacklistStatus', {'userId': userId});
  }

  static Future getBlacklist() async {
    return await _channel.invokeMethod('getBlacklist', {});
  }

  static Future setNotificationQuietHours(String startTime,
      int spanMinutes) async {
    return await _channel.invokeMethod('setNotificationQuietHours',
        {'spanMinutes': spanMinutes, 'startTime': startTime});
  }

  static Future removeNotificationQuietHours() async {
    return await _channel.invokeMethod('removeNotificationQuietHours', {});
  }

  static Future getNotificationQuietHours() async {
    return await _channel.invokeMethod('getNotificationQuietHours', {});
  }

  static Future startCustomService(String kefuId) async {
    return await _channel
        .invokeMethod('startCustomService', {'kefuId': kefuId});
  }

  static Future switchToHumanMode(String kefuId) async {
    return await _channel.invokeMethod('switchToHumanMode', {'kefuId': kefuId});
  }

  static Future selectCustomServiceGroup(String kefuId, String groupId) async {
    return await _channel.invokeMethod(
        'selectCustomServiceGroup', {'kefuId': kefuId, 'groupId': groupId});
  }

  static Future evaluateRobotCustomerService(String kefuId,
      bool isRobotResolved, String knowledgeId) async {
    return await _channel.invokeMethod('evaluateRobotCustomerService', {
      'kefuId': kefuId,
      'isRobotResolved': isRobotResolved,
      'knowledgeId': knowledgeId
    });
  }

  static Future evaluateHumanCustomerService(String kefuId, int source,
      String suggest, String dialogId) async {
    return await _channel.invokeMethod('evaluateHumanCustomerService', {});
  }

  static Future stopCustomService(String kefuId) async {
    return await _channel.invokeMethod('stopCustomService', {'kefuId': kefuId});
  }
}
