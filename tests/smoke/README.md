# Litmusimage Smoke Tests

[Puppet litmus](https://github.com/puppetlabs/puppet_litmus/) is used to test
the docker images maintained by this project. The Github Action [workflow](../../../template_build_deploy.yml)
contains steps to setup, provision, and run a simple command.

### Testing

These steps are not guaranteed to perform the exact steps in the
CI workflow, but should generally function to debug image builds
locally.

__Requires Ruby 3+ and Docker on the test host.__

1. Setup
   ```sh
   bundle config set --local path .bundle/vendor
   bundle exec bolt module install
   ```
2. Provision and Test
   ```sh
   bundle exec rake litmus:provision[docker,litmusimage/rockylinux:8]
   bundle exec bolt command run 'last' -t all
   ```
3. Tear down
   ```sh
   bundle exec rake litmus:tear_down
   ```

### Debugging

1. Review docker logs
   ```sh
   docker ps -a --format '{{.ID}}' | xargs -n1 docker logs
   ```
2. Review bolt inventory
   ```sh
   bundle exec bolt inventory show --detail
   ```
