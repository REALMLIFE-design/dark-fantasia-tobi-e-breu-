-- List only pending friend requests involving the authenticated user.
-- Incoming requests are marked received; outgoing requests are marked sent.
create or replace function public.dark_world_list_friend_requests()
returns table(request_id uuid, direction text, username text, created_at timestamptz)
language sql
stable
security definer
set search_path = public
as $$
  select
    fr.id,
    case when fr.addressee_id = auth.uid() then 'received' else 'sent' end,
    p.username,
    fr.created_at
  from public.friend_requests fr
  join public.profiles p
    on p.id = case
      when fr.addressee_id = auth.uid() then fr.requester_id
      else fr.addressee_id
    end
  where auth.uid() is not null
    and fr.status = 'pending'
    and (fr.requester_id = auth.uid() or fr.addressee_id = auth.uid())
  order by fr.created_at desc;
$$;

revoke all on function public.dark_world_list_friend_requests() from public, anon;
grant execute on function public.dark_world_list_friend_requests() to authenticated;
