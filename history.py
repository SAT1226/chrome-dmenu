import sys
import sqlite3
import contextlib
import datetime

argvs = sys.argv

with contextlib.closing(sqlite3.connect("file:" + argvs[1] + '?mode=ro&nolock=1', uri=True)) as conn:
    c = conn.cursor()

    for row in (c.execute('select url, title, last_visit_time from urls')):
        row = list(row)
        d = datetime.datetime.fromtimestamp((row[2] / 1000000) - 11644473600)
        print("%d%02d%02d" % (d.year, d.month, d.day) + ":" + row[1] + " [" + row[0] + "]")
