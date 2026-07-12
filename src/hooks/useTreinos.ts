import { useState, useCallback } from 'react';
import { useFocusEffect } from 'expo-router';
import { Treino, TreinoCompleto } from '../types';
import { carregarTreinos, salvarTreino, deletarTreino, carregarHistorico, salvarHistorico, carregarTreinosLocal, carregarHistoricoLocal } from '../services/firestoreService';

export function useTreinos() {
  const [treinos, setTreinos] = useState<Treino[]>([]);
  const [carregando, setCarregando] = useState(true);

  const carregar = useCallback(async () => {
    try {
      setCarregando(true);
      const dados = await carregarTreinosLocal();
      setTreinos(dados);
      setCarregando(false);

      const dadosR = await carregarTreinos();
      if (JSON.stringify(dados) !== JSON.stringify(dadosR)) setTreinos(dadosR);
    } catch (e) {
      console.warn('Erro ao carregar treinos:', e);
      setTreinos([]);
      setCarregando(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      carregar();
    }, [carregar])
  );

  const adicionarOuEditarTreino = async (treino: Treino) => {
    try {
      await salvarTreino(treino);
      await carregar();
    } catch (e) {
      console.warn('Erro ao salvar treino:', e);
    }
  };

  const deletar = async (id: string) => {
    try {
      await deletarTreino(id);
      await carregar();
    } catch (e) {
      console.warn('Erro ao deletar treino:', e);
    }
  };

  return { treinos, carregando, adicionarOuEditarTreino, deletar, recarregar: carregar };
}

export function useHistorico() {
  const [historico, setHistorico] = useState<TreinoCompleto[]>([]);
  const [carregando, setCarregando] = useState(true);

  const carregar = useCallback(async () => {
    try {
      setCarregando(true);
      const dados = await carregarHistoricoLocal();
      setHistorico(dados);
      setCarregando(false);

      const dadosR = await carregarHistorico();
      if (JSON.stringify(dados) !== JSON.stringify(dadosR)) setHistorico(dadosR);
    } catch (e) {
      console.warn('Erro ao carregar histórico:', e);
      setHistorico([]);
      setCarregando(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      carregar();
    }, [carregar])
  );

  const salvar = async (treino: TreinoCompleto) => {
    try {
      await salvarHistorico(treino);
      await carregar();
    } catch (e) {
      console.warn('Erro ao salvar histórico:', e);
    }
  };

  return { historico, carregando, salvar, recarregar: carregar };
}
