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
    { name = "home-ddcsf.home.lab_443", port = "443", ip = "10.0.0.100", servicetype = "SSL", lbvserver = "LB_Director" },
    { name = "WEM.home.lab_444", port = "444", ip = "10.0.0.99", servicetype = "SSL", lbvserver = "LB_WEM" },
    { name = "studio.home.lab_443", port = "443", ip = "10.0.0.99", servicetype = "SSL", lbvserver = "LB_Studio" },
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
    { name = "LB_Studio", port = "0", ipv46 = "0.0.0.0", servicetype = "SSL", sslprofile = "Secure_sslprofile", lbmethod = "" },
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
    { name = "CSW_Home_443", policyname = "Studio", priority = "120", targetlbvserver = "LB_Studio" },
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
    { name = "HTTPS_responderpolicy", action = "HTTPtoHTTPS_responderaction", rule = "true" },
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
  ]
}
variable "AAA_User_Bind" {
  type = list(object({
    name     = string # This is the name of the Vserver the policy is bound too
    policy   = string
    priority = string
  }))
  default = [
    #{ name = "", policy = "", priority = ""},
    { name = "Users_LDAP_AAA_VS", policy = "Users_LDAP_Policy", priority = "100" },
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
  ]
}
variable "CertandKeyUpload" {
  type = list(object({
    filename    = string # Name of the file to be created under the nsconfig/ssl directory.
    filecontent = string # Place the name of the file to upload after the ./Certificates/ entry.
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
    { order = "4", vservername = "LB_Studio", certkeyname = "Home_Wildcard", snicert = "false" },
    { order = "5", vservername = "LB_WEM", certkeyname = "Home_Wildcard", snicert = "false" },
    { order = "6", vservername = "LB_Director", certkeyname = "Home_Wildcard", snicert = "false" },
    { order = "7", vservername = "VPN_GW", certkeyname = "CVLAB_Wildcard", snicert = "false" },
    { order = "8", vservername = "Users_LDAP_AAA_VS", certkeyname = "Home_Wildcard", snicert = "false" },
  ]
}
variable "STA_bind" {
  type = list(object({
    staserver = string #Must be http:// or https:// and either IP or FQDN that is NetScaler accessible
  }))
  default = [
    #{ staserver = ""},
    { staserver = "http://10.0.0.100" },
  ]
}
variable "VPN_SessionActions" {
  type = list(object({
    name   = string
    wihome = string
  }))
  default = [
    #{ name = "", wihome = ""},
    { name = "VPN_Native_Action", wihome = "http://10.0.0.100/Citrix/Store" },
    { name = "VPN_Web_Action", wihome = "http://10.0.0.100/Citrix/StoreWeb/" },
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
    { name = "VPN_GW", authnprofile = "Users_LDAP_AuthProfile", icaonly = "OFF", ipv46 = "", port = "0" },
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
    { name = "VPN_GW", policy = "VPN_Native_Policy", priority = "100" },
    { name = "VPN_GW", policy = "VPN_Web_Policy", priority = "110" },
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
    { domain = "gslb.cvlab.website", originserver = "cvlab.website", contact = "postmaster.cvlab.website" },
  ]
}
variable "RootRecord" {
  type = list(object({
    domain     = string
    nameserver = string
  }))
  default = [
    #{ domain = "", nameserver = ""},
    { domain = ".", nameserver = "gslb.cvlab.website" },
    { domain = "gslb.cvlab.website", nameserver = "ns1.cvlab.website" },
    { domain = "gslb.cvlab.website", nameserver = "ns2.cvlab.website" },
  ]
}
variable "dnszone" {
  type = list(object({
    zonename = string
  }))
  default = [
    #{ zonename = ""},
    { zonename = "gslb.cvlab.website" },
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
    { sitename = "DC1", siteipaddress = "192.168.0.73", publicip = "2.2.21.11", sitetype = "LOCAL" },
    { sitename = "DC2", siteipaddress = "10.254.1.200", publicip = "1.1.5.214", sitetype = "REMOTE" },
  ]
}
variable "GSLB_Service" {
  type = list(object({
    ip          = string
    port        = string
    servicename = string
    servicetype = string
    sitename    = string
  }))
  default = [
    #{ ip = "", port = "", servicename = "", servicetype = "", sitename = ""},
    { ip = "10.0.0.80", port = "80", servicename = "CSW_Home_80", servicetype = "HTTP", sitename = "DC1" },
    { ip = "10.254.1.201", port = "80", servicename = "CSW_DC2_80", servicetype = "HTTP", sitename = "DC2" },
    { ip = "10.0.0.80", port = "443", servicename = "CSW_Home_443", servicetype = "SSL", sitename = "DC1" },
    { ip = "10.254.1.201", port = "443", servicename = "CSW_DC2_443", servicetype = "SSL", sitename = "DC2" },
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
    { name = "GSLB_VS_CSW", servicetype = "HTTP", domainname = "director.gslb.cvlab.website", DC1servicename = "CSW_Home_80", DC1weight = "100", DC2servicename = "CSW_DC2_80", DC2weight = "100" },
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