# These are the passwords that are prompted at the start of every run.  They are not stored after the run and any testing will require them.
# This is just an added security measure.  If you wish, you can change these from sensitive to just strings and enter the password in clear text.  But be warned.  This is a security flaw.
variable "password" {
  description = "Netscaler Login Password"
  type        = string
  sensitive   = true
}
variable "ldappassword" {
  description = "LDAP account Password"
  type        = string
  sensitive   = true
}
# ----------------------------------------------------
#NETWORKING
# ----------------------------------------------------
# Add any additional SNIPs if your NetScaler is multi-legged.  The Management network SNIP is not needed here, as it is added as part of the initial configuration.
variable "Additional_SNIPs" {
  type = list(object({
    ipaddress  = string
    netmask    = string
    mgmtaccess = string # Value is either ENABLED or DISABLED
  }))
  default = [
    #{ ipaddress = "", netmask = "", mgmtaccess = ""}
  ]
}
# Add any static routes to internal networks here.  This is not for the default route for a single legged NetScaler, as that is defined during the initial install.
# If you are moving management default gateway with a PBR, then you can define the static route here.
variable "static_routes" {
  type = list(object({
    network = string
    netmask = string
    gateway = string
  }))
  default = [
    #{ network = "", netmask = "", gateway = "" },
  ]
}
# ----------------------------------------------------
#LOADBALANCING
# ----------------------------------------------------
# Enter any Loadbalancing servers and services here.  This command will create both the server and the service as needed.
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
  ]
}
# Enter any Load Balancing vServers here.  If there are additional modifications needed with items such as monitors or persistence, enter those in the GUI after creation.
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
  ]
}
# ----------------------------------------------------
#CONTENT SWITCHING
# ----------------------------------------------------
# This section is for creating Content Switching vServers.  Content Switching should be used when you have to put multiple resources behind the same IP with different names,
# or if you need to route traffic based off data in the URL request.  Load Balancers and Responder policies will be bound to the Content Switches to handle traffic.
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
# These are the policies that will be evaluated once bound to a Content Switch
variable "CSW_cspolicy" {
  type = list(object({
    policyname = string
    rule       = string
  }))
  default = [
    #{ policyname = "", rule = ""},
  ]
}
# This is where you bind the polcies to the vServer for routing of traffic.
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
# This section is for binding a Citrix Gateway - VPN, ICA, RDP, or PCOIP to a Content Switch.  You can only have 1 Gateway bound to 1 Content Switch on your entire NetScaler.
variable "CSW_VPNpolicybind" {
  type = list(object({
    name    = string
    vserver = string
  }))
  default = [
    #{ name = "", vserver = ""},
  ]
}
# ----------------------------------------------------
# RESPONDER FUNCTIONS
# ----------------------------------------------------
# Responders handle switching traffic around based off rules you specify.  They can be bound to nearly every form of vServer on the NetScaler.
# These are Responder Actions that will execute when a particular URL request is received on a vServer.
variable "Responder_Action" {
  type = list(object({
    name   = string
    type   = string
    target = string
  }))
  default = [
    #{ name = "", type = "", target = ""},    
  ]
}
# These are the Policies that are bound with the rules to trigger the Responder Actions.
variable "Responder_Policy" {
  type = list(object({
    name   = string
    action = string
    rule   = string
  }))
  default = [
    #{ name = "", action = "", rule = ""},
  ]
}
# This section binds the Responder Policies to the Content Switch vServer.
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
  ]
}
# This section is for binding Responder Policies to Load Balancers.  This is used for when they are directly IP addressable, and for when they are accessed behind a content switch.
variable "LB_vserver_responder_binding" {
  type = list(object({
    order      = string
    name       = string
    policyname = string
    priority   = string
  }))
  default = [
    #{order = "", name = "", policyname = "", priority = ""},  
  ]
}
# ----------------------------------------------------
# AUTHENTICATION PROCESSING
# ----------------------------------------------------
# The NetScaler AAA service can handle many forms of authentication.  The following sections outline the most commonly used methods of authentication.
# SAML Action
# This has been tested with Azure AD and Okta portals.
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
  ]
}
# LDAP Action, used for both AAA user access, and for Domain Admin account access to the NetScaler management plane itself.  
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
  ]
}
# ----------------------------------------------------
# OAUTH Action
# ----------------------------------------------------
# Tested with google.com for gmail.com access via shadow accounts to Citrix Virtual Apps and Desktops
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
     ]
}
# Authentication Policies connect the above actions directly to AAA vservers, or can be attached to nFactor workflows for multiple authentication methods.
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
# ----------------------------------------------------
# NFACTOR CONFIGURATION
# ----------------------------------------------------
# Authentication Policy Labels are used by nFactor for setting up cascading login workflows. See the variables.example.tf for more detail on the workflow.
variable "authenticationpolicylabel" {
  type = list(object({
    labelname   = string
    loginschema = string
  }))
  default = [
    #{ labelname = "",loginschema = ""},
  ]
}
# These binding functions setup the cascading login binding Policy Labels together.
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
    #{ order = "", labelname = "", policyname = "", priority = "", gotopriorityexpression = "NEXT", nextfactor = "" },
  ]
}
# This section is for uploading your custom Login Schemas to the NetScaler.  Make sure to update the ssh.tf to include any custom text fields you may use in your Schema.
variable "LoginSchema" {
  type = list(object({
    filename    = string
    filecontent = string # 
  }))
  default = [
    #{ filename = "", filecontent = "./nfactor/"}, #place your Login Schema in an nfactor folder in the root of your project
  ]
}
# This creates the Login Schema that points to the Login Schema you uploaded previously.  
variable "Nfactor_LoginSchema" {
  type = list(object({
    name                 = string
    authenticationschema = string
  }))
  default = [
    #{ name = "",authenticationschema = "/nsconfig/loginschema/"}
  ]
}
# This is where you define the Policies that apply Actions based off your defined rules.  See the varables.example.tf for more information.
variable "Nfactor_LoginSchema_Policy" {
  type = list(object({
    name   = string
    rule   = string
    action = string
  }))
  default = [
    #{ name = "", rule = "", action = ""}
  ]
}
# This global binding is for binding your LDAP Admin Connection to the NetScaler for administration.  Make sure this is a restricted AD group as these users get full admin
# rights on the NetScaler itself.
variable "Global_Auth_Binding" { # This binding is for login to NetScaler, not for logging into AAA or VPN sites.
  type = list(object({
    policyname = string
    priority   = string
  }))
  default = [
    #{ policyname = "", priority = ""},
  ]
}
# This section is for creating your AAA vServer.  Most should be non-addressable.  You only need an IP on the vServer if it will be accessed directly as an IDP.
variable "AAA_vservers" {
  type = list(object({
    name  = string
    ipv46 = string #If creating a non-addressable AAA vserver leave blank
    port  = string #If creating a non-addressable AAA vserver use 0 for port.
  }))
  default = [
    #{ name = "", ipv46 = "", port = ""},
  ]
}
# This section is for binding Authentication Policies to the appropriate AAA vServer
variable "AAA_User_Bind" {
  type = list(object({
    name     = string # This is the name of the Vserver the policy is bound too
    policy   = string
    priority = string
  }))
  default = [
    #{ name = "", policy = "", priority = ""},
  ]
}
# These are the Profiles that are created to point to point various AAA vServers to Citrix Gateways
variable "AuthenticationProfile" {
  type = list(object({
    name        = string
    authnvsname = string
  }))
  default = [
    #{ name = "", authnvsname = ""},
  ]
}
# ----------------------------------------------------
# CERTIFICATES
# ----------------------------------------------------
# This section denotes what Certificate and Key files are stored on the system to upload to the NetScaler.  For security you should restrict the replication of this project,
# or remove the files after the project has been processed.
variable "CertandKeyUpload" {
  type = list(object({
    filename    = string # Name of the file to be created under the nsconfig/ssl directory.
    filecontent = string # Place the name of the file to upload after the ./Certificates/ entry.
  }))
  default = [
    #{ filename = "", filecontent ="./Certificates/"},
  ]
}
# This section is for creating Certificate definitions on the NetScaler from the files that were just uploaded
# also define what certificates need to be linked for this certificate to work correctly.  
variable "Certificates" {
  type = list(object({
    certkey         = string
    cert            = string
    key             = string
    linkcertkeyname = string
  }))
  default = [
    #{ certkey = "", cert = "", key = "", linkcertkeyname = ""},
  ]
}
# This section is for binding SSL Certificates to various vServers on the NetScaler
variable "SSLbinding" {
  type = list(object({
    order       = string # Required to prevent name collisions with SNI Certs Just create a unique ascending number for each entry.
    vservername = string
    certkeyname = string
    snicert     = string # Must be either true or false
  }))
  default = [
    #{ order = "",vservername = "", certkeyname = "", snicert = ""},
  ]
}
# ----------------------------------------------------
# CITRIX GATEWAY
# ----------------------------------------------------
# This section defines GLOBALLY the STA certificates that will be used for the NetScaler Gateway
# STAs need to match between the NetScaler and the STorefront servers.
variable "STA_bind" {
  type = list(object({
    staserver = string #Must be http:// or https:// and either IP or FQDN that is NetScaler accessible
  }))
  default = [
    #{ staserver = ""},
  ]
}
# This section defines the Session Actions.  Defaults are set on the VPNGateway.tf file, and utilize UPN for user login to pass the necessary domain in the request.
variable "VPN_SessionActions" {
  type = list(object({
    name   = string
    wihome = string
  }))
  default = [
    #{ name = "", wihome = ""},
  ]
}
# This section defines the Session Policies that when evaluated as true, will process the approprate Session Actions
# The default rule for a Native Receiver or Citrix Workspace would be "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\")"
# The default rule for a Web page receiver would be "HTTP.REQ.HEADER(\"User-Agent\").CONTAINS(\"CitrixReceiver\").NOT"
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
# This section defines the vServer for Citrix Gateway connections.  
# Leaving the ipv46 box blank will create a non-addressable Citrix Gateway, which you can only use on 1 Content Switch for the entire NetScaler
# Most Citrix Gateways will have an IP applied to it, and will require TCP/UDP 443 applied to it.
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
  ]
}
# This section will bind the above created Session Policies to the Citrix Gateway Virtual Servers.
variable "VPN_SessionBind" {
  type = list(object({
    name     = string
    policy   = string
    priority = string
  }))
  default = [
    #{ name = "", policy = "", priority = ""},
  ]
}
# ----------------------------------------------------
# GSLB AND ADNS
# ----------------------------------------------------
# GSLB utilizes ADNS for routing sites to ips on a decision based process
# The following configuration is the basic configuration needed to ensure GSLB works correctly
# This is where you bind ADNS services for TCP and UDP to the SNIP that will be used for ADNS and GSLB
# This should be the default SNIP that the NetScaler uses with the Default Gateway to ensure proper send and receive of traffic
# ----------------------------------------------------
# ADNS Configuration
# ----------------------------------------------------
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
# This is where you define the Start of Authority record for the NetScaler to own the proper DNS location
variable "SOA" {
  type = list(object({
    domain       = string
    originserver = string
    contact      = string
  }))
  default = [
    #{ domain = "", originserver = "", contact = ""},
  ]
}
# This is where you define the Root Records for DNS
variable "RootRecord" {
  type = list(object({
    domain     = string
    nameserver = string
  }))
  default = [
    #{ domain = "", nameserver = ""},
  ]
}
# This is where you define the Zone that the NetScaler will hold for GSLB.  All DNS requests for that zone will be sent to the NetScalers for processing
variable "dnszone" {
  type = list(object({
    zonename = string
  }))
  default = [
    #{ zonename = ""},
  ]
}
# ----------------------------------------------------
# GSLB CONFIGURATION
# ----------------------------------------------------
# This section is where you define the sites for all your Remote and Local sites.  This should be tied to the same SNIP as the ADNS
variable "GSLB_Site" {
  type = list(object({
    sitename      = string
    siteipaddress = string
    publicip      = string
    sitetype      = string
  }))
  default = [
    #{ sitename = "", siteipaddress = "", publicip = "", sitetype = ""},
  ]
}
# This section is where you define the Services for all your GSLB Sites.  If you setup GSLB replication you only have to define these on the primary site.
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
# This section is where you created GSLB vServers that serve content for both of your datacenters
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
  ]
}
# This section is where you create GSLB vServers that are served from just the DC1 Datacenter.
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
  ]
}
# This section is where you create GSLB vServers that are served from just the DC2 Datacenter.
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
# When using GSLB and DNS for both internal and external resources you will need to teach your NetScalers what resources are internal
# This section is where you create the Views that will be used to send traffic to the appropriate IP Address 
variable "GSLB_DNSView" {
  type = list(object({
    viewname = string
  }))
  default = [
    #{ viewname = ""},
  ]
}
# This section is where you create DNS actions that will link IP Subnets to the views created previously
variable "DNSAction" {
  type = list(object({
    actionname = string
    actiontype = string
    viewname   = string
  }))
  default = [
    #{ actionname = "",actiontype = "", viewname = ""},
  ]
}
# This section is where you define the subnet rules that will apply to the Actions listed above
variable "DNSPolicy" {
  type = list(object({
    name       = string
    rule       = string
    actionname = string
  }))
  default = [
    #{name = "",rule = "", actionname = ""},
  ]
}
# This section binds the DNS policies globally to tag traffic from specified subnets to the necessary Views created previously
variable "DNSPolicy_Binding" {
  type = list(object({
    policyname = string
    priority   = string
  }))
  default = [
    #{policyname = "",priority = ""},        
  ]
}
# This section binds the internal ip address to match the DNS view created previously.  When clients reference from externally, they get the external address,
# when users access from the internal subnet they get the internal ip address.
variable "GSLB_DNSView_Binding" {
  type = list(object({
    servicename = string
    viewname    = string
    viewip      = string
  }))
  default = [
    #{servicename = "", viewname = "", viewip =""},
  ]
}
