import { useState, useEffect, useCallback } from 'react';
import { RecordesMap } from '../types';
import { carregarRecordes } from '../services/firestoreService';

export function useRecordes() {
  const [recordes, setRecordes] = useState<RecordesMap>({});
  const [carregando, setCarregando] = useState(true);

  const carregar = useCallback(async () => {
    try {
      setCarregando(true);
      const dados = await carregarRecordes();
      setRecordes(dados);
    } catch (e) {
      console.warn('Erro ao carregar recordes:', e);
      setRecordes({});
    } finally {
      setCarregando(false);
    }
  }, []);

  useEffect(() => {
    carregar();
  }, [carregar]);

  return { recordes, carregando, recarregar: carregar };
}
