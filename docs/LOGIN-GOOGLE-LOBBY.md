# Login Google e lobby online — Dark World

## Estado da integração

- O projeto Supabase `dark-world-online` já existe.
- O banco já possui `profiles`, `friend_requests`, `game_rooms` e `room_members`, com RLS habilitado.
- O APK nunca deve conter a chave `service_role` nem o Client Secret do Google.
- A tela inicial e o lobby visual estão no jogo; o acesso Google real permanece bloqueado até o proprietário concluir as credenciais OAuth e o retorno Android.

## Configuração necessária do Google

1. No Google Cloud Console, crie/seleciona um projeto e configure a tela de consentimento OAuth.
2. Crie um OAuth Client ID do tipo **Web application**.
3. Em **Authorized redirect URIs**, adicione exatamente:
   `https://wxzvtbfsemwmwjjhqstp.supabase.co/auth/v1/callback`
4. No Supabase, abra **Authentication → Sign In / Providers → Google**.
5. Ative Google e informe o Client ID e Client Secret obtidos no Google Cloud Console.
6. Salve e teste o provedor no painel antes de liberar a autenticação no APK.

## Retorno ao aplicativo Android

O fluxo nativo ainda precisa registrar e validar um deep link do pacote Android `com.tobiebreu.darkworld3d`. Não habilite o botão como funcional até que:
- o Android receba o callback sem expor tokens em logs;
- o jogo valide o estado/PKCE e estabeleça a sessão Supabase;
- a sessão seja persistida com segurança;
- logout e expiração/renovação sejam testados em aparelho real.

Não coloque Client Secret, service-role key ou refresh token em arquivos versionados, no APK ou em logs.

## Backend de amigos e salas

O banco já contém as tabelas e políticas RLS para perfis, pedidos de amizade e salas de até quatro jogadores. A interface atual mantém essas ações bloqueadas no modo convidado; elas devem ser ligadas à sessão autenticada antes de aceitar convites ou criar salas.

## Operações online preparadas no backend

Migração aplicada ao projeto Supabase e versionada em `supabase/migrations/202611270001_dark_world_social_rooms.sql`:

- `dark_world_create_room(chapter)`: cria sala privada e insere o anfitrião como primeiro membro, com limite de quatro jogadores.
- `dark_world_join_room(room_code)`: valida código, sala aberta e vagas disponíveis; bloqueia concorrência ao entrar.
- `dark_world_send_friend_request(username)`: procura o jogador pelo nome e impede auto-convite e pedidos duplicados.
- `dark_world_respond_friend_request(request_id, accept)`: só permite que o destinatário responda a um pedido pendente.
- `dark_world_list_friends()`: lista apenas amizades aceitas da conta atual.
- Trigger de criação automática do perfil quando uma conta Auth é criada.

Todas as RPCs exigem papel `authenticated`; execução por `anon` e `public` foi revogada. O banco foi conferido após a aplicação. A interface do jogo ainda precisa receber uma sessão OAuth válida e chamar essas RPCs antes de liberar os botões.
