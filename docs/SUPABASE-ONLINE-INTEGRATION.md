# Integração online — Dark World

## Projeto Supabase conectado
- Projeto: `dark-world-online`
- Região: `sa-east-1`
- URL: `https://wxzvtbfsemwmwjjhqstp.supabase.co`
- Cliente Android/Godot usa somente a publishable key. Nunca colocar a `service_role` no app.

## Estrutura já encontrada no banco
- `profiles`: perfis e nomes de jogador.
- `friend_requests`: solicitações e amizades aceitas.
- `game_rooms`: salas com código, capítulo, limite de quatro jogadores e estado.
- `room_members`: participantes.
- RLS está habilitado nas quatro tabelas.

## RPCs existentes e usadas pelo cliente
- `dark_world_create_room(p_chapter)`
- `dark_world_join_room(p_room_code)`
- `dark_world_list_friends()`
- `dark_world_list_friend_requests()`
- `dark_world_send_friend_request(p_username)`
- `dark_world_respond_friend_request(p_request_id, p_accept)`
- `leave_game_room(p_room_id)`

As funções verificadas usam `auth.uid()` para limitar ações à sessão autenticada. O cliente não acessa tabelas de outros jogadores sem passar pelas políticas/RPCs.

## Cliente Godot
- `scripts/online_service.gd` faz chamadas HTTPS ao Auth e RPC do Supabase.
- Sessões de visitante guardam access/refresh token em `user://dark_world_session.cfg`.
- A renovação de sessão é tentada antes de criar uma nova conta anônima.
- O lobby cria sala, entra por código, lista amigos e envia/responde solicitações.
- Se a autenticação anônima estiver desativada ou a rede falhar, o jogador ainda pode entrar no modo local.

## Configuração ainda necessária no Dashboard
1. Em Authentication, habilitar Anonymous Sign-Ins para permitir que o botão de visitante crie uma sessão online. O estado dessa opção não é exposto pelas ferramentas conectadas nesta sessão.
2. Em Authentication → Sign In / Providers → Google, habilitar Google e inserir o Client ID e Client Secret do Google Cloud.
3. Criar os clientes OAuth Android para as assinaturas SHA-1 de debug e release; registrar os Client IDs na configuração Google do Supabase.
4. Definir e permitir o deep link Android de retorno e implementar a troca/validação do resultado OAuth no app. Não inserir Client Secret no APK.
5. Testar criação/entrada de sala e amizade com duas contas em dois dispositivos.

## Auditoria de segurança observada em 28/11/2026
- RLS está habilitado nas quatro tabelas públicas.
- O advisor apontou seis RPCs `SECURITY DEFINER` expostas a usuários autenticados. As definições foram inspecionadas; as operações de escrita verificam `auth.uid()`, e as leituras filtram pela sessão atual. Manter revisão periódica dessas funções.
- O advisor também informa que a proteção contra senhas vazadas está desativada. É uma configuração do Auth Dashboard, não alterada por este commit.

## Limites desta entrega
- Google OAuth ainda não foi ativado porque faltam credenciais e configuração de assinatura Android.
- O multiplayer ainda não sincroniza o estado do mundo/combate em tempo real; esta etapa conecta autenticação, amigos e ciclo básico de salas.
- A integração deve ser validada no Godot 4.3 e em Android real antes de ser promovida para `main`.
