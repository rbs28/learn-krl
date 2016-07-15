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
    provides hello, goodbye
 
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
    }
  }
  rule hello_world {
    select when echo hello
    pre {
      id = event:attr("id");
      default_name = name(id);
    }
    {
      send_directive("say") with
        greeting = "Hello #{default_name}";
    }
    always {
      log ("LOG says hello " + default_name);
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
}
