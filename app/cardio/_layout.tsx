import { Stack } from 'expo-router';

const COR_FUNDO = '#1a1a2e';

export default function CardioLayout() {
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
          headerTitle: 'Cardio',
        }}
      />
      <Stack.Screen
        name="adicionar"
        options={{
          headerTitle: 'Adicionar Cardio',
          presentation: 'modal',
        }}
      />

    </Stack>
  );
}
