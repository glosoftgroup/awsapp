from development import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'awsapp',
        'USER': 'awsapp',
        'PASSWORD': 'awsapp',
        'HOST': 'db',
        'PORT': '5432',
    }
}

BROKER_URL = ""
