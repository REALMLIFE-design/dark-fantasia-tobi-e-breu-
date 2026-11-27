
create or replace function public.create_game_room(
  p_chapter text default 'Floresta Corrompida',
  p_max_players integer default 4
)
returns table (
  room_id uuid,
  room_code text,
  chapter text,
  max_players integer,
  current_players integer
)
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_room public.game_rooms%rowtype;
  v_code text;
  v_attempt integer;
  v_chapter text := pg_catalog.btrim(pg_catalog.coalesce(p_chapter, 'Floresta Corrompida'));
  v_max_players integer := pg_catalog.coalesce(p_max_players, 4);
begin
  if v_user_id is null then
    raise exception 'É necessário entrar na conta para criar uma sala.' using errcode = '28000';
  end if;

  if pg_catalog.length(v_chapter) < 1 or pg_catalog.length(v_chapter) > 80 then
    raise exception 'Capítulo inválido.' using errcode = '22023';
  end if;

  if v_max_players < 1 or v_max_players > 4 then
    raise exception 'A sala deve ter entre 1 e 4 jogadores.' using errcode = '22023';
  end if;

  for v_attempt in 1..5 loop
    v_code := pg_catalog.upper(pg_catalog.substr(pg_catalog.replace(pg_catalog.gen_random_uuid()::text, '-', ''), 1, 8));
    begin
      insert into public.game_rooms (owner_id, room_code, chapter, max_players, status)
      values (v_user_id, v_code, v_chapter, v_max_players, 'waiting')
      returning * into v_room;
      exit;
    exception when unique_violation then
      if v_attempt = 5 then
        raise exception 'Não foi possível gerar um código de sala. Tente novamente.' using errcode = '23505';
      end if;
    end;
  end loop;

  insert into public.room_members (room_id, user_id)
  values (v_room.id, v_user_id)
  on conflict (room_id, user_id) do nothing;

  return query
  select v_room.id, v_room.room_code, v_room.chapter, v_room.max_players,
         (select pg_catalog.count(*)::integer from public.room_members rm where rm.room_id = v_room.id);
end;
$function$;

revoke all on function public.create_game_room(text, integer) from public;
revoke all on function public.create_game_room(text, integer) from anon;
grant execute on function public.create_game_room(text, integer) to authenticated;

create or replace function public.join_room_by_code(p_room_code text)
returns table (
  room_id uuid,
  room_code text,
  chapter text,
  owner_id uuid,
  max_players integer,
  current_players integer
)
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_room public.game_rooms%rowtype;
  v_member_count integer;
  v_code text := pg_catalog.upper(pg_catalog.btrim(pg_catalog.coalesce(p_room_code, '')));
begin
  if v_user_id is null then
    raise exception 'É necessário entrar na conta para entrar em uma sala.' using errcode = '28000';
  end if;

  if pg_catalog.length(v_code) < 6 or pg_catalog.length(v_code) > 12 then
    raise exception 'Digite um código de sala válido.' using errcode = '22023';
  end if;

  select r.* into v_room
  from public.game_rooms r
  where r.room_code = v_code and r.status = 'waiting'
  for update;

  if not found then
    raise exception 'Sala não encontrada ou que não aceita novos jogadores.' using errcode = 'P0002';
  end if;

  if not exists (
    select 1 from public.room_members rm
    where rm.room_id = v_room.id and rm.user_id = v_user_id
  ) then
    select pg_catalog.count(*)::integer into v_member_count
    from public.room_members rm
    where rm.room_id = v_room.id;

    if v_member_count >= v_room.max_players then
      raise exception 'Esta sala já está cheia.' using errcode = '23514';
    end if;

    insert into public.room_members (room_id, user_id)
    values (v_room.id, v_user_id)
    on conflict (room_id, user_id) do nothing;
  end if;

  return query
  select v_room.id, v_room.room_code, v_room.chapter, v_room.owner_id, v_room.max_players,
         (select pg_catalog.count(*)::integer from public.room_members rm where rm.room_id = v_room.id);
end;
$function$;

revoke all on function public.join_room_by_code(text) from public;
revoke all on function public.join_room_by_code(text) from anon;
grant execute on function public.join_room_by_code(text) to authenticated;

alter publication supabase_realtime add table public.game_rooms, public.room_members, public.friend_requests;
