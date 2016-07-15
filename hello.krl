// this is a test

ruleset hello_world {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Randall Sheen (really Phil Windley)"
    logging on
    sharing on
    provides hello
    provides users
 
  }
  global {
    hello = function(obj) {
      msg = "Hello " + obj
      msg
    };

    goodbye = function(obj) {
      msg2 = "Goodbye " + obj
      msg2
    };

    users = function() {
      users = ent:name;
      users
    };

    name = function(id) {
      all_users = users();
      first = all_users{[id, "name", "first"]}.defaultsTo("0000", "could not find user.");
      last = all_users{[id, "name", "last"]}.defaultsTo("---", "could not find user.");
      name = first +  " " + last;
      name;
    };

    user_by_name = function(full_name) {
      all_users = users();
      filtered_users = all_users.filter(function(user_id, val) {
        constructed_name = val{["name", "first"]} + " " + val{["name", "last"]};
        (constructed_name eq full_name);
      });
      user = filtered_users.head().klog("matching user: ");
      user
    };
  }

  rule hello_world {
    select when echo hello
    pre {
      name = event:attr("name").defaultsTo("0000 ----", "no name passed.");
      full_name = name.split(re/\s/);
      first_name = full_name[0].klog("first : ");
      last_name = full_name[1].klog("last : ");
      matching_user = user_by_name(name).klog("user_result: ");
      user_id = matching_user.keys().head().klog("id: ");
      new_user = {
        "id" : last_name.lc() + "_" + first_name.lc(),
        "first" : first_name,
        "last" : last_name
      };
    }
    if(not user_id.isnull()) then {
      send_directive("say") with
        greeting = "Hello #{name}";
    }
    fired {
      log ("LOG says hello to " + name);
      set ent:name{[user_id, "visits"]} ent:name{[user_id, "visits"]} + 1;
    } else {
      raise explicit event 'new user'
        attributes new_user;
      log("LOG asking to created " + name);
    }
  }

  rule goodbye_all {
    select when yell goodbye
    pre {
      name = event:attr("name").klog("passed in number: ");
    }
    {
      send_directive("say") with
        something = "Goodbye #{name}";
    }
    always {
      log ("LOG goodbye " + name);
    }
  }

  rule store_name {
    select when hello name
    pre {
      id = event:attr("id").klog("our pass in id: ");
      first = event:attr("first").klog("our passed in first: ");
      last = event:attr("last").klog("our passed in last: ");
      init = {"_0": {
                "name": {
                  "first":"ASDFHJKL",
                  "last":""}}
             }
    }
    {
      send_directive("store_name") with
        passed_id = id and
        passed_first = first and
        passed_last = last;
    }
    always {
      set ent:name init if not ent:name{["_0"]};
      set ent:name{[id, "name", "first"]} first;
      set ent:name{[id, "name", "last"]} last;
    }
  }

  rule new_user {
    select when explicit new_user
    pre {
      id = event:attr("id").klog("our pass in Id: ");
      first = event:attr("first").klog("our passed in first: ");
      last = event:attr("last").klog("our passed in last: ");
      new_user = {
        "name": {
          "first": first,
          "last": last
        },
        "visits": 1
      };
    }
    {
      send_directive("say") with
        something = "Hello #{first_name} #{last_name}";
      send_directive("new_user") with
        passed_id = id and
        passed_first = first and
        passed_last = last;
    }
    always {
      set ent:name{[id]} new_user;
    }
  }
}
