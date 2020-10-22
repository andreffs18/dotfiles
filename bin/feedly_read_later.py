#!/usr/bin/env python3
import os
import sys
import time
import random
import requests
import webbrowser
import signal
import sys


def signal_handler(signal, frame):
    print('👇 You pressed Ctrl+C! Skipping getting Feedly article.')
    sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)


try:
    FEEDLY_TOKEN = os.environ["FEEDLY_TOKEN"]
except KeyError:
    print("🙅‍♂️ No 'FEEDLY_TOKEN' environment found! Cannot continue.")
    sys.exit(1)


FEEDLY_URL = "https://cloud.feedly.com/v3"

request = requests.Session()
request.headers.update(
    {"Content-Type": "application/json", "Authorization": f"OAuth {FEEDLY_TOKEN}"}
)

try:
    response = request.get(FEEDLY_URL + "/profile")
    if not response.ok:
        print(
            f'🙅‍♂️ {response.json()["errorMessage"].title()}.\n'
            'To refresh "FEEDLY_TOKEN" go to https://feedly.com/v3/auth/dev.\n'
            "Don't forget to run `$ update_feedly_token \"FEEDLY_TOKEN\"` after 👍"
        )
        sys.exit(1)
except Exception as e:
    print(f'🙅‍♂️ Something wrong happend: {str(e)}')
    sys.exit(1)

stream_id = f'user/{response.json()["id"]}/tag/global.saved'
continuation = ""

articles = []
while True:
    # Query feedly API to get all Saved articles, and parse all Article ids, storing them in `articles` variable.
    try:
        response = request.get(
            FEEDLY_URL
            + f"/streams/contents?streamId={stream_id}&continuation={continuation}"
        )
        items = response.json()["items"]
        articles.extend([item.get("id") for item in items])
    except:
        # Might have hit the threshold of requests. Stop fetching and just use the ones we already have
        break

    # Then check if is there any more pages left, if not, then break out of the while loop.
    try:
        continuation = response.json()["continuation"]
        print(f'\r{random.choice(["🤔", "👍", "⚡️", "🥴", "👏"])}', end='', flush=True)
    except KeyError:
        break

# Print message and sleep for a second so we can read it. Finally open page on a web browser.
print(f'\n✅ Found {len(articles)} articles in "Saved for later"!')
time.sleep(1)

# Get article count if given, get only 1 otherwise
count = int(sys.argv[1] if len(sys.argv) > 1 else 1)
for _ in range(count):
    if articles:
        article = random.choice(articles)
        webbrowser.open(f"https://feedly.com/i/entry/{article}")
        articles.remove(article)
