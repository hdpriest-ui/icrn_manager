# Configuration file for the Sphinx documentation builder.

project = 'NCSA Library & Kernel Manager'
copyright = '2025 University of Illinois'
author = 'NCSA'

release = '0.1'
version = '0.1.0'

# -- General configuration

extensions = [
    'sphinx.ext.duration',
    'sphinx.ext.doctest',
    'sphinx.ext.autodoc',
    'sphinx.ext.autosummary',
    'sphinx.ext.intersphinx',
    'sphinx_copybutton',
    'sphinx_tabs.tabs',
]

intersphinx_mapping = {
    'python': ('https://docs.python.org/3/', None),
    'sphinx': ('https://www.sphinx-doc.org/en/master/', None),
}
intersphinx_disabled_domains = ['std']

templates_path = ['_templates']

# -- Options for HTML output

html_theme = 'sphinx_rtd_theme'

# -- Options for EPUB output
epub_show_urls = 'footnote'

# -- custom css
html_css_files = [
    'css/custom.css',
]

# -- custom JS
html_js_files = [
    'js/custom.js',
]

# -- Logo 
html_static_path = ['_static']
html_logo = "images/BlockI-NCSA-Full-Color-RGB_border4.png"
# html_logo = "images/SUPER_FullColor_RGB.png"
html_theme_options = {
     'logo_only': False,
     'display_version': False,
     'flyout_display': 'attached',
 }

# -- Page Title
html_title = 'UIUC NCSA Kernel Manager User Guide'