# SSL Profiles and Certificates

resource "citrixadc_sslparameter" "defaultprofile" {
  defaultprofile = "ENABLED"
}
resource "citrixadc_sslcipher" "Securesslcipher" {
  ciphergroupname = "Securesslcipher"

  ciphersuitebinding {
    ciphername     = "TLS1.3-AES256-GCM-SHA384"
    cipherpriority = 1
  }
  ciphersuitebinding {
    ciphername     = "TLS1.3-CHACHA20-POLY1305-SHA256"
    cipherpriority = 2
  }
  ciphersuitebinding {
    ciphername     = "TLS1.3-AES128-GCM-SHA256"
    cipherpriority = 3
  }
    ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-ECDSA-AES128-GCM-SHA256"
    cipherpriority = 4
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-ECDSA-AES256-GCM-SHA384"
    cipherpriority = 5
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-ECDSA-AES128-SHA256"
    cipherpriority = 6
  }
    ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-ECDSA-AES256-SHA384"
    cipherpriority = 7
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-RSA-AES128-GCM-SHA256"
    cipherpriority = 8
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-ECDHE-RSA-AES256-GCM-SHA384"
    cipherpriority = 9
  }
    ciphersuitebinding {
    ciphername     = "TLS1.2-DHE-RSA-AES128-GCM-SHA256"
    cipherpriority = 10
  }
  ciphersuitebinding {
    ciphername     = "TLS1.2-DHE-RSA-AES256-GCM-SHA384"
    cipherpriority = 11
  }

}
resource "citrixadc_ssldhparam" "SecureDH" {
    dhfile = "/nsconfig/ssl/SecureDH"
    bits   = "2048"
    gen    = "5"
}
resource "citrixadc_sslprofile" "Secure_sslprofile" {
  depends_on = [ citrixadc_sslcipher.Securesslcipher,citrixadc_ssldhparam.SecureDH ]
  name = "Secure_sslprofile"
  ssl3   = "DISABLED"
  tls1   = "DISABLED"
  tls11   = "DISABLED"
  tls12   = "ENABLED"
  tls13   = "ENABLED"
  snienable = "ENABLED"
  dh = "ENABLED"
  dhfile = "/nsconfig/ssl/SecureDH"
  hsts = "ENABLED"
  maxage = 4294967294
  denysslreneg = "NONSECURE"
  ecccurvebindings = ["P_224","P_256","P_384","P_521"]
  cipherbindings {
    ciphername     = "Securesslcipher"
    cipherpriority = 1
}
}
resource "citrixadc_systemfile" "CertandKeyUpload" {
    for_each = { for u in var.CertandKeyUpload : u.filename => u}
    filename = each.key
    filelocation = "/nsconfig/ssl"
    filecontent = file(each.value.filecontent)
}
resource "citrixadc_sslcertkey" "Certificates" {
    for_each = { for u in var.Certificates : u.certkey => u}
      certkey = each.key
      cert = each.value.cert
      key = each.value.key
      notificationperiod = 30
      expirymonitor      = "ENABLED"
      linkcertkeyname = each.value.linkcertkeyname
      depends_on = [ citrixadc_systemfile.CertandKeyUpload ]
}
resource "citrixadc_sslvserver_sslcertkey_binding" "SSLbinding" {
    for_each = { for u in var.SSLbinding : u.vservername => u}
      vservername = each.key
      certkeyname = each.value.certkeyname
      snicert     = each.value.snicert
      depends_on = [ citrixadc_sslcertkey.Certificates, citrixadc_lbvserver.lb_vservers, citrixadc_csvserver.CSW_vservers ]
}
