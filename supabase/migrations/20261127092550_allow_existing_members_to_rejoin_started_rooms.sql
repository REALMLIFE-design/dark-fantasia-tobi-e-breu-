create or replace function private.join_room_by_code(p_room_code text)
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
  v_is_member boolean;
  v_code text := pg_catalog.upper(pg_catalog.btrim(coalesce(p_room_code, '')));
begin
  if v_user_id is null then
    raise exception 'É necessário entrar na conta para entrar em uma sala.' using errcode = '28000';
  end if;
  if pg_catalog.length(v_code) < 6 or pg_catalog.length(v_code) > 12 then
    raise exception 'Digite um código de sala válido.' using errcode = '22023';
  end if;

  select r.* into v_room
  from public.game_rooms r
  where r.room_code = v_code
  for update;

  if not found or v_room.status = 'closed' then
    raise exception 'Sala não encontrada ou encerrada.' using errcode = 'P0002';
  end if;

  select exists (
    select 1 from public.room_members rm
    where rm.room_id = v_room.id and rm.user_id = v_user_id
  ) into v_is_member;

  if not v_is_member then
    if v_room.status <> 'waiting' then
      raise exception 'Esta partida já começou e não aceita novos jogadores.' using errcode = '55000';
    end if;

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
