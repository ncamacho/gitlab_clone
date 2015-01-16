lib =  File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |s|
  s.name        = 'gitlab_clone'
  s.version     = Version::VERSION
  s.date        = '2015-01-15'
  s.summary     = "Pulls down the latest repos from a group in gitlab."
  s.description = "Clones All Repos In A Gitlab Group."
  s.authors     = ["Nestor N. Camacho III"]
  s.email       = 'ncamacho@nnc3.com.to'
  s.files = `git ls-files`.split($/)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.add_dependency("git", "~> 1.2.6")
  s.add_dependency("slop", "~> 3.5.0")
  s.add_dependency("httparty", "~> 0.13.1")
  s.homepage    =
    'https://github.com/ncamacho/gitlab_clone'
  s.license       = 'MIT'
end
