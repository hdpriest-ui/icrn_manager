# Configuration file for the Sphinx documentation builder.

project = 'Illinois Computes Library & Kernel Manager'
copyright = '2025 University of Illinois'
author = 'ICRN Team'

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.viewcode',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

html_theme = 'sphinx_rtd_theme' 