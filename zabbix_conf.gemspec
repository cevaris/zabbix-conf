# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zabbix_conf/version'

Gem::Specification.new do |spec|
  spec.name          = "zabbix_conf"
  spec.version       = ZabbixConf::VERSION
  spec.authors       = ["cevaris"]
  spec.email         = ["cevaris@gmail.com"]
  spec.summary       = %q{File based configuration for Zabbix.}
  spec.description   = %q{Ini configuration files are parsed to configure a Zabbix server via the zabbixapi ruby gem.}
  spec.homepage      = "https://github.com/cevaris/zabbix-conf/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.executables   << 'zabconf'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "zabbixapi"
  spec.add_development_dependency "inifile"
end
