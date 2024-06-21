import datetime
from typing import AsyncGenerator

import httpx
import icalendar
import pytz
from fastapi import FastAPI, Response

app = FastAPI()


@app.get("/")
async def root():
    """Health check."""
    return {"message": "Hello World"}


@app.get("/robots.txt", include_in_schema=False)
async def robots():
    """Disallow indexing."""
    return Response("User-agent: *\nDisallow: /", media_type="text/plain")


def is_older_than(a: datetime.datetime | datetime.date, b: datetime.date) -> bool:
    """Check if a is older than b.

    Args:
        a: datetime object to compare.
        b: date object to compare.

    Returns:
        True if a is older than b, False otherwise.
    """

    if isinstance(a, datetime.datetime):
        return a.date() < b
    return a < b


def is_before_19pm_jst(dt: datetime.datetime) -> bool:
    """Check if the datetime object is before 19:00 JST.

    Args:
        dt: datetime object to check.

    Returns:
        True if the datetime is before 19:00 JST, False otherwise.
    """
    japan_tz = pytz.timezone('Asia/Tokyo')
    dt_jst = dt.astimezone(japan_tz)
    return dt_jst.hour < 19


async def iter_events(url) -> AsyncGenerator[icalendar.Calendar, None]:
    """Iterate over events in iCal file.

    Args:
        url: URL of iCal file.

    Yields:
        icalendar.Calendar: iCalendar event.
    """
    async with httpx.AsyncClient(timeout=None) as client:
        async with client.stream("GET", url) as resp:
            component_lines: list[str] = []
            async for line in resp.aiter_lines():
                if line.startswith("BEGIN:VEVENT"):
                    component_lines = ["BEGIN:VEVENT"]
                elif line.startswith("END:VEVENT"):
                    component_lines.append("END:VEVENT")
                    yield icalendar.Calendar.from_ical("\n".join(component_lines))
                    component_lines = []
                else:
                    component_lines.append(line)


@app.get("/calendar/{email}/{calendar_id}")
async def calendar(email: str, calendar_id: str):
    """Get anonymized iCal file.

    Args:
        email: User email address for Google Calendar.
        calendar_id: Calendar ID for Google Calendar.
    """

    url = f"https://calendar.google.com/calendar/ical/{email}/{calendar_id}/basic.ics"

    new_cal = icalendar.Calendar()
    criteria = datetime.date.today() - datetime.timedelta(days=7)

    # イベントを追加
    async for component in iter_events(url):
        start: datetime.datetime | datetime.date = component.get("dtstart").dt
        summary: str | None = component.get("summary")

        if is_older_than(start, criteria):
            continue
        if summary and "作業" in summary:
            continue
        if summary:
            if '面談' in summary or '面接' in summary:
                summary = '会議'
            elif isinstance(start, datetime.datetime) and is_before_19pm_jst(start):
                summary = '会議'
            else:
                summary = '予定'

        cal_event = icalendar.Event()
        cal_event.add("summary", summary)
        cal_event.add("dtstart", start)
        if end := component.get("dtend"):
            cal_event.add("dtend", end.dt)
        new_cal.add_component(cal_event)

    ics_data = new_cal.to_ical()

    headers = {"Content-Disposition": 'attachment; filename="calendar.ics"'}
    return Response(content=ics_data, headers=headers)
