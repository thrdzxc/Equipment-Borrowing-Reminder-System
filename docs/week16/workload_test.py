import concurrent.futures
import csv
import math
import sys
import time
import urllib.request

name = sys.argv[1]
workers = int(sys.argv[2])
duration = int(sys.argv[3])
url = "http://127.0.0.1:8000/api/health"

def worker(end_time):
    records = []
    while time.monotonic() < end_time:
        start = time.perf_counter()
        try:
            with urllib.request.urlopen(url, timeout=5) as response:
                status = response.status
                response.read()
        except Exception:
            status = 0

        elapsed_ms = (time.perf_counter() - start) * 1000
        records.append((status, elapsed_ms))
        time.sleep(0.5)

    return records

print("Workload:", name)
print("Clients:", workers)
print("Target duration:", duration, "seconds")
print("Endpoint:", url)

start = time.monotonic()
end = start + duration

with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
    futures = [pool.submit(worker, end) for _ in range(workers)]
    records = []
    for future in futures:
        records.extend(future.result())

actual = time.monotonic() - start
latencies = sorted(value for _, value in records)
total = len(records)
success = sum(1 for status, _ in records if status == 200)
errors = total - success

def percentile(values, p):
    if not values:
        return 0.0
    index = max(0, math.ceil(len(values) * p) - 1)
    return values[index]

result = {
    "workload": name,
    "clients": workers,
    "duration_seconds": round(actual, 2),
    "requests": total,
    "success": success,
    "errors": errors,
    "error_percent": round(100 * errors / total, 2) if total else 0,
    "requests_per_second": round(total / actual, 2),
    "average_ms": round(sum(latencies) / total, 2) if total else 0,
    "median_ms": round(percentile(latencies, 0.50), 2),
    "p95_ms": round(percentile(latencies, 0.95), 2)
}

for key, value in result.items():
    print(f"{key}: {value}")

with open(f"week16_{name}_results.csv", "w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=result.keys())
    writer.writeheader()
    writer.writerow(result)
