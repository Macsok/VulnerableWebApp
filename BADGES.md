# GitHub Actions Badges dla README.md

Możesz dodać te badge'y do swojego README.md aby pokazać status workflow'ów:

## SAST Checkov Scan
```markdown
![SAST Security Scan](https://github.com/Macsok/VulnerableWebApp/actions/workflows/sast-checkov.yml/badge.svg)
```

## Docker Image CI
```markdown
![Docker Image CI](https://github.com/Macsok/VulnerableWebApp/actions/workflows/docker-image.yml/badge.svg)
```

## Azure Deployment
```markdown
![Azure Deployment](https://github.com/Macsok/VulnerableWebApp/actions/workflows/azure.yml/badge.svg)
```

## Wszystkie razem w README.md
Dodaj na górze README.md:

```markdown
# VulnerableWebApp

![SAST Security Scan](https://github.com/Macsok/VulnerableWebApp/actions/workflows/sast-checkov.yml/badge.svg)
![Docker Image CI](https://github.com/Macsok/VulnerableWebApp/actions/workflows/docker-image.yml/badge.svg)
![Azure Deployment](https://github.com/Macsok/VulnerableWebApp/actions/workflows/azure.yml/badge.svg)
```

Badge'y będą pokazywać:
- ✅ Zielony - workflow zakończył się sukcesem
- ❌ Czerwony - workflow się nie powiódł
- 🟡 Żółty - workflow jest w trakcie
