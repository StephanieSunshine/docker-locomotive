#!/usr/bin/env bash
source /etc/profile.d/rvm.sh

echo "Installing latest bundler..."
gem install bundler

if [ ! -f /home/app/engine/app ]; then
	echo
	echo "Setting up Ruby on Rails..."
	gem install rails -v 4.2.7.1
	cd /home/app; rails new engine --skip-bundle --skip-active-record --skip
	cd /home/app/engine
	
	echo "gem 'locomotivecms', '~> 3.1.1', :git => 'https://github.com/locomotivecms/engine.git', :tag => 'v3.1.1'" >> "Gemfile"
	echo "gem 'puma'" >> "Gemfile"
	echo "gem 'therubyracer', platforms: :ruby" >> "Gemfile"
fi

echo 
echo "Installing ruby gems..."
RAILS_ENV=production bundle install
chown -R app:app /var/lib/gems

if [ ! -f config/initializers/locomotive.rb ]; then
	echo 
	echo "Installing locomotive..."
	cd /home/app/engine; rails generate locomotive:install
	sed -i 's/localhost/db/g' /home/app/engine/config/mongoid.yml
	rake secret > SECRET_KEY_BASE
fi
chown app:app -R /home/app

echo
echo "Compiling Assets..."
su - app -c "cd /home/app/engine; SECRET_KEY_BASE=`cat SECRET_KEY_BASE` RAILS_ENV=production bundle exec rake assets:precompile --trace"

echo
echo "Starting Phusion Passenger Stand-alone..."
SECRET_KEY_BASE=`cat SECRET_KEY_BASE` RAILS_ENV=production bundle exec passenger start -a 0.0.0.0 -p 80 -e production
