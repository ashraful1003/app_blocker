# App Blocker — Functional Requirements Document (FRD)

Version 1.1 (draft) · Oct 29, 2026 · @License9

## 1. How to read this document

The SRS says **what** the app does. This FRD says **how** each feature should behave, step by step. It is for the client, designers, developers and testers.

- Each feature has the same ID as in the SRS (FR-01 to FR-13).
- Each feature ends with **How we test it**: simple checks that prove the feature works.
- Items marked *(Later)* are not built in the first version.

## 2. The main rules

These rules apply everywhere in the app.

1. **Stricter changes work straight away.** Adding an app or website, adding a schedule, lowering a limit, or turning on strict mode never needs approval.
2. **Weaker changes need approval, but only in strict mode.** This includes removing an app or website, shortening or deleting a schedule, raising a limit, turning off strict mode, and uninstalling. When strict mode is off, these changes work straight away.
3. **Approval means one of two things:** a correct code from the partner, or a finished 24-hour wait.
4. **Partner codes change every 30 seconds.** After 5 wrong codes in a row, the user must wait 15 minutes before trying again.
5. **Only one 24-hour wait at a time.** The user can cancel it whenever they like.
6. **One approval covers one change.** Approving the removal of Instagram does not unlock anything else.
7. **Changing the phone's clock does nothing.** The app uses its own timer for waits and limits.
8. **The streak resets** when a weaker change is approved in strict mode, or when the app finds that its protection was switched off.
9. **Some apps can never be blocked:** phone calls, messages, emergency calls, the home screen and this app.
10. **If Premium ends while strict mode is on,** strict mode stays on until the user gets approval to turn it off. This stops people from cancelling payment just to escape. Extra Premium rules pause but are not deleted.

## 3. Getting started and picking apps

### FR-01 Getting started (Free)

1. Three short welcome screens explain the app: block what hooks you, a partner holds the keys, watch your streak grow.
2. The app asks for one permission per screen, with a short reason for each: Usage access, Display over other apps, Accessibility, and Notifications.
3. Device admin is asked for later, only when the user turns on strict mode.
4. On Xiaomi, Oppo, Vivo, Realme, OnePlus and Samsung phones, the app shows how to stop the phone from closing it to save battery.
5. The app checks its permissions every time it opens and every 15 minutes. If one is missing, it shows a notification to help the user fix it.

**How we test it**

- On a new install, after setup, every permission is on, or the user can see which one is missing and why it matters.
- If the user turns off Accessibility, they get a notification within 15 minutes.
- If strict mode is on and Accessibility is turned off, the streak resets.

### FR-02 Picking apps (Free)

1. The app shows every app on the phone, A to Z, with a search box.
2. Next to each app, it shows how long the user spent in it per day over the last week. This helps them choose.
3. The user ticks the apps they want blocked. Unticking an app is a weaker change.
4. Apps that can never be blocked are greyed out, with a note saying why.
5. When the user installs a new app, the app asks: "Add it to your blocklist?"

**How we test it**

- With 150 apps on the phone, the list appears within 1 second.
- If strict mode is on and the user unticks Instagram, the app asks for approval first.

## 4. Blocking: schedules, limits and websites

### FR-03 Schedules (Free: 2, Premium: unlimited)

1. A schedule has a name, a start time, an end time, and the days it runs. Quick choices: every day, weekdays, weekends.
2. By default it blocks everything on the blocklist. The user can pick only some apps instead.
3. A schedule can run overnight, for example 10 pm to 7 am.
4. If two schedules overlap, an app is blocked when either one is on.
5. On Free, trying to add a third schedule shows the Premium offer.

**How we test it**

- A schedule of 10 pm to 7 am on weekdays blocks apps at 11:30 pm on Friday, unblocks them at 7 am on Saturday, and does not start on Saturday night.
- If the user travels to a new time zone, the next schedule follows the new local time.

### FR-04 Daily limits (Premium)

1. The user sets a daily time for an app, from 5 minutes to 8 hours.
2. Time is only counted while the app is open on screen.
3. The app warns the user when 5 minutes are left. When time runs out, the app is blocked until midnight.
4. Limits and schedules work together. An app is blocked if either one says so.

**How we test it**

- With a 30-minute limit on YouTube, after 30 minutes of use, the next open shows: "Daily limit reached. Back at midnight."

### FR-13 Blocking websites (Free: 3 sites, Premium: unlimited)

1. The user pastes any link, for example `https://www.instagram.com/reels/abc`.
2. The app keeps only the website name (`instagram.com`) and shows it so the user can confirm.
3. The whole website is blocked, including versions like `m.instagram.com`.
4. Websites follow the same schedules and strict mode rules as apps. Removing a website is a weaker change.
5. Supported browsers: Chrome, Samsung Internet, Firefox, Edge, Opera, Brave and DuckDuckGo. Private or incognito tabs are blocked too.
6. The app shows a short note: links opened inside other apps (like Instagram or WhatsApp) are not blocked.
7. *(Later)* Block only one part of a site, such as YouTube Shorts. Handle browsers not on the list.

**How we test it**

- If the user pastes `https://www.instagram.com/reels/abc`, then visiting `instagram.com` or `m.instagram.com` in Chrome shows the block screen.
- Blocking also works in an incognito tab.
- A Free user who tries to add a fourth website sees the Premium offer.
- If the user types something that is not a link, the app asks them to check it.

### FR-05 How blocking works (Free)

1. The app watches which app or website is open.
2. If it is blocked, the block screen covers it within 1 second. Closing the block screen takes the user to the home screen.
3. When the block ends, access comes back by itself. The app can show a note like "Instagram is available again".
4. Every attempt to open something blocked is counted as an urge.
5. Blocking starts again by itself after the phone restarts or the app updates.

**How we test it**

- A blocked app is blocked however it is opened: from the home screen, recent apps, a notification or a shortcut.
- If the phone restarts during a block, blocking is back within 10 seconds.

### FR-06 Home screen (Free)

1. Shows each active schedule and the time left, each daily limit and the time left, whether strict mode is on, the streak, and any 24-hour wait in progress.
2. A quiet notification always shows what's next, for example "Blocking 4 apps until 7:00".

### FR-11 Block screen (Free)

1. Covers the whole screen. Shows the app or website, why it is blocked, when it opens again, and how many times the user has tried to open it this week.
2. It has only one button: "Close". There is no unlock button here. To weaken a rule, the user goes through section 6.
3. *(Later)* The user can choose a plain screen, a motivational message or their own message.

## 5. Strict mode, partner and the 24-hour wait

### FR-07 Strict mode (Premium)

1. To turn on strict mode, the user must first add a partner and allow Device admin. Each step has a screen that explains why.
2. Before it starts, the app shows exactly what will be locked. The user types "I commit" to confirm.
3. While strict mode is on, the user cannot:
   - uninstall the app,
   - open the phone settings that would switch the app off,
   - make any weaker change inside the app.
4. If they try to open those settings, a message appears: "Strict mode is on. Ask your partner or start a 24-hour wait to change this."
5. Turning strict mode off is itself a weaker change.

**How we test it**

- With strict mode on, trying to uninstall the app does not work, and the message appears.
- With strict mode on, opening Settings > Accessibility shows the message, and the page can't be used.

### FR-08 Partner (Premium, 7-day free trial)

**Adding a partner**

1. The app shows a QR code. The partner scans it with a free authenticator app, such as Google Authenticator.
2. The partner reads out the 6-digit code they now see, and the user types it in. This proves setup worked.
3. The secret behind the codes is then locked away. The user can never see it again.
4. The user saves the partner's name and phone number, so they can call or message them quickly later.

**Asking for approval**

1. The app shows the change the user wants, for example "Unblock Instagram".
2. A share button sends the partner a ready-made message: "I'm asking to unblock Instagram. Please send me your code if you agree."
3. If the partner agrees, they send their current code. The user types it in, and the change is made.

**Changing partner:** this is a weaker change, so it needs the current partner's code or a 24-hour wait.

*(Later)* The partner gets a notification and taps "Approve" in their own app.

**How we test it**

- A code from the last 30 seconds works.
- After 5 wrong codes in a row, the user must wait 15 minutes.
- Even if the app's data is cleared, the app still can't be uninstalled, and the streak resets.

### FR-09 24-hour wait (Premium)

1. On any approval screen, the user can choose "Start 24-hour wait" instead of asking the partner.
2. The home screen shows a countdown. Reminders at 12 hours and 1 hour left ask: "Still want this? You can cancel."
3. When the wait ends, the user must open the app and confirm once more. If they don't confirm within the next 24 hours, the request ends.
4. Cancelling works straight away and does not reset the streak.

**How we test it**

- If the user moves the phone's clock forward a day, the countdown does not change.
- When the wait ends and the user confirms, the change is made and the streak resets.

## 6. How a user asks to weaken a rule

&#91;embedded content: loosening-change approval flow · 2 routes\]

When strict mode is off, changes happen straight away. When it is on, the user gets a code from their partner, or waits 24 hours and confirms. Either way, the change is made and the streak resets. Cancelling the wait leaves everything as it was.

## 7. Stats, streak and payments

### FR-10 Stats and streak (Free: 7 days, Premium: full history)

1. **Urges:** each try to open something blocked is counted. Repeated tries within 10 seconds count as one.
2. **Time saved:** the app measures how long the user spent in each app in the week before they started. Time saved is that amount minus what they use now.
3. **Streak:** the number of days in a row with no weaker changes. Milestones at 1, 3, 7, 14, 30, 60, 90 and 365 days.
4. **Weekly summary**, every Monday morning: urges resisted per app, time saved, the hours when urges are strongest, and streak progress.
5. Free users see the last 7 days. Premium users see everything. All data stays on the phone.
6. The user can download their stats as a spreadsheet file, or delete them all.

**How we test it**

- After 14 blocked tries on Instagram this week, the summary says: "You resisted Instagram 14 times this week."
- A Free user sees only the last 7 days. Older data is kept, and unlocks with Premium.

### FR-12 Payments

1. Premium is a monthly or yearly subscription, bought through Google Play. The client sets the prices.
2. The partner feature has a 7-day free trial, starting when the user adds a partner.
3. A "Restore purchase" button brings Premium back on a new phone.
4. The app checks Premium each time it opens. It works offline for up to 7 days between checks.
5. When Premium ends, the user sees what has paused and how to subscribe again (see main rule 10).
6. *(Later)* Payments are double-checked on our server.

## 8. Screens and stored data

### Screens in the first version

| Screen | What it is for | Feature |
| --- | --- | --- |
| Welcome | Explain the app in 3 short steps | FR-01 |
| Permissions | Ask for each permission with a reason | FR-01 |
| Battery setup | Stop the phone from closing the app | FR-01 |
| Home | What is blocked now, time left, streak | FR-06, FR-10 |
| Pick apps | Choose apps to block | FR-02 |
| Websites | Paste links to block websites | FR-13 |
| Schedules | Add and edit schedules | FR-03 |
| Daily limits | Set time limits per app | FR-04 |
| Strict mode setup | Explain, confirm, turn on | FR-07 |
| Add partner | QR code, test code, partner contact | FR-08 |
| Ask for approval | Share request, enter code, or start the 24-hour wait | FR-08, FR-09 |
| Block screen | Covers a blocked app or website | FR-11 |
| Strict mode message | Covers protected phone settings | FR-07 |
| Stats | Urges, time saved, streak, weekly summary | FR-10 |
| Premium | Plans and free trial | FR-12 |
| Settings | Notifications, download or delete stats, restore purchase, help | FR-10, FR-12 |

### What the app stores (for the development team)

Everything is stored on the phone, encrypted. The partner's secret is kept in Android's secure key storage.

| Item | What is saved |
| --- | --- |
| Blocked app | App ID, name, date added |
| Blocked website | Website name, date added |
| Schedule | Name, start and end time, days, which apps and websites, on or off |
| Daily limit | App, minutes allowed, minutes used today, reset time |
| Strict mode | On or off, date turned on, Device admin status |
| Partner | Name, phone number, link to the locked secret, date added, wrong-code count, locked-until time |
| Change request | What change, approved by code or wait, requested at, ready at, status |
| Urge | App or website, time, which rule blocked it |
| Streak event | Reset or protection lost, time, reason |
| Usage before start | App, average minutes per day, date measured |
| Premium | Plan, product, expiry date, last checked |

*(Later)* With accounts, this data is backed up to the cloud. The partner's secret moves to the partner's side.
