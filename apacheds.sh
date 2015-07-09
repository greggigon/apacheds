#!/bin/bash
function wait_for_ldap {
	echo "Waiting for LDAP to be available "
	c=0

    ldapsearch -h localhost -p 10389 -D 'uid=admin,ou=system' -w secret ou=system;
    
    while [ $? -ne 0 ]; do
        echo "LDAP not up yet... retrying... ($c/20)"
        sleep 4
 		
 		if [ $c -eq 20 ]; then
 			echo "TROUBLE!!! After [${c}] retries LDAP is still dead :("
 			exit 2
 		fi
 		c=$((c+1))
    	
    	ldapsearch -h localhost -p 10389 -D 'uid=admin,ou=system' -w secret ou=system;
    done 
}

if [ -f /bootstrap/config.ldif ]; then
	echo "Using config file from /bootstrap/config.ldif"
	rm -rf /var/lib/apacheds-2.0.0_M20/default/conf/config.ldif

	cp /bootstrap/config.ldif /var/lib/apacheds-2.0.0_M20/default/conf/
	chown apacheds.apacheds /var/lib/apacheds-2.0.0_M20/default/conf/config.ldif
fi

if [ -d /bootstrap/schema ]; then
	echo "Using schema from /bootstrap/schema directory"
	rm -rf /var/lib/apacheds-2.0.0_M20/default/partitions/schema 

	cp -R /bootstrap/schema/ /var/lib/apacheds-2.0.0_M20/default/partitions/
	chown -R apacheds.apacheds /var/lib/apacheds-2.0.0_M20/default/partitions/
fi

/opt/apacheds-2.0.0_M20/bin/apacheds start default

wait_for_ldap


if [ -n "${BOOTSTRAP_FILE}" ]; then
	echo "Bootstraping Apache DS with Data from ${BOOTSTRAP_FILE}"
	
	ldapmodify -h localhost -p 10389 -D 'uid=admin,ou=system' -w secret -f $BOOTSTRAP_FILE
fi

trap "echo 'Stoping Apache DS';/opt/apacheds-2.0.0_M20/bin/apacheds stop default;exit 0" SIGTERM SIGKILL

while true
do
  tail -f /dev/null & wait ${!}
done