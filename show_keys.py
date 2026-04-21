import os
import sys
from pathlib import Path

# Ensure the backend config is importable

# Add ceo/backend to sys.path so ceo.backend.config.keys_manager can be imported
sys.path.insert(0, str(Path(__file__).parent / 'ceo' / 'backend'))

from config.keys_manager import KeysManager

if __name__ == '__main__':
    # Optionally set MASTER_KEY if you have it as an env var or in .env
    master_key = os.environ.get('MASTER_KEY')
    if not master_key:
        print("[ERROR] MASTER_KEY environment variable is not set. Cannot decrypt keys.")
        sys.exit(1)

    manager = KeysManager()
    # Load encrypted keys
    encrypted_keys = manager._read_persisted_keys()
    if not encrypted_keys:
        print("No keys found in .secure_keys.json.")
        sys.exit(0)

    print("Decrypted keys from .secure_keys.json:\n")
    for key, encrypted_value in encrypted_keys.items():
        try:
            decrypted = manager.decrypt_key(encrypted_value)
            print(f"{key}: {decrypted}")
        except Exception as e:
            print(f"{key}: [DECRYPTION FAILED] {e}")
