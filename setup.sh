# Update System to latest binaries.
apt-get -y  update
apt-get -y  upgrade

# Default Raspian does not have all locales
# Causes Perl environment errors during apt process.
#
# This takes a while to run, so hopefully we can
# do it once and keep in base image. Uncomment to setup locales
#apt-get -y  install locales
#dpkg-reconfigure locales

# Install packages for ZTP Process.
# Expect some of these to fail startup process.
apt-get -y  install isc-dhcp-server
apt-get -y  install nginx-full
apt-get -y  install atftpd
apt-get -y  install vsftpd
apt-get -y  install git

# Install generic network tools
apt-get -y  install screen
apt-get -y  install mtr
apt-get -y  install nmap
apt-get -y  install traceroute
apt-get -y  install whois
apt-get -y  install tcpdump
apt-get -y  install dhcpdump

# Create Base directory structure.
# This will be moved to a git repo before final
groupadd ztp
usermod -a -G ztp pi

mkdir /ztp
mkdir /ztp/etc
mkdir /ztp/files
mkdir /ztp/utils
chgrp -R ztp /ztp
chmod -R 775 /ztp/

# Insert step here to copy files from remote repo

# Set vsftpd user homedir to /ztp/files
usermod -d /ztp/files ftp
rm -rf /srv/ftp
ln -s /ztp/files /srv/ftp
rm -rf /etc/vsftpd.conf
ln -s /ztp/etc/vsftpd.conf /etc/vsftpd.conf
/etc/init.d/vsftpd restart

# Set vsftpd user homedir to /ztp/files
rm -rf /etc/default/atftpd
rm -rf /srv/tftp
ln -s /ztp/files /srv/tftp
ln -s /ztp/etc/atftpd /etc/default/atftpd
update-rc.d atftpd defaults
touch /var/log/atftpd.log
chown nobody.nogroup /var/log/atftpd.log
/etc/init.d/atftpd restart


# Set ISC to source files from /ztp/etc which sets DHCP to eth1 and default config
rm -rf /etc/default/isc-dhcp-server
rm -rf /etc/dhcp/dhcpd.conf
ln -s /ztp/etc/isc-dhcp-server /etc/default/isc-dhcp-server
ln -s /ztp/etc/dhcpd.conf /etc/dhcp/dhcpd.conf
update-rc.d isc-dhcp-server defaults
/etc/init.d/isc-dhcp-server restart

# Make Symbolic link for nginx webroot to point to /ztp/files
rm -rf /usr/share/nginx/www
ln -s /ztp/files /usr/share/nginx/www
update-rc.d nginx defaults
/etc/init.d/nginx restart

# Repoint rsyslog file + enable network syslog
rm -rf /etc/rsyslog.conf
ln -s /ztp/etc/rsyslog.conf /etc/rsyslog.conf
ln -s /ztp/etc/rsyslogd-ztp /etc/rsyslog.d/ztp_log.conf
ln -s /ztp/etc/logrotate-ztp /etc/logrotate.d/ztp
/etc/init.d/rsyslog restart
