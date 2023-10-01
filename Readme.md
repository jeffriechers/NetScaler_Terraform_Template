# Welcome to the Jeff Riechers complete best practice NetScaler Template.  (Complete is a relative term)

If you run into any issues with this template, please notify me with the error, sanitized configuration, and when it failed for you.

If you have any recommendations or requests for this project, please let me know.

## PROJECT OVERVIEW
This template allows you to deploy NetScaler configuration for Load Balancing, Content Switching, AAA VServers, VPN Gateway, GSLB configuration and more.  

The only configuration files you need to modify are provider.tf and variables.tf, so no need to dig into Terraform provider code.  Just pop in the variables for your environment, and get building.

In Provider.TF enter in the NSIP address for your NetScaler, and the username if you don't wish to use nsroot.

In Variables.TF each section has an example line that you can copy and paste into the default section to populate all the necessary settings.  Whenever possible defaults are written directly.  If you need to modify any of the defaults you can modify the necessary .TF file to change the defaults into variables.  The code for almost every section is designed to be easy to read, so if you modify one segment, the others are modified in the same method.

When using GSLB, this config will setup replication.  So on the secondary datacenters you only need to configure GSLB sites.  Any GSLB services and virtual servers will be replicated from the primary site to the secondary site. You currently must enable Telnet/SSH access on the SNIP for GSLB sync manually for sync to occur.  With proper NAT and ACL configuration only the NetScalers will be allowed access to that sync port and SNIP.

## VPX INITIAL INSTALLATION GUIDE
1. Deploy VPX with proper Interfaces and Networks
    - if installing in ESXi, vmxnet3 is recommended for the network adapter
2. From VPX console set Managment IP, Subnet Mask, and default Gateway
3. From Browser GUI - Set NSRoot default password
4. In the initial setup wizard setup the following configuration
    - set the Management SNIP
    - Set Hostname, DNS IP, Timezone, NTP server, and ADM Service settings 
    - Skip the license configuration, as this requires a reboot for the new nsroot password defined in step 3
5. Reboot
6. From Browser Gui install your NetScaler license
7. If using a custom local account instead of nsroot, create it now.
8. Save config and reboot.

At this point your machine is ready for terraforming.  Now would be a time to Snapshot the machine if you want to test deploying your configuration, and rolling back to a known good state.  

If you do want to rollback in this method, make sure to delete your terraform.tfstate and any tfstate.backups in your folder so that it runs as a new build on that new snapshot.

## TERRAFORM CONFIGURATION GUIDE
1. Copy certificate and key files to the ./Certificates directory.
    - PEM file format is recommended.
    - If you are storing your directory in a public Github repository, make sure to delete these certificates after they have been imported.
2. Modify the provider.tf with your NetScaler access information.
3. Modify the variables.tf for your environment.
4. Run a terraform -plan from your project directory
    - It will prompt for the password for the NetScaler on every plan and apply run.
    - It will prompt for the LDAP password for the ldap service account on every plan and apply run.
5. If the configuration looks good, run a terraform -apply.
    - Besides login prompts the apply will ask you to confirm that you are modifying configuration
6. When you run the apply it will save the configuration at the end of the run.  However, if in your environment you see a configuration being deployed after the save command executes, let me know what the process was so I can modify the configuration.
7. After your configuration is deployed, you now can setup High Availability for your NetScaler pair.  Make sure to setup the STAYPRIMARY and STAYSECONDARY on the nodes before linking them to keep the unit with the config from being overwritten with null data.

## KNOWN ISSUES

If you do a terraform apply -destroy, the Diffie Hellman key is not removed, so you need to manually delete the file from /nsconfig/ssl/SecureDH.  You can do this via putty, winscp, or from the browser gui under Trafic Management->SSL->Manage Certificates / Keys / CSRs

Load Balancer Services cannot be bound with the new Order setting.  I have a ticket open with the owner of the CitrixADC provider, and they are adding this feature.  For now you can modify the binding manually from the gui.

## TO DO LIST

- Create a process to remove the Diffie-Hellman key when you set the variable
- Setup a method to deploy to multiple datacenters at the same time for GSLB configurations
    - Currently you need to clone the Directory and configure it seperately
- Change some of the initial prompting, so that if you aren't using LDAP it won't prompt
- Add additional authentication methods
    - Currently just LDAP is support
    - SAML configuration needed
    - Radius configuration needed
    - Certificate based authentication configuration needed
    - nFactor login tree for multi-authentication needed
- Programmatically setup HA configuration.
- Setting up GSLB SNIP to get management access for config sync
