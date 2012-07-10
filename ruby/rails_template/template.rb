template_path=File.dirname(__FILE__)

# Git Repository initialize
git :init
git commit: '--allow-empty -m "first commit"'

git add: '-A'
git commit: "-m 'rails new #{app_name}'"

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

git add: '-A'
git commit: '-m "setup .gitignore"'

# Add gems
## required gems
gem_group :development, :test do
  # test
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'spork-rails'
  gem 'rails_best_practices'
  gem 'cucumber-rails'
  gem 'database_cleaner'

  # debug
  gem 'sextant'
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'awesome_print'
end

## TODO: optional gems
optional_gems = [
  'devise',
  'cancan',
  'haml-rails',
  'kaminari',
  'crumy',
  'paperclip',
  'paranoia',
  'active_decorator',
  'settingslogic',
  'timecop',
  'rails_admin',
  'twitter-bootstrap-rails',
  'therubyracer',
  'rails-erd',
  'sdoc',
]
# optional_gems.each do |gem_name|
#   if yes?("Would you like to install #{gem_name}? (yes/no) ")
#     gem gem_name
#   end
# end

run 'bundle install --path vendor/bundle'

# OPTIMIZE: auto setup spork
# generate 'rspec:install'
# run 'bundle exec spork rspec --bootstrap'

git add: '-A'
git commit: '-m "setup gems"'

# Add scaffold templates
controller_template='lib/templates/rails/scaffold_controller/controller.rb'
file controller_template, File.read("#{template_path}/#{controller_template}")

git add: '-A'
git commit: '-m "setup scaffold templates"'


say <<-END
  ============================================================================
  ToDo
  * setup "spec/spec_helper.rb" for spork-rails
END
