# resource "ssh_resource" "Custom_LogonPoint_Text_Strings" {
#   host     = "IP of host"
#   user     = "nsroot"
#   password = var.password
#   file {
#     content     = "{\"Authentication_Choice_text\":\"Please select authentication type to continue Login ...\",\"Authentication_Choice_Logon\":\"Log On\",\"Authentication_Choice_Selection\":\"(Select a login type)\",\"Authentication_Choice_LDAP\":\"LDAP\",\"Authentication_Choice_SAML\":\"SAML\",\"Authentication_Choice_OTP\":\"OTP\",\"Authentication_Choice_Google\":\"Google\",\"Authentication_Choice_Okta\":\"Okta\"}"
#     destination = "/var/netscaler/logon/LogonPoint/custom/strings.en.json"
# #   }
#   timeout = "15s"
#   commands = [
#   ]
# }
# resource "ssh_resource" "SAML_Subject_Fix" {
#   host     = "IP of host"
#   user     = "nsroot"
#   password = var.password
#   file {
#     content     = "nsapimgr_wr.sh -ys call=ns_saml_dont_send_subject"
#     destination = "/nsconfig/rc.netscaler"
#     permissions = "0644"
#   }
#   timeout = "15s"
#   commands = [
#     "exit"
#   ]

# }