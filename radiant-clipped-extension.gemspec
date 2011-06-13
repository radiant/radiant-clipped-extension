# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-clipped-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-clipped-extension"
  s.version     = RadiantClippedExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Keith Bingman", "Benny Degezelle", "William Ross", "John W. Long"]
  s.email       = ["radiant@radiantcms.org"]
  s.homepage    = "http://radiantcms.org"
  s.summary     = %q{Assets for Radiant CMS}
  s.description = %q{Assets extension on based Keith Bingman's excellent Paperclipped extension.}

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]

  s.post_install_message = %{
  Add this to your radiant project with:
    config.gem 'radiant-clipped-extension', :version => '~>#{RadiantClippedExtension::VERSION}'
  }

  s.add_dependency 'acts_as_list', "~> 0.1.2"
  s.add_dependency 'paperclip', "~> 2.3.11"
  s.add_dependency 'uuidtools', "~> 2.1.2"
end