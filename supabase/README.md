# Supabase — Dark World Online

Estas migrações são a cópia versionada do histórico aplicado ao projeto `dark-world-online` (região `sa-east-1`). Elas permitem reconstruir o esquema de perfis, amizades e salas em um projeto Supabase novo.

## Ordem das migrações

1. `20261126230101_dark_world_online_foundation.sql` — tabelas, índices, RLS, políticas e criação de perfil após cadastro.
2. `20261126230114_tighten_friend_and_room_access.sql` — corrige a política de leitura de membros e impede trocar os participantes de uma solicitação.
3. `20261126231630_secure_room_creation_join_and_realtime.sql` — RPCs iniciais de sala e publicação Realtime.
4. `20261126231652_secure_room_rpc_wrappers.sql` — move a lógica privilegiada para o schema privado e expõe wrappers SECURITY INVOKER.
5. `20261126233451_fix_room_members_rls_recursion.sql` — remove recursão da política de leitura de membros com helper SECURITY DEFINER restrito a usuários autenticados.
6. `20261126233534_index_game_room_owners.sql` — adiciona índice para a chave estrangeira de proprietário da sala.

## Aplicar em outro projeto

Com o Supabase CLI instalado e autenticado:

```sh
supabase link --project-ref SEU_PROJECT_REF
supabase db push
```

Configure Auth e os provedores separadamente no Dashboard. Google OAuth ainda não está habilitado: requer credenciais OAuth próprias e configuração de redirect URLs.

## Segurança

- O jogo usa somente a publishable key no cliente.
- Nunca colocar `service_role`, secret key ou credenciais OAuth privadas no APK/repositório.
- As políticas RLS continuam obrigatórias para acesso a perfis, solicitações, salas e membros.
- `create_game_room` e `join_room_by_code` só podem ser executadas por usuários autenticados.
- Realtime publica `game_rooms`, `room_members` e `friend_requests`; o lobby atual ainda faz polling periódico e não sincroniza movimento/combate.
