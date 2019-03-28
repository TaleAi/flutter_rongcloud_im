package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by wangmingqiang on 16/8/26.
 */
public class TranslatedCustomServiceMode {
    int mode;

    public TranslatedCustomServiceMode(int csMode) {
        mode = csMode;
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("mode", this.mode);
        return map;
    }
}
