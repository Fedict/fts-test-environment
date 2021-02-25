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
require_cmd git-lfs

status "Pulling submodules..."
git submodule init
git submodule update
status "Starting minishift..."
minishift start
minishift config set routing-suffix "local.test.belgium.be"
status "Creating project..."
eval $(minishift oc-env)
oc login -u system -p admin
if [ "$(oc get -o json project bosa-trust-services 2>/dev/null | jq '.status.phase')" = '"Active"' ]; then
	status "old bosa-trust-services project found. Deleting..."
	oc delete project bosa-trust-services
	sleep 60
fi
oc new-project --display-name="BOSA Trust Services" bosa-trust-services
status "Creating ImageStreams and builds..."
oc process -f builds-streams.yaml | oc apply -f -
status "Setting up secrets..."
oc create secret generic softhsm-tokens-esealing --from-file=softhsm-tokens-esealing.tgz
sleep 1
status "Loading images..."
oc start-build --from-dir=$(pwd) mvn-dockers
oc start-build --from-dir=$(pwd) squid
oc start-build --from-dir=$(pwd)/esealing mvn-esealing
oc start-build --from-dir=$(pwd)/GUI-sign guisign
oc start-build --from-dir=$(pwd)/sign-validation mvn-signvalidation
oc create -f configmaps.yaml

# Create config maps for frontend code
rm -rf gui-config
cp -a GUI-sign/public/config gui-config
sed -i -e 's,ta.fts.bosa.belgium.be,local.test.belgium.be,g' gui-config/config.js
oc create configmap gui-sign-config --from-file=gui-config

oc create -f postgres.yaml
oc create -f minio.yaml
oc create -f squid-whitelist.yaml
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
oc create -f openshift/sign-validation.json
oc create -f openshift/guisign.json
oc create -f openshift/esealing.json
status "Done; the project should now be loading into your openshift."
echo "To access the services, edit /etc/hosts to point sign.local.test.belgium.be,"
echo "validate.local.test.belgium.be, esealing.local.test.belgium.be, and"
echo "minio.local.test.belgium.be to" $(minishift ip)
echo "To move on:"
echo "  * 'minishift console' opens the OpenShift console in your default browser"
echo "    (log on with user name 'system' and password 'admin')"
echo "  * 'eval \$(minishift oc-env)' adds the 'oc' command to your shell's \$PATH"
echo "  * 'oc start-build --from-dir=. -F mvn-dockers' updates the 'Dockerfile's"
echo "    used for Java-using images"
echo "  * For rebuilding/updating images:"
echo "    * esealing: 'oc start-build --from-dir=./esealing -F mvn-esealing'"
echo "    * Signing GUI: 'oc start-build --from-dir=./GUI-sign -F guisign'"
echo "    * Sign/validation backend: 'oc start-build --from-dir=./sign-validation -F mvn-signvalidation'"
echo "    Note that a rebuild automatically triggers a restart of the (new) image"
echo "  * 'oc get pods' lists the currently-running pods"
echo "  * 'oc port-forward <pod name> <local port number>:<remote port number>'"
echo "  * 'oc rsh <pod name>' gets you a shell in a pod"
echo "  * 'minishift stop' stops the cluster (restart with 'minishift start')."
echo "  * 'minishift delete' deletes the cluster."
