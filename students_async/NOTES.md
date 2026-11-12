# NOTES: Practice 10, The Data Arrives Later

## Level 1: order of events

Predicted (before running):
```
A
C
fetchStudents #1
B
6 students
```

Actual:
```
A
C
fetchStudents #1
B
6 students
```

Why: `main()` runs to the end without waiting for anything. `Future.delayed`
only schedules a timer, and `fetchStudents()` runs synchronously up to its
first `await`, so `fetchStudents #1` is printed right away. The callbacks
`B` and `6 students` are events, they run later, after the first frame is
drawn. `B` comes first because its timer was created first.

Third call to `fetchStudents()`:
```
Unhandled Exception: Instance of 'NoConnectionException'
```
Nobody awaited that Future, so the error went to the console and the app
kept running as if nothing happened. Remember that line: it is Level 5.

With `sleep(Duration(seconds: 2))` instead of `await Future.delayed(...)`
the app did not draw its first frame for two seconds. The loop was blocked,
not waiting. I put the `await` back and deleted the experiments from `main()`.

## Level 2: without `if (!mounted) return;`

I deleted both guards and pressed Back within two seconds. First line of the
red error in the console:
```
setState() called after dispose(): _StudentsScreenState#4f2a1(lifecycle state: defunct, not mounted)
```
The response arrived at a State that was already gone. With the guards put
back, nothing is printed.

## Level 3: FutureBuilder

- With `future: _future` (a field): flipping the Switch ten times prints only
  one `fetchStudents #1`, and the list never flickers.
- With `future: _api.fetchStudents()` inside `build`: a spinner on every flip,
  and the console counts `#2 #3 #4 ...`, one request per rebuild. The third
  one fails.
- With `hasData` checked before `hasError`: when the server is down there is
  no data, so the spinner never goes away. `hasError` must be first.

## Level 4: countdown

Version A (StreamBuilder), no `cancel()` anywhere in my code, Back at 7:
the console stops. StreamBuilder cancelled the subscription for me.

Version B (listen) with `_sub.cancel()` in `dispose`, Back at 7:
the console stops at `tick 7`. The subscription was cancelled, the generator
stopped at its next `await`, nothing ticked for a dead screen.

Version B with `_sub.cancel()` commented out, Back at 7:
```
setState() called after dispose(): _VersionBState#4f2a1(lifecycle state: defunct, not mounted)
tick 6
tick 5
tick 4
tick 3
tick 2
tick 1
tick 0
```
The console keeps printing all the way down to 0 with nobody on screen.
That is the leak. I put `cancel()` back.

## Level 5: errors that do not vanish

The way the AI writes it:
```dart
onPressed: () { _api.save(n); Navigator.pop(context); }
```
`flutter analyze` flags this line with `unawaited_futures`. I tapped Save
twice anyway: the screen popped as if it worked, and the console said:
```
Unhandled Exception: Bad state: server rejected 6
```
The user saw a success, but the server had rejected the save.

The honest version: `await` inside `try` / `on StateError`, a `mounted` check
after the `await`, `Navigator.pop` only on success, the error message in a
SnackBar only on failure, and a `_saving` flag that disables the button and
shows a small spinner while the request is in flight. A fast double tap sends
one request, not two.

## Checks

- `flutter analyze`: No issues found!
- `dart format .`: done
- `screenshot_error.png` and `screenshot_countdown.png` are committed