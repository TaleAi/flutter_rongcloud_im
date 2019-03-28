package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by wangmingqiang on 16/8/26.
 */
public class TranslatedCustomServiceDialogID {
    String dialogId;
    public TranslatedCustomServiceDialogID(String id) {
        dialogId = id;
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("dialogId", this.dialogId);
        return map;
    }
}
