variable "password" {
  description = "Netscaler Password"
  type        = string
  sensitive   = true
}
variable "ldappassword" {
  description = "LDAP account Password"
  type        = string
  sensitive   = true
}
variable "Additional_SNIPs" {
  type = list(object({
    ipaddress  = string
    netmask    = string
    mgmtaccess = string # Value is either ENABLED or DISABLED
  }))
  default = [
    #{ ipaddress = "", netmask = "", mgmtaccess = ""}
    { ipaddress = "10.0.0.2", netmask = "255.255.255.0", mgmtaccess = "ENABLED" }
  ]
}
variable "static_routes" {
  type = list(object({
    network = string
    netmask = string
    gateway = string
  }))
  default = [
    #{ network = "", netmask = "", gateway = "" },
    { network = "10.254.0.0", netmask = "255.255.0.0", gateway = "10.0.0.1" },
  ]
}
variable "lb_services" {
  type = list(object({
    name        = string
    port        = string
    ip          = string
    servicetype = string
    lbvserver   = string
  }))
  default = [
    #{ name = "", port = "", ip = "", servicetype = "", lbvserver = "" },
    { name = "home-dc1.home.lab_636", port = "636", ip = "10.0.0.3", servicetype = "TCP", lbvserver = "LB_LDAPS" },
    { name = "home-dc1.home.lab_389", port = "389", ip = "10.0.0.3", servicetype = "TCP", lbvserver = "LB_LDAP" },
    { name = "home-dc1.home.lab_80", port = "80", ip = "10.0.0.3", servicetype = "HTTP", lbvserver = "LB_CRL" },
    { name = "home-ddcsf.home.lab_443", port = "443", ip = "10.0.0.12", servicetype = "SSL", lbvserver = "LB_Director" },
    { name = "WEM.home.lab_444", port = "444", ip = "10.0.0.12", servicetype = "SSL", lbvserver = "LB_WEM" },
  ]
}
variable "lb_vservers" {
  type = list(object({
    lbmethod    = string
    sslprofile  = string #Use Secure_sslprofile to utilize the hardened profile created by this terraform
    name        = string
    port        = string #If creating a non-addressable load balancer use 0 for port.
    ipv46       = string #If creating a non-addressable load balancer use 0.0.0.0 for IP.
    servicetype = string
  }))
  default = [
    #{ name = "", port = "", ipv46 = "", servicetype = "", sslprofile = "", lbmethod = "" },
    { name = "LB_LDAPS", port = "636", ipv46 = "10.0.0.81", servicetype = "TCP", sslprofile = "", lbmethod = "" },
    { name = "LB_LDAP", port = "389", ipv46 = "10.0.0.81", servicetype = "TCP", sslprofile = "", lbmethod = "" },
    { name = "LB_Director", port = "0", ipv46 = "0.0.0.0", servicetype = "SSL", sslprofile = "Secure_sslprofile", lbmethod = "" },
    { name = "LB_WEM", port = "0", ipv46 = "0.0.0.0", servicetype = "SSL", sslprofile = "Secure_sslprofile", lbmethod = "" },
    { name = "LB_CRL", port = "0", ipv46 = "0.0.0.0", servicetype = "HTTP", sslprofile = "", lbmethod = "" },
  ]
}
variable "CSW_vservers" {
  type = list(object({
    ipv46       = string
    name        = string
    port        = string
    servicetype = string
    sslprofile  = string #Use Secure_sslprofile to utilize the hardened profile created by this terraform
  }))
  default = [
    #{ name = "", port = "", ipv46 = "", servicetype = "", sslprofile = ""},
    { name = "CSW_Home_443", port = "443", ipv46 = "10.0.0.80", servicetype = "SSL", sslprofile = "Secure_sslprofile" },
    { name = "CSW_Home_80", port = "80", ipv46 = "10.0.0.80", servicetype = "HTTP", sslprofile = "" },
    { name = "External_CSW_Home_443", port = "443", ipv46 = "192.168.0.13", servicetype = "SSL", sslprofile = "Secure_sslprofile" },
    { name = "External_CSW_Home_80", port = "80", ipv46 = "192.168.0.13", servicetype = "HTTP", sslprofile = "" },

  ]
}
variable "CSW_cspolicy" {
  type = list(object({
    policyname = string
    rule       = string
  }))
  default = [
    #{ policyname = "", rule = ""},
    { policyname = "Director", rule = "HTTP.REQ.HOSTNAME.CONTAINS(\"director.home.lab\")" },
    { policyname = "WEM", rule = "HTTP.REQ.HOSTNAME.CONTAINS(\"wem.home.lab\")" },
    { policyname = "Studio", rule = "HTTP.REQ.HOSTNAME.CONTAINS(\"studio.home.lab\")" },
    { policyname = "Storefront", rule = "HTTP.REQ.HOSTNAME.CONTAINS(\"storefront.home.lab\")" },
    { policyname = "CRL", rule = "HTTP.REQ.HOSTNAME.CONTAINS(\"url\")" },
  ]
}
variable "CSW_policybind" {
  type = list(object({
    name            = string
    policyname      = string
    priority        = string
    targetlbvserver = string
  }))
  default = [
    #{ name = "", policyname = "", priority = "", targetlbvserver = ""},
    { name = "CSW_Home_443", policyname = "Director", priority = "100", targetlbvserver = "LB_Director" },
    { name = "CSW_Home_443", policyname = "WEM", priority = "110", targetlbvserver = "LB_WEM" },
    { name = "CSW_Home_443", policyname = "Studio", priority = "120", targetlbvserver = "LB_Director" },
    { name = "CSW_Home_443", policyname = "Storefront", priority = "150", targetlbvserver = "LB_Director" },
    { name = "External_CSW_Home_80", policyname = "CRL", priority = "100", targetlbvserver = "LB_CRL" },
  ]
}
variable "CSW_VPNpolicybind" {
  type = list(object({
    name    = string
    vserver = string
  }))
  default = [
    #{ name = "", vserver = ""},
    { name = "External_CSW_Home_443", vserver = "VPN_GW" },
  ]
}
variable "Responder_Action" {
  type = list(object({
    name   = string
    type   = string
    target = string
  }))
  default = [
    #{ name = "", type = "", target = ""},
    { name = "HTTPtoHTTPS_responderaction", type = "redirect", target = "\"https://\"+HTTP.REQ.HEADER(\"Host\").HTTP_HEADER_SAFE+HTTP.REQ.URL.PATH_AND_QUERY.HTTP_URL_SAFE" },
    { name = "Director_Redirect", type = "redirect", target = "\"https://\"+HTTP.REQ.HOSTNAME+\"/Director/\"" },
    { name = "Studio_Redirect", type = "redirect", target = "\"https://\"+HTTP.REQ.HOSTNAME+\"/Citrix/WebStudio/login/\"" },
    { name = "CRL_Redirect", type = "redirect", target = "\"http://\"+HTTP.REQ.HOSTNAME+\"/crl/\"" },
  ]
}
variable "Responder_Policy" {
  type = list(object({
    name   = string
    action = string
    rule   = string
  }))
  default = [
    #{ name = "", action = "", rule = ""},
    { name = "HTTPS_responderpolicy", action = "HTTPtoHTTPS_responderaction", rule = "HTTP.REQ.HOSTNAME.EQ(\"url\").NOT" },
    { name = "Director_Redirect_Policy", action = "Director_Redirect", rule = "HTTP.REQ.URL.EQ(\"/\") && HTTP.REQ.HOSTNAME.EQ(\"director.home.lab\")" },
    { name = "Studio_Redirect_Policy", action = "Studio_Redirect", rule = "HTTP.REQ.URL.EQ(\"/\") && HTTP.REQ.HOSTNAME.EQ(\"studio.home.lab\")" },
    { name = "CRL_Redirect_Policy", action = "CRL_Redirect", rule = "HTTP.REQ.HOSTNAME.EQ(\"url\")" },
  ]
}
variable "CSW_responderbinding" {
  type = list(object({
    name                   = string
    policyname             = string
    priority               = string
    gotopriorityexpression = string
    bindpoint              = string
  }))
  default = [
    #{ name = "", policyname = "", priority = "", gotopriorityexpression = "", bindpoint = ""},
    { name = "CSW_Home_80", policyname = "HTTPS_responderpolicy", priority = "100", gotopriorityexpression = "END", bindpoint = "REQUEST" },
    { name = "External_CSW_Home_80", policyname = "HTTPS_responderpolicy", priority = "100", gotopriorityexpression = "END", bindpoint = "REQUEST" },
  ]
}
variable "LB_vserver_responder_binding" {
  type = list(object({
    order      = string
    name       = string
    policyname = string
    priority   = string
  }))
  default = [
    #{order = "", name = "", policyname = "", priority = ""},  
    { order = "1", name = "LB_Director", policyname = "Director_Redirect_Policy", priority = "100" },
    { order = "2", name = "LB_Director", policyname = "Studio_Redirect_Policy", priority = "110" },
    { order = "3", name = "LB_CRL", policyname = "CRL_Redirect_Policy", priority = "120" },
  ]
}
variable "saml_action" {
  type = list(object({
    name                    = string
    metadataurl             = string
    samltwofactor           = string
    requestedauthncontext   = string
    digestmethod            = string
    signaturealg            = string
    metadatarefreshinterval = string
  }))
  default = [
    # {  name = "", metadataurl = "", samltwofactor = "", requestedauthncontext = "", digestmethod = "", signaturealg = "", metadatarefreshinterval = ""},
    { name = "Azure_SAML", metadataurl = "", samltwofactor = "OFF", requestedauthncontext = "minimum", digestmethod = "SHA256", signaturealg = "RSA-SHA256", metadatarefreshinterval = "1" },
    { name = "Okta", metadataurl = "", samltwofactor = "OFF", requestedauthncontext = "minimum", digestmethod = "SHA256", signaturealg = "RSA-SHA256", metadatarefreshinterval = "1" },
  ]
}
variable "ldap_action" {
  type = list(object({
    name                       = string
    serverip                   = string
    serverport                 = string
    defaultauthenticationgroup = string # If you are creating a global group to login to the NetScaler, "NetScaler_Admins" is pre-defined in the AAA.tf for this field.
    ldapbase                   = string
    ldapbinddn                 = string
    searchfilter               = string
  }))
  default = [
    #{ name = "", serverip = "", serverport = "", defaultauthenticationgroup = "", ldapbase = "", ldapbinddn = "", searchfilter = ""},
    { name = "Netscaler_Admin_LDAP", serverip = "10.0.0.81", serverport = "636", defaultauthenticationgroup = "NetScaler_Admins", ldapbase = "dc=home,dc=lab", ldapbinddn = "administrator@home.lab", searchfilter = "memberOf=CN=Domain Admins,CN=Users,DC=HOME,DC=LAB" },
    { name = "Users_LDAP", serverip = "10.0.0.81", serverport = "636", defaultauthenticationgroup = "", ldapbase = "dc=home,dc=lab", ldapbinddn = "administrator@home.lab", searchfilter = "" },
  ]
}
variable "oauth_action" {
  type = list(object({
    name                   = string
    authorizationendpoint  = string
    tokenendpoint          = string
    clientid               = string
    clientsecret           = string
    idtokendecryptendpoint = string

  }))
  default = [
    #{ name = "", authorizationendpoint = "tokenendpoint = "",clientid = "",clientsecret = "",  idtokendecryptendpoint = ""},
    { name = "GoogleOauth", authorizationendpoint = "", tokenendpoint = "", clientid = "", clientsecret = "", idtokendecryptendpoint = "" },
  ]
}
variable "Authentication_Policy" {
  type = list(object({
    name   = string
    rule   = string
    action = string
  }))
  default = [
    #{ name = "", rule = "", action = ""},
    { name = "NetScaler_Admin_LDAP_Policy", rule = "true", action = "Netscaler_Admin_LDAP" },
    { name = "Users_LDAP_Policy", rule = "true", action = "Users_LDAP" },
    { name = "Azure_SAML_Policy", rule = "true", action = "Azure_SAML" },
    { name = "Okta_Policy", rule = "true", action = "Okta" },
    { name = "Google_Policy", rule = "true", action = "GoogleOauth" },
    { name = "Nfactor_LDAP", rule = "HTTP.REQ.BODY(500).AFTER_STR(\"domain=\").CONTAINS(\"LDAP\")", action = "NO_AUTHN" },
    { name = "Nfactor_SAML", rule = "HTTP.REQ.BODY(500).AFTER_STR(\"domain=\").CONTAINS(\"SAML\")", action = "NO_AUTHN" },
    { name = "Nfactor_Okta", rule = "HTTP.REQ.BODY(500).AFTER_STR(\"domain=\").CONTAINS(\"Okta\")", action = "NO_AUTHN" },
    { name = "Nfactor_Google", rule = "HTTP.REQ.BODY(500).AFTER_STR(\"domain=\").CONTAINS(\"Google\")", action = "NO_AUTHN" },
    { name = "DomainDropDown_Policy", rule = "true", action = "NO_AUTHN" },
    { name = "NFactor_AAA_Flow", rule = "true", action = "NO_AUTHN" },
  ]
}
variable "authenticationpolicylabel" {
  type = list(object({
    labelname   = string
    loginschema = string
  }))
  default = [
    #{ labelname = "",loginschema = ""},
    { labelname = "Auth_Selection", loginschema = "Authentication_Choice" },
    { labelname = "Check_Auth", loginschema = "LSCHEMA_INT" },
    { labelname = "LDAP_Auth_Selection", loginschema = "lschema_single_factor_deviceid" },
    { labelname = "SAML_Auth_Selection", loginschema = "LSCHEMA_INT" },
    { labelname = "Okta_Auth_Selection", loginschema = "LSCHEMA_INT" },
    { labelname = "Google_Auth_Selection", loginschema = "LSCHEMA_INT" },
  ]
}

variable "Nfactor_binding" {
  type = list(object({
    order                  = string
    labelname              = string
    policyname             = string
    priority               = string
    gotopriorityexpression = string
    nextfactor             = string
  }))
  default = [
    #{ labelname = "", policyname = "", priority = ""},
    { order = "1", labelname = "Auth_Selection", policyname = "DomainDropDown_Policy", priority = "100", gotopriorityexpression = "NEXT", nextfactor = "Check_Auth" },
    { order = "2", labelname = "Check_Auth", policyname = "Nfactor_LDAP", priority = "100", gotopriorityexpression = "NEXT", nextfactor = "LDAP_Auth_Selection" },
    { order = "3", labelname = "Check_Auth", policyname = "Nfactor_SAML", priority = "110", gotopriorityexpression = "NEXT", nextfactor = "SAML_Auth_Selection" },
    { order = "4", labelname = "LDAP_Auth_Selection", policyname = "Users_LDAP_Policy", priority = "100", gotopriorityexpression = "NEXT", nextfactor = "" },
    { order = "5", labelname = "SAML_Auth_Selection", policyname = "Azure_SAML_Policy", priority = "110", gotopriorityexpression = "NEXT", nextfactor = "" },
    { order = "6", labelname = "Check_Auth", policyname = "Nfactor_Google", priority = "120", gotopriorityexpression = "NEXT", nextfactor = "Google_Auth_Selection" },
    { order = "7", labelname = "Google_Auth_Selection", policyname = "Google_Policy", priority = "100", gotopriorityexpression = "NEXT", nextfactor = "" },
    { order = "8", labelname = "Check_Auth", policyname = "Nfactor_Okta", priority = "130", gotopriorityexpression = "NEXT", nextfactor = "Okta_Auth_Selection" },
    { order = "9", labelname = "Okta_Auth_Selection", policyname = "Okta_Policy", priority = "100", gotopriorityexpression = "NEXT", nextfactor = "" },
  ]
}
variable "Global_Auth_Binding" { # This binding is for login to NetScaler, not for logging into AAA or VPN sites.
  type = list(object({
    policyname = string
    priority   = string
  }))
  default = [
    #{ policyname = "", priority = ""},
    { policyname = "NetScaler_Admin_LDAP_Policy", priority = "100" },
  ]
}
variable "AAA_vservers" {
  type = list(object({
    name  = string
    ipv46 = string #If creating a non-addressable AAA vserver leave blank
    port  = string #If creating a non-addressable AAA vserver use 0 for port.
  }))
  default = [
    #{ name = "", ipv46 = "", port = ""},
    { name = "Users_LDAP_AAA_VS", ipv46 = "", port = "0" },
    { name = "Azure_SAML_AAA_VS", ipv46 = "", port = "0" },
    { name = "Nfactor_AAA_VS", ipv46 = "", port = "0" }

  ]
}
variable "AAA_User_Bind" {
  type = list(object({
    name                   = string # This is the name of the Vserver the policy is bound too
    policy                 = string
    priority               = string
    gotopriorityexpression = string
    nextfactor             = string

  }))
  default = [
    #{ name = "", policy = "", priority = ""},
    { name = "Users_LDAP_AAA_VS", policy = "Users_LDAP_Policy", priority = "100", gotopriorityexpression = "", nextfactor = "" },
    { name = "Azure_SAML_AAA_VS", policy = "Azure_SAML_Policy", priority = "100", gotopriorityexpression = "", nextfactor = "" },
    { name = "Nfactor_AAA_VS", policy = "NFactor_AAA_Flow", priority = "100", gotopriorityexpression = "NEXT", nextfactor = "Auth_Selection" },
  ]
}
variable "AuthenticationProfile" {
  type = list(object({
    name        = string
    authnvsname = string
  }))
  default = [
    #{ name = "", authnvsname = ""},
    { name = "Users_LDAP_AuthProfile", authnvsname = "Users_LDAP_AAA_VS" },
    { name = "Azure_SAML_AuthProfile", authnvsname = "Azure_SAML_AAA_VS" },
    { name = "NFactor_AuthProfile", authnvsname = "Nfactor_AAA_VS" },
  ]
}
variable "LoginSchema" {
  type = list(object({
    filename    = string
    filecontent = string # 
  }))
  default = [
    #{ filename = "", filecontent = "./nfactor/"},
    { filename = "Authentication_dropdown.xml", filecontent = "./nfactor/Authentication_dropdown.xml" },
  ]
}
variable "Nfactor_LoginSchema" {
  type = list(object({
    name                 = string
    authenticationschema = string
  }))
  default = [
    #{ name = "",authenticationschema = "/nsconfig/loginschema/"}
    { name = "Authentication_Choice", authenticationschema = "/nsconfig/loginschema/Authentication_dropdown.xml" }
  ]
}
variable "Nfactor_LoginSchema_Policy" {
  type = list(object({
    name   = string
    rule   = string
    action = string
  }))
  default = [
    #{ name = "", rule = "", action = ""}
    { name = "Authentication_Choice", rule = "true", action = "Authentication_Choice" }
  ]
}
variable "CertandKeyUpload" {
  type = list(object({
    filename    = string
    filecontent = string # 
  }))
  default = [
    #{ filename = "", filecontent = ""},
    { filename = "HomeWildcard.pem", filecontent = "./Certificates/HomeWildcard.pem" },
    { filename = "ISRG.cer", filecontent = "./Certificates/ISRG.cer" },
    { filename = "R3Intermediate.cer", filecontent = "./Certificates/R3Intermediate.cer" },
    { filename = "vpncert.cer", filecontent = "./Certificates/vpncert.cer" },
    { filename = "vpncert.key", filecontent = "./Certificates/vpncert.key" },
    { filename = "10cert.cer", filecontent = "./Certificates/10cert.cer" },
    { filename = "10cert.key", filecontent = "./Certificates/10cert.key" },
    { filename = "HomeRoot.crt", filecontent = "./Certificates/HomeRoot.crt" },
    { filename = "cvlab.cer", filecontent = "./Certificates/cvlab.cer" },
    { filename = "cvlab.key", filecontent = "./Certificates/cvlab.key" },

  ]
}
variable "Certificates" {
  type = list(object({
    certkey         = string
    cert            = string
    key             = string
    linkcertkeyname = string
  }))
  default = [
    #{ certkey = "", cert = "", key = "", linkcertkeyname = ""},
    { certkey = "Home_Wildcard", cert = "HomeWildcard.pem", key = "HomeWildcard.pem", linkcertkeyname = "Home_Root" },
    { certkey = "CVLAB_Wildcard", cert = "cvlab.cer", key = "cvlab.key", linkcertkeyname = "R3Intermediate" },
    { certkey = "10min_Wildcard", cert = "10cert.cer", key = "10cert.key", linkcertkeyname = "R3Intermediate" },
    { certkey = "VPN_Wildcard", cert = "vpncert.cer", key = "vpncert.key", linkcertkeyname = "R3Intermediate" },
    { certkey = "R3Intermediate", cert = "R3Intermediate.cer", key = "", linkcertkeyname = "ISRG" },
    { certkey = "ISRG", cert = "ISRG.cer", key = "", linkcertkeyname = "" },
    { certkey = "Home_Root", cert = "HomeRoot.crt", key = "", linkcertkeyname = "" },
  ]
}
variable "SSLbinding" {
  type = list(object({
    order       = string # Required to prevent name collisions with SNI Certs Just create a unique ascending number for each entry.
    vservername = string
    certkeyname = string
    snicert     = string # must be true or false
  }))
  default = [
    #{ vservername = "", certkeyname = "", snicert = ""},
    { order = "1", vservername = "CSW_Home_443", certkeyname = "Home_Wildcard", snicert = "true" },
    { order = "2", vservername = "CSW_Home_443", certkeyname = "VPN_Wildcard", snicert = "true" },
    { order = "3", vservername = "CSW_Home_443", certkeyname = "CVLAB_Wildcard", snicert = "true" },
    { order = "5", vservername = "LB_WEM", certkeyname = "Home_Wildcard", snicert = "false" },
    { order = "6", vservername = "LB_Director", certkeyname = "Home_Wildcard", snicert = "false" },
    { order = "7", vservername = "VPN_GW", certkeyname = "CVLAB_Wildcard", snicert = "false" },
    { order = "8", vservername = "Users_LDAP_AAA_VS", certkeyname = "Home_Wildcard", snicert = "false" },
    { order = "9", vservername = "External_CSW_Home_443", certkeyname = "VPN_Wildcard", snicert = "true" },
    { order = "10", vservername = "External_CSW_Home_443", certkeyname = "CVLAB_Wildcard", snicert = "true" },
    { order = "11", vservername = "Nfactor_AAA_VS", certkeyname = "CVLAB_Wildcard", snicert = "false" },
    { order = "12", vservername = "Azure_SAML_AAA_VS", certkeyname = "CVLAB_Wildcard", snicert = "false" },
  ]
}
variable "STA_bind" {
  type = list(object({
    staserver = string #Must be http:// or https:// and either IP or FQDN that is NetScaler accessible
  }))
  default = [
    #{ staserver = ""},
    { staserver = "http://10.0.0.12" },
  ]
}
variable "VPN_SessionActions" {
  type = list(object({
    name   = string
    wihome = string
  }))
  default = [
    #{ name = "", wihome = ""},
    { name = "VPN_Native_Action", wihome = "http://10.0.0.12/Citrix/Store" },
    { name = "VPN_Web_Action", wihome = "http://10.0.0.12/Citrix/StoreWeb/" },
    { name = "FAS_Native_Action", wihome = "http://10.0.0.12/Citrix/FAS" },
    { name = "FAS_Web_Action", wihome = "http://10.0.0.12/Citrix/FASWeb/" },
  ]
}
variable "VPN_SessionPolicy" {
  type = list(object({
    name   = string
    rule   = string
    action = string
  }))
  default = [
    #{ name = "", rule = "", action = ""},
    { name = "VPN_Native_Policy", rule = "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\")", action = "VPN_Native_Action" },
    { name = "VPN_Web_Policy", rule = "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\").NOT", action = "VPN_Web_Action" },
    { name = "FAS_Native_Policy", rule = "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\")", action = "FAS_Native_Action" },
    { name = "FAS_Web_Policy", rule = "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\").NOT", action = "FAS_Web_Action" },
  ]
}
variable "VPN_Vserver" {
  type = list(object({
    name         = string
    authnprofile = string
    icaonly      = string
    ipv46        = string # leave blank if binding to Content Switch
    port         = string # Set to 0 if binding to Content Switch
  }))
  default = [
    #{ name = "", authnprofile = "", icaonly = "", ipv46 = "", port = "443"},
    { name = "VPN_GW", authnprofile = "NFactor_AuthProfile", icaonly = "OFF", ipv46 = "", port = "0" },
  ]
}
variable "VPN_SessionBind" {
  type = list(object({
    name     = string
    policy   = string
    priority = string
  }))
  default = [
    #{ name = "", policy = "", priority = ""},
    { name = "VPN_GW", policy = "FAS_Native_Policy", priority = "100" },
    { name = "VPN_GW", policy = "FAS_Web_Policy", priority = "110" },
  ]
}
variable "ADNS_Services" {
  type = list(object({
    name        = string
    ip          = string
    servicetype = string
  }))
  default = [
    #{ name = "", ip = "", servicetype = ""},
    { name = "ADNS", ip = "192.168.0.73", servicetype = "ADNS" },
    { name = "ADNS_TCP", ip = "192.168.0.73", servicetype = "ADNS_TCP" },
  ]
}
variable "SOA" {
  type = list(object({
    domain       = string
    originserver = string
    contact      = string
  }))
  default = [
    #{ domain = "", originserver = "", contact = ""},
    { domain = "", originserver = "", contact = "" },
  ]
}
variable "RootRecord" {
  type = list(object({
    domain     = string
    nameserver = string
  }))
  default = [
    #{ domain = "", nameserver = ""},
    { domain = ".", nameserver = "nope" },
    { domain = "nope", nameserver = "ns1.nope" },
    { domain = "nope", nameserver = "ns2.nope" },
  ]
}
variable "dnszone" {
  type = list(object({
    zonename = string
  }))
  default = [
    #{ zonename = ""},
    { zonename = "nope" },
  ]
}
variable "GSLB_Site" {
  type = list(object({
    sitename      = string
    siteipaddress = string
    publicip      = string
    sitetype      = string
  }))
  default = [
    #{ sitename = "", siteipaddress = "", publicip = "", sitetype = ""},
    { sitename = "DC1", siteipaddress = "192.168.0.73", publicip = "", sitetype = "LOCAL" },
    { sitename = "DC2", siteipaddress = "10.254.1.200", publicip = "", sitetype = "REMOTE" },
  ]
}
variable "GSLB_Service" {
  type = list(object({
    ip          = string
    port        = string
    servicename = string
    servicetype = string
    sitename    = string
    publicip    = string
    publicport  = string
  }))
  default = [
    #{ ip = "", port = "", servicename = "", servicetype = "", sitename = ""},
    { ip = "10.0.0.80", port = "80", publicip = "", publicport = "80", servicename = "CSW_Home_80", servicetype = "HTTP", sitename = "DC1" },
    { ip = "10.254.1.201", port = "80", publicip = "", publicport = "80", servicename = "CSW_DC2_80", servicetype = "HTTP", sitename = "DC2" },
    { ip = "10.0.0.80", port = "443", publicip = "", publicport = "443", servicename = "CSW_Home_443", servicetype = "SSL", sitename = "DC1" },
    { ip = "10.254.1.201", port = "443", publicip = "", publicport = "443", servicename = "CSW_DC2_443", servicetype = "SSL", sitename = "DC2" },
    { ip = "192.168.0.13", port = "443", publicip = "", publicport = "443", servicename = "External_CSW_Home_443", servicetype = "SSL", sitename = "DC1" },
  ]
}
variable "GSLB_vserver" {
  type = list(object({
    name           = string
    servicetype    = string
    domainname     = string
    DC1servicename = string
    DC1weight      = string
    DC2servicename = string
    DC2weight      = string
  }))
  default = [
    #{ name = "", servicetype = "", domainname = "", DC1servicename = "", DC1weight = "", DC2servicename = "", DC2weight = ""},
    { name = "GSLB_VS_CSW", servicetype = "HTTP", domainname = "nope", DC1servicename = "CSW_Home_80", DC1weight = "100", DC2servicename = "CSW_DC2_80", DC2weight = "100" },
  ]
}
variable "DC1_GSLB_vserver" {
  type = list(object({
    name           = string
    servicetype    = string
    domainname     = string
    DC1servicename = string
    DC1weight      = string
  }))
  default = [
    #{ name = "", servicetype = "", domainname = "", DC1servicename = "", DC1weight = ""},

    { name = "External_CSW", servicetype = "HTTP", domainname = "nope", DC1servicename = "External_CSW_Home_443", DC1weight = "100" },
  ]
}
variable "DC2_GSLB_vserver" {
  type = list(object({
    name           = string
    servicetype    = string
    domainname     = string
    DC2servicename = string
    DC2weight      = string
  }))
  default = [
    #{ name = "", servicetype = "", domainname = "", DC2servicename = "", DC2weight = ""},
  ]
}
variable "GSLB_DNSView" {
  type = list(object({
    viewname = string
  }))
  default = [
    #{ viewname = ""},
    { viewname = "HomeInternal" },
  ]
}
variable "DNSAction" {
  type = list(object({
    actionname = string
    actiontype = string
    viewname   = string
  }))
  default = [
    #{ actionname = "",actiontype = "", viewname = ""},
    { actionname = "HomeInternal", actiontype = "ViewName", viewname = "HomeInternal" },
  ]
}
variable "DNSPolicy" {
  type = list(object({
    name       = string
    rule       = string
    actionname = string
  }))
  default = [
    #{name = "",rule = "", actionname = ""},
    { name = "HomeInternal_Policy", rule = "CLIENT.IP.SRC.IN_SUBNET(192.168.0.0/24) || CLIENT.IP.SRC.IN_SUBNET(10.0.0.0/24)", actionname = "HomeInternal" },
  ]
}
variable "DNSPolicy_Binding" {
  type = list(object({
    policyname = string
    priority   = string
  }))
  default = [
    #{policyname = "",priority = ""},        
    { policyname = "HomeInternal_Policy", priority = "10" },
  ]
}
variable "GSLB_DNSView_Binding" {
  type = list(object({
    servicename = string
    viewname    = string
    viewip      = string
  }))
  default = [
    #{servicename = "", viewname = "", viewip =""},
    { servicename = "External_CSW_Home_443", viewname = "HomeInternal", viewip = "192.168.0.13" },
  ]
}
