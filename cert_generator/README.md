# Self-signed SSL certificate generator
This simple script is designed to generate a self-signed SSL certificate using OpenSSL, using a root CA. To run it in Terminal, use the following command:
```bash
./generate_cert.sh \
  --domain sub.mydomain.xyz \
  [--alt sub2.mydomain.xyz] \
  [--alt sub3.mydomain.xyz] \
  --key-length 4096 \
  --validity 365 \
  --root-crt root.crt \
  --root-key root.key \
  --cleanup
```