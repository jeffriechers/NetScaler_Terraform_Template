#Responder Policies and Actions
resource "citrixadc_responderaction" "Responder_Action" {
  for_each          = { for u in var.Responder_Action : u.name => u }
  name              = each.key
  type              = each.value.type
  bypasssafetycheck = "YES"
  target            = each.value.target
  depends_on        = [citrixadc_csvserver.CSW_vservers]
}
resource "citrixadc_responderpolicy" "Responder_Policy" {
  for_each   = { for u in var.Responder_Policy : u.name => u }
  name       = each.key
  action     = each.value.action
  rule       = each.value.rule
  depends_on = [citrixadc_responderaction.Responder_Action]
}
resource "citrixadc_responderpolicy" "Drop_Non_US" {
  name       = "Drop_Non_US"
  action     = "DROP"
  rule       = "CLIENT.IP.SRC.MATCHES_LOCATION(\"*.US.*.*.*.*\").NOT"
  logaction  = "Non_US_Drop"
  depends_on = [citrixadc_auditmessageaction.NonUS_MessageAction]
}
resource "citrixadc_responderpolicy" "Drop_Non_US_and_Canada" {
  name       = "Drop_Non_US_and_Canada"
  action     = "DROP"
  rule       = "CLIENT.IP.SRC.MATCHES_LOCATION(\"*.US.*.*.*.*\").NOT && CLIENT.IP.SRC.MATCHES_LOCATION(\"*.CA.*.*.*.*\").NOT"
  logaction  = "Non_USorCanada_Drop"
  depends_on = [citrixadc_auditmessageaction.NonUSorCanada_MessageAction]
}
resource "citrixadc_csvserver_responderpolicy_binding" "CSW_responderbinding" {
  for_each               = { for u in var.CSW_responderbinding : u.name => u }
  name                   = each.key
  policyname             = each.value.policyname
  priority               = each.value.priority
  gotopriorityexpression = each.value.gotopriorityexpression
  bindpoint              = each.value.bindpoint
  depends_on             = [citrixadc_responderpolicy.Responder_Policy]
}
#Load Balancers Responder Policies
resource "citrixadc_lbvserver_responderpolicy_binding" "LB_vserver_responder_binding" {
  for_each   = { for u in var.LB_vserver_responder_binding : u.order => u }
  name       = each.value.name
  policyname = each.value.policyname
  priority   = each.value.priority
  bindpoint  = "REQUEST"
  depends_on = [citrixadc_responderpolicy.Responder_Policy]
}