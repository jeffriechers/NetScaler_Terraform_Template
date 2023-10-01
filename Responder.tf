#Responder Policies and Actions
resource "citrixadc_responderaction" "Responder_Action" {
  for_each = { for u in var.Responder_Action : u.name => u}
  name    = each.key
  type    = each.value.type
  bypasssafetycheck = "YES"
  target  = each.value.target
  depends_on = [ citrixadc_csvserver.CSW_vservers]
}
resource "citrixadc_responderpolicy" "Responder_Policy" {
  for_each = { for u in var.Responder_Policy : u.name => u}
  name    = each.key
  action = each.value.action
  rule = each.value.rule
  depends_on = [citrixadc_responderaction.Responder_Action]
}
 resource "citrixadc_csvserver_responderpolicy_binding" "CSW_responderbinding" {
  for_each = { for u in var.CSW_responderbinding : u.name => u}
      name = each.key
      policyname = each.value.policyname
      priority = each.value.priority
      gotopriorityexpression = each.value.gotopriorityexpression
      bindpoint = each.value.bindpoint
      depends_on = [ citrixadc_responderpolicy.Responder_Policy ]
   }