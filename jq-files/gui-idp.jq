.items[0].spec.template.spec.containers[0].envFrom = [{"configMapRef": {"name":"databaseconfig"}},{"configMapRef":{"name":"httpproxysettings"}}]
|.items[2].spec.host="idp.local.test.belgium.be"
|.items[2].spec.tls={"insecureEdgeTerminationPolicy":"Redirect","termination":"edge"}
|.items[2].spec.wildcardPolicy="None"
|.items[0].spec.template.spec.containers[0].volumeMounts=[{"name":"config-volume","mountPath":"/app/build/config"}]
|.items[0].spec.template.spec.volumes = [{"name":"config-volume","configMap":{"name":"gui-idp-config"}}]
|.items[0].spec.template.spec.containers[0].command=["serve"]
|.items[0].spec.template.spec.containers[0].args=["-s","-S","build"]
