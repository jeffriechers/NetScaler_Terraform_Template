# Management PBRs for management network
#  resource "citrixadc_nspbr" "MGMT_nspbr" {
#   name       = "Management"
#   action     = "ALLOW"
#   nexthop    = "true"
#   nexthopval = "10.0.0.1"
#   srcip = true
#   srcipval = "10.0.0.3-10.0.0.5" #HA Pair NSIP and SNIP should be contiguous
#   srcipop = "="
#   destip = true
#   destipval = "0.0.0.0-255.255.255.255" #If management network should only respond to select subnets, shrink this range
#   destipop = "="
#   state = "ENABLED"
# } 
# resource "citrixadc_nspbrs" "Apply_PBRs" {
#   action = "apply"
# }

resource "citrixadc_route" "StaticRoutes" {
    for_each = { for u in var.static_routes : u.network => u}
    network    = each.key
    netmask    = each.value.netmask
    gateway    = each.value.gateway
    advertise  = "DISABLED"
}
# Netscaler Modes and Features
resource "citrixadc_nsmode" "nsmode" {
    fr = true
    edge = true
    l3 = true
    mbf = true
    usnip = true
    pmtud = true
}
resource "citrixadc_nsfeature" "nsfeature" {
    lb = true
    cs = true
    ssl = true
    ic = true
    sslvpn = true
    aaa = true
    rewrite = true
    cmp = true
    wl = true
    appfw = true
    responder = true
    appflow = true
    ch = false
    contentaccelerator = true
    rep = true
    bot = true
    gslb = true
    rdpproxy = true
    adaptivetcp = true
    hdosp = true
    feo = true
}
#Netscaler System Configuration
resource "citrixadc_nsvpxparam" "ESXI_vpxparam" {
    cpuyield = "YES"
}
resource "citrixadc_icaparameter" "HA_icaparameter" {
  edtpmtuddf           = "ENABLED"
  edtpmtuddftimeout    = 100
  l7latencyfrequency   = 0
  enablesronhafailover = "YES"
}
resource "citrixadc_locationparameter" "NS_LocationParameter" {
  matchwildcardtoany = "YES"
}
resource "citrixadc_locationfile" "NS_LocationFile" {
  locationfile = "/var/netscaler/inbuilt_db/Citrix_Netscaler_InBuilt_GeoIP_DB_IPv4"
  format       = "netscaler"
}
#Save NS Config
resource "citrixadc_nsconfig_save" "tf_ns_save" {
    all        = true
    timestamp = timestamp()
    depends_on = [ citrixadc_sslcertkey.Certificates, citrixadc_lbvserver.lb_vservers, citrixadc_sslvserver_sslcertkey_binding.SSLbinding,citrixadc_gslbvserver.GSLB_vserver, citrixadc_sslvserver.vpn_sslvserver, citrixadc_csvserver.CSW_vservers ]
}