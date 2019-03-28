package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.MessageContent;
import io.rong.message.CommandNotificationMessage;

/**
 * Created by  ailei 31/1/2019.
 */
public class TranslatedCommandNotificationMessage extends TranslatedMessageContent {
    String name;
    String data;

    public TranslatedCommandNotificationMessage(MessageContent content) {
        CommandNotificationMessage msg = (CommandNotificationMessage) content;
        this.name = msg.getName() == null ? "" : msg.getName();
        this.data = msg.getData() == null ? "" : msg.getData();
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("name", this.name);
        map.put("data", this.data);
        return map;
    }
}
