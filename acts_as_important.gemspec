Gem::Specification.new do |s|
  s.name = 'acts_as_important'
  s.version = '0.3.1'
  s.email = 'contact@culturecode.ca'
  s.homepage = 'http://github.com/culturecode/acts_as_important'
  s.summary = 'Allows the you track what records are important to users and why.'
  s.authors = ['Nicholas Jakobsen', 'Ryan Wallace']

  s.files = Dir["{app,config,db,lib}/**/*"]

  s.add_dependency "rails", "~> 4.0"
end
