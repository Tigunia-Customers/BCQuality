---
bc-version: [all]
domain: reliability
keywords: [guided-experience, assisted-setup, manual-setup, insertassistedsetup, insertmanualsetup, exists-guard, idempotent, install, upgrade, caption]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not guard a Guided Experience insert on Exists

## Description

`GuidedExperience.InsertAssistedSetup` and `InsertManualSetup` are **content-versioned upserts**, not plain inserts. `GuidedExperienceImpl.Insert` computes a version from the content and returns early when nothing changed:

```al
Version := GetVersion(PrevGuidedExperienceItem, Code, Title, ShortTitle, Description, ExpectedDuration, ExtensionId, ...);

if Version = -1 then begin
    // This means that the record hasn't changed, so we shouldn't insert a new version of the object.
    ...
    exit;
end;
```

So a rerun with identical content exits quietly — it never throws — and a rerun with a **changed** Title, Short Title, Description, Assisted Setup Group, Manual Setup Category or Keywords inserts a **new version** row. That versioning is the platform's mechanism for getting a changed caption into an environment that already has the entry.

Wrapping the call in `if not GuidedExperience.Exists(Type, ObjectType::Page, Page::"X") then` defeats it. `Exists` matches on type plus target object only, and is blind to content, so once the entry exists **no caption change ever reaches that company again**. The guard is usually added to prevent a duplicate-insert error that cannot actually occur.

The failure is silent and easy to misread as a failed deployment: the code is correct, the new build is published, and the Assisted Setup or Manual Setup entry still shows the old title and the old group. A fresh install looks fine, which is why it survives testing and only bites existing environments.

## Best Practice

Call `InsertAssistedSetup` / `InsertManualSetup` unconditionally and let the platform's versioning supply idempotency. Register from install **and** from an upgrade cohort, because neither an `OnInstallAppPerCompany` trigger nor an already-set upgrade tag re-runs on a republish — an existing company needs a new upgrade-tag cohort to pick up a changed caption.

See sample: `do-not-guard-guided-experience-insert-on-exists.good.al`.

## Anti Pattern

An `if not GuidedExperience.Exists(...)` around the insert, typically with a comment claiming the guard prevents a duplicate insert that would throw. Detection signal: a registration procedure whose Insert calls are wrapped in `Exists`, or one that is only reachable from `OnInstallAppPerCompany`. Use `Remove` (not a guard) when the target object itself changed and the stale entry must go.

See sample: `do-not-guard-guided-experience-insert-on-exists.bad.al`.

## See also

Originates from commissions-management PR #187 / issue #186: renaming the Assisted Setup entry and moving it to a new Assisted Setup Group changed nothing in the sandbox, because both inserts were guarded on `Exists`.
