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
