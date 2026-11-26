# Login Google e lobby online — configuração necessária

## O que esta atualização entrega
- Tela de login antes do menu principal, com arte de Dark World.
- Botão visual de login Google e modo visitante para continuar a campanha local.
- Tela de lobby com quatro vagas, lista de amigos vazia e ações de convite/sala.
- As telas informam claramente quando os serviços online ainda não estão conectados.

## Para ativar login Google real
1. Criar um projeto no Firebase e registrar o aplicativo Android com o package id `com.tobiebreu.darkworld3d`.
2. Configurar Google como provedor em Authentication.
3. Criar/obter o OAuth Web Client ID e configurar os fingerprints SHA-1/SHA-256 do certificado usado na build.
4. Integrar o fluxo nativo Google Identity Services para Android e entregar o ID token ao Firebase Authentication.
5. Validar o fluxo de login, logout, expiração e restauração da sessão em aparelho Android físico.
6. Não colocar client secret, service account ou credenciais privadas dentro do APK/repositório.

O botão Google nesta versão é intencionalmente honesto: ele informa que a autenticação ainda não foi configurada. Não cria sessão falsa nem libera o menu como se o usuário estivesse autenticado.

## Para ativar amigos e salas
- Definir backend autoritativo para perfis, presença, lista de amigos, convites, criação/entrada em salas e sincronização de partidas.
- Usar o UID verificado pelo Firebase; nunca confiar em nomes/UIDs enviados pelo cliente.
- Limitar salas a quatro jogadores, validar convites no servidor e aplicar regras contra spam.
- Conectar o lobby ao backend e só mostrar jogadores reais após receber presença confirmada.

Até essa integração, o modo visitante mantém o jogo solo e os controles locais funcionando.
