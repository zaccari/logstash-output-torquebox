# coding: utf-8

Gem::Specification.new do |s|
  s.name          = 'logstash-output-torquebox'
  s.version       = '1.0.1'
  s.authors       = ['Michael Zaccari']
  s.email         = ['michael.zaccari@accelerated.com']

  s.summary       = 'Push events to a TorqueBox messaging server (HornetQ)'
  s.description   = 'This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install logstash-output-torquebox. This gem is not a stand-alone program'
  s.homepage      = 'https://github.com/mzaccari/logstash-output-torquebox'
  s.license       = 'MIT'
  s.require_paths = ['lib']

  # Files
  s.files         = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE.txt']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'output' }

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core-plugin-api', '~> 1.0'
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'torquebox-messaging', '~> 3.1'

  s.add_development_dependency 'logstash-devutils'
end
