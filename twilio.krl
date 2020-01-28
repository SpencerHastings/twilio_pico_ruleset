 
ruleset twilio_m {
  meta {
    configure using account_sid = ""
                    auth_token = ""
    provides
        send_sms, messages
  }
 
  global {
    send_sms = defaction(to, from, message) {
       base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/>>
       http:post(base_url + "Messages.json", form = {
                "From":from,
                "To":to,
                "Body":message
            })
    }
    messages = function(to, from) {
        base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/>>
        url =   (to == null && from == null) => base_url + "Messages.json?Page=0" |
                (to != null && from == null) => base_url + "Messages.json?To=" + to + "&Page=0"|
                (to == null && from != null) => base_url + "Messages.json?From=" + from + "&Page=0" |
                                            base_url + "Messages.json?To=" + to + "&From=" + from + "&Page=0" 
        response = http:get(url)
        status = response{"status_code"};
 
 
        error_info = {
            "error": "sky cloud request was unsuccesful.",
            "httpStatus": {
                "code": status,
                "message": response{"status_line"}
            }
        };
    
    
        response_content = response{"content"}.decode();
        response_error = (response_content.typeof() == "Map" && response_content{"error"}) => response_content{"error"} | 0;
        response_error_str = (response_content.typeof() == "Map" && response_content{"error_str"}) => response_content{"error_str"} | 0;
        error = error_info.put({"skyCloudError": response_error, "skyCloudErrorMsg": response_error_str, "skyCloudReturnValue": response_content});
        is_bad_response = (response_content.isnull() || response_content == "null" || response_error || response_error_str);
    
    
        // if HTTP status was OK & the response was not null and there were no errors...
        (status == "200" && not is_bad_response) => response_content | error
        }
  }
}