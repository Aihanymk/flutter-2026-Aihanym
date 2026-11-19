# Practice 11 — A Real Server: NOTES

## Level 1 — Postman findings

`GET https://jsonplaceholder.typicode.com/users` → **200 OK**, `Content-Type: application/json; charset=utf-8`.
The body is a **JSON array of 10 users**. `GET /users/1` → the same user as a single **object**.

### User (top level)

| field    | JSON type | Dart type | nullable? |
|----------|-----------|-----------|-----------|
| id       | number (int) | `int` | no |
| name     | string | `String` | no |
| username | string | `String` | no |
| email    | string | `String` | no |
| address  | object | `Address` | no |
| phone    | string (e.g. `1-770-736-8031 x56442`) | `String` (+ getter `phoneDigits`) | no |
| website  | string | `String?` | yes — the only field I treat as optional |
| company  | object | `Company` record `({String name, String catchPhrase})` | no |

### address (nested once)

| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string | `String` | no |
| suite   | string | `String` | no |
| city    | string | `String` | no |
| zipcode | string | `String` | no |
| geo     | object (nested twice: `address.geo`) | `Geo` | no |

### address.geo (nested twice)

| field | JSON type | Dart type | nullable? |
|-------|-----------|-----------|-----------|
| lat   | **string** (`"-37.3159"`) | `double` via `double.parse` | no |
| lng   | **string** (`"81.1496"`)  | `double` via `double.parse` | no |

### company

| field       | JSON type | Dart type | nullable? |
|-------------|-----------|-----------|-----------|
| name        | string | `String` | no |
| catchPhrase | string | `String` | no |
| bs          | string | not modelled (the app does not need it) | no |

`toJson()` therefore does not send `bs` back. `User.fromJson(user.toJson()) == user` still holds, because equality is on `id`.

### Other requests

| request | status | body |
|---------|--------|------|
| `GET /users/999` | **404 Not Found** | `{}` — an empty object, so without a status check `fromJson` would fail on `id` |
| `POST /users` (JSON body + `Content-Type: application/json`) | **201 Created** | my fields echoed back **plus `"id": 11`** — nothing is really saved |
| `GET /users?id=3` | 200 | a **list of one** user, not an object |

Mapping used in `ApiClient._check`: 401 → `UnauthorizedException`, 404 → `NotFoundException`, ≥ 500 → `ServerException(status)`.

## Level 5 — Two kinds of "no network"

| test | what I did | time until the Offline view |
|------|------------|-----------------------------|
| Airplane mode | emulator → Airplane mode on, pull to refresh | < 1 s (SocketException, the OS knows there is no route) |
| Network that leads nowhere | host set to the unreachable address `10.255.255.1`, Retry | **10 s** (connection timeout) |

I had no hotspot without internet, so the second test was done with an unreachable address.
Packets leave and never return, which is the same situation as a dead Wi-Fi.

### Observation: 75 s vs 10 s in DevTools

With a plain `http.Client()` the screen showed Offline after 10 s (my `.timeout(10s)`),
but DevTools → Network kept the request as `Pending` and later showed `Error` after **75 s**.
`.timeout()` only stops waiting in Dart; the socket stayed open until the OS gave up.
Fix: the client is `IOClient(HttpClient()..connectionTimeout = const Duration(seconds: 10))`,
so the socket is closed after 10 s as well. After that DevTools shows `Error`, **10 s**.

### Screenshots

- `screenshot_timeout.png` — DevTools → Network: `GET https://10.255.255.1/users`, no HTTP status (`Error`), 10 s
- `screenshot_200.png` — DevTools → Network: `GET /users`, 200, response body opened (`List (10 items)`)

## Checks

```
grep -rn "package:http" lib/
lib/core/api/api_client.dart
lib/features/users/user_repository.dart   # uses http.Response to expect 201
lib/main.dart                              # composition root: IOClient (package:http/io_client.dart)
```

`main.dart` is the one allowed exception: it is the only file that creates the HTTP client.
Screens and models never import `package:http`.