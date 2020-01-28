 
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
    messages = defaction(to, from) {
        base_url = <<https://#{account_sid}:#{auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/>>
        url =   (to == "" && from == "") => base_url + "Messages.json" |
                (to != "" && from == "") => base_url + "Messages.json?To=" + to |
                (to == "" && from != "") => base_url + "Messages.json?From=" + from |
                                            base_url + "Messages.json?To=" + to + "&From=" + from 
        http:get(url)
    }
  }
}