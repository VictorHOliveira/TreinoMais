import { View, Text, StyleSheet } from 'react-native';

interface Props {
  tempo: number;
  formatarDuracao: (s: number) => string;
}

export default function TimerTreino({ tempo, formatarDuracao }: Props) {
  return (
    <View style={styles.tempoContainer}>
      <Text style={styles.tempoLabel}>Tempo</Text>
      <Text style={styles.tempo}>{formatarDuracao(tempo)}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  tempoContainer: {
    alignItems: 'center',
    marginBottom: 16,
  },
  tempoLabel: {
    fontSize: 14,
    color: '#888',
  },
  tempo: {
    fontSize: 36,
    fontWeight: 'bold',
    color: '#fff',
    fontVariant: ['tabular-nums'],
  },
});
