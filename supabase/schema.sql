-- Voya Supabase schema. Run this once in your project's SQL Editor
-- (Dashboard > SQL Editor > New query) after creating the project. See
-- README.md "Set up Supabase" for the rest of the setup (env vars, Google
-- OAuth provider, redirect URL).

-- ---------------------------------------------------------------------------
-- profiles: editable username/avatar, one row per auth.users row.
-- ---------------------------------------------------------------------------
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  avatar_url text,
  updated_at timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "own profile" on profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

-- Auto-creates an empty profile row the moment someone signs up, so the app
-- never has to handle "user exists but has no profile row yet".
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username)
  values (new.id, new.raw_user_meta_data ->> 'username');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- interview_sessions / interview_results: one row per completed practice
-- session. `user_id` is denormalized onto both tables (rather than only on
-- interview_sessions and joining for the results policy) so both RLS
-- policies stay simple and identical in shape.
-- ---------------------------------------------------------------------------
create table interview_sessions (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  country_name text not null,
  country_flag text not null,
  purpose text not null,
  difficulty text not null,
  duration_minutes int not null,
  started_at timestamptz not null,
  turn_count int not null,
  overall_score numeric,
  created_at timestamptz not null default now()
);

create table interview_results (
  session_id uuid primary key references interview_sessions(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  completed_at timestamptz not null,
  communication numeric not null,
  clarity numeric not null,
  answer_quality numeric not null,
  speaking_pace numeric not null,
  consistency numeric not null,
  strengths jsonb not null,
  practice_areas jsonb not null,
  questions_to_practice jsonb not null,
  filler_word_counts jsonb not null
);

alter table interview_sessions enable row level security;
alter table interview_results enable row level security;

create policy "own sessions" on interview_sessions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own results" on interview_results
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- avatars Storage bucket. Create the bucket itself first in the dashboard:
-- Storage > New bucket > name it "avatars" > Public bucket. Then run this.
-- Expects each user's avatar uploaded at path `<user_id>/<filename>`.
-- ---------------------------------------------------------------------------
create policy "avatar images are publicly readable"
  on storage.objects for select using (bucket_id = 'avatars');
create policy "users upload their own avatar"
  on storage.objects for insert with check (
    bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
  );
create policy "users update their own avatar"
  on storage.objects for update using (
    bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]
  );
