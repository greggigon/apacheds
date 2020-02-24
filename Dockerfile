FROM centos:7

MAINTAINER "Apirath Promyan @ https://github.com/p-apirath/apacheds"

ENV JDK_VERSION=1.8.0 \
    APACHEDS_VERSION=2.0.0.AM25
    
ADD apacheds.sh /usr/local/bin/	
RUN useradd apacheds

RUN yum -y update \
    && yum -y install java-${JDK_VERSION}-openjdk openldap-clients \
    && curl -s https://downloads.apache.org/directory/apacheds/dist/${APACHEDS_VERSION}/apacheds-${APACHEDS_VERSION}-x86_64.rpm -o /tmp/apacheds.rpm \
    && yum -y localinstall /tmp/apacheds.rpm \
    && rm -rf /tmp/apacheds.rpm
    
RUN mkdir -p /bootstrap \
    && ln -s /var/lib/apacheds-${APACHEDS_VERSION}/default/partitions /data \
    && chmod +x /usr/local/bin/apacheds.sh \
    && chown -R apacheds.apacheds /data \
    && chown -R apacheds.apacheds /var/lib/apacheds-${APACHEDS_VERSION}/default/partitions

VOLUME /data
VOLUME /bootstrap

ENTRYPOINT /usr/local/bin/apacheds.sh

EXPOSE 10389
EXPOSE 389
