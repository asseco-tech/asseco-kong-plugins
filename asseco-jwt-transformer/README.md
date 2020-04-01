# asseco-jwt-transformer

This is a [Kong](https://konghq.com/kong/) middleware to operate on selected values from *Json Web Token* (*JWT*) provided in HTTP authorization header. Selected values can be cloned to the request body or they can be used to create request headers.

## Configuration

Configure this plugin on a Route with:

```
curl -X POST "http://kong:8001/routes/{route_id}/plugins \
    --data "name=asseco-jwt-transformer" \
    --data "config.cloning_fields=login" \
    --data "config.hashed_cloning_fields=password" \
    --data "config.cloning_place=body"
```

- **route_id** - the id of the Route that this plugin configuration will target,
- **config.cloning_fields** - optional, the list of field names for cloning,
- **config.hashed_cloning_fields** - optional, the list of field names for cloning; additionally, values are hashed (using *MD5* algorithm),
- **config.cloning_place** - if it equals `body` then field and its value is cloned to request body; if it equals `header` - the plugin creates request headers in form `X-JWT-{field_name}` (default: `body`).


## Examples

Token payload:

```json
{
  "login": "abracadabra",
  "password": "youknowmypwd"
}
```

### *Example 1*.

Plugin configuration:

```json
cloning_fields: "login"
hashed_cloning_fields: "password"
```

Request body:

```json
{
  "jwt": {
    "login": "abracadabra",
    "password": "5083fa1d525cf0274ad1633e2bcb89f5"
  },
  [... request body ...]
}
```

### *Example 2*.

Plugin configuration:

```json
cloning_fields: "login"
hashed_cloning_fields: "password"
cloning_place: "header"
```

Request headers:

```
X-JWT-login: abracadabra
X-JWT-password: 5083fa1d525cf0274ad1633e2bcb89f5
```

## Credits

Enrique García Cota + Adam Baldwin + hanzao + Equi 4 Software (
[MD5 computation in Lua (5.1-3, LuaJIT)](https://github.com/kikito/md5.lua))
