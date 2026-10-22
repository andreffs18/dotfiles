#!/usr/bin/env python3
"""
Refreshes the Feedly OAuth token by reading the feedly.token.auth cookie
directly from Chrome via the macOS Keychain.

Setup (one-time):
  python -m pip install browser-cookie3 requests
"""
import os
import re
import sys

import browser_cookie3
import requests


FEEDLY_API = "https://cloud.feedly.com/v3"
SECRETS_FILE = os.path.expanduser("~/.secrets")


def get_token():
    """
    Read and decrypt Chrome cookies for feedly.com via the macOS Keychain.
    Note: macOS may prompt for Keychain access the first time this runs.
    """
    cj = browser_cookie3.chrome(domain_name=".feedly.com")
    cookies = list(cj)
    for c in cookies:
        print(f"  {c.name}: {c.value[:40]}...")
    return next((c.value for c in cookies if c.name == "feedly.token.auth"), None)


def verify_token(token):
    """Verify the token is valid by hitting the Feedly profile endpoint."""
    r = requests.get(f"{FEEDLY_API}/profile", headers={"Authorization": f"OAuth {token}"})
    if r.ok:
        print(f"  Authenticated as: {r.json().get('email')}")
    return r.ok


def update_secrets(token):
    """Replace all existing FEEDLY_TOKEN lines in ~/.secrets with the new token."""
    with open(SECRETS_FILE, "r") as f:
        content = f.read()

    content = re.sub(r"export FEEDLY_TOKEN=[^\n]*\n?", "", content)
    content = content.rstrip("\n") + f"\nexport FEEDLY_TOKEN={token}\n"

    with open(SECRETS_FILE, "w") as f:
        f.write(content)


def main():
    print("🍪 Reading Chrome cookies for feedly.com...")
    token = get_token()

    if not token:
        print("❌ feedly.token.auth cookie not found. Make sure you're logged into Feedly in Chrome.")
        sys.exit(1)

    print("🔍 Verifying token against Feedly API...")
    if not verify_token(token):
        print("❌ Token is invalid or expired. Try logging into Feedly in Chrome again.")
        sys.exit(1)

    update_secrets(token)
    print("✅ FEEDLY_TOKEN updated in ~/.secrets")
    print("   Run `resource` or open a new terminal tab to use it.")


if __name__ == "__main__":
    main()
