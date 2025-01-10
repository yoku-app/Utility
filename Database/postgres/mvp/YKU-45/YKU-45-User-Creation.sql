drop table public.user_profiles;
drop function public.handle_new_user cascade;

create table public.user_profiles (
  id bigint primary key generated always as identity,
  user_id uuid not null references auth.users(id) on delete cascade,
  email text not null,
  display_name text not null,
  avatar_url text,
  DOB date,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now(),
  respondent_onboarding_completion timestamp,
  creator_onboarding_completion timestamp,
);

alter table public.user_profiles enable row level security;
create index idx_profiles_user_id on public.user_profiles(user_id);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.user_profiles (user_id, email, display_name, avatar_url)
  values (
    new.id, 
    new.email,
    coalesce(new.raw_user_meta_data ->> 'name', ''), 
    coalesce(new.raw_user_meta_data ->> 'avatar_url', '')
  );
  return new;
end;
$$;

-- trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.user_profile
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();