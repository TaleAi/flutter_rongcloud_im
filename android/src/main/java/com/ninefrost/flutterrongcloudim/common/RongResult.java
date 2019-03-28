package com.ninefrost.flutterrongcloudim.common;

import java.util.HashMap;
import java.util.Map;

public class RongResult {
    Object result;
    Status status;

    public Object getResult() {
        return result;
    }

    public void setResult(Object result) {
        this.result = result;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Map toMap(){
        Map map = new HashMap();
        map.put("status", this.status.ordinal());
        map.put("result", this.result);
        return map;
    }

    public static enum Status {
        prepare, success, error, progress
    }

}
