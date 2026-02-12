# Amplify pipeline configuration

Configurar no console do Amplify:

- Branch `main` -> ambiente `prod`
- Branch `develop` -> ambiente `dev`
- Variáveis por branch:
  - `VUE_APP_API_URL=https://<alb-dns-ou-dominio>/api/`
- Build settings (`amplify.yml`):

```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - cd frontend
        - npm ci
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: frontend/dist
    files:
      - '**/*'
  cache:
    paths:
      - frontend/node_modules/**/*
```

- Rewrites and redirects para SPA:
  - Source: `</^[^.]+$|\.(?!(css|js|png|jpg|svg|ico|json)$)([^.]+$)/>`
  - Target: `/index.html`
  - Type: `200 (Rewrite)`
