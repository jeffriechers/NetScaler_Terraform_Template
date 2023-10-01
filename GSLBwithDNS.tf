#DNS Configuration
#ADNS
resource "citrixadc_service" "ADNS_Services" {
  for_each = { for u in var.ADNS_Services : u.name => u}
    name        = each.key
    port        = 53
    ip          = each.value.ip
    servicetype = each.value.servicetype
}
#DNS Records
#SOA
resource "citrixadc_dnssoarec" "SOA" {
  for_each = { for u in var.SOA : u.domain => u}
    domain =  each.key
    originserver  = each.value.originserver
    contact =  each.value.contact
    expire = 3600
    refresh = 3600
}
#Name Server Records
resource "citrixadc_dnsnsrec" "RootRecord" {
    for_each = { for u in var.RootRecord : u.nameserver => u}
    domain = each.value.domain
    nameserver = each.key
}

#Zones
resource "citrixadc_dnszone" "dnszone" {
    for_each = { for u in var.dnszone : u.zonename => u}
    zonename = each.key
    proxymode     = "NO"
    depends_on = [ citrixadc_dnssoarec.SOA, citrixadc_dnsnsrec.RootRecord ]
}

#---------------
#GSLB Configuration
#GSLB Parameters
  resource "citrixadc_gslbparameter" "gslbparameter" {
  automaticconfigsync = "ENABLED"
}
#GSLB Sites
resource "citrixadc_gslbsite" "GSLB_Site" {
  for_each = { for u in var.GSLB_Site : u.sitename=> u}
      sitename        = each.key
      siteipaddress   = each.value.siteipaddress
      publicip = each.value.publicip
      sitetype = each.value.sitetype
}
resource "citrixadc_gslbservice" "GSLB_Service" {
  for_each = { for u in var.GSLB_Service : u.servicename=> u}
    ip          = each.value.ip
    port        = each.value.port
    servicename = each.key
    servicetype = each.value.servicetype
    sitename    = each.value.sitename
    depends_on = [ citrixadc_gslbsite.GSLB_Site, citrixadc_csvserver.CSW_vservers, citrixadc_lbvserver.lb_vservers]
}
resource "citrixadc_gslbvserver" "GSLB_vserver" {
  for_each = { for u in var.GSLB_vserver : u.name=> u}
      dnsrecordtype = "A"
      name          = each.key
      servicetype   = each.value.servicetype
        domain {
          domainname = each.value.domainname
          ttl        = "60"
        }
        service {
          servicename = each.value.DC1servicename
          weight      = each.value.DC1weight
        }
        service {
          servicename =  each.value.DC2servicename
          weight      =  each.value.DC2weight
        }
    depends_on = [ citrixadc_gslbsite.GSLB_Site, citrixadc_gslbservice.GSLB_Service ]
}

