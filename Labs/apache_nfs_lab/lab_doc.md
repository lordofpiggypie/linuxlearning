Apache Web Server and NFS Interaction Lab:

Scenario:
	-Two virtual machines running RedHat 10. One server *minime* is running Apache webserver with ChatGPT Generated custom webpage. Second Server *nfs* is running an nfs server with an
	LVM that mounts to the webserver with a shared directory hosting a ChatGPT custom webpage containing lab details. The NFS mount on the Apache server needs to be an on-demand
	mount for scalability and resiliancy. HTTPS will use port 8443

Steps:

	1. Create VM minime on Hypervisor named "minime" with RHEL 10 server and install httpd
		sudo dnf -y update
		sudo dnf -y install epel-release
		sudo dnf install httpd
		sudo systemctl enable httpd
		sudo systemctl start httpd
	2. Move the httpd root directory and set up and configure HTTPS with SSL
		sudo -u apache mkdir -p /srv/testste
		sudo vim /etc/httpd/conf/httpd.conf
		DocumentRoot "/srv/testsite"
		Change directory files to /srv/testsite location
		sudo systemctl daemon-reload
		sudo systemctl enable httpd
		sudo systemctl start httpd
		sudo firewall-cmd --permanent --add-service=https
		sudo firewall-cmd --zone=public --permanent --add-port=2049/tcp
		sudo firewall-cmd --reload
		sudo dnf install mod_ssl
		sudo systemctl restart httpd
		sudo openssl req -x509 -nodes -days 365 \
   		 -newkey rsa:4096 \
   		 -keyout /etc/pki/tls/private/selfsigned.key \
   		 -out /etc/pki/tls/certs/selfsigned.crt
		sudo chmod 600 /etc/pki/tls/private/selfsigned.key
		sudo vim /etc/httpd/conf.d/ssl.conf
			Listen 8443
			<VirtualHost *:8443>
   				DocumentRoot "/srv/testsite"
    				ServerName minime

    				SSLEngine on
    				SSLCertificateFile /etc/pki/tls/certs/selfsigned.crt
    				SSLCertificateKeyFile /etc/pki/tls/private/selfsigned.key

    				<Directory "/srv/testsite">
        				AllowOverride None
        				Require all granted
    				</Directory>

    				ErrorLog logs/ssl_error_log
    				TransferLog logs/ssl_access_log
			</VirtualHost>
		sudo systemctl restart httpd
		We will set up a file share directory in httpd after the NFS Server
	3. Set a static IP for minime
		sudo nmcli connection modify enp0s3 ipv4.addresses 192.168.1.253/24 
		sudo nmcli connection modify enp0s3 ipv4.gateway 192.168.1.254 
		sudo nmcli connection modify enp0s3 ipv4.dns "8.8.8.8 8.8.4.4" 
		sudo nmcli connection modify enp0s3 ipv4.method manual 
		sudo nmcli connection down enp0s3 && sudo nmcli connection up enp0s3
	4. Name the server
		hostnamectl hostname minime
	5. Create VM nfs on Hypervisor with RHEL 10 and install nfs
		sudo dnf -y update
		sudo dnf install epel-release
		sudo dnf install nfs-utils
		sudo systemctl enable --now nfs-server
	6. Configure shared directory
		sudo mkdir -p /srv/nfs/webdata
		sudo chmod 770 /srv/nfs/webdata
		sudo chown 48:48 /srv/nfs/webdata
	7. Configure nfs exports
		/srv/nfs/webdata  VM1_IP_ADDRESS(rw,sync,no_root_squash)
		sudo exportfs -arv
	8. Set Rich firewall rules
		sudo firewall-cmd --permanent --zone=public \
 		  --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="nfs" accept'
		sudo firewall-cmd --permanent --zone=public \
	 	  --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="rpc-bind" accept'
		sudo firewall-cmd --permanent --zone=public \
		  --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="mountd" accept'
	0. Set static IP for "nfs"
		sudo nmcli connection modify enp0s3 ipv4.addresses 192.168.1.253/24
                sudo nmcli connection modify enp0s3 ipv4.gateway 192.168.1.254
                sudo nmcli connection modify enp0s3 ipv4.dns "8.8.8.8 8.8.4.4"
                sudo nmcli connection modify enp0s3 ipv4.method manual
                sudo nmcli connection down enp0s3 && sudo nmcli connection up enp0s3
		sudo hostnamectl hostname nfs
	10. Configure "minime" for NFS mount
		sudo dnf install -y httpd
		sudo systemctl enable --now httpd
		sudo vim /etc/httpd/conf.d/ssl.conf
			<Directory "/srv/testsite/shared">
				Options Indexes FollowSymLinks
    				AllowOverride None
    				Require all granted
			</Directory>
		sudo vim /etc/fstab
		192.168.1.232:/srv/nfs/webdata /srv/testsite/shared nfs defaults,_netdev,x-systemd.automount  0 0
		sudo mkdir -p /srv/testsite/shared
		sudo chown -R apache:apache /srv/testside/shared
		sudo semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html(/.*)?'
		sudo restorecon -Rv /srv/testsite/
	11. Set SELinux exception on "minime" so that httpd can reach nfs resources (Not best practice I dont think)
		sudo setsebool -P httpd_use_nfs 1
		sudo systemctl reload httpd
	12. Mount the share on "minime"
		sudo mount -a
	13. Check mount status
		mount | grep nfs
		showmount -e 192.168.1.232
		df -h | grep nfs
	14. Add ChatGPT HTTP art to the httpd directories
		on "minime" index.html @ /srv/testsite
		on "nfs" lab_diagram.html @ /srv/nfs/webdata

