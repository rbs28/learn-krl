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
    global_int = 0;

    hello = function(obj) {
      msg = "Hello " + obj
      msg
    };

    goodbye = function(obj) {
      msg2 = "Goodbye " + obj
      msg2
    };
  }
  rule hello_world {
    select when echo hello
    pre {
      name = event:attr("name").klog("our passed in Name: ");
    }
    {
      send_directive("say") with
        something = "Hello #{name}";
    }
    always {
      log ("LOG says hello " + name);
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
 
}
