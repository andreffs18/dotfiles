#!/usr/bin/env python3
import fnmatch
import getpass
import os
import random
import re
import requests
import signal
import sys
import time
import webbrowser
from datetime import datetime, timedelta


CACHE_DIRECTORY = f"/Users/{getpass.getuser()}/.dotfiles/cache"
FEEDLY_URL = "https://cloud.feedly.com/v3"


def signal_handler(signal, frame):
    print("👇 You pressed Ctrl+C! Skipping getting Feedly article.")
    sys.exit(0)


signal.signal(signal.SIGINT, signal_handler)

try:
    FEEDLY_TOKEN = os.environ["FEEDLY_TOKEN"]
except KeyError:
    print("🙅‍♂️ No 'FEEDLY_TOKEN' environment found! Cannot continue.")
    sys.exit(1)


request = requests.Session()
request.headers.update({"Content-Type": "application/json", "Authorization": f"OAuth {FEEDLY_TOKEN}"})


def read_cache(timeframe=15):
    """
    Search for the most recent "feedly-articles-{date}.txt" and return list of cached ids.
    This method takes an optional argument (`timeframe=15`) to check if there is a saved file
    that was stored during the last `timeframe` days. If that is the case, return list of saved
    ids, otherwise, return None, while not forgetting to delete the existing file.
    """
    caches = sorted(
        [file for file in os.listdir(CACHE_DIRECTORY) if fnmatch.fnmatch(file, "feedly-articles-*.txt")],
        reverse=True,
    )
    if not caches:
        return None

    match = re.search(r"\d{4}-\d{2}-\d{2}", caches[0])
    date = datetime.strptime(match.group(), "%Y-%m-%d")

    today = datetime.utcnow()
    if today > date + timedelta(days=timeframe):
        os.remove(os.path.join(CACHE_DIRECTORY, caches[0]))
        return None

    with open(os.path.join(CACHE_DIRECTORY, caches[0]), "r+") as bak:
        articles = bak.read().splitlines()

    if not articles:
        os.remove(os.path.join(CACHE_DIRECTORY, caches[0]))

    return articles


def save_cache(articles):
    """
    From given list of article ids, create new file to cache that information. Then filename
    will follow the format 'feedly-articles-{date}.txt' in which the date follows the format
    "%Y-%m-%d". This date will be used to check which is the most recent cache.
    """
    caches = sorted(
        [file for file in os.listdir(CACHE_DIRECTORY) if fnmatch.fnmatch(file, "feedly-articles-*.txt")],
        reverse=True,
    )
    if not caches:
        caches.append(f'feedly-articles-{datetime.utcnow().strftime("%Y-%m-%d")}.txt')

    with open(os.path.join(CACHE_DIRECTORY, caches[0]), "w+") as bak:
        bak.write("\n".join(articles))


def get_articles_from_feedly():
    """
    Method that requests feedly for list of available articles, stored under "Saved for Later"
    board.
    """
    try:
        response = request.get(FEEDLY_URL + "/profile")
        if not response.ok:
            print(
                f'🙅‍♂️ {response.json()["errorMessage"].title()}.\n'
                'To refresh "FEEDLY_TOKEN" go to https://feedly.com/v3/auth/dev.\n'
                'Don\'t forget to run `$ update_feedly_token "FEEDLY_TOKEN"` after 👍'
            )
            sys.exit(1)
    except Exception as e:
        print(f"🙅‍♂️ Something wrong happend: {str(e)}")
        sys.exit(1)

    stream_id = f'user/{response.json()["id"]}/tag/global.saved'
    continuation = ""
    articles = []
    while True:
        # Query feedly API to get all Saved articles, and parse all Article ids, storing them in `articles` variable.
        try:
            response = request.get(FEEDLY_URL + f"/streams/contents?streamId={stream_id}&continuation={continuation}")
            items = response.json()["items"]
            articles.extend([item.get("id") for item in items])
        except:
            # Might have hit the threshold of requests. Stop fetching and just use the ones we already have
            break

        # Then check if is there any more pages left, if not, then break out of the while loop.
        try:
            continuation = response.json()["continuation"]
            print(f'\r{random.choice(["🤔", "👍", "⚡️", "🥴", "👏"])}', end="", flush=True)
        except KeyError:
            break

    return articles


def open_articles_in_browser(articles, amount=1):
    """
    From list of `articles`, open given `amount` of new tabs, on any available webbrowser
    with random articles from the list. Finally, return new list of articles, without
    opened ones
    """
    try:
        count = int(sys.argv[1])
    except (ValueError, IndexError):
        count = amount

    for _ in range(count):
        if articles:
            article = random.choice(articles)
            webbrowser.open(f"https://feedly.com/i/entry/{article}", False)
            articles.remove(article)
    return articles


# Try to find cached articles before requesting Feedly for more.
articles = read_cache()
if not articles:
    articles = get_articles_from_feedly()

# Print message and sleep for a second so we can read it.
print(f'\n✅ Found {len(articles)} articles in "Saved for later"!')
time.sleep(1)

# Get article count if given, get only 1 otherwise.
articles = open_articles_in_browser(articles)

# Save cache of scrapped articles for 15 days.
save_cache(articles)
