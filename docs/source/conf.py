import os
import sys

sys.path.append(os.path.abspath("./_ext"))

# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "Time de DB do C3SL"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

language = "pt"

templates_path = ["_templates"]
exclude_patterns = []

extensions = [
    "sphinxcontrib.svgbob",
    "sphinx.ext.todo",
    "sphinx_inline_tabs",
    "sphinx_copybutton",
    "sphinx_tippy",
    "sphinx_togglebutton",
    "myst_parser",
    "inline_svgbob",
    "ipmi",
]

myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "fieldlist",
]

myst_heading_anchors = 2

copybutton_prompt_text = r">>> |\$ |.+:.+# |.+@.+> |<.+>"
copybutton_prompt_is_regexp = True
copybutton_line_continuation_character = "\\"
copybutton_here_doc_delimiter = "EOF"
copybutton_copy_empty_lines = False

todo_include_todos = True

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "furo"
html_static_path = ["_static"]
html_css_files = ["svgbob.css"]

# html_logo = "_static/root-logo.png"
html_theme_options = {
    "sidebar_hide_name": True,
#    "source_edit_link": "https://gitlab.c3sl.ufpr.br/C3Root/docs/-/blob/main/source/{filename}",
}
