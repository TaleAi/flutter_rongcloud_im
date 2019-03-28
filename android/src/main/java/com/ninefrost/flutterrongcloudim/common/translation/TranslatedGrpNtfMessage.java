package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.MessageContent;
import io.rong.message.GroupNotificationMessage;

/**
 * Created by weiqinxiao on 16/1/4.
 */
public class TranslatedGrpNtfMessage extends TranslatedMessageContent {
    private String operatorUserId;
    private String operation;
    private String data;
    private String message;
    private String extra;

    public TranslatedGrpNtfMessage(MessageContent content) {
        GroupNotificationMessage msg = (GroupNotificationMessage)content;
        operation = msg.getOperation() == null ? "" : msg.getOperation();
        operatorUserId = msg.getOperatorUserId() == null ? "" : msg.getOperatorUserId();
        data = msg.getData() == null ? "" : msg.getData();
        message = msg.getMessage() == null ? "" : msg.getMessage();
        extra = msg.getExtra() == null ? "" : msg.getExtra();
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("operatorUserId", this.operatorUserId);
        map.put("operation", this.operation);
        map.put("data", this.data);
        map.put("message", this.message);
        map.put("extra", this.extra);
        return map;
    }
}
