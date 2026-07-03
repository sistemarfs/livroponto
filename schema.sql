-- ============================================
-- Livro & Ponto — schema Supabase
-- Cole isto inteiro no SQL Editor do seu projeto
-- Supabase (Project > SQL Editor > New query > Run)
-- ============================================

create extension if not exists pgcrypto;

-- senha de acesso do app (linha única)
create table if not exists app_settings (
  id int primary key default 1,
  password text not null,
  updated_at timestamptz default now(),
  constraint single_row check (id = 1)
);

-- receitas
create table if not exists income (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  description text not null,
  amount numeric(12,2) not null,
  created_at timestamptz default now()
);

-- contas a pagar
create table if not exists bills (
  id uuid primary key default gen_random_uuid(),
  due_date date not null,
  description text not null,
  amount numeric(12,2) not null,
  paid boolean not null default false,
  created_at timestamptz default now()
);

-- registros de ponto
create table if not exists punches (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  time text not null,
  type text not null check (type in ('entrada','saida')),
  note text,
  created_at timestamptz default now()
);

-- ============================================
-- RLS: como o app usa 1 senha só (sem login individual),
-- liberamos leitura/escrita pela chave anon.
-- Isso equivale, em termos de segurança, à senha do app:
-- quem tem o link e a senha usa o app; quem tem a
-- anon key (pública no código) também consegue acessar
-- as tabelas diretamente. Para uso pessoal/pequena equipe
-- isso é aceitável; não use para dados sensíveis de terceiros.
-- ============================================

alter table app_settings enable row level security;
alter table income enable row level security;
alter table bills enable row level security;
alter table punches enable row level security;

create policy "allow all app_settings" on app_settings for all using (true) with check (true);
create policy "allow all income" on income for all using (true) with check (true);
create policy "allow all bills" on bills for all using (true) with check (true);
create policy "allow all punches" on punches for all using (true) with check (true);
