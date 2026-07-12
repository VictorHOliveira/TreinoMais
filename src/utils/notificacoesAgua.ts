type NotificationsModule = any;

const REGULAR_PREFIX = 'agua-regular';
const NAG_PREFIX = 'agua-nag';
let _modPromise: Promise<NotificationsModule | null> | null = null;
let _handlerSet = false;

async function loadNotifications(): Promise<NotificationsModule | null> {
  if (_modPromise) return _modPromise;

  _modPromise = (async () => {
    try {
      const mod = await import('expo-notifications');
      if (!_handlerSet) {
        mod.setNotificationHandler({
          handleNotification: async () => ({
            shouldShowAlert: true,
            shouldPlaySound: true,
            shouldSetBadge: false,
            shouldShowBanner: true,
            shouldShowList: true,
          }),
        });
        _handlerSet = true;
      }
      return mod;
    } catch {
      return null;
    }
  })();

  return _modPromise;
}

export async function setupCategoriaTomei(): Promise<void> {
  try {
    const mod = await loadNotifications();
    if (!mod) return;

    await mod.setNotificationCategoryAsync('agua-tomei', [
      {
        identifier: 'tomei',
        buttonTitle: 'Tomei! 💧',
        options: { opensAppToForeground: true },
      },
      {
        identifier: 'ignorar',
        buttonTitle: 'Ignorar',
        options: { opensAppToForeground: false },
      },
    ]);
  } catch (e) {
    console.warn('Erro ao configurar categoria de notificação:', e);
  }
}

export async function pedirPermissaoNotificacao(): Promise<boolean> {
  const mod = await loadNotifications();
  if (!mod) return false;

  const { status: existingStatus } = await mod.getPermissionsAsync();
  let finalStatus = existingStatus;
  if (existingStatus !== 'granted') {
    const { status } = await mod.requestPermissionsAsync();
    finalStatus = status;
  }
  return finalStatus === 'granted';
}

export async function agendarNotificacaoRegular(intervaloMinutos: number): Promise<void> {
  try {
    const mod = await loadNotifications();
    if (!mod) return;

    await cancelarNotificacaoRegular();
    await mod.scheduleNotificationAsync({
      identifier: REGULAR_PREFIX,
      content: {
        title: '💧 Hora de beber água!',
        body: 'Mantenha-se hidratado. Toque em "Tomei!" para registrar.',
        data: { tipo: 'regular' },
        categoryIdentifier: 'agua-tomei',
      },
      trigger: {
        type: mod.SchedulableTriggerInputTypes.TIME_INTERVAL,
        seconds: Math.max(intervaloMinutos * 60, 60),
        repeats: true,
      },
    });
  } catch (e) {
    console.warn('Erro ao agendar notificação regular:', e);
  }
}

export async function agendarNotificacaoNag(): Promise<void> {
  try {
    const mod = await loadNotifications();
    if (!mod) return;

    const identifier = `${NAG_PREFIX}-${Date.now()}`;
    await mod.scheduleNotificationAsync({
      identifier,
      content: {
        title: '💧 Beba água!',
        body: 'Você já tomou água? Toque em "Tomei!" para registrar.',
        data: { tipo: 'nag' },
        categoryIdentifier: 'agua-tomei',
      },
      trigger: {
        type: mod.SchedulableTriggerInputTypes.TIME_INTERVAL,
        seconds: 60,
        repeats: false,
      },
    });
  } catch (e) {
    console.warn('Erro ao agendar notificação nag:', e);
  }
}

async function cancelarNotificacaoRegular(): Promise<void> {
  try {
    const mod = await loadNotifications();
    if (!mod) return;

    const scheduled: any[] = await mod.getAllScheduledNotificationsAsync();
    const regular = scheduled.filter((n: any) => n.identifier === REGULAR_PREFIX);
    for (const n of regular) {
      await mod.cancelScheduledNotificationAsync(n.identifier);
    }
  } catch (e) {
    console.warn('Erro ao cancelar notificação regular:', e);
  }
}

export async function cancelarTodasNags(): Promise<void> {
  try {
    const mod = await loadNotifications();
    if (!mod) return;

    const scheduled: any[] = await mod.getAllScheduledNotificationsAsync();
    const nags = scheduled.filter((n: any) => n.identifier.startsWith(NAG_PREFIX));
    for (const n of nags) {
      await mod.cancelScheduledNotificationAsync(n.identifier);
    }
  } catch (e) {
    console.warn('Erro ao cancelar nags:', e);
  }
}

export async function cancelarTodasNotificacoesAgua(): Promise<void> {
  await cancelarNotificacaoRegular();
  await cancelarTodasNags();
}

export function iniciarListenerNag(
  onTomei: () => void,
): () => void {
  let limpar: (() => void) | null = null;

  (async () => {
    const mod = await loadNotifications();
    if (!mod) return;

    const subscription = mod.addNotificationResponseReceivedListener((response: any) => {
      if (response.actionIdentifier === 'tomei') {
        onTomei();
        mod.dismissNotificationAsync(response.notification.request.identifier);
      }
      if (response.notification.request.content.data?.tipo === 'nag') {
        agendarNotificacaoNag();
      }
    });

    const receivedSubscription = mod.addNotificationReceivedListener((notification: any) => {
      if (notification.request.content.data?.tipo === 'regular') {
        agendarNotificacaoNag();
      }
    });

    limpar = () => {
      subscription.remove();
      receivedSubscription.remove();
    };
  })();

  return () => {
    limpar?.();
  };
}
