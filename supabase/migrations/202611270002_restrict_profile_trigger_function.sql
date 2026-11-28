-- Keep the profile bootstrap function callable only by its owner.
-- PostgreSQL triggers do not require callers to have EXECUTE on the trigger function.
REVOKE ALL ON FUNCTION public.ensure_dark_world_profile() FROM PUBLIC, anon, authenticated, service_role;
