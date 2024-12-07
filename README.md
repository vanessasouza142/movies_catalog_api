# Movies Catalog API

Esta API foi desenvolvida para gerenciar um catálogo de filmes. Ela oferece dois endpoints principais: um para realizar a leitura de um arquivo CSV e criar os filmes no banco de dados e outro para listar todos os filmes cadastrados, podendo também filtrar os registros por ano de lançamento, gênero e país.

## Requisitos

- **Ruby** 3.2.2
- **Rails** 7.1.4.1
- **SQLite3** 1.4+
- **RSpec** (para testes)

## Instalação

1. Clone o repositório para o seu computador:
   > git clone https://github.com/vanessasouza142/movies_catalog_api.git
2. Navegue até o diretório do projeto: 
   > cd movies_catalog_api
3. Instale as dependências do projeto:
   > bundle install
4. Crie e migre o banco de dados SQLite:
   > rails db:create
   > rails db:migrate

## Executando o Servidor

1. Inicie o servidor Rails do projeto:
   > rails server

## Documentação

A documentação dessa API foi desenvolvida e pode ser acessada através do Postman.

1. Acesse a documentação no link abaixo:
   > https://documenter.getpostman.com/view/23291260/2sAYBbfA2i

## Testes

1. O projeto inclui testes de requisição. Para rodar, execute:
   > rspec
