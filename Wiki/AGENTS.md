# Agent Guide for Villalab Homelab

This file is a quick operational guide for AI agents working on this homelab wiki and its related Docker stacks.

## Machine Overview
- Hostname/access target: `pilla`
- SSH user: `villacus`
- Purpose: personal homelab for self-hosted services, media, DNS filtering, file sharing, remote access, and admin tools
- Primary network access patterns:
  - LAN services usually expose ports on `192.168.0.9:PORT`
  - Remote access is often published through Tailscale under `name-service.tailf45616.ts.net`

## Source of Truth
- The canonical stack reference is [servicios.md](servicios.md)
- The individual wiki pages should reflect what is actually deployed in Docker
- Do not invent services or settings that are not in `servicios.md` unless the user explicitly asks for a proposal

## Services Present on the Host
- [Homepage](Homepage.md): dashboard for system and container status
- [Immich](Immich.md): photo and video library platform
- [Navidrome](Navidrome.md): music streaming server
- [Nextcloud](Nextcloud.md): private cloud storage and collaboration
- [Odysseus](Odysseus.md): local information search / query service with ChromaDB
- [Pi-hole](Pi-hole.md): network ad blocker with Unbound recursive DNS
- [Portainer](Portainer.md): Docker administration UI
- [Samba](Samba.md): SMB/CIFS file sharing
- [Speedtest](Speedtest.md): network speed test server
- [Vaultwarden](Vaultwarden.md): self-hosted password manager
- [Tailscale](Tailscale.md): host-level remote access and service publication notes

## Operational Rules
- Prefer the current deployed stack over assumptions
- If a wiki page conflicts with `servicios.md`, treat `servicios.md` as the reference for documentation
- Do not modify the host or containers unless the user explicitly asks for changes
- Avoid changing secrets in place unless the user explicitly requests a security pass
- Keep documentation consistent:
  - title
  - short description
  - Docker stack
  - explanation by section
  - access URLs
  - volumes
  - environment variables
  - `.env` example when applicable
  - restart policy

## Tailscale Notes
- Tailscale runs on the host, not as a normal application container in the wiki flow
- Useful commands already used on the machine:
  - `tailscale status`
  - `tailscale status --self`
  - `tailscale ping <ip>`
  - `sudo tailscale up`
  - `sudo tailscale down`
  - `sudo tailscale logout`
  - `sudo tailscale set --operator=$USER`
  - `sudo tailscale serve --bg --https 443 --service=svc:<name> 127.0.0.1:<port>`
  - `tailscale serve clear svc:<name>`
  - `tailscale serve reset svc:<name>`
  - `tailscale funnel off`
- Common published services include Portainer, Vaultwarden, Homepage, Nextcloud, Speedtest, Navidrome, Pi-hole, and Odysseus

## Access Patterns
- Homepage: `192.168.0.9:3000`
- Immich: `192.168.0.9:2283`
- Navidrome: `192.168.0.9:4533`
- Nextcloud: `192.168.0.9:8081`
- Odysseus: `192.168.0.9:7000`
- Portainer: `192.168.0.9:9000`
- Speedtest: `192.168.0.9:3002`
- Vaultwarden: `192.168.0.9:8080`
- Samba: SMB on `192.168.0.9:445`
- Pi-hole: web UI under `/admin`, DNS on the LAN host

## Security Guidance
- Never commit or document real passwords in plaintext when a variable or placeholder can be used
- If a page currently contains a secret, mark it for replacement with `.env` in a follow-up pass
- Use `restart: unless-stopped` for most services unless the live stack intentionally uses `always`
- When documenting volume paths, prefer the real mounted paths from the deployed stack

## Current Wiki Workflow
1. Read the live stack source (`servicios.md` and/or Docker on the host)
2. Update the matching wiki page
3. Keep the wording aligned with the actual deployed configuration
4. Save security hardening for a dedicated pass after documentation is correct

## Notes for Future Agents
- The wiki is in Spanish, but short English headings are acceptable if they help automation
- Be conservative: if data is unclear, ask or inspect the host instead of guessing
- Do not rewrite the host-level Tailscale setup into a Docker stack page
