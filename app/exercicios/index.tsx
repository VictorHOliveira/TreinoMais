import { useState } from 'react';
import { View, StyleSheet } from 'react-native';
import ListaExercicios from '../../src/components/ListaExercicios';
import DetalhesExercicioModal from '../../src/components/DetalhesExercicioModal';
import exerciciosData from '../../src/data/exercicios.json';

const COR_FUNDO = '#1a1a2e';

export default function ExerciciosScreen() {
  const [exercicioDetalheId, setExercicioDetalheId] = useState<string | null>(null);

  const exercicioDetalhe = exercicioDetalheId
    ? exerciciosData.find((e: any) => e.id === exercicioDetalheId) ?? null
    : null;

  return (
    <View style={styles.container}>
      <ListaExercicios onDetalhe={setExercicioDetalheId} />
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
});
