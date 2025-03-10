## 0.4.0

> Note: This release has breaking changes.

 - **REFACTOR**: Making type S for Edge mandatory.
 - **FIX**: fixed assert on BaseEntryPoint.
 - **FIX**: added assert to detect if entryConnector does not lead to EntryPoint.
 - **FEAT**: plantuml converter supports entryConnectors with keys (Trigger) with optional members.
 - **DOCS**: Review and correct README.md of hisma.
 - **DOCS**: updated README.md.
 - **BREAKING** **REFACTOR**: renamed onError to onSkip.
 - **BREAKING** **REFACTOR**: eliminated getParentName as redundant.
 - **BREAKING** **REFACTOR**: renaming StateMachineWithChangeNotifier and StateMachine.

## 0.3.1+2

 - **FIX**: Broken rendering since PlantUML 1.2023.2.
 - **FIX**: Catch only Exceptions.
 - **DOCS**: Note for MacOS app builders.

## 0.3.1+1

 - Update a dependency to the latest release.

## 0.3.1

 - **FIX**: Changed onError type to Action.
 - **FIX**: minInterval checks before Guard.
 - **FEAT**: Introduced internal transitions.

## 0.3.0+1

 - Update a dependency to the latest release.

## 0.3.0

> Note: This release has breaking changes.

 - **FIX**: Added unawaited_futures to analysis. Fixed findings.
 - **FIX**: Few linter fixes after flutter upgrade.
 - **FIX**: WebSocketChannel.connect exceptions now caught by await on ready.
 - **BREAKING** **FIX**: Added files accidentally left out from previous commit.

## 0.2.0+1

 - Update a dependency to the latest release.

## 0.2.0

> Note: This release has breaking changes.

 - **FIX**: EntryPoint to EntryPoint.
 - **DOCS**: Removed TODO as it was converted to GitHub discussion [#6](https://github.com/tamas-p/hisma/issues/6).
 - **BREAKING** **FEAT**: Added transitions to EntryPoints per [#4](https://github.com/tamas-p/hisma/issues/4).

## 0.1.1+2

 - **DOCS**: Fixed relative links issue in README.md files described in [#5](https://github.com/tamas-p/hisma/issues/5).

## 0.1.1+1

 - Update a dependency to the latest release.

## 0.1.1

 - **FIX**: Renamed hisma_vis_server.dart to visma.dart and added dart docs to library declarations.
 - **FEAT**: Initial commit on GitHub.

## 0.1.0

- Initial development release.
