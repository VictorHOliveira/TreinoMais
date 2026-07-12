import { useState, useCallback } from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useRouter, useFocusEffect } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useTreinos, useHistorico } from '../../src/hooks/useTreinos';
import { carregarPerfil, carregarPerfilLocal } from '../../src/services/firestoreService';
import { PerfilUsuario } from '../../src/types';
import PainelAgua from '../../src/components/agua/PainelAgua';
import PainelCardio from '../../src/components/cardio/PainelCardio';

const COR_PRIMARIA = '#6C63FF';
const COR_FUNDO = '#1a1a2e';
const COR_CARD = '#16213e';
const COR_SUCESSO = '#4CAF50';
const COR_AVISO = '#ff9800';

const DICAS = [
  'Lembre-se de descansar 60-90 segundos entre as séries para máxima hipertrofia.',
  'Beba pelo menos 500ml de água durante o treino para manter o desempenho.',
  'Aqueça com 5-10 minutos de cardio leve antes de começar os exercícios.',
  'Varie os exercícios a cada 4-6 semanas para estimular os músculos de forma diferente.',
  'Durma 7-8 horas por noite para otimizar a recuperação muscular.',
  'Coma proteína dentro de 30 minutos após o treino para melhor recuperação.',
  'A técnica é mais importante que a carga. Foque na execução correta.',
];

function getMsgHorario(): string {
  const h = new Date().getHours();
  if (h < 12) return 'Bom dia';
  if (h < 18) return 'Boa tarde';
  return 'Boa noite';
}

function getRandomDica(): string {
  return DICAS[Math.floor(Math.random() * DICAS.length)];
}

export default function HomeScreen() {
  const router = useRouter();
  const { treinos } = useTreinos();
  const { historico } = useHistorico();
  const [perfil, setPerfil] = useState<PerfilUsuario | null>(null);
  const [dica] = useState(getRandomDica);

  useFocusEffect(
    useCallback(() => {
      (async () => {
        const local = await carregarPerfilLocal();
        setPerfil(local);

        const remote = await carregarPerfil();
        if (JSON.stringify(local) !== JSON.stringify(remote)) setPerfil(remote);
      })();
    }, [])
  );

  const diasSeguidos = historico.length >= 3;

  const nomeUsuario = perfil?.nome?.trim() || 'Atleta';

  return (
    <View style={styles.container}>
      <View style={styles.headerRow}>
        <View style={styles.greetingSection}>
          <Text style={styles.greeting}>{getMsgHorario()}, </Text>
          <Text style={styles.nome}>{nomeUsuario}</Text>
        </View>
        <View style={styles.headerIcons}>
          <TouchableOpacity onPress={() => router.push('/perfil')} style={styles.headerIcon}>
            <Ionicons name="person-circle" size={36} color={COR_PRIMARIA} />
          </TouchableOpacity>
        </View>
      </View>

      {perfil && (
        <View style={styles.perfilBadge}>
          <Ionicons name="fitness" size={14} color={COR_PRIMARIA} />
          <Text style={styles.perfilBadgeTexto}>
            {perfil.nivel.charAt(0).toUpperCase() + perfil.nivel.slice(1)} • {perfil.objetivo || 'Treino'}
          </Text>
        </View>
      )}

      <View style={styles.stats}>
        <TouchableOpacity
          style={styles.statCard}
          onPress={() => router.push('/treinos')}
          activeOpacity={0.7}
        >
          <Ionicons name="barbell" size={26} color={COR_PRIMARIA} />
          <Text style={styles.statNumero}>{treinos.length}</Text>
          <Text style={styles.statLabel}>Treinos</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.statCard}
          onPress={() => router.push('/concluidos')}
          activeOpacity={0.7}
        >
          <Ionicons name="checkmark-circle" size={26} color={COR_SUCESSO} />
          <Text style={styles.statNumero}>{historico.length}</Text>
          <Text style={styles.statLabel}>Concluídos</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.statCard}
          onPress={() => router.push('/historico')}
          activeOpacity={0.7}
        >
          <Ionicons name="time" size={26} color={COR_PRIMARIA} />
          <Text style={styles.statNumero}>{historico.length}</Text>
          <Text style={styles.statLabel}>Histórico</Text>
        </TouchableOpacity>
      </View>

      {diasSeguidos && (
        <View style={styles.badgeConquista}>
          <Ionicons name="trophy" size={18} color="#FFD700" />
          <Text style={styles.badgeTexto}>Parabéns! Você treinou 3+ vezes essa semana!</Text>
        </View>
      )}

      <TouchableOpacity
        style={styles.botaoPrincipal}
        onPress={() => router.push('/criar-treino')}
      >
        <Ionicons name="add-circle" size={24} color="#fff" />
        <Text style={styles.botaoTexto}>Criar Novo Treino</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={styles.botaoSecundario}
        onPress={() => router.push('/exercicios')}
      >
        <Ionicons name="fitness" size={24} color={COR_PRIMARIA} />
        <Text style={styles.botaoSecundarioTexto}>Ver Exercícios</Text>
      </TouchableOpacity>

      <PainelAgua />

      <PainelCardio />

      <View style={styles.dicas}>
        <Text style={styles.dicasTitulo}>Dica do Dia</Text>
        <Text style={styles.dicasTexto}>{dica}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COR_FUNDO,
    padding: 20,
    paddingTop: 60,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 4,
  },
  greetingSection: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    flexShrink: 1,
  },
  headerIcons: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  headerIcon: {
    padding: 4,
  },
  greeting: {
    fontSize: 22,
    color: '#fff',
  },
  nome: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#fff',
  },
  perfilBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    gap: 6,
    backgroundColor: COR_PRIMARIA + '15',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    marginBottom: 24,
    marginTop: 8,
  },
  perfilBadgeTexto: {
    fontSize: 12,
    color: COR_PRIMARIA,
    fontWeight: '600',
  },
  stats: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 16,
  },
  statCard: {
    flex: 1,
    backgroundColor: COR_CARD,
    borderRadius: 16,
    padding: 16,
    alignItems: 'center',
    gap: 6,
    borderWidth: 1,
    borderColor: '#333',
  },
  statNumero: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
  statLabel: {
    fontSize: 11,
    color: '#888',
  },
  badgeConquista: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    backgroundColor: '#FFD700' + '15',
    borderRadius: 12,
    padding: 12,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#FFD700' + '30',
  },
  badgeTexto: {
    fontSize: 13,
    color: '#FFD700',
    fontWeight: '600',
    flex: 1,
  },
  botaoPrincipal: {
    backgroundColor: COR_PRIMARIA,
    borderRadius: 16,
    padding: 18,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    marginBottom: 12,
  },
  botaoTexto: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  botaoSecundario: {
    backgroundColor: COR_CARD,
    borderRadius: 16,
    padding: 18,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    marginBottom: 24,
    borderWidth: 1,
    borderColor: '#333',
  },
  botaoSecundarioTexto: {
    color: COR_PRIMARIA,
    fontSize: 16,
    fontWeight: '600',
  },
  dicas: {
    backgroundColor: COR_CARD,
    borderRadius: 16,
    padding: 20,
    borderLeftWidth: 4,
    borderLeftColor: COR_PRIMARIA,
  },
  dicasTitulo: {
    fontSize: 16,
    fontWeight: 'bold',
    color: COR_PRIMARIA,
    marginBottom: 8,
  },
  dicasTexto: {
    fontSize: 14,
    color: '#aaa',
    lineHeight: 20,
  },
});
