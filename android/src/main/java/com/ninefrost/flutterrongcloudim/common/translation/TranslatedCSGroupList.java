package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.rong.imlib.model.CSGroupItem;

/**
 * Created by wangmingqiang on 16/8/26.
 */
public class TranslatedCSGroupList {
    List<TranslatedCSGroupItem> groupList = new ArrayList<TranslatedCSGroupItem>();
    public TranslatedCSGroupList(List<CSGroupItem> groups) {
        for (CSGroupItem item : groups)
            groupList.add(new TranslatedCSGroupItem(item));
    }

    public Map toMap() {
        Map map = new HashMap();
        List<Map> list = new ArrayList();
        for (TranslatedCSGroupItem item : groupList)
            list.add(item.toMap());
        map.put("groupList", list);
        return map;
    }
}
