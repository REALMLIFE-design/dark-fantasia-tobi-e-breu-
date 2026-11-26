# Dark World — autenticação e serviços online

## Login por e-mail (Supabase Auth)
- O jogo usa o projeto Supabase `dark-world-online`.
- A tela inicial oferece criação de conta e login por e-mail/senha.
- O cadastro envia o nome do aventureiro como metadado; o trigger `handle_new_user` cria o perfil.
- Se a confirmação de e-mail estiver ativa no Supabase, o jogador precisa confirmar o endereço antes de entrar.
- O token de acesso fica somente em memória durante a execução atual. Persistência/renovação de sessão ainda precisa ser adicionada.
- A chave `sb_publishable_...` no cliente é pública por definição. Nunca colocar `service_role`, secret key, senha do banco ou OAuth client secret no jogo.

## Google
O botão Google continua como aviso. Para ativá-lo, configurar o provedor Google no Supabase Auth e implementar o fluxo OAuth nativo para Android com retorno seguro ao jogo. Não simular login.

## Amigos e salas
As tabelas `profiles`, `friend_requests`, `game_rooms` e `room_members` já existem no banco. A interface de lobby ainda não faz operações nessas tabelas. Antes de ativar criação/entrada em salas, validar as políticas RLS, expor as tabelas necessárias na Data API e definir regras de autorização e presença. Não usar a chave administrativa no cliente.

## Testes pendentes
1. Abrir o projeto no Godot 4.3 e verificar erros de parse.
2. Criar uma conta de teste e confirmar o e-mail, se exigido.
3. Fazer login, reiniciar o jogo e validar o comportamento da sessão.
4. Testar em Android físico; o cliente atual usa HTTPRequest e ainda não tem persistência/refresh de sessão.
