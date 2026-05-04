-- ============================================================
-- INDIRA OMS — Supabase Database Schema (v2)
-- Run this entire script in Supabase → SQL Editor
-- ============================================================

-- USERS TABLE
create table if not exists public.users (
  id text primary key,
  name text not null,
  role text not null,
  branch text not null,
  password text not null,
  email text,
  phone text,
  approved boolean default false,
  status text default 'pending',
  pin_changed boolean default false,
  created_at timestamp with time zone default timezone('utc', now())
);

-- ORDERS TABLE (with new image + order copy columns)
create table if not exists public.orders (
  order_id text primary key,
  tracking_code text not null,
  branch_name text not null,
  sales_person text not null,
  customer_name text not null,
  customer_number1 text,
  customer_number2 text,
  address text,
  floor_number text,
  assembling_required text default 'no',
  delivery_date text,
  manufacture_or_vendor text default 'manufacture',
  status text default 'Order Created',
  priority text default 'Normal',
  branch_approved text default 'no',
  branch_approved_by text default '',
  factory_assigned_to text,
  created_at text,
  products jsonb default '[]'::jsonb,
  order_copy_url text default '',
  updated_at timestamp with time zone default timezone('utc', now())
);

-- STORAGE BUCKET for images (run separately in Supabase Storage section)
-- Create a bucket called "oms-images" with public access enabled

-- Enable Realtime
alter publication supabase_realtime add table users;
alter publication supabase_realtime add table orders;

-- Row Level Security
alter table public.users enable row level security;
alter table public.orders enable row level security;

create policy "Allow all on users" on public.users for all using (true) with check (true);
create policy "Allow all on orders" on public.orders for all using (true) with check (true);

-- ============================================================
-- IMPORTANT: Also create a Storage Bucket!
-- Go to Supabase → Storage → New Bucket
-- Name: oms-images
-- Public: YES (toggle on)
-- ============================================================

-- ============================================================
-- v3 UPDATE — Run these if you already have the table:
-- ============================================================
alter table public.orders add column if not exists delivered_image_url text default '';
alter table public.orders add column if not exists challan_image_url text default '';

-- ============================================================
-- v4 UPDATE — Run these in Supabase SQL Editor:
-- ============================================================
alter table public.orders add column if not exists factory_delivery_date text default '';
alter table public.orders add column if not exists branch_query text default '';
alter table public.orders add column if not exists is_second_approval boolean default false;
alter table public.orders add column if not exists verified_by text default 'showroom';

-- v5 UPDATE:
alter table public.users add column if not exists photo_url text default '';

-- v6 UPDATE: total order value
alter table public.orders add column if not exists total_order_value numeric default 0;

-- ─── TASKS TABLE ─────────────────────────────────────────────────────────────
create table if not exists tasks (
  id                text primary key,
  phone_number      text default '',
  task_description  text not null,
  assigned_to_id    text not null,
  assigned_to_name  text not null,
  assigned_to_role  text not null,
  assigned_by_name  text default 'Owner',
  created_at        timestamptz default now(),
  status            text default 'pending',  -- 'pending' | 'completed' | 'doubt'
  status_note       text default '',
  doubt_reply       text default '',
  completed_at      text default ''
);

-- Enable realtime for tasks
alter publication supabase_realtime add table tasks;

-- ─── USER FCM TOKENS (for push notifications) ────────────────────────────────
create table if not exists public.user_tokens (
  user_id   text primary key,
  fcm_token text not null,
  updated_at timestamptz default now()
);
alter table public.user_tokens enable row level security;
create policy "Allow all on user_tokens" on public.user_tokens for all using (true) with check (true);

-- ============================================================
-- v7 UPDATE — ORDER COMMENTS / ACTIVITY LOG
-- Run in Supabase → SQL Editor
-- ============================================================
create table if not exists public.order_comments (
  id          text primary key,
  order_id    text not null,
  user_id     text not null,
  user_name   text not null,
  user_role   text not null,
  comment     text not null,
  is_system   boolean default false,
  created_at  timestamptz default now()
);
alter table public.order_comments enable row level security;
create policy "Allow all on order_comments" on public.order_comments for all using (true) with check (true);
alter publication supabase_realtime add table order_comments;

-- ============================================================
-- v8 UPDATE — CUSTOMER ENQUIRIES + CUSTOM FORM FIELDS
-- Run in Supabase → SQL Editor
-- ============================================================
create table if not exists public.customer_enquiries (
  id                  text primary key,
  customer_name       text not null,
  phone1              text not null,
  phone2              text default '',
  location            text not null,
  project_type        text not null,
  others_description  text default '',
  heard_about_us      text default '',
  house_type          text not null,
  entry_date          text not null,
  entered_by          text not null,
  entered_by_role     text default '',
  custom_fields       jsonb default '{}'::jsonb,
  assigned_rep        text default '',
  enquiry_status      text default 'New',
  pending_reason      text default '',
  status_history      jsonb default '[]'::jsonb,
  created_at          timestamptz default now()
);
alter table public.customer_enquiries enable row level security;
create policy "Allow all on customer_enquiries" on public.customer_enquiries for all using (true) with check (true);
alter publication supabase_realtime add table customer_enquiries;

create table if not exists public.custom_form_fields (
  id          text primary key,
  field_name  text not null,
  field_type  text default 'text',
  sort_order  integer default 0,
  is_active   boolean default true
);
alter table public.custom_form_fields enable row level security;
create policy "Allow all on custom_form_fields" on public.custom_form_fields for all using (true) with check (true);

-- ============================================================
-- v9 UPDATE — ENQUIRY WORKFLOW (if you already ran v8)
-- Run in Supabase → SQL Editor
-- ============================================================
alter table public.customer_enquiries add column if not exists assigned_rep text default '';
alter table public.customer_enquiries add column if not exists enquiry_status text default 'New';
alter table public.customer_enquiries add column if not exists pending_reason text default '';
alter table public.customer_enquiries add column if not exists status_history jsonb default '[]'::jsonb;
