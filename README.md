# AegisTrap

AegisTrap is a modular multi-service honeypot for authorized lab research.
It emulates SSH, FTP, HTTP, and HTTPS services, records attacker activity,
and displays sessions, credentials, commands, requests, alerts, and analytics
in a local dashboard.

## Current Services

| Service | Default port | Behavior |
| --- | ---: | --- |
| SSH | 2222 | Real SSH handshake via Paramiko, password auth capture, fake Linux shell |
| FTP | 2121 | FTP command capture, login capture, basic listings |
| HTTP | 8080 | Realistic internal gateway/admin portal, login capture, request logging |
| HTTPS | 8443 | TLS-wrapped HTTP honeypot with self-signed certificate |
| Dashboard | 5000 | Local-only Flask dashboard on `127.0.0.1` |

## Setup and Configuration

### 1. Environment Variables (.env)

AegisTrap manages configuration overrides via environment variables.

1. Copy the template environment file:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and set a secure, unique key for `AEGISTRAP_DASHBOARD_SECRET_KEY` (e.g. generate a long random hex string).

---

## Running the Project

You can run AegisTrap either natively or using Docker.

### Option A: Running with Docker (Recommended)

Docker ensures AegisTrap runs consistently across different platforms.

1. **Build and Run container** (automatically starts all ports and binds host mounts):
   ```bash
   docker-compose up --build -d
   ```
2. **Stop container**:
   ```bash
   docker-compose down
   ```

*Persistent Data: Logs and sqlite database files are saved in the local `./logs` and `./data` directories on your host machine via Docker bind mounts.*

### Option B: Running Natively

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
2. **Run the honeypot**:
   ```bash
   python -m aegistrap
   ```

---

## Honeypot Endpoints

Once running, access the services using the following:

- **Dashboard**: `http://127.0.0.1:5000` (Contains captured activity; access is local-only by default)
- **SSH Trap**: `ssh -p 2222 root@<honeypot-ip>`
- **FTP Trap**: `ftp <honeypot-ip> 2121`
- **HTTP Trap**: `http://<honeypot-ip>:8080`
- **HTTPS Trap**: `https://<honeypot-ip>:8443`

---

## Team GitHub Sharing Workflow

Since multiple team members are uploading the project to their own GitHub repositories:
1. Ensure `.env` is **never committed** (pre-configured in `.gitignore`).
2. Run `git status` to verify that `data/aegistrap.db`, logs, and certificates are ignored before committing.
3. Teammates cloning the repository should follow the **Setup and Configuration** steps to create their own `.env` file.

---

## Safety Model

AegisTrap never executes attacker commands on the host operating system. SSH commands run against an in-memory virtual Linux session. HTTP/FTP/SSH inputs are logged and interpreted, not executed.

Do not expose the dashboard to the network. It contains captured credentials and attacker activity.
