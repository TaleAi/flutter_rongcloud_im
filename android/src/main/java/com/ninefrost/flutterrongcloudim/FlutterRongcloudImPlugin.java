package com.ninefrost.flutterrongcloudim;

import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterRongcloudImPlugin
 */
public class FlutterRongcloudImPlugin implements MethodCallHandler {

    private RongIMLib rongIMLib = new RongIMLib();

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_rongcloud_im");
        RongIMLib.channel = channel;
        RongIMLib.mContext = registrar.context();
        channel.setMethodCallHandler(new FlutterRongcloudImPlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals(ConstantFunc.DISABLE_LOCAL_NOTIFICATION)) {
            rongIMLib.disableLocalNotification(result);
        } else if (call.method.equals(ConstantFunc.INIT)) {
            rongIMLib.init(call, result);
        } else if (call.method.equals(ConstantFunc.SET_USER_INFO)) {
            rongIMLib.setUserInfo(call, result);
        } else if (call.method.equals(ConstantFunc.CONNECT)) {
            rongIMLib.connect(call, result);
        } else if (call.method.equals(ConstantFunc.LOGOUT)) {
            rongIMLib.logout(result);
        } else if (call.method.equals(ConstantFunc.DISCONNECT)) {
            rongIMLib.disconnect(result);
        } else if (call.method.equals(ConstantFunc.GET_CONVERSATION_LIST)) {
            rongIMLib.getConversationList(result);
        } else if (call.method.equals(ConstantFunc.SET_ON_RECEIVE_MESSAGE_LISTENER)) {
            rongIMLib.setOnReceiveMessageListener(result);
        } else if (call.method.equals(ConstantFunc.GET_GROUP_CONVERSATION_LIST)) {
            rongIMLib.getGroupConversationList(call, result);
        } else if (call.method.equals(ConstantFunc.GET_CONVERSATION)) {
            rongIMLib.getConversation(call, result);
        } else if (call.method.equals(ConstantFunc.REMOVE_CONVERSATION)) {
            rongIMLib.removeConversation(call, result);
        } else if (call.method.equals(ConstantFunc.SET_CONVERSATION_TO_TOP)) {
            rongIMLib.setConversationToTop(call, result);
        } else if (call.method.equals(ConstantFunc.GET_TOTAL_UNREAD_COUNT)) {
            rongIMLib.getTotalUnreadCount(result);
        } else if (call.method.equals(ConstantFunc.GET_UNREAD_COUNT)) {
            rongIMLib.getUnreadCount(call, result);
        } else if (call.method.equals(ConstantFunc.GET_UNREAD_COUNT_BY_CONVERSATION_TYPES)) {
            rongIMLib.getUnreadCountByConversationTypes(call, result);
        } else if (call.method.equals(ConstantFunc.GET_LATEST_MESSAGES)) {
            rongIMLib.getLatestMessages(call, result);
        } else if (call.method.equals(ConstantFunc.GET_HISTORY_MESSAGES)) {
            rongIMLib.getHistoryMessages(call, result);
        } else if (call.method.equals(ConstantFunc.GET_HISTORY_MESSAGE_SBY_OBJECT_NAME)) {
            rongIMLib.getHistoryMessagesByObjectName(call, result);
        } else if (call.method.equals(ConstantFunc.DELETE_MESSAGES)) {
            rongIMLib.deleteMessages(call, result);
        } else if (call.method.equals(ConstantFunc.CLEAR_MESSAGES)) {
            rongIMLib.clearMessages(call, result);
        } else if (call.method.equals(ConstantFunc.CLEAR_MESSAGES_UNREAD_STATUS)) {
            rongIMLib.clearMessagesUnreadStatus(call, result);
        } else if (call.method.equals(ConstantFunc.SET_MESSAGE_EXTRA)) {
            rongIMLib.setMessageExtra(call, result);
        } else if (call.method.equals(ConstantFunc.SET_MESSAGE_RECEIVED_STATUS)) {
            rongIMLib.setMessageReceivedStatus(call, result);
        } else if (call.method.equals(ConstantFunc.GET_TEXT_MESSAGE_DRAFT)) {
            rongIMLib.getTextMessageDraft(call, result);
        } else if (call.method.equals(ConstantFunc.SAVE_TEXT_MESSAGE_DRAFT)) {
            rongIMLib.saveTextMessageDraft(call, result);
        } else if (call.method.equals(ConstantFunc.CLEAR_TEXT_MESSAGE_DRAFT)) {
            rongIMLib.clearTextMessageDraft(call, result);
        } else if (call.method.equals(ConstantFunc.CREATE_DISCUSSION)) {
            rongIMLib.createDiscussion(call, result);
        } else if (call.method.equals(ConstantFunc.GET_DISCUSSION)) {
            rongIMLib.getDiscussion(call, result);
        } else if (call.method.equals(ConstantFunc.SET_DISCUSSION_NAME)) {
            rongIMLib.setDiscussionName(call, result);
        } else if (call.method.equals(ConstantFunc.ADD_MEMBER_TO_DISCUSSION)) {
            rongIMLib.addMemberToDiscussion(call, result);
        } else if (call.method.equals(ConstantFunc.REMOVE_MEMBER_FROM_DISCUSSION)) {
            rongIMLib.removeMemberFromDiscussion(call, result);
        } else if (call.method.equals(ConstantFunc.QUIT_DISCUSSION)) {
            rongIMLib.quitDiscussion(call, result);
        } else if (call.method.equals(ConstantFunc.SEND_TEXT_MESSAGE)) {
            rongIMLib.sendTextMessage(call, result);
        } else if (call.method.equals(ConstantFunc.SEND_IMAGE_MESSAGE)) {
            rongIMLib.sendImageMessage(call, result);
        } else if (call.method.equals(ConstantFunc.SEND_VOICE_MESSAGE)) {
            rongIMLib.sendVoiceMessage(call, result);
        } else if (call.method.equals(ConstantFunc.SEND_RICH_CONTENT_MESSAGE)) {
            rongIMLib.sendRichContentMessage(call, result);
        } else if (call.method.equals(ConstantFunc.SEND_LOCATION_MESSAGE)) {
            rongIMLib.sendLocationMessage(call, result);
        } else if (call.method.equals(ConstantFunc.SEND_COMMAND_NOTIFICATION_MESSAGE)) {
            rongIMLib.sendCommandNotificationMessage(call, result);
        } else if (call.method.equals(ConstantFunc.SEND_COMMAND_MESSAGE)) {
            rongIMLib.sendCommandMessage(call, result);
        } else if (call.method.equals(ConstantFunc.GET_CONVERSATION_NOTIFICATION_STATUS)) {
            rongIMLib.getConversationNotificationStatus(call, result);
        } else if (call.method.equals(ConstantFunc.SET_CONVERSATION_NOTIFICATION_STATUS)) {
            rongIMLib.setConversationNotificationStatus(call, result);
        } else if (call.method.equals(ConstantFunc.SET_DISCUSSION_INVITE_STATUS)) {
            rongIMLib.setDiscussionInviteStatus(call, result);
        } else if (call.method.equals(ConstantFunc.SYNC_GROUP)) {
            rongIMLib.syncGroup(call, result);
        } else if (call.method.equals(ConstantFunc.JOIN_GROUP)) {
            rongIMLib.joinGroup(call, result);
        } else if (call.method.equals(ConstantFunc.QUIT_GROUP)) {
            rongIMLib.quitGroup(call, result);
        } else if(call.method.equals(ConstantFunc.SET_CONNECTION_STATUS_LISTENER)) {
            rongIMLib.setConnectionStatusListener(result);
        } else if (call.method.equals(ConstantFunc.JOIN_CHAT_ROOM)) {
            rongIMLib.joinChatRoom(call, result);
        } else if (call.method.equals(ConstantFunc.QUIT_CHAT_ROOM)) {
            rongIMLib.quitChatRoom(call, result);
        } else if (call.method.equals(ConstantFunc.CLEAR_CONVERSATIONS)) {
            rongIMLib.clearConversations(call, result);
        } else if (call.method.equals(ConstantFunc.GET_CONNECTION_STATUS)) {
            rongIMLib.getConnectionStatus(result);
        } else if (call.method.equals(ConstantFunc.GET_REMOTE_HISTORY_MESSAGES)) {
            rongIMLib.getRemoteHistoryMessages(call, result);
        } else if (call.method.equals(ConstantFunc.SET_MESSAGE_SENT_STATUS)) {
            rongIMLib.setMessageSentStatus(call, result);
        } else if (call.method.equals(ConstantFunc.GET_CURRENT_USERID)) {
            rongIMLib.getCurrentUserId(result);
        } else if (call.method.equals(ConstantFunc.GET_DELTA_TIME)) {
            rongIMLib.getDeltaTime(result);
        } else if (call.method.equals(ConstantFunc.ADD_TO_BLACKLIST)) {
            rongIMLib.addToBlacklist(call, result);
        } else if (call.method.equals(ConstantFunc.REMOVE_FROM_BLACK_LIST)) {
            rongIMLib.removeFromBlacklist(call, result);
        } else if (call.method.equals(ConstantFunc.GET_BLACK_LIST_STATUS)) {
            rongIMLib.getBlacklistStatus(call, result);
        } else if (call.method.equals(ConstantFunc.GET_BLACK_LIST)) {
            rongIMLib.getBlacklist(result);
        } else if (call.method.equals(ConstantFunc.SET_NOTIFICATION_QUIET_HOURS)) {
            rongIMLib.setNotificationQuietHours(call, result);
        } else if (call.method.equals(ConstantFunc.REMOVE_NOTIFICATION_QUIET_HOURS)) {
            rongIMLib.removeNotificationQuietHours(result);
        } else if (call.method.equals(ConstantFunc.GET_NOTIFICATION_QUIET_HOURS)) {
            rongIMLib.getNotificationQuietHours(result);
        } else if (call.method.equals(ConstantFunc.START_CUSTOM_SERVICE)) {
            rongIMLib.startCustomService(call, result);
        } else if (call.method.equals(ConstantFunc.SWITCH_TO_HUMANMODE)) {
            rongIMLib.switchToHumanMode(call, result);
        } else if (call.method.equals(ConstantFunc.SELECT_CUSTOM_SERVICE_GROUP)) {
            rongIMLib.selectCustomServiceGroup(call, result);
        } else if (call.method.equals(ConstantFunc.EVALUATE_ROBOT_CUSTOMER_SERVICE)) {
            rongIMLib.evaluateRobotCustomerService(call, result);
        } else if (call.method.equals(ConstantFunc.EVALUATE_HUMAN_CUSTOMER_SERVICE)) {
            rongIMLib.evaluateHumanCustomerService(call, result);
        } else if (call.method.equals(ConstantFunc.STOP_CUSTOM_SERVICE)) {
            rongIMLib.stopCustomService(call, result);
        } else {
            result.notImplemented();
        }
    }
}
