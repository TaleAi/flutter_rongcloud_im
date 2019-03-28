package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.MessageContent;
import io.rong.message.LocationMessage;

/**
 * Created by  ailei 31/1/2019.
 */
public class TranslatedLocationMessage extends TranslatedMessageContent {
    double latitude;
    double longitude;
    String poi;
    String imagePath;
    String extra;

    public TranslatedLocationMessage(MessageContent messageContent) {
        LocationMessage locationMessage = (LocationMessage) messageContent;
        extra = locationMessage.getExtra() == null ? "" : locationMessage.getExtra();
        latitude = locationMessage.getLat();
        longitude = locationMessage.getLng();
        imagePath = locationMessage.getImgUri() != null ? locationMessage.getImgUri().getPath() : null;
        poi = locationMessage.getPoi() == null ? "" : locationMessage.getPoi();
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("latitude", this.latitude);
        map.put("longitude", this.longitude);
        map.put("poi", this.poi);
        map.put("imagePath", this.imagePath);
        map.put("extra", this.extra);
        return map;
    }
}
