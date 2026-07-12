import { useState, useCallback, useLayoutEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useRouter, useNavigation } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import ListaExercicios from '../../src/components/ListaExercicios';
import DetalhesExercicioModal from '../../src/components/DetalhesExercicioModal';
import { confirmarSelecao } from '../../src/utils/selecionarExercicioState';
import exerciciosData from '../../src/data/exercicios.json';

const COR_FUNDO = '#1a1a2e';
const COR_PRIMARIA = '#6C63FF';
const COR_CARD = '#16213e';

export default function SelecionarExercicioScreen() {
  const router = useRouter();
  const navigation = useNavigation();
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [exercicioDetalheId, setExercicioDetalheId] = useState<string | null>(null);

  const toggle = useCallback((id: string) => {
    setSelectedIds(prev => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
  }, []);

  const handleAdicionar = () => {
    if (selectedIds.size === 0) return;
    confirmarSelecao([...selectedIds]);
    router.dismiss();
  };

  useLayoutEffect(() => {
    navigation.setOptions({
      headerRight: () =>
        selectedIds.size > 0 ? (
          <TouchableOpacity
            onPress={handleAdicionar}
            style={styles.headerBotao}
            activeOpacity={0.7}
          >
            <Ionicons name="checkmark-circle" size={20} color="#fff" />
            <Text style={styles.headerBotaoTexto}>Adicionar ({selectedIds.size})</Text>
          </TouchableOpacity>
        ) : null,
    });
  }, [navigation, selectedIds]);

  const exercicioDetalhe = exercicioDetalheId
    ? exerciciosData.find((e: any) => e.id === exercicioDetalheId) ?? null
    : null;

  return (
    <View style={styles.container}>
      <ListaExercicios
        selecionaveis
        idsSelecionados={selectedIds}
        mostrarPR={false}
        mostrarDescricao={false}
        onDetalhe={setExercicioDetalheId}
        onSelect={toggle}
      />

      <DetalhesExercicioModal
        exercicio={exercicioDetalhe}
        visible={!!exercicioDetalhe}
        onClose={() => setExercicioDetalheId(null)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COR_FUNDO,
  },
  headerBotao: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: COR_PRIMARIA,
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 8,
    marginRight: 4,
  },
  headerBotaoTexto: {
    fontSize: 13,
    fontWeight: 'bold',
    color: '#fff',
  },
});
