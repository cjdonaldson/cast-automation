#!/bin/bash
# to extract MD,
#   sed -n '/^#start__md$/,/^#end__md$/{/^#start__md$/d; /^#end__md$/d; p; }' file.sh | sed 's/^# //'

scriptProcessingDir="scriptProcessing"
mkdir "$scriptProcessingDir" 2> /dev/null

port=8020

#start__md
# ## cast-global-setup.sh
# cast-global-setup.sh is to be sourced from each CAST functional script and not from the test script.
# And defines communication global variables.
#
# The following global variables need to be defined prior to sourcing the respective CAST functional script either via shell __export__s
# or script __set__s in the test script
# * castuser  The CAST user name to be used
# * castpw    The password for CAST user
# * castip    The ip address of the CAST to be automated
#
#
# which define castHttps and uriBase variables that can be used like:
#
# &nbsp;&nbsp; `$castHttps <options> $uriBase/<uriTarget>`
#
# `$scriptProcessingDir` variable provides a location for operational result storage and work area.
# Prepend to file names.
#
#end__md
castHttps="curl -skL --trace-ascii $scriptProcessingDir/trace.out --user $castuser:$castpw "
uriBase="https://$castip:$port"

#xmlDataPost="__Content-Type=application/xml&__Accept=*/*"
xmlDataPost="__Content-Type=application/xml"

