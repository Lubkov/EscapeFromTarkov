program MapEditorTest;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  TestPoint in 'Source\TestPoint.pas',
  TestConnection in 'Source\TestConnection.pas',
  TestMapLevel in 'Source\TestMapLevel.pas',
  TestLocalMap in 'Source\TestLocalMap.pas',
  TestData in 'TestData.pas',
  TestUtils in 'TestUtils.pas';

{$R *.RES}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  DUnitTestRunner.RunRegisteredTests;
end.
