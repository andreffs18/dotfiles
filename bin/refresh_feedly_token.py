#!/usr/bin/env python3
"""
Refreshes the Feedly OAuth token by reading the `feedly.session` entry
(field `feedlyToken`) from Chrome's localStorage for https://feedly.com.

Setup (one-time):
  python -m pip install dfindexeddb python-snappy requests zstd
"""
import json
import os
import pathlib
import re
import shutil
import sys
import tempfile

import requests
from dfindexeddb.leveldb.record import FolderReader


FEEDLY_API = "https://cloud.feedly.com/v3"
SECRETS_FILE = os.path.expanduser("~/.secrets")
CHROME_LS = os.path.expanduser(
    "~/Library/Application Support/Google/Chrome/Default/Local Storage/leveldb"
)


def get_token():
    """Read feedlyToken from Chrome's localStorage (copied, as Chrome locks the DB)."""
    with tempfile.TemporaryDirectory() as tmp:
        db = pathlib.Path(tmp) / "leveldb"
        shutil.copytree(CHROME_LS, db)
        records = [
            r.record
            for r in FolderReader(db).GetRecords(use_manifest=True)
            if r.record.key.endswith(b"feedly.session")
        ]
    if not records:
        return None
    latest = max(records, key=lambda r: r.sequence_number)
    return json.loads(latest.value[1:]).get("feedlyToken")  # value[0] is the encoding byte


def verify_token(token):
    """Verify the token is valid by hitting the Feedly profile endpoint."""
    r = requests.get(f"{FEEDLY_API}/profile", headers={"Authorization": f"OAuth {token}"})
    if r.ok:
        print(f"👤 Authenticated as: {r.json().get('email')}")
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
    print("🔑 Reading feedly.session from Chrome localStorage...")
    token = get_token()
    if not token:
        print("❌ feedly.session not found in Chrome localStorage. Make sure you're logged into Feedly in Chrome.")
        sys.exit(1)

    print("🔍 Verifying token against Feedly API...")
    if not verify_token(token):
        print("❌ Token is invalid or expired. Try logging into Feedly in Chrome again.")
        sys.exit(1)

    update_secrets(token)
    print("✅ FEEDLY_TOKEN updated in ~/.secrets")
    print("🔄 Run `resource` or open a new terminal tab to use it.")


if __name__ == "__main__":
    main()
