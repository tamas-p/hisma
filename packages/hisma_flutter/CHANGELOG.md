## 0.6.0+3

 - **FIX**: drawer close by back button.

## 0.6.0+2

 - **FIX**: fix processing back button in inactive machine.

## 0.6.0+1

 - **FIX**: double tap Android back button crash.
 - **FIX**: for bug of signaling UiClosed when UI was not closed.

## 0.6.0

> Note: This release has breaking changes.

 - **DOCS**: updated README.md with the Presenter class usage.
 - **BREAKING** **REFACTOR**: added arg to SnackBarPresenter.
 - **BREAKING** **REFACTOR**: replace present function with Presenter class.
 - **BREAKING** **CHORE**: renamed fireArg to arg.

## 0.5.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: provide fire event and argument to presenter.

## 0.4.0+3

 - Update a dependency to the latest release.

## 0.4.0+2

 - Update a dependency to the latest release.

## 0.4.0+1

 - **DOCS**: overlay argument is referred now in README.md.

## 0.4.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: commented out BottomSheetCreator.

## 0.3.0

> Note: This release has breaking changes.

 - **REFACTOR**: Old tests tuned for new generator.
 - **REFACTOR**: removed historyFlowDown from start().
 - **REFACTOR**: moved getKey to assistance.dart.
 - **REFACTOR**: cleaned up start check.
 - **REFACTOR**: hisma router delegate refactored.
 - **REFACTOR**: Changed prints to logs + refactored some tests.
 - **REFACTOR**: Added remove from stack as well besides setClosed().
 - **REFACTOR**: removed navigatorState argument.
 - **REFACTOR**: router delegate _fire refactored.
 - **REFACTOR**: Removed required for arg in machine stop.
 - **REFACTOR**: Commented out not used notify.
 - **REFACTOR**: Made rootNavigator of PagelessCreator required.
 - **REFACTOR**: Finished updates to new version.
 - **REFACTOR**: older test now use new API.
 - **REFACTOR**: Started refactoring imperative handler.
 - **REFACTOR**: Cleaned up _stateIds handling.
 - **REFACTOR**: Eliminated not used S (State) generic type from Creators.
 - **REFACTOR**: Pageless handling refactored to its own class.
 - **REFACTOR**: useRootNavigator is now a parameter.
 - **REFACTOR**: Started refactoring minimize RouterDelegate use.
 - **REFACTOR**: Monkey test refactored into its own file.
 - **REFACTOR**: First all-pass of fire with context.
 - **REFACTOR**: Instead of PagelessPage use _pageless.
 - **REFACTOR**: First phase of new router delegator.
 - **REFACTOR**: Using _stackIds instead of _pageMap.
 - **REFACTOR**: Created and now using DialogCreator.
 - **FIX**: changed from late to explicit assert on empty _previousPages.
 - **FIX**: return if _routerDelegate is not initialized.
 - **FIX**: Moved pageless cleanup to stop.
 - **FIX**: Updated older test to cache HismaRouterDelegate.
 - **FIX**: Cached HismaRouterDelegates to allow Hot reload.
 - **FIX**: Navigator key must be the same to allow transitions work.
 - **FIX**: Added missed out constructor arguments.
 - **FIX**: When open imperative we shall not await it.
 - **FIX**: Added check if machine is stopped.
 - **FIX**: Added historyFlowDown argument.
 - **FEAT**: added support to pass through entry and exit points.
 - **FEAT**: Assert that no history is used with HismaRouterDelegate.
 - **FEAT**: Added showSnackBar to test app.
 - **FEAT**: Adding test app for BottomSheet.
 - **FEAT**: Added support for root navigator.
 - **FEAT**: Added all use-cases for SMWCN.
 - **FEAT**: Imperative basics added.
 - **FEAT**: Started working on Imperative in SMwCN.
 - **FEAT**: Added support for overlay pages.
 - **DOCS**: Added more specifics.
 - **DOCS**: Modified class diagram for non paged.
 - **DOCS**: Added all classes before Router built.
 - **DOCS**: Changed RenderFlex to the actual _RenderTheatre.
 - **DOCS**: Hide stereotype.
 - **DOCS**: All objects are present now on the diagram.
 - **DOCS**: Draft of navigation object diagram ready.
 - **DOCS**: added explanation on throw.
 - **DOCS**: added note for assert in case of missing event.
 - **DOCS**: Added comment on importance of using the appropriate key for the Navigator.
 - **DOCS**: Improved BackButtonDispatcher object diagram.
 - **DOCS**: updated till 02_simple.dart the README.md.
 - **DOCS**: updated overlay page section of README.md.
 - **DOCS**: dialogs section is updated.
 - **DOCS**: update utility states and hierarchy sections.
 - **DOCS**: updated Additional information section.
 - **DOCS**: Simple class doc for NavigationMachine.
 - **BREAKING** **REFACTOR**: renamed files for Machine and NavigationMachine.
 - **BREAKING** **REFACTOR**: removed history from NavigationMachine constructor.
 - **BREAKING** **REFACTOR**: Removed internal and uiClosed from fire.
 - **BREAKING** **REFACTOR**: eliminated redundant machine argument.
 - **BREAKING** **REFACTOR**: renaming StateMachineWithChangeNotifier and StateMachine.

## 0.2.0+4

 - Update a dependency to the latest release.

## 0.2.0+3

 - Update a dependency to the latest release.

## 0.2.0+2

 - Update a dependency to the latest release.

## 0.2.0+1

 - Update a dependency to the latest release.

## 0.2.0

> Note: This release has breaking changes.

 - **FIX**: Added unawaited_futures to analysis. Fixed findings.
 - **BREAKING** **FIX**: Added files accidentally left out from previous commit.

## 0.1.1+5

 - Update a dependency to the latest release.

## 0.1.1+4

 - **DOCS**: Added plantuml diagrams created when studied Flutter routing.

## 0.1.1+3

 - **FIX**: Changed to use super-initializer parameters.

## 0.1.1+2

 - **DOCS**: Fixed relative links issue in README.md files described in [#5](https://github.com/tamas-p/hisma/issues/5).

## 0.1.1+1

 - Update a dependency to the latest release.

## 0.1.1

 - **FIX**: Added pub.dev compliant package descriptions to 3 pubspec.yaml files.
 - **FEAT**: Initial commit on GitHub.

## 0.1.0

- Initial development release.
