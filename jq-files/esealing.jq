.items[0].spec.template.spec.containers[0].env[0]={"name":"JPDA_OPTS","value":"-agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n"}
|.items[0].spec.template.spec.containers[0].command=["catalina.sh","jpda","run"]
|.items[0].spec.template.spec.containers[0].image="registry-fsf.services.belgium.be:5000/eidas/esealing:develop"
|.items[0].spec.template.spec.initContainers[0].image="registry-fsf.services.belgium.be:5000/eidas/esealing:develop"
|.items[2].spec.host="esealing.local.test.belgium.be"
|.items[2].spec.tls={"insecureEdgeTerminationPolicy":"Redirect","termination":"edge"}
|.items[2].spec.wildcardPolicy="None"
