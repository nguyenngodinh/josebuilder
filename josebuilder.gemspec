Gem::Specification.new do |s|
  s.name     = 'josebuilder'
  s.version  = '0.0.4'
  s.authors  = ['Nguyen Ngo Dinh']
  s.email    = ['nguyenngodinh@outlook.com']
  s.summary  = 'Create JSON Signature and encryption structures'
  s.description = "json signature and encryption builder"
  s.homepage = 'https://github.com/nguyenngodinh/josebuilder'
  s.license  = 'MIT'

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'activesupport', '>= 3.0.0', '< 5'
  s.add_dependency 'multi_json',    '~> 1.2'
  s.add_runtime_dependency 'jwt', '~> 1.4', '>= 1.4.1'

  s.files         = `git ls-files`.split("\n")
end

