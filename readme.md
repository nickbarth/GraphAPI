# RakeAR
RakeAR is a Ruby Gem containing some common Rake tasks to help manage your ActiveRecord database independant of Rails.

# How To Use

Install the gem 

    gem install rake-ar

Add a require to your `Rakefile`

    require 'rake_ar/rake'

You will now have some rake tasks to manage your ActiveRecord database.

    rake -T

    rake db:clear             # Clear all database records
    rake db:console           # Loads IRB with your ActiveRecord models and a database connection
    rake db:create_migration  # Creates a new ActiveRecord migration
    rake db:drop              # Drops all database tables
    rake db:load              # Loads your schema file into the database
    rake db:migrate           # Migrates your database
    rake db:regen             # Regenerates the database from migrations
    rake db:reseed            # Reloads the database from your schema file and reseeds it
    rake db:schema            # Dumps a new schema file
    rake db:seed              # Loads your seed data file

To configure them just initialize a new instance of RakeAR in your `Rakefile` to override the defaults.

    @rake_ar = RakeAR.new connect_file:   "#{Dir.pwd}/db/connect.rb", # File containing a valid ActiveRecord connection
                          migration_path: "#{Dir.pwd}/db/migrate/",   # Path to migrations folder
                          seed_file:      "#{Dir.pwd}/db/seeds.rb",   # Ruby database seed script
                          schema_file:    "#{Dir.pwd}/db/schema.rb",  # Schema file the database is written too and loaded from
                          models_path:    "#{Dir.pwd}/app/models"     # Path to the applications ActiveRecord models

### License
WTFPL &copy; 2012 Nick Barth
