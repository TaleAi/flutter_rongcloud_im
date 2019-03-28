package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.MessageContent;
import io.rong.message.CommandMessage;

/**
 * Created by  ailei 31/1/2019.
 */
public class TranslatedCommandMessage extends TranslatedMessageContent {
    String name;
    String data;

    public TranslatedCommandMessage(MessageContent content) {
        CommandMessage msg = (CommandMessage) content;
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
