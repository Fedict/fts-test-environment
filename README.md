# test-environment

The `setup-testenv.sh` script will configure minishift so it runs all the
containers for the BOSA trust services.

HOWTO:

- Install [minishift](https://github.com/minishift/minishift)
- Make sure that `base64`, `jq`, `psql`, and `stty` are available
  (Debian/Ubuntu: `sudo apt install jq postgresql-client coreutils`)
- configure minishift's virtualization for your platform as explained in
  their [Getting Started
  guide](https://docs.okd.io/3.11/minishift/getting-started/index.html)
- Make sure minishift is available in your `$PATH`
- From this directory, run `./setup-testenv.sh`.
- Edit your `/etc/hosts` (`C:\\Windows\\system32\\hosts.txt` on Windows)
  to redirect the services to the right IP address (as shown at the end
  of `setup-environment.sh`, or which you can recall by way of
  `minishift ip`.
- Wait until all the images have been built (this depends on the speed
  of your Internet connection and your CPU...)
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

To update a deployment, "cd" into the directory that contains a checkout
of the relevant git repository for the project in question (this can be
a checkout somewhere else, and doesn't have to be the one in this
directory); then run

    oc start-build --from-dir=$(pwd) mvn-projectname

for Java projects, or

    oc start-build --from-dir=$(pwd) projectname

Where `projectname` is the relevant build name (you can get a list with
`oc get bc`). Add the parameter `-F` to `start-build` to follow the
build log. After the build finishes, minishift will automatically
restart the container with the software.

You can rerun `setup-testenv.sh` after a `git pull` in this directory in
case relevant changes have been made to the script and you want the new
version. Note though that that will delete all deployments and start
everything again from scratch, although some caching will be involved.

If running `setup-testenv.sh` fails with the message that the project
"bosa-trust-services" already exists, then just wait a minute or two and
try again. This happens happens because minishift does not immediately
delete all resources upon "oc project delete", which is one of the first
steps the script does if the project exists, after which it waits a
minute to allow for minishift to clean up everything. Depending on your
hardware, however, a minute may not be enough.

For more questions, talk to Wouter.

# Platform support

`minishift` exists for Linux, Windows, and macOS. However, currently the
script has only been tested on Linux.

Since macOS is a Unix, it *should* work, although this has not yet been
tested. For Windows, you'll need some form of a Unix shell; either
WSL or something like cygwin might work. This, too, has not been tested.
