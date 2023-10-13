#servers and services
resource "citrixadc_service" "lb_services" {
  for_each    = { for u in var.lb_services : u.name => u }
  name        = each.key
  port        = each.value.port
  ip          = each.value.ip
  servicetype = each.value.servicetype
  lbvserver   = each.value.lbvserver
  depends_on  = [citrixadc_lbvserver.lb_vservers]
}

#LoadBalancers
resource "citrixadc_lbvserver" "lb_vservers" {
  for_each    = { for u in var.lb_vservers : u.name => u }
  name        = each.key
  lbmethod    = each.value.lbmethod
  servicetype = each.value.servicetype
  ipv46       = each.value.ipv46
  port        = each.value.port
  sslprofile  = each.value.sslprofile
  depends_on  = [citrixadc_sslprofile.Secure_sslprofile, citrixadc_ssldhparam.SecureDH]
}
