import datetime
import hashlib
import hmac
import os

import google.auth
import googleapiclient.discovery
import icalendar
import pytz
from fastapi import FastAPI, HTTPException, Response
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

SCOPES = ["https://www.googleapis.com/auth/calendar.readonly"]
GOOGLE_APPLICATION_CREDENTIALS = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
CALENDAR_SALT = os.getenv("CALENDAR_SALT")

app = FastAPI()

static_dir = os.path.join(os.path.dirname(__file__), "static")
app.mount("/static", StaticFiles(directory=static_dir), name="static")

creds = None
if GOOGLE_APPLICATION_CREDENTIALS:
    creds = google.auth.load_credentials_from_file(
        GOOGLE_APPLICATION_CREDENTIALS, SCOPES
    )[0]
service = googleapiclient.discovery.build("calendar", "v3", credentials=creds)


@app.get("/hash_generator")
async def hash_generator():
    """Serve the hash generator HTML page."""
    return FileResponse(os.path.join(static_dir, "hash_generator.html"))


@app.get("/robots.txt", include_in_schema=False)
async def robots():
    """Serve robots.txt from static directory."""
    return FileResponse(os.path.join(static_dir, "robots.txt"), media_type="text/plain")


@app.get("/")
async def root():
    """Health check."""
    return {"message": "Hello World"}


def is_before_19pm_jst(dt: datetime.datetime) -> bool:
    """Check if the datetime object is before 19:00 JST.

    Args:
        dt: datetime object to check.

    Returns:
        True if the datetime is before 19:00 JST, False otherwise.
    """
    japan_tz = pytz.timezone("Asia/Tokyo")
    dt_jst = dt.astimezone(japan_tz)
    return dt_jst.hour < 19


def generate_calendar_hash(calendar_id: str) -> str:
    """Generate a hash for the given calendar ID using the salt."""
    if not CALENDAR_SALT:
        raise ValueError("CALENDAR_SALT is not set")
    return hmac.new(
        CALENDAR_SALT.encode(), calendar_id.encode(), hashlib.sha256
    ).hexdigest()


def verify_calendar_hash(calendar_id: str, provided_hash: str) -> bool:
    """Verify the provided hash against the generated hash for the calendar ID."""
    return hmac.compare_digest(generate_calendar_hash(calendar_id), provided_hash)


@app.get("/calendar/{calendar_id}/{calendar_hash}")
async def calendar(calendar_id: str, calendar_hash: str):
    """Get anonymized future events from Google Calendar in iCalendar format.

    Args:
        calendar_id: Calendar ID for Google Calendar.
        calendar_hash: Hash of the calendar ID for verification.
    """
    try:
        if not verify_calendar_hash(calendar_id, calendar_hash):
            raise HTTPException(status_code=403, detail="Invalid calendar hash")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    now = datetime.datetime.utcnow().isoformat() + "Z"  # 'Z' indicates UTC time
    events_result = (
        service.events()
        .list(
            calendarId=calendar_id,
            timeMin=now,
            maxResults=1000,
            singleEvents=True,
            orderBy="startTime",
        )
        .execute()
    )
    events: list[dict] = events_result.get("items", [])

    cal = icalendar.Calendar()
    cal.add("prodid", f"-//My calendar product//{calendar_id}//")
    cal.add("version", "2.0")
    cal.add("name", calendar_id)

    for event in events:
        start = event["start"].get("dateTime", event["start"].get("date"))
        end = event["end"].get("dateTime", event["end"].get("date"))
        summary = event.get("summary", "No Title")

        start_dt = datetime.datetime.fromisoformat(start.rstrip("Z"))

        if "T" not in start:  # Skip all date events
            continue
        if "作業" in summary:
            continue
        if "面談" in summary or "面接" in summary:
            summary = "会議"
        elif "移動" in summary or "出社" in summary:
            summary = "移動"
        elif is_before_19pm_jst(start_dt):
            summary = "会議"
        else:
            summary = "予定"

        cal_event = icalendar.Event()
        cal_event.add("summary", summary)

        if "T" in start:  # This is a date-time
            cal_event.add("dtstart", start_dt)
        else:  # This is a date
            cal_event.add("dtstart", datetime.date.fromisoformat(start))

        if "T" in end:  # This is a date-time
            cal_event.add("dtend", datetime.datetime.fromisoformat(end.rstrip("Z")))
        else:  # This is a date
            cal_event.add("dtend", datetime.date.fromisoformat(end))

        cal_event.add("dtstamp", datetime.datetime.utcnow())
        cal_event["uid"] = event["id"]

        cal.add_component(cal_event)

    ics_data = cal.to_ical()

    headers = {"Content-Disposition": 'attachment; filename="calendar.ics"'}
    return Response(content=ics_data, headers=headers, media_type="text/calendar")
