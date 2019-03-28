package com.ninefrost.flutterrongcloudim.common.translation;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.rong.imlib.model.Discussion;

/**
 * Created by weiqinxiao on 15/9/16.
 */
public class TranslatedDiscussion {
    String creatorId;
    String id;
    String name;
    List<String> memberIdList;
    String inviteStatus;

    public TranslatedDiscussion(Discussion discussion) {
        this.creatorId = discussion.getCreatorId();
        this.id = discussion.getId();
        this.name = discussion.getName();
        this.memberIdList = discussion.getMemberIdList();
        this.inviteStatus = discussion.isOpen() ? "OPENED" : "CLOSED";
    }

    public Map toMap() {
        Map map = new HashMap();
        map.put("creatorId",this.creatorId );
        map.put("id", this.id);
        map.put("name", this.name);
        map.put("memberIdList", this.memberIdList);
        map.put("inviteStatus", this.inviteStatus);
        return map;
    }
}
