package com.ninefrost.flutterrongcloudim.common.translation;
import java.util.HashMap;
import java.util.Map;

import io.rong.imlib.model.CSGroupItem;

public class TranslatedCSGroupItem {
    String groupId;
    String name;
    boolean online;
    public TranslatedCSGroupItem(CSGroupItem item){
        this.groupId = item.getId();
        this.name = item.getName();
        this.online = item.getOnline();
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("groupId", this.groupId);
        map.put("name", this.name);
        map.put("online", this.online);
        return map;
    }
}
