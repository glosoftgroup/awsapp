# flake8: noqa
from base import *

# RAVEN_CONFIG = {
#     'dsn':
# 'https://edaa5095b0a64ad8b426b4b8388a3fe3:fb5168674ca34900845f596a9cbda48d@sentry.io/111005',
#     'release': PROJECT_ROOT,
# }

DEBUG = False
ALLOWED_HOSTS = ['*']

INSECURE_LOGGING = False

STAGE = 'staging'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'awsappstaging',
        'USER': 'awsappstaging',
        'PASSWORD': '',
        'HOST': 'aws.domain.eu-west-1.rds.amazonaws.com',
        'PORT': '5432',
    }
}

SECURE_SSL_REDIRECT = False