package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.Conversation;

/**
 * Created by weiqinxiao on 15/9/16.
 */
public class TranslatedConversationNtfyStatus {
    int code;
    String notificationStatus;

    public TranslatedConversationNtfyStatus(Conversation.ConversationNotificationStatus status) {
        this.code = status.getValue();
        this.notificationStatus = (status == null ? "" : status.toString());
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("code", this.code);
        map.put("notificationStatus", this.notificationStatus);
        return map;
    }
}
