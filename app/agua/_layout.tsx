import { Stack } from 'expo-router';

const COR_FUNDO = '#1a1a2e';

export default function AguaLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: true,
        headerStyle: { backgroundColor: COR_FUNDO },
        headerTintColor: '#fff',
      }}
    >
      <Stack.Screen
        name="index"
        options={{
          headerTitle: 'Tomar Água',
        }}
      />
      <Stack.Screen
        name="config"
        options={{
          headerTitle: 'Configurar Água',
          presentation: 'modal',
        }}
      />
    </Stack>
  );
}
