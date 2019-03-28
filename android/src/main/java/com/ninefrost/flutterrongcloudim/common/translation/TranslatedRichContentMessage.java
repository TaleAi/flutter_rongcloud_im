package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.MessageContent;
import io.rong.message.RichContentMessage;

/**
 * Created by  ailei 31/1/2019.
 */
public class TranslatedRichContentMessage extends TranslatedMessageContent {
    String title;
    String description;
    String imageUrl;
    String url;
    String extra;

    public TranslatedRichContentMessage(MessageContent content) {
        RichContentMessage richContentMessage = (RichContentMessage)content;
        this.extra = richContentMessage.getExtra() == null ? "" : richContentMessage.getExtra();
        this.title = richContentMessage.getTitle() == null ? "" : richContentMessage.getTitle();
        this.description = richContentMessage.getContent() == null ? "" : richContentMessage.getContent();
        this.imageUrl = richContentMessage.getImgUrl() == null ? "" : richContentMessage.getImgUrl();
        this.url = richContentMessage.getUrl() == null ? "" : richContentMessage.getUrl();
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("title", this.title);
        map.put("description", this.description);
        map.put("imageUrl", this.imageUrl);
        map.put("url", this.url);
        map.put("extra", this.extra);
        return map;
    }
}
