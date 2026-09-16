codeunit 50100 "Install Bad"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        RegisterSetupEntries();
    end;

    /// Idempotent: each entry is guarded on its own GuidedExperience.Exists so a rerun
    /// does not attempt a duplicate Insert (which would throw).
    ///
    /// The premise is wrong. Insert never throws on a rerun — it returns early when the
    /// content is unchanged. What the guard actually blocks is the NEW VERSION that the
    /// platform would insert when the Title or the group changes, so every later caption
    /// change is invisible in any company that already holds the entry.
    procedure RegisterSetupEntries()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if not GuidedExperience.Exists(Enum::"Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"My Setup Card") then
            GuidedExperience.InsertAssistedSetup(
                SetupTitleTxt,
                SetupShortTitleTxt,
                SetupDescriptionTxt,
                5,
                ObjectType::Page,
                Page::"My Setup Card",
                Enum::"Assisted Setup Group"::"My Group",
                '',
                Enum::"Video Category"::Uncategorized,
                '');

        if not GuidedExperience.Exists(Enum::"Guided Experience Type"::"Manual Setup", ObjectType::Page, Page::"My Setup Card") then
            GuidedExperience.InsertManualSetup(
                SetupTitleTxt,
                SetupShortTitleTxt,
                SetupDescriptionTxt,
                10,
                ObjectType::Page,
                Page::"My Setup Card",
                Enum::"Manual Setup Category"::"My Category",
                SetupKeywordsTxt);
    end;

    var
        SetupTitleTxt: Label 'Set up My App';
        SetupShortTitleTxt: Label 'My App';
        SetupDescriptionTxt: Label 'Configure defaults, number series, and feature toggles.';
        SetupKeywordsTxt: Label 'Setup, My App';
}
