-- FitTrack Database Schema
-- Run this in your Supabase SQL editor

-- Profiles
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nome TEXT,
    altura_cm NUMERIC(5,1),
    data_nascimento DATE,
    foto_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Body Measurements
CREATE TABLE body_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    peso_kg NUMERIC(5,1) NOT NULL,
    gordura_percent NUMERIC(4,1),
    massa_muscular_kg NUMERIC(5,1),
    circunferencia_cintura NUMERIC(5,1),
    data DATE NOT NULL DEFAULT CURRENT_DATE,
    observacao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE body_measurements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own measurements"
    ON body_measurements FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own measurements"
    ON body_measurements FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own measurements"
    ON body_measurements FOR DELETE
    USING (auth.uid() = user_id);

-- Exercises (cache from Wger API)
CREATE TABLE exercises (
    id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL,
    descricao TEXT,
    musculo_principal TEXT NOT NULL,
    musculos_secundarios TEXT[] DEFAULT '{}',
    equipamento TEXT,
    imagem_url TEXT,
    video_url TEXT,
    categoria TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view exercises"
    ON exercises FOR SELECT
    USING (true);

CREATE POLICY "Anyone can insert exercises"
    ON exercises FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Anyone can update exercises"
    ON exercises FOR UPDATE
    USING (true);

-- Workouts
CREATE TABLE workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    descricao TEXT,
    dia_semana INTEGER CHECK (dia_semana >= 1 AND dia_semana <= 7),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own workouts"
    ON workouts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workouts"
    ON workouts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workouts"
    ON workouts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own workouts"
    ON workouts FOR DELETE
    USING (auth.uid() = user_id);

-- Workout Exercises (junction table)
CREATE TABLE workout_exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    ordem INTEGER NOT NULL,
    series_padrao INTEGER,
    reps_padrao INTEGER,
    descanso_segundos INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own workout exercises"
    ON workout_exercises FOR SELECT
    USING (auth.uid() IN (
        SELECT user_id FROM workouts WHERE id = workout_id
    ));

CREATE POLICY "Users can insert own workout exercises"
    ON workout_exercises FOR INSERT
    WITH CHECK (auth.uid() IN (
        SELECT user_id FROM workouts WHERE id = workout_id
    ));

CREATE POLICY "Users can delete own workout exercises"
    ON workout_exercises FOR DELETE
    USING (auth.uid() IN (
        SELECT user_id FROM workouts WHERE id = workout_id
    ));

-- Workout Sessions (logged workouts)
CREATE TABLE workout_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    data TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    duracao_minutos INTEGER,
    observacoes TEXT,
    energia_perceived INTEGER CHECK (energia_perceived >= 1 AND energia_perceived <= 10),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sessions"
    ON workout_sessions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions"
    ON workout_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Exercise Sets (individual sets within a session)
CREATE TABLE exercise_sets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    set_numero INTEGER NOT NULL,
    peso_kg NUMERIC(5,1),
    reps INTEGER,
    rpe NUMERIC(2,1),
    falhou BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE exercise_sets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sets"
    ON exercise_sets FOR SELECT
    USING (auth.uid() IN (
        SELECT user_id FROM workout_sessions WHERE id = session_id
    ));

CREATE POLICY "Users can insert own sets"
    ON exercise_sets FOR INSERT
    WITH CHECK (auth.uid() IN (
        SELECT user_id FROM workout_sessions WHERE id = session_id
    ));

-- Cardio Sessions
CREATE TABLE cardio_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    data TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    tipo TEXT NOT NULL,
    duracao_minutos INTEGER NOT NULL,
    distancia_km NUMERIC(6,2),
    calorias INTEGER,
    frequencia_cardiaca_media INTEGER,
    percepcao_esforco INTEGER CHECK (percepcao_esforco >= 1 AND percepcao_esforco <= 10),
    observacao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE cardio_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cardio"
    ON cardio_sessions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cardio"
    ON cardio_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own cardio"
    ON cardio_sessions FOR DELETE
    USING (auth.uid() = user_id);

-- Water Log
CREATE TABLE water_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    data DATE NOT NULL DEFAULT CURRENT_DATE,
    hora TIME DEFAULT CURRENT_TIME,
    quantidade_ml INTEGER DEFAULT 200,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE water_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own water logs"
    ON water_log FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own water logs"
    ON water_log FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Favorite Exercises
CREATE TABLE favorite_exercises (
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    exercise_id INTEGER NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, exercise_id)
);

ALTER TABLE favorite_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own favorites"
    ON favorite_exercises FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
    ON favorite_exercises FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
    ON favorite_exercises FOR DELETE
    USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_body_measurements_user_date ON body_measurements(user_id, data DESC);
CREATE INDEX idx_workouts_user ON workouts(user_id);
CREATE INDEX idx_workout_exercises_workout ON workout_exercises(workout_id);
CREATE INDEX idx_workout_sessions_user_date ON workout_sessions(user_id, data DESC);
CREATE INDEX idx_exercise_sets_session ON exercise_sets(session_id);
CREATE INDEX idx_exercise_sets_exercise ON exercise_sets(exercise_id);
CREATE INDEX idx_cardio_sessions_user_date ON cardio_sessions(user_id, data DESC);
CREATE INDEX idx_water_log_user_date ON water_log(user_id, data DESC);
