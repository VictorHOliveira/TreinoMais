import '@react-native-firebase/app';

let _authInstance: any = null;
let _firestoreInstance: any = null;

export function getAuth() {
  if (!_authInstance) {
    const mod = require('@react-native-firebase/auth');
    _authInstance = mod.default();
  }
  return _authInstance;
}

export function getDb() {
  if (!_firestoreInstance) {
    const mod = require('@react-native-firebase/firestore');
    _firestoreInstance = mod.default();
  }
  return _firestoreInstance;
}

export const USERS_COLLECTION = 'users';
