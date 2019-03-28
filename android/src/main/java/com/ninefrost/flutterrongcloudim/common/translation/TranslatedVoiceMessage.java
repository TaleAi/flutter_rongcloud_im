package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.MessageContent;
import io.rong.message.VoiceMessage;

/**
 * Created by  ailei 31/1/2019.
 */
public class TranslatedVoiceMessage extends TranslatedMessageContent {
    String voicePath;
    int duration;
    String extra;

    public TranslatedVoiceMessage(MessageContent content) {
        VoiceMessage voiceMessage = (VoiceMessage) content;
        this.duration = voiceMessage.getDuration();
        this.extra = voiceMessage.getExtra() == null ? "" : voiceMessage.getExtra();
        this.voicePath = voiceMessage.getUri() != null ? voiceMessage.getUri().getPath() : null;
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("voicePath", this.voicePath);
        map.put("duration", this.duration);
        map.put("extra", this.extra);
        return map;
    }
}
