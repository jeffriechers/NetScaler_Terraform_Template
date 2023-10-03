# Content Switches Virtual Servers
resource "citrixadc_csvserver" "CSW_vservers" {
  for_each = { for u in var.CSW_vservers : u.name => u}
        name        = each.key
        servicetype = each.value.servicetype
        ipv46 = each.value.ipv46
        port = each.value.port
        sslprofile = each.value.sslprofile
        depends_on = [citrixadc_sslprofile.Secure_sslprofile]
  }
#Content Switching Policies
resource "citrixadc_cspolicy" "CSW_cspolicy" {
  for_each = { for u in var.CSW_cspolicy : u.policyname => u}
  policyname      = each.key
  rule            = each.value.rule
  depends_on = [ citrixadc_lbvserver.lb_vservers]
}
#Load Balancer bindings
resource "citrixadc_csvserver_cspolicy_binding" "CSW_policybind" {
  for_each = { for u in var.CSW_policybind : u.policyname => u}
    name = each.value.name
    policyname = each.key
    priority = each.value.priority
    targetlbvserver = each.value.targetlbvserver
    depends_on = [ citrixadc_lbvserver.lb_vservers, citrixadc_csvserver.CSW_vservers ]
}
