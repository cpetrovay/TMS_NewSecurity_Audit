# Security Audit script for TMS

When upgrading TMS, new fields and hierarchies are added to the system. These need to be adjusted with Security Groups, but DBConfig only offer the option to universally apply no rights, view rights, or full rights. This script can help to identify these new hierarchies and fields, so they can be adjusted accordingly.

- Make sure that you have a Security Group with no Rights in your system before upgrading.
- Upgrade TMS.
- Run *Maintanance > Data Dictionary > Add Missing Security > Full Rights* in DBConfig.
- Get the primary key for the Security Group created or notes in Step 1.
- Run the script against that Security Group.

After making changes, you can reset your "No Rights" Security Group in DBConfig with the following:

- Open the "No Rights" Security Group
- Goto *Reset > No rights* on the File menu.
