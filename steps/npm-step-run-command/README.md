# npm-step-run-command

This step container runs an [NPM command](https://docs.npmjs.com/cli-documentation/). An NPM step with no configuration will run `npm test` using the default settings as set by NPM. You can define any flags on a command; those listed in the step specifications are only suggestions.

## Examples

```yaml
steps:
# build
- name: npm
  image: relaysh/npm-step-run-command
  spec:
    command: build
    git:
      name: design-system,
      repository: https://github.com/puppetlabs/design-system.git
# test
- name: npm
  image: relaysh/npm-step-run-command
  spec:
    command: test
    git:
      name: design-system,
      repository: https://github.com/puppetlabs/design-system.git
# publish
- name: npm
  image: relaysh/npm-step-run-command
  spec:
    command: publish
    flags:
      tag: latest
      access: public
      otp: null
      dry-run: false
    git:
      name: design-system,
      repository: https://github.com/puppetlabs/design-system.git
    npm:
      token:
        $type: Secret
        name: npm_token
# ls
- name: npm
  image: relaysh/npm-step-run-command
  spec:
    command: ls
    git:
      name: design-system,
      repository: https://github.com/puppetlabs/design-system.git
    packageFolder: packages/react-components
    flags:
      json: true
```
