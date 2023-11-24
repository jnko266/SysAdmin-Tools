# How to run Certbot Docker container?
## TL;DR  
``` shell
docker run -it --rm \
    -v "${PWD}/certs_$(date +%Y%m%d_%H%M%S)":/etc/letsencrypt \
    -v "${PWD}/logs_$(date +%Y%m%d_%H%M%S)":/var/log/letsencrypt \
    certbot/certbot certonly --manual --preferred-challenges=dns
```
## How to use this? 
This simple command uses the official [Certbot Docker image](https://hub.docker.com/r/certbot/certbot) in manual mode (i.e. certificates won't get renewed automatically) using DNS challenge.  
This also creates two directories in the directory where the command gets executed. In these directories, the certificates and logs will be stored.  
When the command above gets executed, it will ask for some information, such as email address and domain name(s) to be included in the certificate. The DNS challenge will be used to verify that you are the owner of the domain(s). This means you will have to deploy a DNS TXT record to the `_acme-challenge.yourdomain.xyz` subdomain(s)
## When to use this?
This is useful for when you want to deploy a certificate on a machine which serves some content and accepts generated certificates, but doesn't allow you to install Certbot on it. Some applications generate certificates automatically, however only for specific records, such as `sub.domain.xyz`, but do not allow for generation of wildcard certificates, such as `*.domain.xyz`.