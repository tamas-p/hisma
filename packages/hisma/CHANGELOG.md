## 0.5.0

> Note: This release has breaking changes.

 - **FEAT**: Added instance level configuration of monitorCreators.
 - **DOCS**: added link to hisma itself on pub.dev in README.md.
 - **BREAKING** **FEAT**: Introduced getStructureRecursive.
 - **BREAKING** **FEAT**: ConsoleMonitor includes machine name now.

## 0.4.0

> Note: This release has breaking changes.

 - **REFACTOR**: made start() more readable.
 - **REFACTOR**: removed historyFlowDown from start().
 - **REFACTOR**: removed StateChangeNotification.
 - **REFACTOR**: Making type S for Edge mandatory.
 - **REFACTOR**: Eliminated the use of GetName message.
 - **REFACTOR**: Removed required for arg in machine stop.
 - **REFACTOR**: Started refactoring imperative handler.
 - **REFACTOR**: hisma router delegate refactored.
 - **FIX**: fixed assert on BaseEntryPoint.
 - **FIX**: added assert on EntryPoint check.
 - **FIX**: added assert to detect if entryConnector does not lead to EntryPoint.
 - **FIX**: parent machine generics to dynamic.
 - **FEAT**: plantuml converter supports entryConnectors with keys (Trigger) with optional members.
 - **FEAT**: Added parent to machines + hierarchy test.
 - **DOCS**: Review and correct README.md of hisma.
 - **DOCS**: review and correct README.md.
 - **DOCS**: added docs for SkipSource.
 - **DOCS**: updated README.md.
 - **DOCS**: Small docs improvements.
 - **DOCS**: added explanation on throw.
 - **DOCS**: Updated diagrams.
 - **BREAKING** **REFACTOR**: renamed onError to onSkip.
 - **BREAKING** **REFACTOR**: eliminated exceptions for transitions.
 - **BREAKING** **REFACTOR**: Removed internal and uiClosed from fire.
 - **BREAKING** **REFACTOR**: changed notifyMonitors to private.
 - **BREAKING** **REFACTOR**: eliminated getParentName as redundant.
 - **BREAKING** **REFACTOR**: renamed files for Machine and NavigationMachine.
 - **BREAKING** **REFACTOR**: renaming StateMachineWithChangeNotifier and StateMachine.
 - **BREAKING** **FEAT**: Trigger now has only optional attributes.

## 0.3.2+1

 - **FIX**: Catch only Exceptions.

## 0.3.2

 - **REFACTOR**: Removed half baked copyWith methods.
 - **FIX**: typo.
 - **FEAT**: Introduced assert configuration per [#17](https://github.com/tamas-p/hisma/issues/17).
 - **FEAT**: handlers can now define sync/async functions.
 - **DOCS**: Added dart docs to StateMachine.strict variable.

## 0.3.1

 - **REFACTOR**: re-enable play.
 - **REFACTOR**: Failing Guard throws exception if no onError defined.
 - **REFACTOR**: OnErrorAction instead of Action.
 - **FIX**: Changed onError type to Action.
 - **FIX**: minInterval checks before Guard.
 - **FIX**: Return null in case of onError triggered.
 - **FIX**: Refactored example to be more realistic.
 - **FEAT**: Added onError for transitions.
 - **FEAT**: Introduced internal transitions.
 - **DOCS**: rewording.
 - **DOCS**: Added 'More on transitions' section.

## 0.3.0+1

 - **FIX**: StateMachine now does not await on monitor notifications.

## 0.3.0

> Note: This release has breaking changes.

 - **FIX**: Added unawaited_futures to analysis. Fixed findings.
 - **FIX**: Few linter fixes after flutter upgrade.
 - **FIX**: While adding monitor tests few async issues fixed.
 - **DOCS**: Fixed a typo.
 - **DOCS**: Added warning not to use copyWith.
 - **DOCS**: Added arg to YouTube link to set captions on.
 - **BREAKING** **FIX**: Changed methods to private where public was not needed.
 - **BREAKING** **FIX**: Hisma exceptions used instead of Exception. Also added machine find tests.
 - **BREAKING** **FIX**: Added files accidentally left out from previous commit.
 - **BREAKING** **FIX**: arg for actions, data for StateMachin constructor.

## 0.2.0+1

 - **DOCS**: Improved feature overview section.
 - **DOCS**: Added GitHub column to hisma packages tables.

## 0.2.0

> Note: This release has breaking changes.

 - **FIX**: Inactive machine shall not be shown by getActiveStateRecursive().
 - **FIX**: EntryPoint to EntryPoint.
 - **DOCS**: Changed EntryPoint/ExitPoint documentation according to [#4](https://github.com/tamas-p/hisma/issues/4).
 - **DOCS**: Added example for EntryPoint transitions.
 - **BREAKING** **FEAT**: Guard method got machine & data parameters [#13](https://github.com/tamas-p/hisma/issues/13).
 - **BREAKING** **FEAT**: Added transitions to EntryPoints per [#4](https://github.com/tamas-p/hisma/issues/4).

## 0.1.1+2

 - **DOCS**: Fixed relative links to other packages.

## 0.1.1+1

 - **DOCS**: Changed repository URL that points to package in monorepo to address [#5](https://github.com/tamas-p/hisma/issues/5).

## 0.1.1

 - **FIX**: Renamed hisma_vis_server.dart to visma.dart and added dart docs to library declarations.
 - **FEAT**: Initial commit on GitHub.
 - **DOCS**: Added references to Dart and Flutter.
 - **DOCS**: Changed warning to disclaimer.
 - **DOCS**: Small change in the help needed section of hisma package README.md.
 - **DOCS**: Moved next steps and help needed section to hisma package README.md.

## 0.1.0

- Initial development release.
