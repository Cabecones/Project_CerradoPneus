# shop

A primeira versão do app estava com o CRUD todo funcionando em escala menor com produtos com menos especificações. Mas sem tela de login.

Fiz a integração com a api para puxar os produtos e implementei as funcionalidades de filtro e pesquisa, mas a função de editar e adicionar só modificam em uma página, quando ele vai para a home e puxa a api novamente ele reseta como estava, pois a API é imutável.

As funcionalidades de adicionar ao carrinho e de fazer a compra estão funcionando, pode verificar as compras na página de pedidos.

Tentei implementar a interface de login, mas sem sucesso nas funcionalidades, apenas implementei as partes visuais, mas pode observar os códigos em que tentei implementar o funcionamento para ver se segui a lógica correta.

Para acessar a página de login, é necessário descomentar a rota nos arquivos de rota e alterar a rota raíz '/', necessário alterar na main.dart também.
