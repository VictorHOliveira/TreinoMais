import { useEffect, useRef } from 'react';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuth } from '../src/contexts/AuthContext';
import { checkAndMigrate } from '../src/services/syncFirestore';

const COR_FUNDO = '#1a1a2e';
const COR_PRIMARIA = '#6C63FF';

export default function Index() {
  const { user, loading } = useAuth();
  const router = useRouter();
  const migrated = useRef(false);

  useEffect(() => {
    if (loading) return;
    if (user) {
      if (!migrated.current) {
        migrated.current = true;
        checkAndMigrate(user.uid).catch(console.error);
      }
      router.replace('/(tabs)');
    } else {
      router.replace('/login');
    }
  }, [user, loading]);

  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" color={COR_PRIMARIA} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COR_FUNDO,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
