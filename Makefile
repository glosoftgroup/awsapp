env=development
process=all
group=all

runserver:
	python manage.py runserver --settings=configuration.settings.$(env)

ANSIBLE = ansible  $(group) -i devops/inventory/$(env)
ANSIBLE_PLAYBOOK = ansible-playbook -i devops/inventory/$(env)

# Match any playbook in the devops directory
% :: devops/%.yml
ifdef tags
	$(ANSIBLE_PLAYBOOK) $< -l $(group) -t $(tags)
else ifdef commit
	$(ANSIBLE_PLAYBOOK) $< -l $(group) -e 'APP_VERSION=$(commit)'
else ifdef config
	$(ANSIBLE_PLAYBOOK) $< -l $(group) -e 'EB_CONFIG=$(config) SETTINGS=$(settings)'
else ifdef settings
	$(ANSIBLE_PLAYBOOK) $< -l $(group) -e 'EB_CONFIG=$(config) SETTINGS=$(settings)'
else ifdef limit
	$(ANSIBLE_PLAYBOOK) $< -l $(group) --limit $(limit)
else
	$(ANSIBLE_PLAYBOOK) $< -l $(group)
endif

ping :
	$(ANSIBLE) -m ping

status :
	$(ANSIBLE) -s -a"supervisorctl status" -l app_servers
	$(ANSIBLE) -s -a "service haproxy status" -l load_balancers
	ansible-playbook devops/monitor.yml -i devops/inventory/$(env)

restart start stop :
	$(ANSIBLE) -s -a "supervisorctl $(@) $(process)" -l app_servers

restart-supervisor :
	ansible app_servers -i devops/inventory/$(env) -m shell -s \
	-a "service supervisor stop && sleep 5 && service supervisor start"

change_to_haproxy:
	ansible load_balancers -i devops/inventory/$(env) -m shell -s \
	-a "sudo service nginx stop && sleep 5 && sudo service haproxy start"

change_to_nginx:
	ansible load_balancers -i devops/inventory/$(env) -m shell -s \
	-a "sudo service haproxy stop && sleep 5 && sudo service nginx start"

lb-status:
	ansible load_balancers -i devops/inventory/$(env) -s -a "service haproxy status"

lb-restart:
	ansible load_balancers -i devops/inventory/$(env) -s -a "sudo service haproxy restart"
lb-start:
	ansible load_balancers -i devops/inventory/$(env) -s -a "sudo service haproxy start"
lb-stop:
	ansible load_balancers -i devops/inventory/$(env) -s -a "sudo service haproxy stop"
haproxy-status:
	ansible load_balancers -i devops/inventory/$(env) -m shell -s -a 'sudo echo "show info;show stat;show table" | socat /var/lib/haproxy/stats stdio'

# recovery to be used incase haproxy results into errors
ngix-status:
	ansible load_balancers -i devops/inventory/$(env) -s -a "service nginx status"
ngix-restart:
	ansible load_balancers -i devops/inventory/$(env) -s -a "sudo service nginx restart"
ngix-start:
	ansible load_balancers -i devops/inventory/$(env) -s -a "sudo service nginx start"
ngix-stop:
	ansible load_balancers -i devops/inventory/$(env) -s -a "sudo service nginx stop"

help:
	@echo ''
	@echo 'Usage: '
	@echo ' make <command> [option=<option_value>]...'
	@echo ''
	@echo 'Setup & Deployment:'
	@echo ' make configure		Prepare servers'
	@echo ' make deploy 		Deploy app'
	@echo ''
	@echo 'Options:  '
	@echo ' env			Inventory file (Default: development)'
	@echo ' group			Inventory subgroup (Default: all)'
	@echo ''
	@echo 'Example:'
	@echo ' make configure env=staging group=app_servers'
	@echo ''
	@echo 'Application Management:'
	@echo ' make status 		Display process states'
	@echo ' make start		Start processes'
	@echo ' make restart		Restart processes'
	@echo ' make restart-supervisor	Restart supervisord'
	@echo ''
	@echo 'Options: '
	@echo ' process		A supervisor program name or group (Default: all)'
	@echo ''
	@echo 'Example:'
	@echo ' make restart process=awsapp:celery'
	@echo 'make project_status -> to know the last commit deployed and when it was deployed'
	@echo ''
	@echo 'Queue Request Callbacks:'
	@echo ' make runcallbacks action=<action_value> -> get all completed requests and queue their callbacks'
	@echo ''
	@echo 'Options: '
	@echo ' action 		should be one of either freeze,strike,disburse'
	@echo ''
	@echo 'Example:'
	@echo ' make runcallbacks action=strike'
	@echo ''
	@echo 'ElasticBeanstalk commands'
	@echo 'Options: '
	@echo ' settings 		set of settings to use eg staging, production'
	@echo ' config 		    config file to use without the _config.yml. config file should be located at .elasticbeanstalk/dev_configs eg .elasticbeanstalk/dev_configs/myconfigname_config.yml'
	@echo 'Example: using staging settings and .elasticbeanstalk/dev_configs/test_staging_config.yml'
	@echo 'For creating an elasticbeanstalk environment: '
	@echo ' make eb_create_env settings=staging config=test_staging'
	@echo 'For deploying to elasticbeanstalk: '
	@echo ' make eb_deploy settings=staging config=test_staging'


coverage:
	$(ANSIBLE) -a "/home/vagrant/.virtualenvs/awsapp/bin/coverage erase"
	$(ANSIBLE) -a "/home/vagrant/.virtualenvs/awsapp/bin/coverage run --omit=".virtualenvs/*,*settings*,*manage*,*lib/logging*,*migrations*,*__init__*,*lib/cryptography*,*admin*,*celery*" /vagrant/manage.py test --liveserver=localhost:8081 --settings=awsapp.settings.test"
	$(ANSIBLE) -a "/home/vagrant/.virtualenvs/awsapp/bin/coverage report --fail-under=80"

test:
	$(ANSIBLE) -a "/home/vagrant/.virtualenvs/awsapp/bin/python /vagrant/manage.py test --liveserver=localhost:8081 --settings=configuration.settings.test chdir=/vagrant" -l app_servers

messages :
	$(ANSIBLE) -a "/home/vagrant/.virtualenvs/awsapp/bin/django-admin.py makemessages --all --no-obsolete --keep-pot --extension=py chdir=/vagrant/ussd" -l app_servers

compilemessages :
	$(ANSIBLE) -a "/home/vagrant/.virtualenvs/awsapp/bin/django-admin.py compilemessages chdir=/vagrant/ussd" -l app_servers

local_server:
	@killall -9 python | echo
	@python manage.py runserver 3000 --settings=configuration.settings.development

# for dev debugging.
run2:
	@sudo killall -9 supervisord | echo
	@sudo killall -9 gunicorn | echo
	@python manage.py validate --settings=awsapp.settings.development &
	@python manage.py collectstatic --noinput --settings=configuration.settings.development &
	@python manage.py syncdb --settings=configuration.settings.development &
	@python manage.py migrate --settings=configuration.settings.development &
	@authbind --deep python manage.py runserver 0.0.0.0:3000 --settings=configuration.settings.development

cel:
	@sudo killall -9 celery | echo
	@export DJANGO_SETTINGS_MODULE="configuration.settings.development" && \
	celery worker -A awsapp --loglevel=DEBUG --beat --autoreload --concurrency=2 -Q complete_session,incomplete_session #--events

shell:
	@python manage.py shell_plus --settings=configuration.settings.development
