# flake8: noqa
import logging
import sys

from base import *

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
PROJECT_DIR = os.path.dirname(BASE_DIR)
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'awsapp',
        'HOST': '127.0.0.1',
        'USER': 'awsapp',
        'PASSWORD': '',
        'PORT': '5432'
    }
}

SECURE_SSL_REDIRECT = False

INSTALLED_APPS += (
    'django_extensions', 'debug_toolbar', 'debug_panel',
)

MIDDLEWARE += [
    'debug_panel.middleware.DebugPanelMiddleware',
]


# this is needed to enable the django-debug-toolbar
def show_toolbar(request):

    return True

DEBUG_TOOLBAR_CONFIG = {
    'SHOW_TOOLBAR_CALLBACK': 'configuration.settings.development.show_toolbar',
}
