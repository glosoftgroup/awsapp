# flake8: noqa
from base import *

RAVEN_CONFIG = {
    'dsn': 'https://77186e27797d4110a5634c1ead79b409:e0385adc238b457990fe7b5ceb1398d2@sentry.io/111003',  # noqa

    # If you are using git, you can also automatically configure the
    # release based on the git info.
    'release': PROJECT_ROOT,
}

DEBUG = False
ALLOWED_HOSTS = ['*']

STAGE = 'production'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'awsappprod',
        'USER': 'awsappprod',
        'PASSWORD': 'Dg*9$Qr8YFCPy$3h*Xjh',
        'HOST': 'awsappprod-prod.eu-west-1.rds.amazonaws.com',
        'PORT': '5432',
    }
}

SECURE_SSL_REDIRECT = False