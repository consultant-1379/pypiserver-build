## Security Guidelines

### Operative Tasks

This service does not include any operative tasks.
{!../../build/markdown/fragments/.generated/service_ports.md!}

### Certificates

Python Package Repository Service uses service mesh based certificates for system-internal
TLS based communication.

  1. Application metrics over TLS need to be scraped using SM(Istio) certificates.
     Refer [TLS Setting for Metrics Scraping over Istio][smpromtls]

### Security Events that can be logged

No security events logged by the service.

[smpromtls]: https://istio.io/latest/docs/ops/integrations/prometheus/#tls-settings
