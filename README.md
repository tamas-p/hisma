Hisma monorepo.

This [monorepo](https://en.wikipedia.org/wiki/Monorepo) includes [Dart](https://dart.dev/) and [Flutter](https://flutter.dev/) packages and examples for [Hisma](packages/hisma/) that is a hierarchical state machine implementation for Dart and Flutter.

## Features

You can create hierarchical state machines that are loosely based on the [UML](https://www.omg.org/spec/UML/) state machine specification that is in turn based on [Harel's statechart](https://en.wikipedia.org/wiki/State_diagram#Harel_statechart). These state machines can even drive your Flutter routing. See [hisma](packages/hisma/) and [hisma_flutter](packages/hisma_flutter/) packages for more details.

See an example Flutter application ([fb_auth_hisma_example](examples/fb_auth_hisma_example/)) in action that is using [hisma](packages/hisma/) state machine defined in [fb_auth_hisma](packages/fb_auth_hisma/) for the user management workflow, [hisma_flutter](packages/hisma_flutter/) for Flutter routing based on the state machine and [visma](packages/visma/) to monitor and visualize the state machine:

![fb_auth_hisma_example.gif](examples/fb_auth_hisma_example/doc/resources/fb_auth_hisma_example.gif)

## Additional information

### Next steps

- Finalize API.
- Increase test coverage.
- Improve documentation.
- More helper classes in hisma_extra.

### Help needed

- Feedback, especially about things you would like to change.
- Finding bugs are always welcomed.
  - Providing a failing test to demonstrate the bug is even better.
- Creating tests.
- Creating documentation.

### Contact

If you have any questions, comments please go to [Hisma GitHub Discussions](https://github.com/tamas-p/hisma/discussions) to start or join discussions.
