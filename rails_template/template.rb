git :init
git :add => "-A"
git :commit => "-m 'rails new #{app_name}'"

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'rails3-generators'
  gem 'spork-rails'
  gem 'pry-rails'
end

optional_gems = [
  'haml-rails',
]
optional_gems.each do |gem_name|
  if yes?("Would you like to install #{gem_name}? (yes/no) ")
    gem gem_name
  end
end

run 'bundle install --path vendor/bundle'
generate 'rspec:install'

# Overwrite .gitignore
run 'cp ~/rails_template/gitignore/Rails.gitignore .gitignore'

# Add scaffold template
run 'mkdir -p lib/templates/rails/scaffold_controller/'
run 'cp ~/rails_template/lib/templates/rails/scaffold_controller/controller.rb lib/templates/rails/scaffold_controller/controller.rb'

rake 'db:create'

git :init
git :add => "-A"
git :commit => "-m 'initialize #{app_name}'"

run 'bundle exec spork rspec --bootstrap'

say <<-END
  ============================================================================
  ToDo
  * setup "spec/spec_helper.rb" for spork-rails
END
