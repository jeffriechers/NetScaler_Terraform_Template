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
    - Skip the license configuration, as this requires a reboot for the new nsroot password defined in step 3 (This has been fixed in 14.1 and it will reboot before the license installation process)
5. Reboot
6. From Browser Gui install your NetScaler license
7. If using a custom local account instead of nsroot, create it now.
8. Save config and reboot.

At this point your machine is ready for terraforming.  Now would be a time to Snapshot the machine if you want to test deploying your configuration, and rolling back to a known good state.  

If you do want to rollback in this method, make sure to delete your terraform.tfstate and any tfstate.backups in your folder so that it runs as a new build on that new snapshot.

## TERRAFORM CONFIGURATION GUIDE
Clone this repository locally.  I recommend Visual Studio Code with the Terraform Extension installed for proper syntax verification.
1. Copy certificate and key files to a ./Certificates directory in your project.
    - PEM file format is recommended.
    - If you are storing your directory in a public Github repository, make sure to delete these certificates after they have been imported.
2. Modify the provider.tf with your NetScaler access information.
3. Modify the variables.tf for your environment.
4. Run a terraform -init so that the latest CitrixADC terraform provider gets installed.
5. Run a terraform -plan from your project directory
    - It will prompt for the password for the NetScaler on every plan and apply run.
    - It will prompt for the LDAP password for the ldap service account on every plan and apply run.
6. If the configuration looks good, run a terraform -apply.
    - Besides login prompts the apply will ask you to confirm that you are modifying configuration
7. When you run the apply it will save the configuration at the end of the run.  However, if in your environment you see a configuration being deployed after the save command executes, let me know what the process was so I can modify the configuration.
8. After your configuration is deployed, you now can setup High Availability for your NetScaler pair.  Make sure to setup the STAYPRIMARY and STAYSECONDARY on the nodes before linking them to keep the unit with the config from being overwritten with null data.
9. Occassionally Terraform will add entries out of order from my testing.  So if you get any errors about missing items, just rerun the Apply and it should work.  If it continues to fail, check your syntax.
10. With the SSH engine I use to create the rc.netscaler file for fixing SAML subject issues with Azure it will give a timeout error message.  But do not worry, the system has created the file and set the appropriate permissions.  I have a support request in with the provider for a potential fix.  If you are modifying the rc.netscaler, make sure to reboot the NetScaler to get those settigs to take effect.

## WHATS NEW
11-06-2023
- Added OAuth configuration for Gmail.com authenticaion
- Created an nfactor workflow for selecting an authentication method.  This is for demo labs to try different authentication methods, and as an example for building your own nFactor workflows.
- Added ssh provider for executing commands directly on the NetScaler.  This is commented out by default in the provider.tf and ssh.tf.
- Added additional documentation in the variables.tf for better explanation of sections and variables

11-01-2023
- Added SAML configuration that has been tested with Azure AD
- Modified GSLB configuration for environments that only host items in a single DC

10-13-2023
- Added DNS Views for shared GSLB for inside and outside on the same NetScaler

10-12-2023
- Added Content Switch Binding of NetScaler VPN Gateway

10-10-2023
- Added Message Actions and Responder Policies for Blocking non-US or non-US and non-Canada public IPs for virtual servers
- Bind Responder policy to public VIP to protect access

10-3-2023
- Variables.example has been uploaded from my test environment if you have questions as to what values would look like.
- Added an order field for Certificate Binding to prevent collisions with SNI binding multiple certs to a single entity.
- More Documentation added to .TF files for better clarification on format and function.

## KNOWN ISSUES

If you do a terraform apply -destroy, the Diffie Hellman key is not removed, so you need to manually delete the file from /nsconfig/ssl/SecureDH.  You can do this via putty, winscp, or from the browser gui under Trafic Management->SSL->Manage Certificates / Keys / CSRs

GSLB Services cannot be bound with the new Order setting.  I have a ticket open with the owner of the CitrixADC provider, and they are adding this feature.  For now you can modify the binding manually from the gui.  1.37.0 provides support for Order binding on regular load balancing vservers.


## TO DO LIST

- Setup a method to deploy to multiple datacenters at the same time for GSLB configurations
    - Currently you need to clone the Directory and configure it seperately
- Change some of the initial prompting, so that if you aren't using LDAP it won't prompt
- Add additional authentication methods
    - Radius configuration needed
    - Certificate based authentication configuration needed
- Programmatically setup HA configuration.
- Setting up GSLB SNIP to get management access for config sync
