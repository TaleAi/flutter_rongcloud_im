package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.UserInfo;
import io.rong.message.ImageMessage;

/**
 * Created by  ailei 31/1/2019.
 */
public class TranslatedImageMessage extends TranslatedMessageContent {
    String thumbPath;
    String imageUrl;
    UserInfo userInfo;
    String extra;

    public TranslatedImageMessage(MessageContent content) {
        ImageMessage imageMessage = (ImageMessage) content;

        this.imageUrl = imageMessage.getRemoteUri() != null ?
                        imageMessage.getRemoteUri().toString() :
                        (imageMessage.getLocalUri() != null ? imageMessage.getLocalUri().getPath() : "");
        this.thumbPath = imageMessage.getThumUri() != null ? imageMessage.getThumUri().getPath() : "";
        this.extra = imageMessage.getExtra() == null ? "" : imageMessage.getExtra();
        this.userInfo = imageMessage.getUserInfo() == null ? null : imageMessage.getUserInfo();
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
        map.put("thumbPath", this.thumbPath);
        map.put("imageUrl", this.imageUrl);
        map.put("extra", this.extra);
        map.put("user", this.getUserInfo());
        return map;
    }
}
