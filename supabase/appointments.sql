-- Expected booking tables. day_of_week uses DateTime.weekday: Monday=1 .. Sunday=7.

create table if not exists providers (
  id uuid primary key default gen_random_uuid(),
  name text not null
);

create table if not exists provider_weekly_availability (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references providers (id) on delete cascade,
  day_of_week integer not null check (day_of_week between 1 and 7),
  open_minutes integer not null,
  close_minutes integer not null,
  unique (provider_id, day_of_week)
);

create table if not exists provider_availability_overrides (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references providers (id) on delete cascade,
  date date not null,
  open_minutes integer,
  close_minutes integer,
  is_closed boolean not null default false,
  unique (provider_id, date)
);

create table if not exists appointments (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null,
  provider_id uuid not null references providers (id),
  service_id uuid not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null,
  service_name text not null,
  duration_minutes integer not null,
  price numeric not null,
  created_at timestamptz not null default now()
);
