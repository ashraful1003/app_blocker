enum ChangeDirection { stricter, weaker }

enum SettingsChangeKind {
  addApp,
  removeApp,
  addWebsite,
  removeWebsite,
  addSchedule,
  removeSchedule,
  lowerLimit,
  raiseLimit,
  enableStrictMode,
  disableStrictMode,
}

ChangeDirection classifyChange(SettingsChangeKind change) {
  return switch (change) {
    SettingsChangeKind.addApp => ChangeDirection.stricter,
    SettingsChangeKind.removeApp => ChangeDirection.weaker,
    SettingsChangeKind.addWebsite => ChangeDirection.stricter,
    SettingsChangeKind.removeWebsite => ChangeDirection.weaker,
    SettingsChangeKind.addSchedule => ChangeDirection.stricter,
    SettingsChangeKind.removeSchedule => ChangeDirection.weaker,
    SettingsChangeKind.lowerLimit => ChangeDirection.stricter,
    SettingsChangeKind.raiseLimit => ChangeDirection.weaker,
    SettingsChangeKind.enableStrictMode => ChangeDirection.stricter,
    SettingsChangeKind.disableStrictMode => ChangeDirection.weaker,
  };
}
