codeunit 50101 "Install Good"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        RegisterSetupEntries();
    end;

    /// Idempotent through the platform, not through a guard: GuidedExperienceImpl.Insert
    /// computes a version from the content, returns early when nothing changed, and inserts
    /// a new version when the Title, Short Title, Description, group, category or keywords
    /// change. Calling it unconditionally is what lets a changed caption reach a company
    /// that already holds the entry.
    procedure RegisterSetupEntries()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
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
        SetupTitleTxt: Label 'Set up MyApp';
        SetupShortTitleTxt: Label 'MyApp';
        SetupDescriptionTxt: Label 'Configure defaults, number series, and feature toggles.';
        SetupKeywordsTxt: Label 'Setup, MyApp';
}
