import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react';
import type { FirebaseAuthTypes } from '@react-native-firebase/auth';

let _auth: any = null;
function auth() {
  if (!_auth) _auth = require('@react-native-firebase/auth').default();
  return _auth;
}

interface AuthContextType {
  user: FirebaseAuthTypes.User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType>({} as AuthContextType);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<FirebaseAuthTypes.User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = auth().onAuthStateChanged((u) => {
      setUser(u);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    await auth().signInWithEmailAndPassword(email, password);
  }, []);

  const register = useCallback(async (email: string, password: string) => {
    await auth().createUserWithEmailAndPassword(email, password);
  }, []);

  const logout = useCallback(async () => {
    await auth().signOut();
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
