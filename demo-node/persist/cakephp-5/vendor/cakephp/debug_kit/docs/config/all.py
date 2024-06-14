# Global configuration information used across all the
# translations of documentation.
#
# Import the base theme configuration
from cakephpsphinx.config.all import *

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#

# The full version, including alpha/beta/rc tags.
release = '5.x'

# The search index version.
search_version = 'debugkit-5'

# The marketing display name for the book.
version_name = ''

# Project name shown in the black header bar
project = 'CakePHP DebugKit'

# Other versions that display in the version picker menu.
version_list = [
    {'name': '3.x', 'number': 'debugkit/3.x', 'title': '3.x'},
    {'name': '4.x', 'number': 'debugkit/4.x', 'title': '4.x'},
    {'name': '5.x', 'number': 'debugkit/5.x', 'title': '5.x', 'current': True},
]

# Languages available.
languages = ['en', 'fr', 'ja', 'pt']

# The GitHub branch name for this version of the docs
# for edit links to point at.
branch = '5.x'

# Current version being built
version = '5.x'

# Language in use for this directory.
language = 'en'

show_root_link = True

repository = 'cakephp/debug_kit'

source_path = 'docs/'

hide_page_contents = ('search', '404', 'contents')

# DebugKit docs use mp4 videos to show the UI
extensions.append('sphinxcontrib.video')
