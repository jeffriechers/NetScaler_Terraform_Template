resource "citrixadc_auditmessageaction" "NonUS_MessageAction" {
  name              = "Non_US_Drop"
  loglevel          = "WARNING"
  stringbuilderexpr = "CLIENT.IP.SRC + \" was dropped because they are not in the US.  They are listed as \" + CLIENT.IP.SRC.LOCATION"
  logtonewnslog     = "YES"
}
resource "citrixadc_auditmessageaction" "NonUSorCanada_MessageAction" {
  name              = "Non_USorCanada_Drop"
  loglevel          = "WARNING"
  stringbuilderexpr = "CLIENT.IP.SRC + \" was dropped because they are not in the US.  They are listed as \" + CLIENT.IP.SRC.LOCATION"
  logtonewnslog     = "YES"
}
