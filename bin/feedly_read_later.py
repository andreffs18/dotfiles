#!/usr/bin/env python3
import fnmatch
import json
import os
import random
import re
import signal
import sys
import threading
import time
import unicodedata
import webbrowser
from collections import Counter
from collections.abc import Callable, Sequence
from dataclasses import asdict, dataclass, field
from datetime import UTC, datetime, timedelta
from types import FrameType
from typing import Any

import requests


# region Type definitions
@dataclass
class Entry:
    """Compact article record, stored in the cache and used to build the stats."""

    id: str
    ts: int | None = None  # epoch seconds
    origin: str | None = None
    categories: list[str] = field(default_factory=list)

    @classmethod
    def from_feedly(cls, item: dict[str, Any]) -> "Entry":
        """
        Build an entry from one of the `items` of feedly's "/streams/contents" response. Example item:
        {
          "id": "puQkfDdl2BcfO7M6775hz3I0o2LgRRleDDobp9hOhGo=_18292153cb6:1abc650:268d1644",
          "keywords": ["web-development", "javascript"],
          "origin": {"streamId": "feed/https://betterprogramming.pub/feed", "title": "Better Programming - Medium"},
          "categories": [{"id": "user/39e9c8fc-.../category/39ecdc59-...", "label": "Development"}],
          "published": 1688630000000,        # epoch ms
          "actionTimestamp": 1688640000000,  # epoch ms, when the article was saved (if feedly sends it)
          "title": "How To Create Beautiful Command Line Interactions With Node.js",
          ...
        }
        """
        ts = item.get("actionTimestamp") or item.get("published")
        origin = item.get("origin") or {}
        return cls(
            id=item["id"],
            ts=ts // 1000 if ts else None,
            origin=origin.get("title"),
            categories=[category["label"] for category in item.get("categories") or []],
        )

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> "Entry":
        """Build an entry from what `asdict` stored in the cache."""
        return cls(id=data["id"], ts=data.get("ts"), origin=data.get("origin"), categories=data.get("categories", []))


# endregion

CACHE_DIRECTORY = os.path.expanduser("~/.cache/feedly")
FEEDLY_URL = "https://cloud.feedly.com/v3"


def _signal_handler(signal: int, frame: FrameType | None) -> None:
    print("👇 You pressed Ctrl+C! Skipping getting Feedly article.")
    sys.exit(0)


def read_cache(timeframe: int = 15) -> list[Entry] | None:
    """
    Search for the most recent "feedly-articles-{date}.json" and return list of cached ids.
    This method takes an optional argument (`timeframe=15`) to check if there is a saved file
    that was stored during the last `timeframe` days. If that is the case, return list of saved
    ids, otherwise, return None, while not forgetting to delete the existing file.
    """
    caches = sorted(
        [file for file in os.listdir(CACHE_DIRECTORY) if fnmatch.fnmatch(file, "feedly-articles-*.json")],
        reverse=True,
    )
    if not caches:
        return None

    match = re.search(r"\d{4}-\d{2}-\d{2}", caches[0])
    date = datetime.strptime(match.group(), "%Y-%m-%d")

    today = datetime.now(UTC).replace(tzinfo=None)
    if today > date + timedelta(days=timeframe):
        os.remove(os.path.join(CACHE_DIRECTORY, caches[0]))
        return None

    try:
        with open(os.path.join(CACHE_DIRECTORY, caches[0])) as f:
            articles = [Entry.from_dict(data) for data in json.load(f)]

        if not articles:
            os.remove(os.path.join(CACHE_DIRECTORY, caches[0]))
    except (ValueError, KeyError, TypeError, AttributeError):
        # Corrupted cache, ignore it and fetch again.
        articles = []

    return articles


def build_session() -> requests.Session:
    """Create a requests session authenticated with `FEEDLY_TOKEN`, or exit if it is not set."""
    try:
        token = os.environ["FEEDLY_TOKEN"]
    except KeyError:
        print("🙅‍♂️ No 'FEEDLY_TOKEN' environment found! Cannot continue.")
        sys.exit(1)

    session = requests.Session()
    session.headers.update({"Content-Type": "application/json", "Authorization": f"OAuth {token}"})
    return session


def get_articles_from_feedly(request: requests.Session) -> list[Entry]:
    """
    Method that requests feedly for list of available articles, stored under "Saved for Later"
    board.
    """

    def _animate(stop_event: threading.Event) -> None:
        emojis = ["🤔", "👍", "⚡️", "🥴", "👏"]
        frames = [".  ", ".. ", "..."]
        i = 0
        while not stop_event.is_set():
            print(f"\r{emojis[i % len(emojis)]} Getting articles{frames[i % len(frames)]}", end="", flush=True)
            i += 1
            time.sleep(1)
        print("\r" + " " * 30 + "\r", end="", flush=True)

    try:
        response = request.get(FEEDLY_URL + "/profile")
        if not response.ok:
            print(
                f"🙅‍♂️ {response.json()['errorMessage'].title()}.\n"
                'To refresh "FEEDLY_TOKEN" run `$ update_feedly_token` 👍'
            )
            sys.exit(1)
    except Exception as e:
        print(f"🙅‍♂️ Something wrong happen: {e!s}")
        sys.exit(1)

    # Spin up animator thread so the ellipsis cycles smoothly while API pages are fetched.
    stop_event = threading.Event()
    animator = threading.Thread(target=_animate, args=(stop_event,))
    animator.start()

    stream_id = f"user/{response.json()['id']}/tag/global.saved"
    continuation = ""
    articles = []
    while True:
        # Query feedly API to get all Saved articles, and parse all Article ids, storing them in `articles` variable.
        try:
            response = request.get(FEEDLY_URL + f"/streams/contents?streamId={stream_id}&continuation={continuation}")
            payload = request.get(
                FEEDLY_URL + f"/streams/contents?streamId={stream_id}&continuation={continuation}"
            ).json()
            articles.extend(Entry.from_feedly(item) for item in payload["items"])
        except Exception as _e:
            # Might have hit the threshold of requests. Stop fetching and just use the ones we already have
            break

        # Then check if is there any more pages left, if not, then break out of the while loop.
        continuation = payload.get("continuation")
        if not continuation:
            break

    stop_event.set()
    animator.join()

    return articles


def open_articles_in_browser(articles: list[Entry], amount: int = 1) -> tuple[list[Entry], list[Entry]]:
    """
    From list of `articles`, open given `amount` of new tabs, on any available webbrowser
    with random articles from the list. Finally, return new list of articles, without
    opened ones, plus the list of opened ones
    """
    try:
        count = int(sys.argv[1])
    except (ValueError, IndexError):
        count = amount

    opened = []
    for _ in range(count):
        if articles:
            article = random.choice(articles)
            webbrowser.open(f"https://feedly.com/i/entry/{article.id}", False)
            articles.remove(article)
            opened.append(article)
    return articles, opened


def save_cache(articles: list[Entry]) -> None:
    """
    From given list of article ids, create new file to cache that information. Then filename
    will follow the format 'feedly-articles-{date}.json' in which the date follows the format
    "%Y-%m-%d". This date will be used to check which is the most recent cache.
    """
    caches = sorted(
        [file for file in os.listdir(CACHE_DIRECTORY) if fnmatch.fnmatch(file, "feedly-articles-*.json")],
        reverse=True,
    )
    if not caches:
        caches.append(f"feedly-articles-{datetime.now(UTC).strftime('%Y-%m-%d')}.json")

    with open(os.path.join(CACHE_DIRECTORY, caches[0]), "w+") as f:
        json.dump([asdict(article) for article in articles], f)


class Stats:
    """
    Stats about the articles left in the backlog (`entries`).
    Articles opened in this run (`opened`) are shown next to the counters they were taken from.
    """

    PALETTE = [39, 208, 41, 171, 220]  # ANSI 256 colors for the top categories
    OTHER_COLOR = 244
    DELTA_COLOR = 196
    SPARKS = "▁▂▃▄▅▆▇█"
    BAR_WIDTH = 30
    LABEL_WIDTH = 28
    AGE_BUCKETS = [("< 1 month", 30), ("1-3 months", 90), ("3-6 months", 180), ("6-12 months", 365), ("> 1 year", None)]

    def __init__(self, entries: Sequence[Entry], opened: Sequence[Entry] = (), max_months: int = 12) -> None:
        """Keep only entries with a date for the time based charts. `max_months` caps how many months are charted."""
        self.entries = entries
        self.dated = [e for e in entries if e.ts]
        self.opened_all = opened
        self.opened = [e for e in opened if e.ts]
        self.max_months = max_months
        self.now = datetime.now(UTC).timestamp()

    # Formatting helpers
    @staticmethod
    def _color(text: str, code: int) -> str:
        """Wrap `text` in the given ANSI 256 color, unless stdout is not a terminal (e.g. piped)."""
        return f"\033[38;5;{code}m{text}\033[0m" if sys.stdout.isatty() else text

    @classmethod
    def _delta(cls, n: int) -> str:
        """Red "-n" marker for counters that lost `n` articles in this run, empty when `n` is 0."""
        return " " + cls._color(f"-{n}", cls.DELTA_COLOR) if n else ""

    @staticmethod
    def _width(text: str) -> int:
        """Columns `text` takes in a terminal: emojis and CJK take 2, combining marks and joiners take 0."""
        return sum(
            0 if unicodedata.category(c) in ("Mn", "Cf") else 2 if unicodedata.east_asian_width(c) in "WF" else 1
            for c in text
        )

    @classmethod
    def _fit(cls, text: str, width: int) -> str:
        """Pad `text` with spaces to `width` columns, or cut it and add "…" if it does not fit."""
        if cls._width(text) > width:
            while cls._width(text) > width - 2:
                text = text[:-1]
            text = text.rstrip() + "… "
        return text + " " * (width - cls._width(text))

    @classmethod
    def _bar(cls, count: int, peak: int) -> int:
        """Bar length (in characters) of `count`, scaled so that `peak` fills `BAR_WIDTH`."""
        return round(cls.BAR_WIDTH * count / max(peak, 1))

    # Grouping helpers
    @staticmethod
    def _month(ts: float) -> str:
        """Convert epoch seconds to a "YYYY-MM" label (UTC)."""
        return datetime.fromtimestamp(ts, UTC).strftime("%Y-%m")

    @staticmethod
    def _month_range(first: str, last: str) -> list[str]:
        """All "YYYY-MM" labels from `first` to `last`, inclusive, so months without articles are kept."""
        year, month = int(first[:4]), int(first[5:])
        months = []
        while f"{year:04d}-{month:02d}" <= last:
            months.append(f"{year:04d}-{month:02d}")
            year, month = (year + 1, 1) if month == 12 else (year, month + 1)
        return months

    def _age_counts(self, entries: Sequence[Entry]) -> list[int]:
        """Count `entries` per `AGE_BUCKETS` bucket, based on how long ago they were saved."""
        counts = [0] * len(self.AGE_BUCKETS)
        for e in entries:
            age = (self.now - e.ts) / 86400
            counts[next(i for i, (_, limit) in enumerate(self.AGE_BUCKETS) if limit is None or age < limit)] += 1
        return counts

    # Sections
    def _top(self, title: str, label: Callable[[Entry], list[str]]) -> None:
        """Print a bar chart with the 5 most common `label`s of the backlog, and how many were opened in this run."""
        counts = Counter(l for e in self.entries for l in label(e))
        if not counts:
            return
        gone = Counter(l for e in self.opened_all for l in label(e))
        top = counts.most_common(5)
        print(f"\n{title}")
        for name, count in top:
            bar = "█" * self._bar(count, top[0][1])
            print(f"  {self._fit(name, self.LABEL_WIDTH)}{bar:<{self.BAR_WIDTH}} {count}{self._delta(gone[name])}")

    def print_tops(self) -> None:
        """Print the 5 most common origins and categories in the backlog, as bars."""
        self._top("📊 Top origins", lambda e: [e.origin] if e.origin else [])
        self._top("🏷️  Top categories", lambda e: e.categories)

    def print_age(self) -> None:
        """Print a histogram of the backlog age, with the articles opened in this run marked next to it."""
        counts, opened_counts = (
            self._age_counts(self.dated),
            self._age_counts(self.opened),
        )
        print("\n⏳ Backlog age")
        for (label, _), count, gone in zip(self.AGE_BUCKETS, counts, opened_counts):
            print(f"  {label:<12}{'█' * self._bar(count, max(counts)):<{self.BAR_WIDTH}} {count}{self._delta(gone)}")

    def print_months(self) -> None:
        """
        Print a sparkline and a stacked bar per month with the articles saved on it, colored by their
        main category (top 5, the rest is grouped as "other"). Opened articles are marked next to it.
        """
        per_month: dict[str, list[str]] = {}
        for e in self.dated:
            per_month.setdefault(self._month(e.ts), []).append(e.categories[0] if e.categories else "Uncategorized")
        if not per_month:
            return
        opened_per_month = Counter(self._month(e.ts) for e in self.opened)

        months = self._month_range(min(per_month), max(per_month))[-self.max_months :]
        totals = [len(per_month.get(m, [])) for m in months]
        peak = max(totals)
        sparkline = "".join(self.SPARKS[round((len(self.SPARKS) - 1) * t / max(peak, 1))] for t in totals)
        print(f"\n📈 Saved per month ({months[0]} → {months[-1]}): {sparkline}  peak {peak}")

        colors = self.PALETTE + [self.OTHER_COLOR]
        top = [l for l, _ in Counter(l for m in months for l in per_month.get(m, [])).most_common(len(self.PALETTE))]
        for month, total in zip(months, totals):
            bag = Counter(per_month.get(month, []))
            # Round the running total instead of each segment, so rounding errors never make the bar overflow.
            counts = [bag[l] for l in top] + [total - sum(bag[l] for l in top)]
            edges = [self._bar(sum(counts[: i + 1]), peak) for i in range(len(counts))]
            widths = [edge - previous for edge, previous in zip(edges, [0] + edges)]
            bar = "".join(self._color("█" * w, colors[i]) for i, w in enumerate(widths))
            padding = " " * (self.BAR_WIDTH - sum(widths))
            print(f"  {month} {bar}{padding} {total}{self._delta(opened_per_month[month])}")
        legend = "  ".join(self._color("█", self.PALETTE[i]) + f" {l}" for i, l in enumerate(top))
        print(f"  {legend}  {self._color('█', self.OTHER_COLOR)} other")

    def print(self) -> None:
        """Print all sections. Charts are skipped when there are no dated articles."""
        self.print_tops()
        if self.dated or self.opened:
            self.print_age()
            self.print_months()
            print()


def main() -> None:
    os.makedirs(CACHE_DIRECTORY, exist_ok=True)
    signal.signal(signal.SIGINT, _signal_handler)

    # Try to find cached articles before requesting Feedly for more.
    articles = read_cache()
    if not articles:
        articles = get_articles_from_feedly(build_session())

    # Print message and sleep for a second so we can read it.
    print(f'✅ Found {len(articles)} articles in "Saved for later"!')
    time.sleep(1)

    # Get article count if given, get only 1 otherwise.
    articles, opened = open_articles_in_browser(articles)

    # Save cache of scrapped articles for 15 days. Opened articles are already removed, so the next run starts from them.
    save_cache(articles)

    # Stats reflect what is left in the backlog after opening.
    print(f"📖 {len(articles)} left in the backlog")
    Stats(articles, opened).print()


if __name__ == "__main__":
    main()
