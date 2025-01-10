alter table public.user_profiles add column main_focus text check (main_focus in ('creator', 'respondent', 'hybrid'));
alter table public.user_profiles add column phone text;

create or replace function public.handle_phone_confirmation()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  if new.phone is not null then
    update public.user_profiles
    set phone = new.phone
    where user_id = new.id;
  end if;
  return new;
end;