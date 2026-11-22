-- DYNKORA starter schema. Review and deploy with Supabase SQL Editor.
create extension if not exists pgcrypto;
create type public.app_role as enum ('player','club_admin','super_admin');
create type public.booking_status as enum ('pending','confirmed','cancelled','completed');
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'New Player',
  username text unique,
  skill_level text default 'Beginner',
  rating_points integer not null default 1000,
  role public.app_role not null default 'player',
  created_at timestamptz not null default now()
);
create table public.courts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  venue text not null,
  hourly_rate numeric(10,2) not null default 200,
  is_active boolean not null default true
);
create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.profiles(id),
  court_id uuid not null references public.courts(id),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status public.booking_status not null default 'pending',
  total_amount numeric(10,2) not null,
  payment_status text not null default 'unpaid',
  created_at timestamptz not null default now(),
  constraint valid_booking_time check (ends_at > starts_at)
);
create table public.open_play_sessions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  host_id uuid not null references public.profiles(id),
  starts_at timestamptz not null,
  skill_level text not null default 'All levels',
  capacity integer not null default 8,
  venue text not null,
  created_at timestamptz not null default now()
);
create table public.open_play_members (
  session_id uuid references public.open_play_sessions(id) on delete cascade,
  player_id uuid references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key(session_id, player_id)
);
create table public.tournaments (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  starts_at timestamptz not null,
  division text not null,
  registration_fee numeric(10,2) not null default 0,
  capacity integer not null default 16,
  status text not null default 'registration_open'
);
create table public.tournament_entries (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  player_id uuid not null references public.profiles(id),
  partner_id uuid references public.profiles(id),
  payment_status text not null default 'unpaid',
  created_at timestamptz not null default now(),
  unique(tournament_id, player_id)
);
create table public.matches (
  id uuid primary key default gen_random_uuid(),
  tournament_id uuid not null references public.tournaments(id) on delete cascade,
  round_number integer not null,
  team_a text,
  team_b text,
  score_a integer,
  score_b integer,
  winner text
);
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.profiles(id),
  booking_id uuid references public.bookings(id),
  tournament_entry_id uuid references public.tournament_entries(id),
  provider text,
  provider_reference text unique,
  amount numeric(10,2) not null,
  currency text not null default 'PHP',
  status text not null default 'pending',
  created_at timestamptz not null default now()
);
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  player_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
alter table public.courts enable row level security;
alter table public.bookings enable row level security;
alter table public.open_play_sessions enable row level security;
alter table public.open_play_members enable row level security;
alter table public.tournaments enable row level security;
alter table public.tournament_entries enable row level security;
alter table public.matches enable row level security;
alter table public.payments enable row level security;
alter table public.notifications enable row level security;
-- Starter-safe policies: users can view public club data and only their own private rows.
create policy "profiles readable by authenticated" on public.profiles for select to authenticated using (true);
create policy "players update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "courts readable" on public.courts for select to authenticated using (true);
create policy "bookings own rows" on public.bookings for select to authenticated using (auth.uid() = player_id);
create policy "players create own bookings" on public.bookings for insert to authenticated with check (auth.uid() = player_id);
create policy "open play sessions readable" on public.open_play_sessions for select to authenticated using (true);
create policy "open play membership own rows" on public.open_play_members for all to authenticated using (auth.uid() = player_id) with check (auth.uid() = player_id);
create policy "tournaments readable" on public.tournaments for select to authenticated using (true);
create policy "tournament entries own rows" on public.tournament_entries for all to authenticated using (auth.uid() = player_id) with check (auth.uid() = player_id);
create policy "matches readable" on public.matches for select to authenticated using (true);
create policy "payments own rows" on public.payments for select to authenticated using (auth.uid() = player_id);
create policy "notifications own rows" on public.notifications for all to authenticated using (auth.uid() = player_id) with check (auth.uid() = player_id);
-- IMPORTANT: Add vetted admin-only policies and server-side payment verification before production.
