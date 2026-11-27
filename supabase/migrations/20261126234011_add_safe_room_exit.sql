create or replace function private.leave_game_room(p_room_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_room public.game_rooms%rowtype;
begin
  if v_user_id is null then
    raise exception 'É necessário entrar na conta para sair da sala.' using errcode = '28000';
  end if;

  select r.* into v_room
  from public.game_rooms r
  where r.id = p_room_id
  for update;

  if not found then
    raise exception 'Sala não encontrada.' using errcode = 'P0002';
  end if;

  if v_room.owner_id = v_user_id then
    update public.game_rooms
    set status = 'closed'
    where id = p_room_id;
    delete from public.room_members
    where room_id = p_room_id;
    return true;
  end if;

  delete from public.room_members
  where room_id = p_room_id and user_id = v_user_id;

  if not found then
    raise exception 'Você não faz parte desta sala.' using errcode = '42501';
  end if;

  return false;
end;
$function$;

revoke all on function private.leave_game_room(uuid) from public, anon;
grant execute on function private.leave_game_room(uuid) to authenticated;

create or replace function public.leave_game_room(p_room_id uuid)
returns boolean
language sql
security invoker
set search_path = ''
as $function$
  select private.leave_game_room(p_room_id);
$function$;

revoke all on function public.leave_game_room(uuid) from public, anon;
grant execute on function public.leave_game_room(uuid) to authenticated;