# Kubernetes Library

<p align="center">
  <img alt="kubernetes-logo" src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Kubernetes_logo_without_workmark.svg/617px-Kubernetes_logo_without_workmark.svg.png?20190926210707" height="160" />
  <p align="center">Welcome to my Kubernetes Library, a storage place for my assets related to my journey around Kubernetes' Land</p>
</p>

---

![GitHub Latest Release](https://img.shields.io/github/v/release/carlosrodlop/K8s-lib?logo=github) ![GitHub Issues](https://img.shields.io/github/issues/carlosrodlop/K8s-lib?logo=github) [![gitleaks badge](https://img.shields.io/badge/protected%20by-gitleaks-blue)](https://github.com/zricethezav/gitleaks#pre-commit) [![gitsecrets](https://img.shields.io/badge/protected%20by-gitsecrets-blue)](https://github.com/awslabs/git-secrets) [![helm docs](https://img.shields.io/badge/docs%20by-helmdocs-blue)](https://github.com/norwoodj/helm-docs) [![mdLinkChecker](https://github.com/carlosrodlop/K8s-lib/actions/workflows/mdLinkChecker.yml/badge.svg)](https://github.com/carlosrodlop/K8s-lib/actions/workflows/mdLinkChecker.yml)

| [Documentation](https://github.com/carlosrodlop/carlosrodlop-docs/tree/main/kubernetes) | [References](https://github.com/carlosrodlop/carlosrodlop-docs#kubernetes) |
| --------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |

## About

- It is a collection of resources to operate with Kubernetes including:
  - Application Definition: Manifests and Templates (Helm charts)
  - Scripts
  - Makefiles to orchestrate commands and processes
- Note: Services and Namespaces names are not configurable to avoid break integrations.

## Usage

- Parametrization is done using `.env` files. Copy `.env.example` to `.env` to customize the environment variables. Some variables can be passed as arguments to target in the make command (ROOT for example).
- It is Developed using Containers from the [Docker Library](https://github.com/carlosrodlop/docker-lib): `swissknife.ubuntu` and `swissknife.alpine`
- It uses submodules. For example, Helm chart `cb-ci-local` uses Casc Bundles from [carlosrodlop/cb-casc-controllers](https://github.com/carlosrodlop/cb-casc-controllers/tree/main) and [carlosrodlop/cb-casc-oc](https://github.com/carlosrodlop/cb-casc-oc/tree/main).
  - ⚠️ IMPORTANT - It requires `git submodule update --init --recursive`
- It uses [Pre-commits](.pre-commit-config.yaml). See [quickstart](https://pre-commit.com/#quick-start)
