package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;
import io.rong.message.TextMessage;

/**
 * Created by  ailei 31/1/2019.
 */
public class TranslatedTextMessage extends TranslatedMessageContent {
    String text;
    String extra;
    UserInfo userInfo;

    public TranslatedTextMessage(MessageContent content) {
        TextMessage textMessage = (TextMessage) content;
        this.text = textMessage.getContent() == null ? "" : textMessage.getContent();
        this.extra = textMessage.getExtra() == null ? "" : textMessage.getExtra();
        this.userInfo = textMessage.getUserInfo() == null ? null : textMessage.getUserInfo();
    }

    Map getUserInfo() {
        Map map = new HashMap();
        if (this.userInfo != null) {
            map.put("id", this.userInfo.getUserId());
            map.put("name", this.userInfo.getName());
            map.put("avatar", this.userInfo.getPortraitUri().toString());
            map.put("extra", this.userInfo.getExtra());
        }
        return map;
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("text", this.text);
        map.put("extra", this.extra);
        map.put("user", this.getUserInfo());
        return map;
    }
}
