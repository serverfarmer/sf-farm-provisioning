#!/bin/sh
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.dialog


if [ "$1" = "" ]; then
	echo "usage: $0 <profile>"
	exit 1
fi

newrelic="/etc/local/.config/newrelic.license"
template="/etc/local/.provisioning/$1/variables.sh"

if [ -f $template ]; then
	echo "provisioning configuration template \"$1\" already found, exiting"
	exit 0
fi


if [ -s $newrelic ]; then
	license="`cat $newrelic`"
else
	license="put-your-newrelic-license-key-here"
fi

NEWRELIC_LICENSE="`input \"enter newrelic.com license key for provisioning\" $license`"
SNMP_COMMUNITY="`input \"enter snmp v2 community for provisioning\" put-your-snmp-community-here`"

SMTP_RELAY="`input \"enter default smtp relay hostname for provisioning\" smtp.gmail.com`"
SMTP_USERNAME="`input \"[$SMTP_RELAY] enter login\" my-user@gmail.com`"
SMTP_PASSWORD="`input \"[$SMTP_RELAY] enter password for $SMTP_USERNAME\" my-password`"


mkdir -p /etc/local/.provisioning/$1
echo "#!/bin/sh
#
# Settings to use in unattended setup mode; please fill in all variables.
#
# extensions part:
#
export NEWRELIC_LICENSE=$NEWRELIC_LICENSE
export SNMP_COMMUNITY=$SNMP_COMMUNITY
#
# core SF part:
#
export SMTP_RELAY=$SMTP_RELAY
export SMTP_USERNAME=$SMTP_USERNAME
export SMTP_PASSWORD=$SMTP_PASSWORD
#
# Github username (or organization short name), where you have forked
# Server Farmer main repository.
#
export SF_GITHUB=`grep github.com /opt/farm/.git/config |rev |cut -d'/' -f2 |rev`
#
# Email address for confirmations about successful setups.
#
export SF_CONFIRM=serverfarmer-provisioning@`external_domain`
" >$template
chmod 0600 $template