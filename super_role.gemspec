$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "super_role/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "super_role"
  s.version     = SuperRole::VERSION
  s.authors     = ["Roy Y. Bao"]
  s.email       = ["roybao2010@gmail.com"]
  s.homepage    = "http://royybao.com"
  s.summary     = "Provide roles and permissions."
  s.description = "Provide roles and permissions."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "activerecord", "~> 4.0.0"

  s.add_development_dependency "mysql2"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "pry-debugger"
  s.add_development_dependency "rspec"
  s.add_development_dependency "ffaker"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sqlite3"
end
