package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by weiqinxiao on 15/9/16.
 */
public class TranslatedQuietHour {
    String startTime;
    int spanMinutes;

    public TranslatedQuietHour(String startTime, int spanMinutes) {
        this.startTime = startTime;
        this.spanMinutes = spanMinutes;
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("startTime", this.startTime);
        map.put("spanMinutes", this.spanMinutes);
        return map;
    }
}
