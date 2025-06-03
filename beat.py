#!/usr/bin/env python3
"""
Swatch Beat Time (BMT) Calculator

Swatch Beat Time is a decimal time system introduced by Swatch in 1998.
Hopefully, this script will make you feel nostalgic!
"""

from datetime import datetime, timedelta, timezone


def get_swatch_beat():
    """
    Get the current Swatch Beat Time (BMT).
    """

    # Get current time in UTC
    now_utc = datetime.now(timezone.utc)

    # Adjust to Swatch's "Biel Mean Time (UTC+1)"
    bmt = now_utc + timedelta(hours=1)

    # Calculate seconds since midnight BMT
    bmt_midnight = bmt.replace(hour=0, minute=0, second=0, microsecond=0)
    seconds_since_midnight = (bmt - bmt_midnight).total_seconds()

    # Convert to beats (1 beat = 86.4 seconds)
    beat = seconds_since_midnight / 86.4

    # Display (integer & decimal)
    print(f"Current Swatch Beat Time: @{int(beat):03d} ({beat:.2f})")


if __name__ == "__main__":
    get_swatch_beat()
