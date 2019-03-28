package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by wangmingqiang on 16/8/26.
 */
public class TranslatedCustomServiceErrorMsg {
    int errorCode;
    String errorMsg;

    public TranslatedCustomServiceErrorMsg(int code, String msg) {
        errorCode = code;
        errorMsg = msg;
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("errorCode", this.errorCode);
        map.put("errorMsg", this.errorMsg);
        return map;
    }
}
