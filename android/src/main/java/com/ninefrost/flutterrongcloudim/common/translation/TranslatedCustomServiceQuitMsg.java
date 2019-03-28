package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by wangmingqiang on 16/8/26.
 */
public class TranslatedCustomServiceQuitMsg {
    String quitMsg;
    public  TranslatedCustomServiceQuitMsg(String msg) {
        quitMsg = msg;
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("quitMsg", this.quitMsg);
        return map;
    }
}

