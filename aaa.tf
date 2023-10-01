# Create NetScaler local admin group for LDAP group binding
resource "citrixadc_systemgroup" "NetScaler_Admins_systemgroup" {
  groupname = "NetScaler_Admins"
  cmdpolicybinding { 
    policyname = "superuser"
    priority = 100
  }
}
# LDAP Actions
resource "citrixadc_authenticationldapaction" "ldap_action" {
    for_each = { for u in var.ldap_action : u.name => u}
      name = each.key
      serverip   = each.value.serverip
      serverport = each.value.serverport
      authentication = "ENABLED"
      defaultauthenticationgroup = each.value.defaultauthenticationgroup
      ldapbase = each.value.ldapbase
      ldapbinddn = each.value.ldapbinddn
      ldapbinddnpassword =  var.ldappassword
      passwdchange = "ENABLED"
      sectype = "SSL"
      svrtype = "AD"    
      searchfilter = each.value.searchfilter
      groupattrname = "memberOf"
      ldaploginname = "samaccountname"
      ssonameattribute = "userprincipalname"
      depends_on = [ citrixadc_lbvserver.lb_vservers ]
}
# Authentication Policies
resource "citrixadc_authenticationpolicy" "Authentication_Policy" {
    for_each = { for u in var.Authentication_Policy : u.name => u}
      name = each.key
      rule   = each.value.rule
      action = each.value.action
      depends_on = [citrixadc_authenticationldapaction.ldap_action]
}
# Global Authentication Binding
resource "citrixadc_systemglobal_authenticationpolicy_binding" "Global_Auth_Binding" {
    for_each = { for u in var.Global_Auth_Binding : u.policyname => u}
      policyname     = each.key
      priority       = each.value.priority
      depends_on = [ citrixadc_authenticationpolicy.Authentication_Policy ]
}
# AAA Virtual Servers
resource "citrixadc_authenticationvserver" "AAA_vservers" {
    for_each = { for u in var.AAA_vservers : u.name => u}
      name        = each.key
      ipv46       = each.value.ipv46
      port        = each.value.port
      servicetype = "SSL"
      authentication = "ON"
      state          = "ENABLED"
}
resource "citrixadc_authenticationvserver_authenticationpolicy_binding" "AAA_User_Bind" {
    for_each = { for u in var.AAA_User_Bind : u.name => u}
      name      = each.key
      policy    = each.value.policy
      priority  = each.value.priority
      depends_on = [ citrixadc_authenticationvserver.AAA_vservers, citrixadc_authenticationpolicy.Authentication_Policy ]
}
resource "citrixadc_authenticationauthnprofile" "AuthenticationProfile" {
    for_each = { for u in var.AuthenticationProfile : u.name => u}
      name = each.key
      authnvsname = each.value.authnvsname
      depends_on = [ citrixadc_authenticationvserver.AAA_vservers ]
}
