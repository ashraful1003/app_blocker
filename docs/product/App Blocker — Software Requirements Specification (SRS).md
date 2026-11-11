# App Blocker — Software Requirements Specification (SRS)

Version 1.1 (draft) · Oct 29, 2026 · @License9

## 1. What this app is

App Blocker (working name) helps people who want to break a phone or social media habit. The user picks the apps and websites that waste their time. The app blocks them at set times, or after a daily time limit.

### The big idea

Most blocking apps are easy to switch off in a weak moment. This app is different. The user chooses a trusted person, called a **partner**. To weaken any rule, the user needs a code from their partner, or must wait 24 hours.

- Making rules **stricter** always works straight away.
- Making rules **weaker** needs the partner's code or a 24-hour wait.

Our short promise: *the app blocker you can't cheat on.*

### Who it is for

| Person | Who they are | What they want |
| --- | --- | --- |
| The user | An adult, anywhere in the world, who uses their phone more than they want to | Rules they can't break on impulse, and a way to see their progress |
| The partner | A friend, family member or coach the user trusts | A quick way to say yes or no to a request, without installing our app |

### What makes it different

1. **A partner holds the keys.** The user can't uninstall the app or weaken rules without the partner (or a 24-hour wait).
2. **Built for recovery.** A streak counter shows clean days. The app shows wins, like "You resisted Instagram 14 times this week".
3. **Private.** In the first version, nothing leaves the phone.

## 2. First version and later versions

The first version is for Android phones only. It works fully offline, so no account or login is needed. It is in English.

| Feature | First version | Later |
| --- | --- | --- |
| Pick apps to block | Yes |  |
| Block websites by pasting a link | Yes |  |
| Block apps on a schedule (daily or weekly) | Yes |  |
| Daily time limit per app | Yes |  |
| Strict mode (no uninstall, no weakening rules) | Yes |  |
| Partner approval | Partner reads a 6-digit code from an authenticator app | Partner taps "Approve" in their own app |
| 24-hour wait instead of partner | Yes |  |
| Stats, streak and "urges resisted" | Yes, on the phone | Saved to the cloud |
| Block screen | Plain screen | User picks plain, motivational or own message |
| Block only part of a website or app (e.g. YouTube Shorts, Reels) |  | Yes |
| Limit how many times an app is opened |  | Yes |
| "Focus now" button for a quick session |  | Yes |
| Handling browsers we don't support yet |  | Yes |
| Accounts and cloud backup |  | Yes |
| iPhone version |  | Yes |

**Not planned:** controlling another person's phone (parental control), and any claim that the app treats addiction.

## 3. How the app makes money

The app is free to start, with a paid Premium plan.

| Free | Premium |
| --- | --- |
| Block apps | Everything in Free |
| Up to 2 schedules | Unlimited schedules |
| Up to 3 websites | Unlimited websites |
| Plain block screen | Daily time limits |
| Last 7 days of stats | Strict mode with a partner |
|  | Full stats history and streaks |

- Premium is a subscription only, paid monthly or yearly. There is no one-time lifetime option.
- Users can try the partner feature free for 7 days.
- Payments go through Google Play.

### What we are assuming

- Users will give the app the permissions it needs, once we explain why.
- The partner can install a free authenticator app (like Google Authenticator) and can be reached by phone or message.
- English is enough for the first version.

## 4. What the app must do

The first version has 13 features. Each has an ID (like FR-01) so it is easy to find in the FRD, which explains each one in detail.

| ID | Feature | What it does | Plan |
| --- | --- | --- | --- |
| FR-01 | Getting started | Explains the app and asks for each permission, one at a time, with a clear reason. Warns the user if a permission is later turned off. | Free |
| FR-02 | Pick apps | Shows the apps on the phone. The user ticks the ones to block. Phone, messages and emergency calls can never be blocked. | Free |
| FR-03 | Schedules | The user sets times and days when apps are blocked, for example 10 pm to 7 am on weekdays. | Free: 2, Premium: unlimited |
| FR-04 | Daily limits | The user sets how long they can use an app each day. When time runs out, the app is blocked until midnight. | Premium |
| FR-05 | Blocking | When a blocked app opens, the block screen covers it within 1 second. Access comes back by itself when the block ends. | Free |
| FR-06 | Home screen | Shows what is blocked right now, how much time is left, and the streak. | Free |
| FR-07 | Strict mode | Stops the user from uninstalling the app or weakening any rule without their partner's code or a 24-hour wait. | Premium |
| FR-08 | Partner | The user adds a trusted person. The partner gets codes in a free authenticator app and shares one when they agree to a request. | Premium (7-day free trial) |
| FR-09 | 24-hour wait | If the partner can't be reached, the user can ask for a change and wait 24 hours. They can cancel at any time. | Premium |
| FR-10 | Stats and streak | Shows urges resisted, time saved, clean days in a row, and a weekly summary. | Free: 7 days, Premium: full history |
| FR-11 | Block screen | Shows which app is blocked, why, and when it will open again. | Free |
| FR-12 | Payments | Lets the user buy Premium through Google Play and restore it on a new phone. | — |
| FR-13 | Block websites | The user pastes any link. The app blocks that whole website in supported browsers. | Free: 3 sites, Premium: unlimited |

## 5. How well the app must work

| Area | What we promise |
| --- | --- |
| Always on | Blocking keeps working after the phone restarts, the app is closed, or the phone updates. It starts again within 10 seconds of a restart. |
| On time | Schedules start and end within 1 minute of the set time, even when the user travels to a new time zone. |
| Works on popular phones | Tested on Samsung, Xiaomi, Oppo, Vivo, Realme, OnePlus, Motorola and Pixel. The app shows each brand's battery settings so the phone doesn't stop it. |
| Fast | The block screen appears within 1 second. |
| Light on battery | The app uses less than 2% of the battery in a normal day. |
| Private | In the first version, no personal data, app list or usage leaves the phone. |
| Secure | Settings and the partner's secret are stored encrypted. The user never sees the partner's secret after setup. |
| Hard to cheat | Changing the phone's clock, force-closing the app or clearing its data does not unlock anything. |
| Easy to use | A new user can block their first app within 2 minutes after giving permissions. |
| Accessible | Readable text and colours, large touch targets, and support for screen readers and bigger font sizes. |
| Honest | We call strict mode "hard to cheat", never "impossible to bypass". We never say the app treats addiction. |
| Ready for iPhone | The screens are built with Flutter, so they can be reused for iPhone later. Only the blocking part needs rebuilding. |

## 6. Rules and limits from Android and Google

### Phones we support

- Android 8 and newer. This covers almost every phone in use today.
- Phones only. Tablets are not tested in the first version.
- The app screens are built with Flutter. The blocking part is built in Kotlin, Android's own language.

### Permissions the app needs

| Permission (as the user sees it) | Why we need it |
| --- | --- |
| Accessibility | To see which app or website is open, so we can block it. |
| Display over other apps | To show the block screen on top of a blocked app. |
| Usage access | To measure how long each app is used, for daily limits and stats. |
| Device admin | To stop the app being uninstalled while strict mode is on. |
| Always-on notification | To keep blocking running in the background. |

### What Google Play requires

- Before asking for Accessibility or Device admin, we show a clear screen that explains exactly why.
- We send Google a form and a short video showing why the app needs Accessibility.
- We fill in Google's privacy form, stating that no data is collected.
- We do not describe the app as a treatment for addiction.

### What no app can stop

A very determined user can still restart the phone in safe mode or reset the phone. No Android app can prevent this. So we promise "hard to cheat", not "impossible". If this happens, the app notices and resets the user's streak.

### Website blocking limits

- Website blocking works in Chrome, Samsung Internet, Firefox, Edge, Opera, Brave and DuckDuckGo.
- It does not work in in-app browsers, such as a link opened inside Instagram or WhatsApp. The client has accepted this.
- Other browsers will be handled in a later version.

### iPhone (later)

Apple has stricter rules. On iPhone, the app cannot see the list of chosen apps, cannot block uninstall in the same way, and must use Apple's own block screen. The iPhone version will be planned separately.

## 7. Risks and how we handle them

| Risk | What could happen | What we do about it |
| --- | --- | --- |
| Google rejects our Accessibility request | We can't launch on Google Play | Prepare the form and video early, and test with a small group first. |
| Phone brands shut down background apps to save battery | Blocking stops without warning | Show each brand's battery settings during setup, and alert the user if blocking stops. |
| Users quit when asked for many permissions | Fewer active users | Ask for one permission at a time, with a simple reason, and let users block their first app quickly. |
| Users feel trapped | Bad reviews and complaints | The 24-hour wait is always available, and strict mode is clearly explained before it is turned on. |
| Partner changes phone and loses their codes | Partner can't approve | The 24-hour wait still works. The user can then add a new partner. |
| Some people crack the paid features | Lost income | Accept this for the first version. Check payments on our server in a later version. |
| Browsers change their design | Website blocking stops working in that browser | Test each supported browser regularly and update quickly. |

## 8. Open questions

- [ ] Final app name, after checking the name is free to use (ideas: Pact, Holdfast, Keepr, Anchor).
- [ ] Monthly and yearly prices.
- [ ] Brand look and colours.
- [ ] Does the 7-day free trial need a payment card up front?

## 9. Sign-off

| Role | Name | Date |
| --- | --- | --- |
| Client / Product owner |  |  |
| Business analyst / Lead developer |  |  |

## Word list

| Word | Meaning |
| --- | --- |
| Blocklist | The apps and websites the user wants blocked. |
| Schedule | Set times and days when blocking is on. |
| Daily limit | How long an app can be used each day before it is blocked. |
| Strict mode | A mode where the user can't uninstall the app or weaken rules without approval. |
| Partner | A trusted person who approves or refuses changes. |
| Approval code | A 6-digit code from the partner's authenticator app. It changes every 30 seconds. |
| 24-hour wait | A way to make a change without the partner, by waiting 24 hours first. |
| Stricter change | Any change that blocks more. It always works straight away. |
| Weaker change | Any change that blocks less, like removing an app or turning off strict mode. |
| Urge | Each time the user tries to open something that is blocked. |
| Streak | The number of days in a row with no rules weakened. |
