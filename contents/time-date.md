# Time and Date

In C3, time is generally handled as a 64-bit integer. The `Duration` type represents a span of time, while `Time` represents a specific point in time (Unix epoch)

* `Time` A point in time (usually nanoseconds since 1970).
* `Duration`: A length of time.
* `NanoDuration`: High-precision duration (nanoseconds).

```c3
import std::time;

typedef Time = long;
typedef Duration = long;
typedef Clock = ulong;
typedef NanoDuration (Printable) = long;

struct DateTime {
    int usec;
    char sec;
    char min;
    char hour;
    char day;
    Month month;
    Weekday weekday;
    int year;
    ushort year_day;
    Time time;
}

struct TzDateTime {
    inline DateTime date_time;
    int gmt_offset;
}

Time t = time::now();

Time t = t.add_seconds(long seconds);
Time t = t.add_minutes(long minutes);
Time t = t.add_hours(long hours);
Time t = t.add_days(long days);
Time t = t.add_weeks(long weeks);
Time t = t.add_duration(Duration duration) @operator_s(+);
Time t = t.sub_duration(Duration duration) @operator(-);

int cmp = t.compare_to(Time other);
double d = t.to_seconds();
Duration d = t.diff_us(Time other) @operator(-);
double d = t.diff_sec(Time other);
double d = t.diff_min(Time other);
double d = t.diff_hour(Time other);
double d = t.diff_days(Time other);
double d = t.diff_weeks(Time other);

Duration d = time::us(long l); // nano sec
Duration d = time::ms(long l); // mili sec
Duration d = time::sec(long l);
Duration d = time::min(long l);
Duration d = time::hour(long l);
Duration d = time::from_float(double s);

NanoDuration nd;
Duration d;

double x = nd.to_sec();
long x = nd.to_ms();
Duration d = nd.to_duration();
NanoDuration nd = d.to_nano();
long x = d.to_ms();
Duration d = d.mult(long #val); @operator_s(*);
```

### Clock

In C3, the `Clock` type is distinct from the wall-clock `Time` type because it is generally used for monotonic measurements (profiling, intervals, and high-precision timing) rather than calendar dates.

* Unlike `Time`, which can change if the system clock is adjusted, a `Clock` value only moves forward, making it ideal for measuring elapsed time.

```c3
import std::time::clock;

Clock c = clock::now();
NanoDuration nd = c.mark();
Clock c = c.add_nano_duration(NanoDuration nano) @operator_s(+);
Clock c = c.sub_nano_duration(NanoDuration nano) @operator(-);
Clock c = c.add_duration(Duration duration) @operator_s(+);
Clock c = c.sub_duration(Duration duration) @operator(-);
NanoDuration nd = c.nano_diff(Clock other) @operator(-);
NanoDuration nd = c.to_now();
NanoDuration nd = c.to_now();
```

### DateTime

The `std::time::datetime` module in C3 provides the high-level API for "Calendar Time." While `Time` is a raw number (nanoseconds since epoch), `DateTime` and `TzDateTime` are human-readable structures that account for years, months, days, and time zones.

DateTime vs. TzDateTime

* The primary difference between these two structures is how they handle geographic offsets:
* `DateTime`: Represents a "naive" date and time. It doesn't inherently know its relationship to UTC/GMT unless you treat it as such by convention.
* `TzDateTime`: An augmented version of DateTime that includes a `gmt_offset` (in seconds). This is essential for local time calculations and global synchronization.
* `gmt_offset` range: `-12*3600` ~ `+14*3600`, -12 hour to +14 hour

```c3
import std::time::datetime;

DateTime dt = now();
DateTime dt = datetime::from_date(int year, Month month = JANUARY, int day = 1, int hour = 0, int min = 0, int sec = 0, int us = 0);
TzDateTime tzdt = datetime::from_date_tz(int year, Month month = JANUARY, int day = 1, int hour = 0, int min = 0, int sec = 0, int us = 0, int gmt_offset = 0);
TzDateTime tzdt = dt.to_local();
TzDateTime tzdt = dt.with_gmt_offset(int gmt_offset);
TzDateTime tzdt = tzdt.with_gmt_offset(int gmt_offset);
TzDateTime tzdt = dt.to_gmt_offset(int gmt_offset);
TzDateTime tzdt = tzdt.to_gmt_offset(int gmt_offset);
bool b = tzdt.eq(TzDateTime other) @operator(==);
void dt.set_date(int year, Month month = JANUARY, int day = 1, int hour = 0, int min = 0, int sec = 0, int us = 0);
void dt.set_time(Time time);

DateTime dt = dt.add_us(Duration d) @operator_s(+); // nano sec
DateTime dt.sub_us(Duration d) @operator(-); // nano sec
DateTime dt = dt.add_seconds(int seconds);
DateTime dt = dt.add_minutes(int minutes);
DateTime dt = dt.add_hours(int hours);
DateTime dt = dt.add_days(int days);
DateTime dt = dt.add_weeks(int weeks);
DateTime dt = dt.add_years(int years);
DateTime dt = dt.add_months(int months);
TzDateTime tzdt = tzdt.add_us(Duration d) @operator_s(+); // nano sec
TzDateTime tzdt = tzdt.sub_us(Duration d) @operator(-); // nano sec
TzDateTime tzdt = tzdt.add_seconds(int seconds);
TzDateTime tzdt = tzdt.add_minutes(int minutes);
TzDateTime tzdt = tzdt.add_hours(int hours);
TzDateTime tzdt = tzdt.add_days(int days);
TzDateTime tzdt = tzdt.add_weeks(int weeks);
TzDateTime tzdt = tzdt.add_years(int years);
TzDateTime tzdt = tzdt.add_months(int months);
DateTime dt = datetime::from_time(Time time);
TzDateTime tzdt = datetime::from_time_tz(Time time, int gmt_offset);

Time t = dt.to_time();
bool b = dt.after(DateTime compare);
bool b = dt.before(DateTime compare);
int y = dt.diff_years(DateTime from)
double s = dt.diff_sec(DateTime from)
Duration d = dt.diff_us(DateTime from) @operator(-);
bool b = dt.eq(DateTime other) @operator(==);
```

### Date Format

C3 provides a robust set of predefined formats for converting date structures into human-readable or machine-standard strings.

The DateTimeFormat Enum

* C3 includes most industry-standard formats out of the box. These are categorized into three main groups:
* Web & Internet Standards
  * RFC3339 / ISO8601: The gold standard for APIs and databases (e.g., 2006-01-02T15:04:05Z).
  * RFC1123 / RFC822: Commonly used in HTTP headers and Email systems (e.g., Mon, 02 Jan 2006...).
* Legacy & System Formats
  * ANSIC: The classic C asctime() format.
  * UNIXDATE: Similar to the output of the Linux date command.
* Simple Utility Formats
  * DATETIME: A clean, space-separated format (2006-01-02 15:04:05).
  * DATEONLY / TIMEONLY: Useful for logs where only one component is relevant.


```c3
import std::time::datetime;

enum DateTimeFormat {
    ANSIC, // "Mon Jan _2 15:04:05 2006"
    UNIXDATE, // "Mon Jan _2 15:04:05 GMT 2006"
    RUBYDATE, // "Mon Jan 02 15:04:05 -0700 2006"
    RFC822, // "02 Jan 06 15:04 GMT"
    RFC822Z, // "02 Jan 06 15:04 -0700"
    RFC850, // "Monday, 02-Jan-06 15:04:05 GMT"
    RFC1123, // "Mon, 02 Jan 2006 15:04:05 GMT"
    RFC1123Z, // "Mon, 02 Jan 2006 15:04:05 -0700"
    RFC3339, // "2006-01-02T15:04:05Z"
    RFC3339Z, // "2006-01-02T15:04:05+07:00"
    RFC3339MS, // "2006-01-02T15:04:05.999999Z"
    RFC3339ZMS, // "2006-01-02T15:04:05.999999+07:00"
    DATETIME, // "2006-01-02 15:04:05"
    DATEONLY, // "2006-01-02"
    TIMEONLY, // "15:04:05"
}

Allocator allocx;

String s = format::format(allocx, DateTimeFormat type, TzDateTime dt);
String s = format::tformat(DateTimeFormat dt_format, TzDateTime dt);

TzDateTime tzdt;
DateTime dt;

String s = tzdt.format(allocx, DateTimeFormat dt_format);
String s = dt.format(allocx, DateTimeFormat dt_format);
```

### LibC Time

In addition to the high-level `std::time` modules, C3 allows direct access to the underlying C standard library functions via import libc. This is particularly useful for low-level systems programming or when interfacing with legacy C codebases.

```c3
import libc;

CInt ts = libc::timespec_get(TimeSpec* ts, CInt base);
CInt t = libc::nanosleep(TimeSpec* req, TimeSpec* remaining);
ZString zs = libc::ctime(Time_t* timer);
Time_t tm_t = libc::time(Time_t* timer);
Time_t tm_t = libc::timegm(Tm* timeptr);
ZString zs = libc::strptime(char* buf, ZString format, Tm* tm);
usz n = libc::strftime(char* dest, usz maxsize, ZString format, Tm* timeptr);
Tm* tm = libc::localtime(Time_t* timer);
Tm* tm = libc::localtime_r(Time_t* timer, Tm* result);
Tm* tm = libc::gmtime(Time_t* timer);
Tm* tm = libc::gmtime_r(Time_t* timer, Tm* buf);
double tm = libc::difftime(Time_t time1, Time_t time2);
ZString zs = libc::asctime(Tm* timeptr);
ZString zs = asctime_r(Tm* timeptr, char* buf);
```

Low-Level Structures

When working with `libc`, you shift from C3's DateTime objects to C's traditional time structures:
* `Time_t`: Usually a 64-bit integer representing seconds since the epoch.
* `TimeSpec`: A struct containing `tv_sec` and `tv_nsec` for nanosecond precision.
* `Tm`: The C "broken-down time" struct (fields like `tm_year, tm_mon, tm_mday`, etc.). Note that in C, `tm_year` is years since 1900 and `tm_mon` is 0-indexed (0-11).

Core `libc` Categories

High Precision & Sleeping

* `timespec_get()`: Used to get the current time with nanosecond resolution. The base parameter is typically TIME_UTC.
* `nanosleep()`: Suspends the execution of the calling thread. If interrupted by a signal, it returns -1 and puts the remaining time into the second parameter.

Conversions (The "Time Chain")

The libc module facilitates the classic C conversion flow:
| Function | Input | Output | Description |
|---|---|---|---|
| `localtime()` | `Time_t` | `Tm*` | Converts epoch to local time (static buffer). |
| `gmtime_r()` | `Time_t` | `Tm*` | Thread-safe conversion to UTC (user-provided buffer). |
| `timegm()` | `Tm*` | `Time_t` | The inverse: converts UTC Tm back to an epoch integer. |

String Parsing and Formatting

* `strftime()`: The standard way to create highly customized date strings using format specifiers (e.g., %Y-%m-%d %H:%M:%S).
* `strptime()`: Parses a string into a `Tm` struct based on a format string.
* `ctime()` / `asctime()`: Legacy functions that return a fixed-format string (e.g., "Www Mmm dd hh:mm:ss yyyy"). Note: These are generally avoided in modern code in favor of `strftime()`.

Safe vs. Unsafe (The _r Suffix)

In your snippet, you see both `localtime()` and `localtime_r()`. This is a critical distinction in C3/C:
* `localtime()`: Returns a pointer to a static internal buffer. Calling it again from any thread will overwrite the previous result.
* `localtime_r()`: Reentrant version. You provide the memory (`Tm* result`), making it thread-safe.

Arithmetic

While C3's `std::time` uses operator overloading, `libc` uses:
 
* `difftime()`: Returns the difference in seconds as a double (time1 - time2).

Example: Using `libc` for a High-Res Sleep

```C3
import libc;

fn void high_res_wait() {
    libc::TimeSpec req;
    req.tv_sec = 0;
    req.tv_nsec = 500_000_000; // 500ms
    
    libc::nanosleep(&req, null);
}

// Time Formatting
char[64] buf;
Time_t t = libc::time(null);
Tm tm;
usz n = libc::strftime(buf.ptr, buf.len, "%Y%m%d%H%M%S", libc::localtime_r(&t, &tm));
String output = buf[0..n-1];
```


Back to [Table of Contents](0.table-of-contents.md)

