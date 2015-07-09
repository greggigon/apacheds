FROM centos:7

MAINTAINER "Greg Gigon @ https://github.com/greggigon"

ADD apacheds.sh /usr/local/bin/	

RUN yum -y update && yum -y install java-1.7.0-openjdk openldap-clients && curl -s http://mirrors.ukfast.co.uk/sites/ftp.apache.org//directory/apacheds/dist/2.0.0-M20/apacheds-2.0.0-M20-x86_64.rpm -o /tmp/apacheds.rpm \
	&& yum -y localinstall /tmp/apacheds.rpm && rm -rf /tmp/apacheds.rpm && mkdir -p /data && mkdir -p /bootstrap \
	&& ln -s /var/lib/apacheds-2.0.0_M20/default/partitions /data && chmod +x /usr/local/bin/apacheds.sh \
	&& chown -R apacheds.apacheds /data && chown -R apacheds.apacheds /var/lib/apacheds-2.0.0_M20/default/partitions


VOLUME /data
VOLUME /bootstrap

ENTRYPOINT /usr/local/bin/apacheds.sh

EXPOSE 10389
EXPOSE 389