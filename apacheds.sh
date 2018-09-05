#!/bin/bash

APACHEDS_INSTANCE=/var/lib/apacheds-2.0.0_M24/default

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

if [ -f /bootstrap/config.ldif ] && [ ! -f ${APACHEDS_INSTANCE}/conf/config.ldif_migrated ]; then
	echo "Using config file from /bootstrap/config.ldif"
	rm -rf ${APACHEDS_INSTANCE}/conf/config.ldif

	cp /bootstrap/config.ldif ${APACHEDS_INSTANCE}/conf/
	chown apacheds.apacheds ${APACHEDS_INSTANCE}/conf/config.ldif
fi

if [ -d /bootstrap/schema ]; then
	echo "Using schema from /bootstrap/schema directory"
	rm -rf ${APACHEDS_INSTANCE}/partitions/schema 

	cp -R /bootstrap/schema/ ${APACHEDS_INSTANCE}/partitions/
	chown -R apacheds.apacheds ${APACHEDS_INSTANCE}/partitions/
fi

# There should be no correct scenario in which the pid file is present at container start
rm -f ${APACHEDS_INSTANCE}/run/apacheds-default.pid 

/opt/apacheds-2.0.0_M24/bin/apacheds start default

wait_for_ldap


if [ -n "${BOOTSTRAP_FILE}" ]; then
	echo "Bootstraping Apache DS with Data from ${BOOTSTRAP_FILE}"
	
	ldapmodify -h localhost -p 10389 -D 'uid=admin,ou=system' -w secret -f $BOOTSTRAP_FILE $BOOTSTRAP_OPTS
fi

trap "echo 'Stopping Apache DS';/opt/apacheds-2.0.0_M24/bin/apacheds stop default;exit 0" SIGTERM SIGKILL

while true
do
  tail -f /dev/null & wait ${!}
done
