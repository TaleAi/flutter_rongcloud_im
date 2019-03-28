package com.ninefrost.flutterrongcloudim.common;

import java.util.HashMap;
import java.util.Map;

public class RongCustomServiceResult {
    Object result;
    int code;

    public Object getResult() {
        return result;
    }

    public void setResult(Object result) {
        this.result = result;
    }

    public int getStatus() {
        return code;
    }

    public Map toMap(){
        Map map = new HashMap();
        map.put("code", this.code);
        map.put("result", this.result);
        return map;
    }

    public void setStatus(int code) {
        this.code = code;
    }
}
