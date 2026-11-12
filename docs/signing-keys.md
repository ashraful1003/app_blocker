# Release Signing Key Setup

These steps create the signing key for Google Play releases. Do them once,
before milestone M7.

## 1. Generate the upload keystore

On your local machine (not in a cloud session):

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias upload
```

You will be asked for:
- A keystore password (save it securely)
- Your name, organisation and location
- A key password (can be the same as the keystore password)

## 2. Create key.properties

Create a file called `key.properties` (do NOT commit this file):

```properties
storePassword=<your keystore password>
keyPassword=<your key password>
keyAlias=upload
storeFile=upload-keystore.jks
```

## 3. Add secrets to GitHub

1. Base64-encode the keystore:
   ```bash
   base64 -i upload-keystore.jks -o keystore-base64.txt
   ```

2. In your GitHub repository, go to Settings → Secrets and variables → Actions.

3. Add two repository secrets:
   - `KEYSTORE_BASE64`: paste the contents of `keystore-base64.txt`
   - `KEY_PROPERTIES`: paste the contents of `key.properties`

4. Delete the local `keystore-base64.txt` file.

## 4. Store backups securely

- Keep `upload-keystore.jks` and `key.properties` in a secure location
  (e.g. a password manager).
- If you lose the upload key, you can reset it through Google Play Console,
  but it takes time.

## 5. Enable Play App Signing

When you upload your first AAB to Google Play:
1. Google Play Console → Release → Setup → App signing.
2. Choose "Use Google-generated key" for the app signing key.
3. Upload your `upload-keystore.jks` as the upload key.

Google signs the final APK with their key. You sign the upload with yours.

## Security notes

- Never commit `.jks`, `.keystore` or `key.properties` files.
- The `.claude/settings.json` denies reading or writing these files.
- The `.gitignore` excludes them.
- Only GitHub Actions uses the secrets, via the `release.yml` workflow.
