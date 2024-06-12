# Python Style Guide

## Code Snippets / Tips

### Using Strict Types

```python

def number_checksum(number: str) -> bool:
	def digits_of(nr: str) -> list[int]:
		return [int(d) for d in nr]

```

### Using Joblib for parallel tasks / iterations only

```python
from joblib import Parallel, delayed

#results = [math.factorial(x) for x in range(10000)]

results = Parallel(n_jobs=-1)(delayed(math.factorial)(x) for x in range(10000))
```

### Using asyncio for concurrency

```python

async def get_random_name_from_api() -> str:
	name_id = randint(1, 100)
	api_url = f"https://{website}/api/{name_id}"
	character = http_get_sync(api_url)
	return str(character["name"])

async def main() -> None:
	result = await asyncio.gather(*[get_random_name_from_api for _ in range(20)])
	print(result)

if __name__ == "__main__":
	asyncio.run(main())

```

### Handy JSON Types

```python

JSON = int | str | float | bool | None | dict[str, "JSON"] | list["JSON"]
JSONObject = dict[str, JSON]
JSONList = list[JSON]

# http get request syncer / list of requests
import requests

def http_get_sync(url: str) -> JSONObject:
	response = requests.get(url)
	return response.json()

async def http_get(url: str) -> JSONObject:
	return await asyncio.to_thread(http_get_sync, url)

# http async requests with aiohttp
import aiohttp

async def http_get(url: str) -> JSONObject:
	async with aiohttp.ClientSession() as session:
		async with session.get(url) as response:
			return await response.json()

```
