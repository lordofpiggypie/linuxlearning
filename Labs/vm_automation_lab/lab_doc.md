Automate startup of VMs on boot; Shutdown script

Scenario:
	You have two VMs in a lab environment that need to start up automatically when the system boots. VBoxManage Autostart is not allowed. VMs are owned by user piggypie. One VM runs a
	web server with an NFS mount on it, the other server is the NFS server. On boot the web server needs to wait for the nfs server to boot before booting and on shutdown the nfs
	server needs to wait on the web server to shutdown before it does to avoid mount errors.

Steps:	
	1.
