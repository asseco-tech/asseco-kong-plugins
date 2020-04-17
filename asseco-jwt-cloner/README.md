# asseco-jwt-cloner
#### Version: 1.0.0

Plugin **asseco-jwt-cloner** for KONG

GitHub Repository: https://github.com/asseco-tech/asseco-kong-plugins

## Specification
Copying JWT Key from request body to Authorization header. 
Supported Content-Type: x-www-form-urlencoded.

Plugin Params:
 - `config.cloning_field` - field name in body with JWT Key
 - `config.header_overwrite` - overwrite existing Authorization header

## License
 - [LICENSE](LICENSE)
