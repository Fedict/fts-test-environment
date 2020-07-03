#!/bin/bash

set -e

PFW=""
cleanup() {
	if [ ! -z "$PFW" ]; then
		kill -TERM $PFW
		sleep 1
		kill -KILL $PFW
	fi
}

trap cleanup EXIT

status() {
	text="$1"
	equals="============================================================================================================="
	shift
	len=$(( $(printf %s "$text"|wc -c) + 4 ))
	printf "%s\n! %s !\n%s\n" ${equals:0:$len} "$text" ${equals:0:$len}
}

require_cmd() {
	cmd="$1"
	if type $cmd >/dev/null 2>/dev/null; then
		:
	else
		echo "E: required command not found: $cmd. Please install it, then try again."
		exit 1
	fi
}

require_cmd jq
require_cmd minishift
require_cmd psql
require_cmd stty
require_cmd base64

status "Pulling submodules..."
git submodule init
git submodule update
status "Starting minishift..."
minishift start
status "Creating project..."
eval $(minishift oc-env)
oc login -u system -p admin
if [ "$(oc get -o json project bosa-trust-services 2>/dev/null | jq '.status.phase')" = '"Active"' ]; then
	status "old bosa-trust-services project found. Exporting credentials & deleting..."
	json=$(oc get -o json secret/bosa-registry)
	if [ ! -z "$json" ]; then
		user=$(echo $json|jq -r '.data[".dockerconfigjson"]'|base64 -d|jq -r '.auths["registry-fsf.services.belgium.be:5000"]["username"]')
		pass=$(echo $json|jq -r '.data[".dockerconfigjson"]'|base64 -d|jq -r '.auths["registry-fsf.services.belgium.be:5000"]["password"]')
	fi
	oc delete project bosa-trust-services
	sleep 60
fi
oc new-project --display-name="BOSA Trust Services" bosa-trust-services
status "Setting up secrets..."
echo "Please enter your credentials for https://git-fsf.services.belgium.be/"
echo "Note that these will be stored inside the OpenShift environment. For security"
echo "reasons, you should therefore create an access token with the 'read_registry'"
echo "scope (and nothing else) at"
echo "https://git-fsf.services.belgium.be/profile/personal_access_tokens"
if [ -z "$user" ]; then
	printf %s "Username: "
	read user
fi
if [ -z "$pass" ]; then
	stty_orig=$(stty -g)
	stty -echo
	printf %s "Access token: "
	read pass
	stty $stty_orig
	echo ""
fi
oc create secret docker-registry bosa-registry --docker-server=registry-fsf.services.belgium.be:5000 --docker-username="$user" --docker-password="$pass" --docker-email="$user"@zetes.com
oc secrets link default bosa-registry --for=pull
oc create secret generic softhsm-tokens --from-file=softhsm-tokens.tgz
sleep 1
status "Loading images..."
oc create -f configmaps.yaml
rm -rf gui-config
cp -a GUI-sign/public/config gui-config
sed -i -e 's,ta.fts.bosa.belgium.be,local.test.belgium.be,g' gui-config/config.js
oc create configmap gui-config --from-file=gui-config
oc create -f postgres.yaml
oc process -f squid.yaml | oc create -f -
while [ $(( $(oc get -o json statefulset/postgresql | jq .status.readyReplicas) + 0 )) -lt 1 ]
do
	echo "PostgreSQL container not ready yet. Waiting..."
	sleep 10
done
oc port-forward svc/postgresql 7000:5432 &
PFW=$!
sleep 10
export PGPASSWORD=7l8XNiA3
(grep -Ev "(^#|^CREATE DATABASE|^.connect)" sign-validation/signingconfigurator/scripts/01-create-tables.sql; cat insert-profiles.sql) | psql -h localhost -U testuser -p 7000 bosa_fts_ta
kill -TERM $PFW
PFW=""
oc process -f sign-validation/bosadt-openshift-project.yaml | jq '.items[0].spec.template.spec.containers[0].env[0]={"name":"JPDA_OPTS","value":"-agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n"}|.items[0].spec.template.spec.containers[0].command=["catalina.sh","jpda","run"]|.items[0].spec.template.spec.containers[0].envFrom = [{"configMapRef": {"name":"databaseconfig"}},{"configMapRef": {"name": "signvalidationsettings"}},{"configMapRef":{"name":"httpproxysettings"}}]|.items[2].spec.host="validate.local.test.belgium.be"|.items[2].spec.tls = {"insecureEdgeTerminationPolicy": "Redirect","termination":"edge"}|.items[2].spec.wildcardPolicy="None"'| oc create -f -
oc process -f GUI-sign/bosadt-openshift-project.yaml | jq '.items[0].spec.template.spec.containers[0].envFrom = [{"configMapRef": {"name":"databaseconfig"}},{"configMapRef":{"name":"httpproxysettings"}}]|.items[2].spec.host="sign.local.test.belgium.be"|.items[2].spec.tls={"insecureEdgeTerminationPolicy":"Redirect","termination":"edge"}|.items[2].spec.wildcardPolicy="None"|.items[0].spec.template.spec.containers[0].volumeMounts=[{"name":"config-volume","mountPath":"/app/build/config"}]|.items[0].spec.template.spec.volumes = [{"name":"config-volume","configMap":{"name":"gui-config"}}]|.items[0].spec.template.spec.containers[0].command=["serve"]|.items[0].spec.template.spec.containers[0].args=["-s","-S","build"]'| oc create -f -
oc process -f IDP/bosadt-openshift-project.yaml | jq '.items[0].spec.template.spec.containers[0].env[0]={"name":"JPDA_OPTS","value":"-agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n"}|.items[0].spec.template.spec.containers[0].command=["catalina.sh","jpda","run"]|.items[0].spec.template.spec.containers[0].image="registry-fsf.services.belgium.be:5000/eidas/idp:develop"|.items[0].spec.template.spec.initContainers[0].image="registry-fsf.services.belgium.be:5000/eidas/idp:develop".items[2].spec.host="idp.local.test.belgium.be"|.items[2].spec.tls={"insecureEdgeTerminationPolicy":"Redirect","termination":"edge"}|.items[2].spec.wildcardPolicy="None"|.items[0].spec.template.spec.containers[0].envFrom=[{"configMapRef":{"name":"idpconfig"}}]'|oc create -f -
status "Done; the project should now be loading into your openshift."
echo "To access the services, edit /etc/hosts to point sign.local.test.belgium.be,"
echo "validate.local.test.belgium.be and idp.local.test.belgium.be to" $(minishift ip)
echo "To move on:"
echo "  * 'minishift console' opens the OpenShift console in your default browser"
echo "    (log on with user name 'system' and password 'admin')"
echo ""
echo "  * 'eval \$(minishift oc-env)' adds the 'oc' command to your shell's \$PATH"
echo ""
echo "  * 'oc rollout latest dc/signvalidation; oc rollout latest dc/guisign'; oc rollout latest dc/idp'"
echo "    pulls the latest images"
echo "  * 'oc get pods' lists the currently-running pods"
echo "  * 'oc port-forward <pod name> <local port number>:<remote port number>'"
echo "  * 'oc rsh <pod name>' gets you a shell in a pod"
echo ""
echo "  * 'minishift stop' stops the cluster (restart with 'minishift start')."
echo ""
echo "  * 'minishift delete' deletes the cluster."
