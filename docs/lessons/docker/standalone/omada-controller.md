# Omada Controller — Java Heap OOM

## Symptoms

- Controller becomes unresponsive after several days of uptime
- Logs show `java.lang.OutOfMemoryError: Java heap space` across multiple threads
- MongoDB connection timeouts (`TimeoutException: 300000ms`) as a cascading effect
- Container memory usage grows to ~3GB before crash

## Root Cause

No `_JAVA_OPTIONS` set in compose — JVM runs with default max heap of **1024m**.
Insufficient for `mbentley/omada-controller:6.1.0.19` with embedded MongoDB under normal load.

## Fix

Add to `environment:` in compose (list format):

```yaml
- _JAVA_OPTIONS=-Xms512m -Xmx3072m
```

## Notes

- `_JAVA_OPTIONS` takes priority over CLI args without modifying them (JVM behavior)
- Use list format in compose, not dict format — mixing formats causes YAML parse error
- Tested on LXC with 8GB RAM; heap stabilizes around 2-3GB under normal load
- Ref: [mbentley docs — Low Resource Systems](https://github.com/mbentley/docker-omada-software-controller?tab=readme-ov-file#low-resource-systems)
