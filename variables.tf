variable "password" {
    description = "Netscaler Login Password"
    type = string
    sensitive = true
}
variable "ldappassword" {
    description = "LDAP account Password"
    type = string
    sensitive = true
}

variable "static_routes" {
    type = list(object({
        network = string
        netmask = string
        gateway = string
        }  ))
    default = [
    #{ network = "", netmask = "", gateway = "" },
    ]    
}
variable "lb_services" {
    type = list(object({
        name        = string
        port        = string
        ip          = string
        servicetype = string
        lbvserver   = string 
        }  ))
    default = [
    #{ name = "", port = "", ip = "", servicetype = "", lbvserver = "" },
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
        }  ))
    default = [
    #{ name = "", port = "", ipv46 = "", servicetype = "", sslprofile = "", lbmethod = "" },
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
    ]   
}
variable "CSW_cspolicy" {
    type = list(object({
        policyname = string
        rule       = string
    }))
    default = [
    #{ policyname = "", rule = ""},
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
    ]
}
variable "Responder_Action" {
    type = list(object({
        name    = string
        type    = string
        target  = string
    }))
    default = [
    #{ name = "", type = "", target = ""},    
    ]
}
variable "Responder_Policy" {
    type = list(object({
        name    = string
        action  = string
        rule    = string
    }))
    default = [
    #{ name = "", action = "", rule = ""},
    ]
}
variable "CSW_responderbinding" {
    type = list(object({
        name = string
        policyname = string
        priority = string
        gotopriorityexpression = string
        bindpoint = string
    }))
    default = [
    #{ name = "", policyname = "", priority = "", gotopriorityexpression = "", bindpoint = ""},
    ]
   }
variable "CSW_VPNpolicybind" {
        type = list(object({
        name            = string
        vserver         = string
    }))
    default = [
    #{ name = "", vserver = ""},
    ]
}
variable "ldap_action" {
    type = list(object({
        name       = string
        serverip   = string
        serverport = string
        defaultauthenticationgroup = string # If you are creating a global group to login to the NetScaler, "NetScaler_Admins" is pre-defined in the AAA.tf for this field.
        ldapbase = string
        ldapbinddn = string
        searchfilter = string
    }))
    default = [
    #{ name = "", serverip = "", serverport = "", defaultauthenticationgroup = "", ldapbase = "", ldapbinddn = "", searchfilter = ""},
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
    ]
}
variable "Global_Auth_Binding" { # This binding is for login to NetScaler, not for logging into AAA or VPN sites.
    type = list(object({
        policyname     = string
        priority       = string
    }))
    default = [
    #{ policyname = "", priority = ""},
    ]
}
variable "AAA_vservers" {
    type = list(object({
      name        = string
      ipv46       = string #If creating a non-addressable AAA vserver leave blank
      port        = string #If creating a non-addressable AAA vserver use 0 for port.
    }))
    default = [
    #{ name = "", ipv46 = "", port = ""},
    ]
}
variable "AAA_User_Bind" {
    type = list(object({
      name      = string # This is the name of the Vserver the policy is bound too
      policy    = string
      priority  = string
    }))
    default = [
    #{ name = "", policy = "", priority = ""},
    ]
}
variable "AuthenticationProfile" {
    type = list(object({
      name = string
      authnvsname = string
    }))
    default = [
    #{ name = "", authnvsname = ""},
    ]
}
variable "CertandKeyUpload" {
    type = list(object({
        filename = string # Name of the file to be created under the nsconfig/ssl directory.
        filecontent = string # Place the name of the file to upload after the ./Certificates/ entry.
    }))
    default = [
    #{ filename = "", filecontent ="./Certificates/"},
    ]
}
variable "Certificates" {
    type = list(object({
      certkey = string
      cert = string
      key = string
      linkcertkeyname = string
    }))
    default = [
    #{ certkey = "", cert = "", key = "", linkcertkeyname = ""},
    ]
}
variable "SSLbinding" {
    type = list(object({
      order = string # Required to prevent name collisions with SNI Certs Just create a unique ascending number for each entry.
      vservername = string
      certkeyname = string
      snicert     = string # Must be either true or false
        }))
    default = [
    #{ order = "",vservername = "", certkeyname = "", snicert = ""},
    ]
}
variable "STA_bind" {
    type = list(object({
        staserver = string #Must be http:// or https:// and either IP or FQDN that is NetScaler accessible
        }))
    default = [
    #{ staserver = ""},
    ]
}
variable "VPN_SessionActions" {
    type = list(object({
        name = string
        wihome = string
        }))
    default = [
    #{ name = "", wihome = ""},
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
    ]
}
variable "VPN_Vserver" {
    type = list(object({
        name = string
        authnprofile = string
        icaonly = string
        ipv46 = string # leave blank if binding to Content Switch
        port = string # Set to 0 if binding to Content Switch
        }))
    default = [
    #{ name = "", authnprofile = "", icaonly = "", ipv46 = "", port = "443"},
    ]
}
variable "VPN_SessionBind" {
    type = list(object({
        name = string
        policy = string
        priority = string
        }))
    default = [
    #{ name = "", policy = "", priority = ""},
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
    ]
}
variable "SOA" {
    type = list(object({
        domain =  string
        originserver  = string
        contact =  string
        }))
    default = [
    #{ domain = "", originserver = "", contact = ""},
    ]
}
variable "RootRecord" {
    type = list(object({
        domain = string
        nameserver = string
        }))
    default = [
    #{ domain = "", nameserver = ""},
    ]
}
variable "dnszone" {
    type = list(object({
        zonename = string
                }))
    default = [
    #{ zonename = ""},
    ]
}
variable "GSLB_Site" {
    type = list(object({
      sitename        = string
      siteipaddress   = string
      publicip = string
      sitetype = string
                }))
    default = [
    #{ sitename = "", siteipaddress = "", publicip = "", sitetype = ""},
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
    ]
}
variable "GSLB_vserver" {
    type = list(object({
        name          = string
        servicetype   = string
        domainname = string
        DC1servicename = string
        DC1weight      = string
        DC2servicename = string
        DC2weight      = string
                    }))
    default = [
    #{ name = "", servicetype = "", domainname = "", DC1servicename = "", DC1weight = "", DC2servicename = "", DC2weight = ""},
     ]
}
