terraform {
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
    }
  }
}
provider "citrixadc" {
  endpoint = "http://"    #Enter NSIP to NetScaler
  username = "nsroot"     # Modify this if you are using a different account than nsroot.
  password = var.password # This will prompt for the password on every run for security.
}
