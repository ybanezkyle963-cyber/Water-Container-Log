-- WATER CONTAINER LOG: electricity meter (kWh)
-- Run this whole file once in Supabase > SQL Editor.
-- It only ADDS a new table. Your other tables are not changed. Safe to run twice.

create table if not exists public.meter_readings(
  id bigint generated always as identity primary key,
  station_id bigint,                       -- empty = shared meter for all stations
  read_date date not null default current_date,
  reading numeric(12,2) not null check (reading >= 0),   -- number shown on the meter (kWh)
  note text,
  user_id uuid,
  user_name text,
  created_at timestamptz not null default now()
);

-- Only one reading per meter per day
create unique index if not exists meter_readings_one_per_day
  on public.meter_readings (coalesce(station_id, 0), read_date);

alter table public.meter_readings enable row level security;
drop policy if exists "staff all meter" on public.meter_readings;
create policy "staff all meter" on public.meter_readings
  for all to authenticated using (true) with check (true);
grant select, insert, update, delete on public.meter_readings to authenticated;
