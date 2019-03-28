package com.ninefrost.flutterrongcloudim.common;

import java.util.HashMap;
import java.util.Map;

public class RongListenResult {
    public static String PREPARE = "perpare";
    public static String SUCCESS = "success";
    public static String ERROR = "error";
    public static String PROGRESS = "progress";

    Object result;
    String status;

    public Object getResult() {
        return result;
    }

    public void setResult(Object result) {
        this.result = result;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Map toMap(){
        Map map = new HashMap();
        map.put("status", this.status);
        map.put("result", this.result);
        return map;
    }
}
