# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-clipped-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-clipped-extension"
  s.version     = RadiantClippedExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantClippedExtension::AUTHORS
  s.email       = RadiantClippedExtension::EMAIL
  s.homepage    = RadiantClippedExtension::URL
  s.summary     = RadiantClippedExtension::SUMMARY
  s.description = RadiantClippedExtension::DESCRIPTION

  s.add_dependency 'acts_as_list', "~> 0.1.2"
  s.add_dependency 'paperclip', "~> 2.3.16"
  s.add_dependency 'uuidtools', "~> 2.1.2"

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
end