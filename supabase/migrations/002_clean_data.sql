-- FitTrack - Limpar dados (mantém estrutura das tabelas)
-- Execute no SQL Editor do Supabase

-- Limpa todas as tabelas na ordem correta (evita conflitos de FK)
TRUNCATE TABLE exercise_sets CASCADE;
TRUNCATE TABLE workout_sessions CASCADE;
TRUNCATE TABLE workout_exercises CASCADE;
TRUNCATE TABLE workouts CASCADE;
TRUNCATE TABLE cardio_sessions CASCADE;
TRUNCATE TABLE water_log CASCADE;
TRUNCATE TABLE favorite_exercises CASCADE;
TRUNCATE TABLE body_measurements CASCADE;
TRUNCATE TABLE exercises CASCADE;
TRUNCATE TABLE profiles CASCADE;

-- Remove usuários de teste do Auth (opcional)
-- Permite recadastrar o mesmo email
DELETE FROM auth.users;
