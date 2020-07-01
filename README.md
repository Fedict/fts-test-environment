# test-environment

The `setup-environment.sh` script will configure minishift so it runs
all the containers for the BOSA trust services.

HOWTO:

- Install [minishift](https://github.com/minishift/minishift)
- Make sure that `base64`, `jq`, `psql`, and `stty` are available
  (Debian/Ubuntu: `sudo apt install jq postgresql-client coreutils`)
- configure minishift's virtualization for your platform as explained in
  their [Getting Started
guide](https://docs.okd.io/3.11/minishift/getting-started/index.html)
- Make sure minishift is available in your `$PATH`
- From this directory, run `./setup-environment.sh`, and enter your
  credentials to access git-fsf.services.belgium.be when requested
- Edit your `/etc/hosts` (`C:\\Windows\\system32\\hosts.txt` on Windows)
  to redirect the services to the right IP address (as shown at the end
  of `setup-environment.sh`, or which you can recall by way of
  `minishift ip`.
- Wait until all the images have been downloaded (this depends on the
  speed of your Internet connection...)
- Profit!

If you want to delete the project, run `eval $(minishift oc-env)`, then
run `oc project delete bosa-trust-services`.

To access the database, do:

    oc port-forward svc/postgresql 7000:5432

then run `psql -h localhost -p 7000 -U testuser -W` (you can find the
password in [postgresql.yaml](postgresql.yaml) )

To get a shell on any container, do:

    oc get pods

to see a list of the available pods; then

    oc rsh pod/<pod name>

to get a shell on the first container inside that pod (currently all
pods only have one container)

For more questions, talk to Wouter.
