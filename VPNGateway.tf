# Citrix Gateway
resource "citrixadc_vpnglobal_staserver_binding" "STA_bind" {
  for_each = { for u in var.STA_bind : u.staserver => u}
  staserver      = each.key
  staaddresstype = "IPV4"
}
resource "citrixadc_vpnsessionaction" "VPN_SessionActions" {
  for_each = { for u in var.VPN_SessionActions : u.name => u}
    name                       = each.key
    defaultauthorizationaction = "ALLOW"
    sso                        = "ON"
    icaproxy                   = "ON"
    wihome                     = each.value.wihome
}
resource "citrixadc_vpnsessionpolicy" "VPN_SessionPolicy" {
  for_each = { for u in var.VPN_SessionPolicy : u.name => u}
    name   = each.key
    rule   = each.value.rule
    action = each.value.action
    depends_on = [ citrixadc_vpnsessionaction.VPN_SessionActions ]
}
resource "citrixadc_vpnvserver" "VPN_Vserver" {
  for_each = { for u in var.VPN_Vserver : u.name => u}
    name = each.key
    servicetype    = "SSL"
    dtls           = "ON"
    authnprofile = each.value.authnprofile
    icaonly = each.value.icaonly
    ipv46 = each.value.ipv46
    port = each.value.port
    depends_on = [ citrixadc_authenticationauthnprofile.AuthenticationProfile ]
}
resource "citrixadc_vpnvserver_vpnsessionpolicy_binding" "VPN_SessionBind" {
  for_each = { for u in var.VPN_SessionBind : u.policy => u}
    name = each.value.name
    policy = each.key
    priority = each.value.priority
    depends_on = [ citrixadc_vpnvserver.VPN_Vserver, citrixadc_vpnsessionpolicy.VPN_SessionPolicy ]
}
resource "citrixadc_sslvserver" "vpn_sslvserver" {
  for_each = { for u in var.VPN_Vserver : u.name => u}
    vservername = each.key
    sslprofile = "Secure_sslprofile"
    depends_on = [ citrixadc_vpnvserver.VPN_Vserver, citrixadc_sslprofile.Secure_sslprofile ]
}