template_path=File.dirname(__FILE__)

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
remove_file '.gitignore'

ignore_body=[]
ignore_files = [
  'Rails.gitignore',
  'Global/vim.gitignore',
]
ignore_files.each do |file_name|
  ignore_body << "# #{file_name}\n" + File.read("#{template_path}/gitignore/#{file_name}")
end
file '.gitignore', ignore_body.join("\n\n")

# Add scaffold template
controller_template='lib/templates/rails/scaffold_controller/controller.rb'
file controller_template, File.read("#{template_path}/#{controller_template}")

rake 'db:create'

git :add => "-A"
git :commit => "-m 'initialize #{app_name}'"

run 'bundle exec spork rspec --bootstrap'

say <<-END
  ============================================================================
  ToDo
  * setup "spec/spec_helper.rb" for spork-rails
END
