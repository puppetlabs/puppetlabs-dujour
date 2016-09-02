require 'puppetlabs_spec_helper/rake_tasks'

require 'puppet-lint'

PuppetLint.configuration.ignore_paths = ["pkg/**/*.pp", "spec/fixtures/**/*.pp"]
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_quoted_booleans')
PuppetLint.configuration.send('disable_documentation')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
