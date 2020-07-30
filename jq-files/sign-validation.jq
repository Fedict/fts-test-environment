.items[0].spec.template.spec.containers[0].env[0]={"name":"JPDA_OPTS","value":"-agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n"}
|.items[0].spec.template.spec.containers[0].command=["catalina.sh","jpda","run"]
|.items[0].spec.template.spec.containers[0].envFrom = [{"configMapRef": {"name":"databaseconfig"}},{"configMapRef": {"name": "signvalidationsettings"}},{"configMapRef":{"name":"httpproxysettings"}}]
|.items[2].spec.host="validate.local.test.belgium.be"
|.items[2].spec.tls = {"insecureEdgeTerminationPolicy": "Redirect","termination":"edge"}
|.items[2].spec.wildcardPolicy="None"
|.items[0].spec.triggers=[{"type":"ConfigChange"},{"type":"ImageChange","imageChangeParams":{"automatic":true,"containerNames":["signvalidation"],"from":{"kind":"ImageStreamTag","name":"signvalidation:latest"}}}]
