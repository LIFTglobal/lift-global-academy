-- LIFT Global Academy — graduation requirements
--
-- Adds the requirement set itself (one row per subject-category line),
-- and adds credit fields to review_packages so an APPROVED package can
-- count toward a specific category and credit value. Credit is only
-- ever counted from approved packages — drafts and pending submissions
-- never count toward graduation progress.

create table graduation_requirements (
  id uuid primary key default gen_random_uuid(),
  subject_category text not null,
  credits_required numeric not null,
  notes text,
  sort_order integer not null default 0
);

-- Seed LIFT's actual requirement set (Social Studies broken into its
-- four named sub-requirements, since each is tracked separately).
insert into graduation_requirements (subject_category, credits_required, notes, sort_order) values
  ('English', 40, null, 1),
  ('Mathematics', 20, 'Must include Algebra I', 2),
  ('Science', 20, 'One biological and one physical science; must include at least one lab. Becomes 30 if a 3rd science course is taken.', 3),
  ('World History', 10, null, 4),
  ('U.S. History or History of Passport Country', 10, null, 5),
  ('Government', 5, null, 6),
  ('Economics', 5, null, 7),
  ('Visual/Performing Arts, World Language, or CTE', 10, null, 8),
  ('Physical Education', 20, 'Equivalent hours in a competitive sport may qualify', 9),
  ('Health', 0.5, null, 10),
  ('Computer Science', 0.5, null, 11),
  ('Electives', 70, 'Online classes, community service, or apprentice experience may qualify', 12);

alter table graduation_requirements enable row level security;

create policy "graduation_requirements_select" on graduation_requirements for select
  using (true); -- visible to anyone logged in; it's a published standard, not sensitive data

create policy "graduation_requirements_modify" on graduation_requirements for all
  using ((select role from my_account()) = 'lift_evaluator');

-- Add credit tracking fields to review_packages.
-- awarded_credit_value / awarded_credit_category are the values of
-- record, confirmed by the evaluator at approval time — these may
-- differ from whatever the teacher recommended.
alter table review_packages
  add column recommended_credit_value numeric,
  add column awarded_credit_value numeric,
  add column awarded_credit_category text;
