package com.ninefrost.flutterrongcloudim;

import android.app.ActivityManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Handler;
import android.os.HandlerThread;
import android.text.TextUtils;
import android.util.Log;

//import com.google.gson.Gson;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.ninefrost.flutterrongcloudim.common.ErrorCode;
import com.ninefrost.flutterrongcloudim.common.RongCustomServiceResult;
import com.ninefrost.flutterrongcloudim.common.RongException;
import com.ninefrost.flutterrongcloudim.common.RongListenResult;
import com.ninefrost.flutterrongcloudim.common.RongResult;
import com.ninefrost.flutterrongcloudim.common.translation.ITranslatedMessage;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedCSGroupList;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedConversation;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedConversationNtfyStatus;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedCustomServiceDialogID;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedCustomServiceErrorMsg;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedCustomServiceMode;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedCustomServiceQuitMsg;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedDiscussion;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedMessage;
import com.ninefrost.flutterrongcloudim.common.translation.TranslatedQuietHour;

import io.flutter.plugin.common.MethodCall;
import io.rong.imlib.AnnotationNotFoundException;
import io.rong.imlib.CustomServiceConfig;
import io.rong.imlib.ICustomServiceListener;
import io.rong.imlib.IRongCallback.*;
import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.CSCustomServiceInfo;
import io.rong.imlib.model.CSGroupItem;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.CustomServiceMode;
import io.rong.imlib.model.Discussion;
import io.rong.imlib.model.Group;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.UserInfo;
import io.rong.message.CommandMessage;
import io.rong.message.CommandNotificationMessage;
import io.rong.message.GroupNotificationMessage;
import io.rong.message.ImageMessage;
import io.rong.message.LocationMessage;
import io.rong.message.RichContentMessage;
import io.rong.message.TextMessage;
import io.rong.message.VoiceMessage;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;


public class RongIMLib {
    private final String TAG = "RongIMClientModule";

    static RongIMClient mRongClient;
    static MethodChannel channel;
    static Context mContext;
    static UserInfo userInfo;
    //    Gson mGson;
    static Handler mHandler;
    static MessageListener mMessageListener;
    private HashMap<String, CustomServiceListener> customServiceCache = new HashMap<String, CustomServiceListener>();

    private TranslatedMessage translateMessage(Message message) {
        return new TranslatedMessage(message);
    }

    private boolean isInBackground() {
        ActivityManager activityManager = (ActivityManager) mContext.getSystemService(Context.ACTIVITY_SERVICE);
        String appPackageName = mContext.getPackageName();
        List<ActivityManager.RunningTaskInfo> runningTaskInfo = activityManager.getRunningTasks(1);
        String topAppPackageName = runningTaskInfo.get(0).topActivity.getPackageName();
        return !appPackageName.equals(topAppPackageName);
    }

    private void notifyIfNeed(Message message) {

        if (isInQuietTime(mContext)) {
            return;
        }

        RongIMClient.getInstance().getConversationNotificationStatus(message.getConversationType(), message.getTargetId(), new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
            @Override
            public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                if (Conversation.ConversationNotificationStatus.NOTIFY == conversationNotificationStatus) {
                    sendNotification();
                }
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {

            }
        });
    }

    private void sendNotification() {
        Notification notification;
        Intent intent = mContext.getPackageManager().getLaunchIntentForPackage(mContext.getPackageName());
        intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        PackageManager pm = mContext.getPackageManager();
        ApplicationInfo ai = mContext.getApplicationInfo();
        String title = (String) pm.getApplicationLabel(ai);
        String tickerText = mContext.getResources().getString(mContext.getResources().getIdentifier("rc_notification_ticker_text", "string", mContext.getPackageName()));
        PendingIntent pendingIntent = PendingIntent.getActivity(mContext, 0, intent, 0);
        if (android.os.Build.VERSION.SDK_INT < 11) {
            try {
                notification = new Notification(ai.icon, tickerText, System.currentTimeMillis());
                Method method;
                Class<?> classType = Notification.class;
                method = classType.getMethod("setLatestEventInfo", new Class[]{Context.class, CharSequence.class, CharSequence.class, PendingIntent.class});
                method.invoke(notification, new Object[]{mContext, title, tickerText, pendingIntent});
                notification.flags = Notification.FLAG_AUTO_CANCEL;
                notification.defaults = Notification.DEFAULT_SOUND;
            } catch (Exception e) {
                e.printStackTrace();
                return;
            }
        } else {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) ai.loadIcon(pm);
            Bitmap appIcon = bitmapDrawable.getBitmap();
            Notification.Builder builder = new Notification.Builder(mContext);
            builder.setLargeIcon(appIcon);
            builder.setSmallIcon(mContext.getApplicationInfo().icon);
            builder.setTicker(tickerText);
            builder.setContentTitle(title);
            builder.setContentText(tickerText);
            builder.setContentIntent(pendingIntent);
            builder.setAutoCancel(true);
            builder.setDefaults(Notification.DEFAULT_ALL);
            notification = builder.getNotification();
        }
        NotificationManager nm = (NotificationManager) mContext.getSystemService(mContext.NOTIFICATION_SERVICE);
        nm.notify(0, notification);
    }

    class MessageListener implements RongIMClient.OnReceiveMessageListener {

        MessageListener() {
        }

        @Override
        public boolean onReceived(Message message, int left) {
            Log.d(TAG, "onReceived " + message.getObjectName());

            if (isInBackground() && !notificationDisabled) {
                notifyIfNeed(message);
            }
            TranslatedMessage msg = translateMessage(message);
            sendMessage(ConstantFunc.ON_MESSAGE_RECEIVED, new ReceiveMessageModel(left, msg).toMap(), RongListenResult.SUCCESS);
            return false;
        }
    }

    public RongIMLib() {
//        mGson = new Gson();
        HandlerThread thread = new HandlerThread("RongWork");
        thread.start();
        mHandler = new Handler(thread.getLooper());
    }

    private boolean notificationDisabled = true;

    public void disableLocalNotification(Result result) {
        notificationDisabled = true;
        callMethodSuccess(result, "");
    }

    public void init(MethodCall call, Result result) {

        String key = call.argument("appKey");
        Log.d(TAG, key);
        if (TextUtils.isEmpty(key)) {
            callMethodError(result, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        RongIMClient.init(mContext, key);
        try {
            RongIMClient.registerMessageType(GroupNotificationMessage.class);
        } catch (AnnotationNotFoundException e) {
            e.printStackTrace();
        }
        callMethodSuccess(result, "");
    }

    public void connect(MethodCall call, final Result context) {

        String token = call.argument("token");
        Log.d(TAG, token);

        if (TextUtils.isEmpty(token)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

//        final RongResult result = new RongResult();
        try {
            mRongClient = RongIMClient.connect(token, new RongIMClient.ConnectCallback() {
                @Override
                public void onSuccess(String s) {
                    if (mMessageListener != null) {
                        mRongClient.setOnReceiveMessageListener(mMessageListener);
                    }
                    callMethodSuccess(context, new ConnectResult(s).toMap());
                }

                @Override
                public void onTokenIncorrect() {
                    Log.d(TAG, "token 错误" + RongIMClient.ErrorCode.RC_CONN_USER_OR_PASSWD_ERROR.getValue());
                    callMethodError(context, RongIMClient.ErrorCode.RC_CONN_USER_OR_PASSWD_ERROR.getValue());
                }

                @Override
                public void onError(RongIMClient.ErrorCode errorCode) {
                    Log.d(TAG, "错误 错误" + errorCode.getValue());
                    callMethodError(context, errorCode.getValue());
                }

            });
        } catch (Exception e) {
            e.printStackTrace();
            callMethodError(context, new RongException(e));
        }
    }

    public static class ConnectResult {
        String userId;

        public ConnectResult(String userId) {
            this.userId = userId;
        }

        public String getUserId() {
            return userId;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }

        public Map toMap() {
            Map map = new HashMap();
            map.put("userId", this.userId);
            return map;
        }
    }

    public class ConnectionStatusResult {
        AdaptConnectionStatus connectionStatus;

        public ConnectionStatusResult(int code) {
            connectionStatus = AdaptConnectionStatus.setValue(code);
        }

        public Map toMap() {
            Map map = new HashMap();
            map.put("connectionStatus", this.connectionStatus.code);
            return map;
        }
    }

    public void setUserInfo(MethodCall call, final Result context) {
        String id = call.argument("id");
        String name = call.argument("name");
        String avatar = call.argument("avatar");
        String level = call.argument("level");
        Uri uri = Uri.parse(avatar);
        userInfo = new UserInfo(id, name, uri);
        userInfo.setExtra(level);
        callMethodSuccess(context, "");
    }

    public void logout(final Result context) {
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.logout();
        callMethodSuccess(context, "");
    }

    public void disconnect(final Result context) {
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mRongClient.disconnect();
        callMethodSuccess(context, "");
    }

    public void getConversationList(final Result context) {
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                mRongClient.getConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
                    @Override
                    public void onSuccess(List<Conversation> conversations) {
                        ArrayList<Map> list = new ArrayList();
                        if (conversations == null || conversations.size() == 0) {
                            callMethodSuccess(context, list);
                            return;
                        }

                        for (Conversation conversation : conversations) {
                            TranslatedConversation tc = new TranslatedConversation(conversation);
                            list.add(tc.toMap());
                        }
                        callMethodSuccess(context, list);
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode e) {
                        callMethodError(context, new RongException(e.getValue()));
                    }
                });
            }
        });
    }

    public void setOnReceiveMessageListener(final Result context) {
        mMessageListener = new MessageListener();

        if (mRongClient != null) {
            mRongClient.setOnReceiveMessageListener(mMessageListener);
        }
        callMethodSuccess(context, "");
    }

    public static class ReceiveMessageModel {
        int left;
        ITranslatedMessage message;

        public ReceiveMessageModel(int left, ITranslatedMessage message) {
            this.left = left;
            this.message = message;
        }

        public ReceiveMessageModel(ITranslatedMessage message) {
            this.message = message;
        }

        public ITranslatedMessage getMessage() {
            return message;
        }

        public void setMessage(ITranslatedMessage message) {
            this.message = message;
        }

        public Map toMap() {
            Map map = new HashMap();
            map.put("left", left);
            map.put("message", ((TranslatedMessage) message).toMap());
            return map;
        }
    }

    public void getGroupConversationList(MethodCall call, final Result context) {
        final String type = call.argument("conversationType");

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

                mRongClient.getConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {
                    @Override
                    public void onSuccess(List<Conversation> conversations) {
                        if (conversations == null || conversations.size() == 0) {
                            callMethodSuccess(context, "");
                            return;
                        }

                        ArrayList<Map> list = new ArrayList();
                        for (Conversation conversation : conversations) {
                            TranslatedConversation tc = new TranslatedConversation(conversation);
                            list.add(tc.toMap());
                        }
                        callMethodSuccess(context, list);
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode e) {
                        callMethodError(context, new RongException(e.getValue()));
                    }
                }, conversationType);
            }
        });
    }

    public void getConversation(MethodCall call, final Result context) {
        final String type = call.argument("conversationType");
        final String targetId = call.argument("targetId");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

                mRongClient.getConversation(conversationType, targetId, new RongIMClient.ResultCallback<Conversation>() {
                    @Override
                    public void onSuccess(Conversation conversation) {
                        TranslatedConversation tc = null;
                        if (conversation == null) {
                            callMethodSuccess(context, "");
                        } else {
                            tc = new TranslatedConversation(conversation);
                            callMethodSuccess(context, tc.toMap());
                        }
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode e) {
                        callMethodError(context, new RongException(e.getValue()));
                    }
                });
            }
        });
    }

    public void removeConversation(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mRongClient.removeConversation(conversationType, targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void setConversationToTop(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");
        boolean isTop = call.argument("isTop");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mRongClient.setConversationToTop(conversationType, targetId, isTop, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void getTotalUnreadCount(final Result context) {
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.getTotalUnreadCount(new RongIMClient.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer integer) {
                callMethodSuccess(context, integer);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });

    }

    public void getUnreadCount(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");
        List list = call.argument("conversationTypes");
        JSONArray jsonArray = new JSONArray(list);

        if ((TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) && (jsonArray == null || jsonArray.length() == 0)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        if (!TextUtils.isEmpty(type) && !TextUtils.isEmpty(targetId)) {
            Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
            mRongClient.getUnreadCount(conversationType, targetId, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    callMethodSuccess(context, integer);
                }

                @Override
                public void onError(RongIMClient.ErrorCode e) {
                    callMethodError(context, new RongException(e.getValue()));
                }
            });
        } else {
            int i = 0;

            Conversation.ConversationType[] conversationTypes = new Conversation.ConversationType[jsonArray.length()];
            while (i < jsonArray.length()) {
                String item = jsonArray.optString(i);
                Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(item);
                conversationTypes[i] = conversationType;
                i++;
            }

            mRongClient.getUnreadCount(conversationTypes, new RongIMClient.ResultCallback<Integer>() {
                @Override
                public void onSuccess(Integer integer) {
                    callMethodSuccess(context, integer);
                }

                @Override
                public void onError(RongIMClient.ErrorCode e) {
                    callMethodError(context, new RongException(e.getValue()));
                }
            });
        }
    }

    public void getUnreadCountByConversationTypes(MethodCall call, final Result context) {
        getUnreadCount(call, context);
    }

    public void getLatestMessages(MethodCall call, final Result context) {
        final String type = call.argument("conversationType");
        final String targetId = call.argument("targetId");
        final int count = call.argument("count");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mHandler.post(new Runnable() {
            @Override
            public void run() {

                Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

                mRongClient.getLatestMessages(conversationType, targetId, count, new RongIMClient.ResultCallback<List<Message>>() {
                    @Override
                    public void onSuccess(List<Message> messages) {
                        ArrayList<Map> list = new ArrayList();

                        if (messages == null || messages.size() == 0) {
                            callMethodSuccess(context, list);
                            return;
                        }
                        for (Message message : messages) {
                            TranslatedMessage tm = new TranslatedMessage(message);
                            list.add(tm.toMap());
                        }
                        callMethodSuccess(context, list);
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode e) {
                        callMethodError(context, new RongException(e.getValue()));
                    }
                });
            }
        });
    }

    public void getHistoryMessages(MethodCall call, final Result context) {
        final String type = call.argument("conversationType");
        final String targetId = call.argument("targetId");
        final int oldestMessageId = call.argument("oldestMessageId");
        final int count = call.argument("count");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

                mRongClient.getHistoryMessages(conversationType, targetId, oldestMessageId, count, new RongIMClient.ResultCallback<List<Message>>() {
                    @Override
                    public void onSuccess(List<Message> messages) {
                        if (messages == null || messages.size() == 0) {
                            callMethodSuccess(context, "");
                            return;
                        }

                        ArrayList<Map> list = new ArrayList();
                        for (Message message : messages) {
                            TranslatedMessage tm = new TranslatedMessage(message);
                            list.add(tm.toMap());
                        }
                        callMethodSuccess(context, list);
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode e) {
                        callMethodError(context, new RongException(e.getValue()));
                    }
                });
            }
        });
    }

    public void getHistoryMessagesByObjectName(MethodCall call, final Result context) {
        final String type = call.argument("conversationType");
        final String targetId = call.argument("targetId");
        final int oldestMessageId = call.argument("oldestMessageId");
        final String objectName = call.argument("objectName");
        final int count = call.argument("count");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

                mRongClient.getHistoryMessages(conversationType, targetId, objectName, oldestMessageId, count, new RongIMClient.ResultCallback<List<Message>>() {
                    @Override
                    public void onSuccess(List<Message> messages) {
                        if (messages == null || messages.size() == 0) {
                            callMethodSuccess(context, "");
                            return;
                        }

                        ArrayList<Map> list = new ArrayList();
                        for (Message message : messages) {
                            TranslatedMessage tm = new TranslatedMessage(message);
                            list.add(tm.toMap());
                        }
                        callMethodSuccess(context, list);
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode e) {
                        callMethodError(context, new RongException(e.getValue()));
                    }
                });
            }
        });

    }

    public void deleteMessages(MethodCall call, final Result context) {
        List list = call.argument("messageIds");
        JSONArray jsonArray = new JSONArray(list);

        if (jsonArray == null || jsonArray.length() == 0) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        int[] ids = new int[jsonArray.length()];
        int i = 0;
        while (i < jsonArray.length()) {
            ids[i] = jsonArray.optInt(i);
            i++;
        }

        mRongClient.deleteMessages(ids, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void clearMessages(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.clearMessages(conversationType, targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void clearMessagesUnreadStatus(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.clearMessagesUnreadStatus(conversationType, targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void setMessageExtra(MethodCall call, final Result context) {
        int messageId = call.argument("messageId");
        String value = call.argument("value");

        if (messageId < 0 || TextUtils.isEmpty(value)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.setMessageExtra(messageId, value, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void setMessageReceivedStatus(MethodCall call, final Result context) {
        int messageId = call.argument("messageId");
        String status = call.argument("receivedStatus");

        if (messageId < 1 || status == null) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        int value;
        if (status.equals("UNREAD"))
            value = 0;
        else if (status.equals("READ"))
            value = 1;
        else if (status.equals("LISTENED"))
            value = 2;
        else if (status.equals("DOWNLOADED"))
            value = 4;
        else {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Message.ReceivedStatus receivedStatus = new Message.ReceivedStatus(value);
        mRongClient.setMessageReceivedStatus(messageId, receivedStatus, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }


    public void getTextMessageDraft(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.getTextMessageDraft(conversationType, targetId, new RongIMClient.ResultCallback<String>() {
            @Override
            public void onSuccess(String content) {
                if (content == null)
                    callMethodSuccess(context, "");
                else
                    callMethodSuccess(context, content);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void saveTextMessageDraft(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");
        String content = call.argument("content");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(content)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.saveTextMessageDraft(conversationType, targetId, content, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }


    public void clearTextMessageDraft(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mRongClient.clearTextMessageDraft(conversationType, targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void createDiscussion(MethodCall call, final Result context) {
        String name = call.argument("name");
        List<String> ids = call.argument("userIdList");
//        JSONArray jsonArray = new JSONArray(list);


        if (TextUtils.isEmpty(name) || ids == null || ids.size() == 0) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

//        List<String> ids = new ArrayList<String>(jsonArray.length());
//        int i = 0;
//        while (i < jsonArray.length()) {
//            ids.add(jsonArray.optString(i));
//            i++;
//        }

        mRongClient.createDiscussion(name, ids, new RongIMClient.CreateDiscussionCallback() {
            @Override
            public void onSuccess(String s) {
                callMethodSuccess(context, new DiscussionModel(s).toMap());
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, errorCode.getValue());
            }
        });
    }

    private class DiscussionModel {
        String discussionId;

        DiscussionModel(String discussionId) {
            this.discussionId = discussionId;
        }

        public Map toMap() {
            Map map = new HashMap();
            map.put("discussionId", discussionId);
            return map;
        }
    }

    public void getDiscussion(MethodCall call, final Result context) {
        String discussionId = call.argument("discussionId");

        if (TextUtils.isEmpty(discussionId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.getDiscussion(discussionId, new RongIMClient.ResultCallback<Discussion>() {
            @Override
            public void onSuccess(Discussion discussion) {
                TranslatedDiscussion td = null;
                if (discussion == null) {
                    callMethodSuccess(context, "");
                } else {
                    td = new TranslatedDiscussion(discussion);
                    callMethodSuccess(context, td.toMap());
                }
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void setDiscussionName(MethodCall call, final Result context) {
        String discussionId = call.argument("discussionId");
        String name = call.argument("name");

        if (TextUtils.isEmpty(discussionId) || TextUtils.isEmpty(name)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }


        mRongClient.setDiscussionName(discussionId, name, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void addMemberToDiscussion(MethodCall call, final Result context) {
        String discussionId = call.argument("discussionId");
        List<String> ids = call.argument("userIdList");

        if (TextUtils.isEmpty(discussionId) || ids == null || ids.size() == 0) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.addMemberToDiscussion(discussionId, ids, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void removeMemberFromDiscussion(MethodCall call, final Result context) {
        String discussionId = call.argument("discussionId");
        String userId = call.argument("userId");

        if (TextUtils.isEmpty(discussionId) || TextUtils.isEmpty(userId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mRongClient.removeMemberFromDiscussion(discussionId, userId, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void quitDiscussion(MethodCall call, final Result context) {
        String discussionId = call.argument("discussionId");

        if (TextUtils.isEmpty(discussionId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.quitDiscussion(discussionId, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void sendTextMessage(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");
        String content = call.argument("text");
        String extra = call.argument("extra");

        Log.d(TAG, type + ":" + targetId + ":" + content);
        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(content)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        TextMessage textMessage = TextMessage.obtain(content);
        textMessage.setUserInfo(userInfo);
        if (!TextUtils.isEmpty(extra))
            textMessage.setExtra(extra);

        mRongClient.sendMessage(conversationType, targetId, textMessage, null, null, (ISendMessageCallback) (new ISendMessageCallback() {
            public void onAttached(Message message) {
            }

            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                sendMessage(ConstantFunc.ON_MESSAGE_SEND_SUCCESS, translatedMessage.toMap(), RongListenResult.SUCCESS);
            }

            public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
                sendMessage(ConstantFunc.ON_MESSAGE_SEND_ERROR, errorCode.getValue(), RongListenResult.ERROR);
            }
        }));
    }

    public void sendImageMessage(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        final String targetId = call.argument("targetId");
        final String image = call.argument("imagePath");
        final String extra = call.argument("extra");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(image)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        File file = new File(image);
        final Uri imageUri = Uri.fromFile(file);
        if (!file.exists()) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        final Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);

        mHandler.post(new Runnable() {
            @Override
            public void run() {

                final ImageMessage imageMessage = ImageMessage.obtain(imageUri, imageUri);

                imageMessage.setUserInfo(userInfo);

                if (!TextUtils.isEmpty(extra))
                    imageMessage.setExtra(extra);

                mRongClient.sendImageMessage(conversationType, targetId, imageMessage, null, null, new RongIMClient.SendImageMessageCallback() {
                    @Override
                    public void onAttached(Message message) {

                    }

                    @Override
                    public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                        callMethodError(context, new RongException(errorCode.getValue()));
                        sendMessage(ConstantFunc.ON_MESSAGE_SEND_ERROR, errorCode.getValue(), RongListenResult.ERROR);
                    }

                    @Override
                    public void onSuccess(Message message) {
                        TranslatedMessage translatedMessage = new TranslatedMessage(message);
                        sendMessage(ConstantFunc.ON_MESSAGE_SEND_SUCCESS, new ProgressModel(translatedMessage).toMap(), RongListenResult.SUCCESS);
                    }

                    @Override
                    public void onProgress(Message message, int i) {
                        TranslatedMessage translatedMessage = new TranslatedMessage(message);
                        callMethodProgress(ConstantFunc.ON_SEND_IMAGE_MESSAGE_PROGRESS, new ProgressModel(translatedMessage, i).toMap());
                    }
                });
            }
        });
    }

    public static class ProgressModel {
        TranslatedMessage message;
        Integer progress;

        public ProgressModel(int msgId, int progress) {
            message = new TranslatedMessage();
            message.setMessageId(msgId);
            this.progress = progress;
        }

        public ProgressModel(int msgId) {
            message = new TranslatedMessage();
            message.setMessageId(msgId);
        }

        public ProgressModel(TranslatedMessage message) {
            this.message = message;
        }

        public ProgressModel(TranslatedMessage message, int progress) {
            this.message = message;
            this.progress = progress;
        }

        public TranslatedMessage getMessage() {
            return message;
        }

        public void setMessage(TranslatedMessage message) {
            this.message = message;
        }

        public int getProgress() {
            return progress;
        }

        public void setProgress(int progress) {
            this.progress = progress;
        }

        public Map toMap() {
            Map map = new HashMap();
            map.put("progress", this.progress);
            map.put("message", this.message.toMap());
            return map;
        }
    }

    public void sendVoiceMessage(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        final String targetId = call.argument("targetId");
        String voice = call.argument("voicePath");
        final int duration = call.argument("duration");
        final String extra = call.argument("extra");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || duration == 0 || TextUtils.isEmpty(voice)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        final Uri voiceUri = Uri.fromFile(new File(voice));
        File file = new File(voice);
        if (!"file".equals(voiceUri.getScheme()) || !file.exists()) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        final Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mHandler.post(new Runnable() {
            @Override
            public void run() {
                VoiceMessage voiceMessage = VoiceMessage.obtain(voiceUri, duration);
                voiceMessage.setUserInfo(userInfo);
                if (!TextUtils.isEmpty(extra))
                    voiceMessage.setExtra(extra);

                mRongClient.sendMessage(conversationType, targetId, voiceMessage, null, null, (ISendMessageCallback) (new ISendMessageCallback() {
                    public void onAttached(Message message) {
                    }

                    public void onSuccess(Message message) {
                        TranslatedMessage translatedMessage = new TranslatedMessage(message);
                        sendMessage(ConstantFunc.ON_MESSAGE_SEND_SUCCESS, translatedMessage.toMap(), RongListenResult.SUCCESS);
                    }

                    public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                        callMethodError(context, new RongException(errorCode.getValue()));
                        sendMessage(ConstantFunc.ON_MESSAGE_SEND_ERROR, errorCode.getValue(), RongListenResult.ERROR);
                    }
                }));

            }
        });

    }

    public void sendRichContentMessage(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");
        String title = call.argument("title");
        String content = call.argument("description");
        String imageUrl = call.argument("imageUrl");
        final String extra = call.argument("extra");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(title) || TextUtils.isEmpty(content)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        RichContentMessage richContentMessage = RichContentMessage.obtain(title, content, imageUrl);
        if (!TextUtils.isEmpty(extra))
            richContentMessage.setExtra(extra);
        richContentMessage.setUserInfo(userInfo);
        mRongClient.sendMessage(conversationType, targetId, richContentMessage, null, null, (ISendMessageCallback) (new ISendMessageCallback() {
            public void onAttached(Message message) {
            }

            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                sendMessage(ConstantFunc.ON_MESSAGE_SEND_SUCCESS, translatedMessage.toMap(), RongListenResult.SUCCESS);
            }

            public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
                sendMessage(ConstantFunc.ON_MESSAGE_SEND_ERROR, errorCode.getValue(), RongListenResult.ERROR);
            }
        }));
    }

    public void sendLocationMessage(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        final String targetId = call.argument("targetId");
        final double lat = call.argument("latitude");
        final double lng = call.argument("longitude");
        final String poi = call.argument("poi");
        final String imagePath = call.argument("imagePath");
        final String extra = call.argument("extra");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(imagePath)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        final Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        File file = new File(imagePath);
        final Uri imageUri = Uri.fromFile(file);
        if (!file.exists()) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mHandler.post(new Runnable() {
            @Override
            public void run() {
                LocationMessage locationMessage = LocationMessage.obtain(lat, lng, poi, imageUri);
                if (!TextUtils.isEmpty(extra))
                    locationMessage.setExtra(extra);
                mRongClient.sendMessage(conversationType, targetId, locationMessage, null, null, (ISendMessageCallback) (new ISendMessageCallback() {
                    public void onAttached(Message message) {
                    }

                    public void onSuccess(Message message) {
                        TranslatedMessage translatedMessage = new TranslatedMessage(message);
                        sendMessage(ConstantFunc.ON_MESSAGE_SEND_SUCCESS, translatedMessage.toMap(), RongListenResult.SUCCESS);
                    }

                    public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                        callMethodError(context, new RongException(errorCode.getValue()));
                        sendMessage(ConstantFunc.ON_MESSAGE_SEND_ERROR, errorCode.getValue(), RongListenResult.ERROR);
                    }
                }));
            }
        });
    }

    public void sendCommandNotificationMessage(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");
        String name = call.argument("name");
        String data = call.argument("data");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(name) || TextUtils.isEmpty(data)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.sendMessage(conversationType, targetId, CommandNotificationMessage.obtain(name, data), null, null, (ISendMessageCallback) (new ISendMessageCallback() {
            public void onAttached(Message message) {
            }

            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                sendMessage(ConstantFunc.ON_MESSAGE_SEND_SUCCESS, translatedMessage.toMap(), RongListenResult.SUCCESS);
            }

            public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
                sendMessage(ConstantFunc.ON_MESSAGE_SEND_ERROR, errorCode.getValue(), RongListenResult.ERROR);
            }
        }));
    }

    public void sendCommandMessage(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");
        String name = call.argument("name");
        String data = call.argument("data");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(name) || TextUtils.isEmpty(data)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.sendMessage(conversationType, targetId, CommandMessage.obtain(name, data), null, null, (ISendMessageCallback) (new ISendMessageCallback() {
            public void onAttached(Message message) {
            }

            public void onSuccess(Message message) {
                TranslatedMessage translatedMessage = new TranslatedMessage(message);
                sendMessage(ConstantFunc.ON_MESSAGE_SEND_SUCCESS, translatedMessage.toMap(), RongListenResult.SUCCESS);
            }

            public void onError(Message message, RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
                sendMessage(ConstantFunc.ON_MESSAGE_SEND_ERROR, errorCode.getValue(), RongListenResult.ERROR);
            }
        }));
    }

    public void getConversationNotificationStatus(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.getConversationNotificationStatus(conversationType, targetId, new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
            @Override
            public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                TranslatedConversationNtfyStatus state = new TranslatedConversationNtfyStatus(conversationNotificationStatus);
                callMethodSuccess(context, state.toMap());
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void setConversationNotificationStatus(MethodCall call, final Result context) {
        String type = call.argument("conversationType");
        String targetId = call.argument("targetId");
        String status = call.argument("notificationStatus");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(status)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        Conversation.ConversationNotificationStatus conversationNotificationStatus = Conversation.ConversationNotificationStatus.valueOf(status);

        mRongClient.setConversationNotificationStatus(conversationType, targetId, conversationNotificationStatus,
                new RongIMClient.ResultCallback<Conversation.ConversationNotificationStatus>() {
                    @Override
                    public void onSuccess(Conversation.ConversationNotificationStatus conversationNotificationStatus) {
                        TranslatedConversationNtfyStatus state = new TranslatedConversationNtfyStatus(conversationNotificationStatus);
                        callMethodSuccess(context, state.toMap());
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        callMethodError(context, errorCode.getValue());
                    }
                });
    }

    public void setDiscussionInviteStatus(MethodCall call, final Result context) {
        String targetId = call.argument("discussionId");
        String status = call.argument("inviteStatus");

        if (TextUtils.isEmpty(targetId) || TextUtils.isEmpty(targetId) || TextUtils.isEmpty(status)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        RongIMClient.DiscussionInviteStatus discussionInviteStatus = RongIMClient.DiscussionInviteStatus.valueOf(status);
        mRongClient.setDiscussionInviteStatus(targetId, discussionInviteStatus, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));

            }
        });
    }

    public void syncGroup(MethodCall call, final Result context) {
        List list = call.argument("groups");
        JSONArray array = new JSONArray(list);
        if (array == null || array.length() == 0) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        List<Group> groups = new ArrayList<Group>();
        for (int i = 0; i < array.length(); i++) {
            JSONObject object = array.optJSONObject(i);
            if (TextUtils.isEmpty(object.optString("groupId")) || TextUtils.isEmpty(object.optString("groupName"))) {
                callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
                return;
            }
            Group group = new Group(object.optString("groupId"),
                    object.optString("groupName"),
                    TextUtils.isEmpty(object.optString("portraitUrl")) ? null : Uri.parse(object.optString("portraitUrl")));
            groups.add(group);
        }
        mRongClient.syncGroup(groups, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void joinGroup(MethodCall call, final Result context) {
        String groupId = call.argument("groupId");
        String groupName = call.argument("groupName");

        if (TextUtils.isEmpty(groupId) || TextUtils.isEmpty(groupName)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        mRongClient.joinGroup(groupId, groupName, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void quitGroup(MethodCall call, final Result context) {
        String groupId = call.argument("groupId");

        if (TextUtils.isEmpty(groupId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.quitGroup(groupId, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void setConnectionStatusListener(final Result context) {
        RongIMClient.setConnectionStatusListener(new RongIMClient.ConnectionStatusListener() {
            @Override
            public void onChanged(ConnectionStatus connectionStatus) {
                sendMessage(ConstantFunc.ON_CONNECT_STATUS, new ConnectionStatusResult(connectionStatus.getValue()).toMap(), RongListenResult.SUCCESS);
            }
        });
        callMethodSuccess(context, "");
    }

    public void joinChatRoom(MethodCall call, final Result context) {
        String chatRoomId = call.argument("chatRoomId");
        int defMessageCount = call.argument("defMessageCount");

        if (TextUtils.isEmpty(chatRoomId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.joinChatRoom(chatRoomId, defMessageCount, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void quitChatRoom(MethodCall call, final Result context) {
        String chatRoomId = call.argument("chatRoomId");

        if (TextUtils.isEmpty(chatRoomId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.quitChatRoom(chatRoomId, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void clearConversations(MethodCall call, final Result context) {
        List list = call.argument("conversationTypes");
        JSONArray jsonArray = new JSONArray(list);

        if (jsonArray == null || jsonArray.length() == 0) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        int i = 0;
        Conversation.ConversationType[] conversationTypes = new Conversation.ConversationType[jsonArray.length()];
        while (i < jsonArray.length()) {
            String item = jsonArray.optString(i);
            Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(item);
            conversationTypes[i] = conversationType;
            i++;
        }

        mRongClient.clearConversations(new RongIMClient.ResultCallback() {
            @Override
            public void onSuccess(Object o) {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        }, conversationTypes);
    }

    public void getConnectionStatus(final Result context) {
        RongIMClient.ConnectionStatusListener.ConnectionStatus status;
        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        status = mRongClient.getCurrentConnectionStatus();
        int code = -1;
        if (status != null)
            code = status.getValue();
        callMethodSuccess(context, new ConnectionStatusResult(code).toMap());
    }

    public void getRemoteHistoryMessages(MethodCall call, final Result context) {
        final String type = call.argument("conversationType");
        final String targetId = call.argument("targetId");
        final long dateTime = call.argument("dateTime");
        final int count = call.argument("count");

        if (TextUtils.isEmpty(type) || TextUtils.isEmpty(targetId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        Conversation.ConversationType conversationType = Conversation.ConversationType.valueOf(type);
        mRongClient.getRemoteHistoryMessages(conversationType, targetId, dateTime, count, new RongIMClient.ResultCallback<List<Message>>() {
            @Override
            public void onSuccess(List<Message> messages) {
                if (messages == null || messages.size() == 0) {
                    callMethodSuccess(context, "");
                    return;
                }

                ArrayList<Map> list = new ArrayList();
                for (Message message : messages) {
                    TranslatedMessage tm = new TranslatedMessage(message);
                    list.add(tm.toMap());
                }
                callMethodSuccess(context, list);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void setMessageSentStatus(MethodCall call, final Result context) {
        final String state = call.argument("sentStatus");
        final int id = call.argument("messageId");
        if (state == null) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        Message.SentStatus status = Message.SentStatus.valueOf(state);
        if (id <= 0 || status == null) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        Message message = new Message();
        message.setSentStatus(status);
        message.setMessageId(id);
        mRongClient.setMessageSentStatus(new Message(), new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                callMethodSuccess(context, aBoolean);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void getCurrentUserId(final Result context) {
        String id = mRongClient.getCurrentUserId();
        callMethodSuccess(context, id);
    }

    public void getDeltaTime(final Result context) {
        long time = mRongClient.getDeltaTime();
        callMethodSuccess(context, time);
    }

    public void addToBlacklist(MethodCall call, final Result context) {
        String id = call.argument("userId");
        if (TextUtils.isEmpty(id)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.addToBlacklist(id, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void removeFromBlacklist(MethodCall call, final Result context) {
        String id = call.argument("userId");
        if (TextUtils.isEmpty(id)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }
        mRongClient.removeFromBlacklist(id, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void getBlacklistStatus(MethodCall call, final Result context) {
        String id = call.argument("userId");
        if (TextUtils.isEmpty(id)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.getBlacklistStatus(id, new RongIMClient.ResultCallback<RongIMClient.BlacklistStatus>() {
            @Override
            public void onSuccess(RongIMClient.BlacklistStatus blacklistStatus) {
                if (blacklistStatus == null)
                    callMethodSuccess(context, 1);
                else
                    callMethodSuccess(context, blacklistStatus.getValue());
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void getBlacklist(final Result context) {

        mRongClient.getBlacklist(new RongIMClient.GetBlacklistCallback() {
            @Override
            public void onSuccess(String[] strings) {
                if (strings == null || strings.length == 0) {
                    callMethodSuccess(context, new ArrayList<String>());
                    return;
                }
                List<String> list = new ArrayList(Arrays.asList(strings));
                callMethodSuccess(context, list);
            }

            @Override
            public void onError(RongIMClient.ErrorCode e) {
                callMethodError(context, new RongException(e.getValue()));
            }
        });
    }

    public void setNotificationQuietHours(MethodCall call, final Result context) {
        final String startTime = call.argument("startTime");
        final int spanMinutes = call.argument("spanMinutes");
        if (TextUtils.isEmpty(startTime)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        mRongClient.setNotificationQuietHours(startTime, spanMinutes, new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
                saveNotificationQuietHours(mContext, startTime, spanMinutes);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void removeNotificationQuietHours(final Result context) {
        mRongClient.removeNotificationQuietHours(new RongIMClient.OperationCallback() {
            @Override
            public void onSuccess() {
                callMethodSuccess(context, "");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    public void getNotificationQuietHours(final Result context) {
        mRongClient.getNotificationQuietHours(new RongIMClient.GetNotificationQuietHoursCallback() {
            @Override
            public void onSuccess(String startTime, int spanMinutes) {
                TranslatedQuietHour quiet = new TranslatedQuietHour(startTime, spanMinutes);
                callMethodSuccess(context, quiet.toMap());
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                callMethodError(context, new RongException(errorCode.getValue()));
            }
        });
    }

    private final void callMethodSuccess(Result context, Object model) {
        final RongResult result = new RongResult();
        result.setStatus(RongResult.Status.success);
        result.setResult(model);
        context.success(result.toMap());
    }

    private final void sendMessage(String method, Object model, String status) {
        final RongListenResult result = new RongListenResult();
        result.setResult(model);
        result.setStatus(status);
        channel.invokeMethod(method, result.toMap());
    }

    private final void callMethodError(Result context, RongException e) {
        context.error(RongResult.Status.error.toString(), "", e.toMap());
    }

    private final void callMethodError(Result context, Object model, int code) {
        final RongResult result = new RongResult();
        result.setStatus(RongResult.Status.error);
        result.setResult(model);
        RongException e = new RongException(code);
        context.error(RongResult.Status.error.toString(), code + "", result.toMap());
    }

    private final void callMethodError(Result context, int code) {
        final RongResult result = new RongResult();
        result.setStatus(RongResult.Status.error);
        context.error(RongResult.Status.error.toString(), code + "", result.toMap());
    }

    private void callMethodProgress(String method, Object model) {
        final RongResult result = new RongResult();
        result.setStatus(RongResult.Status.progress);
        result.setResult(model);
//        context.success(getJsonStringResult(result), true, false);
        channel.invokeMethod(method, result.toMap());
    }

    private void callMethodPrepare(Result context, Object model) {
        final RongResult result = new RongResult();
        result.setStatus(RongResult.Status.prepare);
        result.setResult(model);
        context.success(result.toMap());
    }

    private void callCustomServiceSuccess(String method) {
        final RongCustomServiceResult result = new RongCustomServiceResult();
        result.setStatus(1);
        channel.invokeMethod(method, result.toMap());
    }

    private void callCustomServiceError(String method, Object modle) {
        final RongCustomServiceResult result = new RongCustomServiceResult();
        result.setStatus(0);
        result.setResult(modle);
        channel.invokeMethod(method, result.toMap());
    }

    private void callCustomServiceModeChanged(String method, Object model) {
        final RongCustomServiceResult result = new RongCustomServiceResult();
        result.setStatus(2);
        result.setResult(model);
        channel.invokeMethod(method, result.toMap());
    }

    private void callCustomServiceQuit(String method, Object model) {
        final RongCustomServiceResult result = new RongCustomServiceResult();
        result.setStatus(3);
        result.setResult(model);
        channel.invokeMethod(method, result.toMap());
    }

    private void callCustomServicePullEvaluation(String method, Object model) {
        final RongCustomServiceResult result = new RongCustomServiceResult();
        result.setStatus(4);
        result.setResult(model);
        channel.invokeMethod(method, result.toMap());
    }

    private void callCustomServiceSelectGroup(String method, Object model) {
        final RongCustomServiceResult result = new RongCustomServiceResult();
        result.setStatus(5);
        result.setResult(model);
        channel.invokeMethod(method, result.toMap());
    }

//    private <T> Map<String, Object> getJsonObjectResult(T result) {
////        String json = mGson.toJson(result);
//        JSONObject object = null;
//        try {
//            object = new JSONObject(json);
//        } catch (JSONException ex) {
//            ex.printStackTrace();
//        }
//        return object;
//    }

//    private <T> String getJsonStringResult(T result) {
//        return mGson.toJson(result);
//    }

    private enum AdaptConnectionStatus {
        NETWORK_UNAVAILABLE(-1, "NETWORK_UNAVAILABLE"),
        CONNECTED(0, "CONNECTED"),
        CONNECTING(1, "CONNECTING"),
        DISCONNECTED(2, "DISCONNECTED"),
        KICKED(3, "KICKED"),
        TOKEN_INCORRECT(4, "TOKEN_INCORRECT"),
        SERVER_INVALID(5, "SERVER_INVALID");

        Integer code;
        String msg;

        AdaptConnectionStatus(int code, String msg) {
            this.code = code;
            this.msg = msg;
        }

        static AdaptConnectionStatus setValue(int code) {
            for (AdaptConnectionStatus c : AdaptConnectionStatus.values()) {
                if (code == c.code) {
                    return c;
                }
            }
            return NETWORK_UNAVAILABLE;
        }
    }

    /**
     * 本地化通知免打扰时间。
     *
     * @param startTime   默认  “-1”
     * @param spanMinutes 默认 -1
     */
    public static void saveNotificationQuietHours(Context mContext, String startTime, int spanMinutes) {

        SharedPreferences mPreferences = null;

        if (mContext != null)
            mPreferences = mContext.getSharedPreferences("RONG_SDK", Context.MODE_PRIVATE);

        if (mPreferences != null) {
            SharedPreferences.Editor editor = mPreferences.edit();
            editor.putString("QUIET_HOURS_START_TIME", startTime);
            editor.putInt("QUIET_HOURS_SPAN_MINUTES", spanMinutes);
            editor.commit();
        }
    }

    /**
     * 获取通知免打扰开始时间
     *
     * @return 时间
     */
    public static String getNotificationQuietHoursForStartTime(Context mContext) {
        SharedPreferences mPreferences = null;

        if (mPreferences == null && mContext != null)
            mPreferences = mContext.getSharedPreferences("RONG_SDK", Context.MODE_PRIVATE);

        if (mPreferences != null) {
            return mPreferences.getString("QUIET_HOURS_START_TIME", "");
        }

        return "";
    }

    /**
     * 获取通知免打扰时间间隔
     *
     * @return 时间
     */
    public static int getNotificationQuietHoursForSpanMinutes(Context mContext) {
        SharedPreferences mPreferences = null;

        if (mPreferences == null && mContext != null)
            mPreferences = mContext.getSharedPreferences("RONG_SDK", Context.MODE_PRIVATE);

        if (mPreferences != null) {
            return mPreferences.getInt("QUIET_HOURS_SPAN_MINUTES", 0);
        }

        return 0;
    }

    private boolean isInQuietTime(Context context) {

        String startTimeStr = getNotificationQuietHoursForStartTime(context);

        int hour = -1;
        int minute = -1;
        int second = -1;

        if (!TextUtils.isEmpty(startTimeStr) && startTimeStr.indexOf(":") != -1) {
            String[] time = startTimeStr.split(":");

            try {
                if (time.length >= 3) {
                    hour = Integer.parseInt(time[0]);
                    minute = Integer.parseInt(time[1]);
                    second = Integer.parseInt(time[2]);
                }
            } catch (NumberFormatException e) {
            }
        }

        if (hour == -1 || minute == -1 || second == -1) {
            return false;
        }

        Calendar startCalendar = Calendar.getInstance();
        startCalendar.set(Calendar.HOUR_OF_DAY, hour);
        startCalendar.set(Calendar.MINUTE, minute);
        startCalendar.set(Calendar.SECOND, second);


        long spanTime = getNotificationQuietHoursForSpanMinutes(context) * 60;
        long startTime = startCalendar.getTimeInMillis() / 1000;

        Calendar endCalendar = Calendar.getInstance();
        endCalendar.setTimeInMillis(startTime * 1000 + spanTime * 1000);

        Calendar currentCalendar = Calendar.getInstance();

        if (currentCalendar.after(startCalendar) && currentCalendar.before(endCalendar)) {
            return true;
        } else {
            return false;
        }
    }

    class CustomServiceListener implements ICustomServiceListener {

        CustomServiceListener() {
        }

        @Override
        public void onSuccess(CustomServiceConfig config) {
            //TranslatedCustomServiceConfig cfg = new TranslatedCustomServiceConfig(config);
            callCustomServiceSuccess(ConstantFunc.ON_CUSTOM_SERVICE_SUCCESS);
        }

        @Override
        public void onError(int code, String msg) {
            TranslatedCustomServiceErrorMsg customServiceErrorMsg = new TranslatedCustomServiceErrorMsg(code, msg);
            callCustomServiceError(ConstantFunc.ON_CUSTOM_SERVICE_ERROR, customServiceErrorMsg.toMap());
        }

        @Override
        public void onModeChanged(CustomServiceMode mode) {
            int csMode = mode.getValue();
            TranslatedCustomServiceMode customerServiceMode = new TranslatedCustomServiceMode(csMode);
            callCustomServiceModeChanged(ConstantFunc.ON_CUSTOM_SERVICE_MODE_CHANGED, customerServiceMode.toMap());
        }

        @Override
        public void onQuit(String msg) {
            TranslatedCustomServiceQuitMsg customServiceQuitMsg = new TranslatedCustomServiceQuitMsg(msg);
            callCustomServiceQuit(ConstantFunc.ON_CUSTOM_SERVICE_QUIT, customServiceQuitMsg.toMap());
        }

        @Override
        public void onPullEvaluation(String dialogId) {
            TranslatedCustomServiceDialogID customServiceDialogID = new TranslatedCustomServiceDialogID(dialogId);
            callCustomServicePullEvaluation(ConstantFunc.ON_CUSTOM_SERVICE_PULL_EVALUATION, customServiceDialogID.toMap());
        }

        @Override
        public void onSelectGroup(List<CSGroupItem> groups) {
            TranslatedCSGroupList csGroupList = new TranslatedCSGroupList(groups);
            callCustomServiceSelectGroup(ConstantFunc.ON_CUSTOM_SERVICE_SELECT_GROUP, csGroupList.toMap());
        }
    }

    public void startCustomService(MethodCall call, Result context) {

        String kefuId = call.argument("kefuId");
        if (TextUtils.isEmpty(kefuId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        String nickname = call.argument("nickname");

        CSCustomServiceInfo info = new CSCustomServiceInfo.Builder()
                .nickName(nickname).build();

        CustomServiceListener csListener = null;
        if (customServiceCache != null)
            csListener = customServiceCache.get(kefuId);
        if (csListener == null)
            csListener = new CustomServiceListener();

        mRongClient.startCustomService(kefuId, csListener, info);
        callMethodSuccess(context, "");
    }

    public void switchToHumanMode(MethodCall call, Result context) {

        String kefuId = call.argument("kefuId");
        if (TextUtils.isEmpty(kefuId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.switchToHumanMode(kefuId);
        callMethodSuccess(context, "");
    }

    public void selectCustomServiceGroup(MethodCall call, Result context) {

        String kefuId = call.argument("kefuId");
        if (TextUtils.isEmpty(kefuId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        String groupId = call.argument("groupId");
        mRongClient.selectCustomServiceGroup(kefuId, groupId);
        callMethodSuccess(context, "");
    }

    public void evaluateRobotCustomerService(MethodCall call, Result context) {

        String kefuId = call.argument("kefuId");
        if (TextUtils.isEmpty(kefuId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        Boolean isRobotResolved = call.argument("isRobotResolved");
        String knowledgeId = call.argument("knowledgeId");
        mRongClient.evaluateCustomService(kefuId, isRobotResolved, knowledgeId);
        callMethodSuccess(context, "");
    }

    public void evaluateHumanCustomerService(MethodCall call, Result context) {
        String kefuId = call.argument("kefuId");
        if (TextUtils.isEmpty(kefuId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }
        int source = call.argument("source");
        String suggest = call.argument("suggest");
        String dialogId = call.argument("dialogId");
        mRongClient.evaluateCustomService(kefuId, source, suggest, dialogId);
        callMethodSuccess(context, "");
    }

    public void stopCustomService(MethodCall call, Result context) {

        String kefuId = call.argument("kefuId");
        if (TextUtils.isEmpty(kefuId)) {
            callMethodError(context, new RongException(ErrorCode.ARGUMENT_EXCEPTION));
            return;
        }

        if (mRongClient == null) {
            callMethodError(context, new RongException(ErrorCode.NOT_CONNECTED));
            return;
        }

        mRongClient.stopCustomService(kefuId);
        CustomServiceListener customServiceListener = customServiceCache.get(kefuId);
        if (customServiceListener != null)
            customServiceCache.remove(kefuId);
        customServiceListener = null;
        callMethodSuccess(context, "");
    }


}

