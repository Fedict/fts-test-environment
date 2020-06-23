#!/bin/bash

set -e

status() {
	text="$1"
	equals="============================================================================================================="
	shift
	len=$(( $(printf %s $text|wc -c) + 5 ))
	printf "%s\n! %s !\n%s\n" ${equals:0:$len} "$text" ${equals:0:$len}
}

status "Pulling submodules..."
git submodule init
git submodule update
status "Starting minishift..."
minishift start
status "Creating project..."
eval $(minishift oc-env)
oc login -u system -p admin
oc new-project --display-name="BOSA Trust Services" bosa-trust-services
status "Setting up pull credentials..."
echo "Please enter your credentials for https://git-fsf.services.belgium.be/"
echo "Note that these will be stored inside the OpenShift environment. For security"
echo "reasons, you should therefore create an access token with the 'read_registry'"
echo "scope (and nothing else) at"
echo "https://git-fsf.services.belgium.be/profile/personal_access_tokens"
printf %s "Username: "
read user
stty_orig=$(stty -g)
stty -echo
printf %s "Access token: "
read pass
stty $stty_orig
echo ""
oc create secret docker-registry bosa-registry --docker-server=registry-fsf.services.belgium.be:5000 --docker-username="$user" --docker-password="$pass" --docker-email="$user"@zetes.com
oc secrets link default bosa-registry --for=pull
status "Loading images..."
oc create -f configmaps.yaml
oc create -f postgres.yaml
oc process -f sign-validation/bosadt-openshift-project.yaml | oc create -f -
oc process -f GUI-sign/bosadt-openshift-project.yaml | oc create -f -
status "Done; the project should now be loading into your openshift."
echo "To access the services, edit /etc/hosts to point the hostname you"
echo "wish to access to" $(minishift ip)
echo "To move on:"
echo "  * 'minishift console' opens the OpenShift console in your default browser"
echo "    (log on with user name 'system' and password 'admin')"
echo ""
echo "  * 'eval \$(minishift oc-env)' adds the 'oc' command to your shell's \$PATH"
echo ""
echo "  * 'oc rollout latest dc/signvalidation; oc rollout latest dc/guisign'"
echo "    pulls the latest images"
echo ""
echo "  * 'minishift stop' stops the cluster (restart with 'minishift start')."
echo ""
echo "  * 'minishift delete' deletes the cluster."
