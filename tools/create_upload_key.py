"""Create a local Android upload key without printing passwords."""
from pathlib import Path
import os
import secrets
import shutil
import subprocess

root = Path(__file__).resolve().parents[1]
keystore = root / 'android' / 'upload-keystore.jks'
properties = root / 'android' / 'key.properties'
if keystore.exists() or properties.exists():
    raise SystemExit('Existing signing files found; refusing to overwrite.')
keytool = shutil.which('keytool') or str(
    Path(os.environ.get('ProgramFiles', 'C:/Program Files'))
    / 'Android/Android Studio/jbr/bin/keytool.exe'
)
password = secrets.token_urlsafe(36)
environment = os.environ.copy()
environment['SIMSABUN_KEY_PASSWORD'] = password
subprocess.run([
    keytool, '-genkeypair', '-v', '-keystore', str(keystore),
    '-storetype', 'JKS', '-alias', 'upload', '-keyalg', 'RSA',
    '-keysize', '2048', '-validity', '10000',
    '-storepass:env', 'SIMSABUN_KEY_PASSWORD',
    '-keypass:env', 'SIMSABUN_KEY_PASSWORD',
    '-dname', 'CN=SIMSABUN Upload, OU=Mobile, O=SIMSABUN, C=KR',
], check=True, env=environment)
properties.write_text(
    f'storePassword={password}\nkeyPassword={password}\n'
    'keyAlias=upload\nstoreFile=upload-keystore.jks\n', encoding='utf-8'
)
print('Created android/upload-keystore.jks and android/key.properties.')
print('Back up both files privately. Passwords were not printed.')
