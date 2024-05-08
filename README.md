# Documentação desenvolvida pelo time de banco de dados do C3SL

[Link para acessar os documentos](https://documentation-db.docs.c3sl.ufpr.br/en/latest/)<br>
Caso deseje alterar algum documento, eles estão localizados em docs/source/pages


## Organização do reposirório
O repositório está organizado da seguinte maneira:
- .pre-commit-config.yaml: Configuração do pre-commit.
- cz.yaml: Configuração do commitizen.
- Makefile: Configuração do Make para a documentação.
- Pipfile: Configuração do ambiente Python usando Pipenv.
- Pipfile.lock: Versão dos módulos Python atual. Este arquivo deve ser incluído no git.
- .readthedocs.yaml: Configuração do ReadTheDocs.
- requirements.txt: Listas de módulos utilizada pelo ReadTheDocs que deve ser igual ao Pipfile, podendo ser regerada com pipenv requirements >requirements.txt.
- source/: Diretório da documentação.
- conf.py: Configuração do Sphinx.
- index.md: Página inicial da documentação.
- pages/: Diretório com as páginas da documentação.
- _static/: Diretório para armazenar arquivos estáticos como imagens, gifs e etc.
- _templates/: Diretório para alterar o estilo das páginas.