# test-environment

The `setup-environment.sh` script will configure minishift so it runs
all the containers for the BOSA trust services.

HOWTO:

- Install [minishift](https://github.com/minishift/minishift)
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
- Profit!

If you want to delete the project, run `eval $(minishift oc-env)`, then
run `oc project delete bosa-trust-services`.

For more questions, talk to Wouter.
